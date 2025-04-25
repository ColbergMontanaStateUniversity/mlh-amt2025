# This script downloads HRRR model data at specified latitude, longitude, and altitude, and
# interpolates pressure-level and surface-level variables to a fixed altitude grid,
# saves the results to NetCDF files in hourly resolution.
# Note: Herbie creates temporary GRIB2 files during the process which can be deleted after NetCDFs are saved.
 
# Outputs per file include:
# - Altitude-interpolated: temperature, pressure, relative humidity
# - Pressure-level: geopotential height, temperature, relative humidity
# - Surface-level: PBL height, 2m temperature, 2m relative humidity, surface pressure

# This script was developed based on a template by Matthew Hayman
# (National Center for Atmospheric Research, NCAR).
# ------------------------------------------------------------------------

# Required imports
import psutil, os, gc, time, traceback, warnings
import numpy as np
import xarray as xr
import datetime
from herbie import Herbie
from scipy.interpolate import griddata
from pyproj import CRS, Transformer
import shutil

# Suppress future warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

# ---------------------------
# USER INPUT: LOCATION & ALTITUDE
# ---------------------------
LATITUDE = 38.0406        # degrees North
LONGITUDE = 242.9124      # degrees East (use 360 system)
ALTITUDE = 1641           # meters above sea level

# Define a standard altitude grid (0 to 12 km in 37.5 m increments)
# 37.5 m is the bin width for the MPD
alt_grid = np.arange(0, 12e3, 37.5)

# ---------------------------
# USER INPUT: DATE RANGE
# ---------------------------
START_DATE = "20230906"  # format: YYYYMMDD
END_DATE   = "20230907"
FXX = 0  # Forecast hour (0 = analysis)

# ---------------------------
# DIRECTORY SETUP
# ---------------------------
BASE_SAVE_DIR = os.path.join(os.getcwd(), "HRRR_data")  # All output .nc and .grib2 files
os.makedirs(BASE_SAVE_DIR, exist_ok=True)

# ---------------------------
# SETUP: Coordinate Transformation
# ---------------------------
source_crs = CRS.from_epsg(4326)  # WGS84 geographic
lcc_proj_str = (
    "+proj=lcc +ellps=sphere +a=6371229.0 +b=6371229.0 "
    "+lon_0=262.5 +lat_0=38.5 +x_0=0.0 +y_0=0.0 "
    "+lat_1=38.5 +lat_2=38.5 +no_defs +type=crs"
)
target_crs = CRS.from_proj4(lcc_proj_str)
transformer = Transformer.from_crs(source_crs, target_crs, always_xy=True)

# ---------------------------
# VARIABLES TO RETRIEVE
# ---------------------------
selected_vars = ['t', 'gh', 'r']  # pressure-level: temperature, geopotential height, relative humidity
selected_surface_vars = ['blh', 't2m', 'r2', 'sp']  # surface: PBL height, 2m temp, 2m RH, surface pressure

# ---------------------------
# DATE RANGE LOOP
# ---------------------------
start_date = datetime.datetime.strptime(START_DATE, "%Y%m%d")
end_date   = datetime.datetime.strptime(END_DATE, "%Y%m%d")
current_date = start_date

while current_date <= end_date:
    print(f"\n===== Processing data for {current_date.strftime('%Y-%m-%d')} =====")
    
    date_str = current_date.strftime("%Y%m%d")
    DATE_DIR = os.path.join(BASE_SAVE_DIR, date_str)
    GRIB_TEMP_DIR = os.path.join(DATE_DIR, "grib2_files")  # Herbie will write here
    os.makedirs(GRIB_TEMP_DIR, exist_ok=True)

    # Loop over each hour of the day
    for hour in range(24):
        hrrr_time = current_date + datetime.timedelta(hours=hour)
        hourly_filename = f"hrrr_{current_date.strftime('%Y%m%d')}_hour_{hour:02d}_lat_{LATITUDE:.4f}_lon_{LONGITUDE:.4f}.nc"
        output_hourly_file = os.path.join(DATE_DIR, hourly_filename)

        # Check if the output file already exists
        if os.path.exists(output_hourly_file):
            print(f"✅ File already exists for {hrrr_time.strftime('%Y-%m-%d %H:%M')} UTC. Skipping this hour.", flush=True)
            continue  # Skip this iteration if file exists

        print(f"\n===== Downloading HRRR data for {hrrr_time.strftime('%Y-%m-%d %H:%M')} UTC =====", flush=True)
        
        try:
            # Download HRRR pressure-level data
            H = Herbie(hrrr_time, model="hrrr", product="prs", fxx=FXX, save_dir=GRIB_TEMP_DIR)
            data_str = r":(?:TMP|HGT|RH):\d+ mb"
            ds = H.xarray(data_str,remove_grib=False)

            print(f"✅ Retrieved HRRR data for {hrrr_time.strftime('%Y-%m-%d %H:%M')}", flush=True)
            print(f"Available HRRR variables: {list(ds.data_vars.keys())}", flush=True)
            
            # Extract pressure levels dynamically
            if "isobaricInhPa" in ds.coords:
                pres_levels = ds["isobaricInhPa"].values
            elif "pressure" in ds.coords:
                pres_levels = ds["pressure"].values
            else:
                raise KeyError(f"Pressure levels not found. Available coordinates: {list(ds.coords.keys())}")

            print(f"✅ Pressure levels: {pres_levels}", flush=True)
            
            # Download HRRR PBLH and 2m temp from surface data
            H_sfc = Herbie(hrrr_time, model="hrrr", product="sfc", fxx=FXX, save_dir=GRIB_TEMP_DIR)
            pblh_ds = H_sfc.xarray(r":HPBL:surface", remove_grib=False)
            t_ds = H_sfc.xarray(r":TMP:2 m above ground", remove_grib=False)
            rh_ds = H_sfc.xarray(r":RH:2 m above ground", remove_grib=False)
            psfc_ds = H_sfc.xarray(r":PRES:surface", remove_grib=False)
            sfc_ds = xr.merge([pblh_ds, t_ds, rh_ds, psfc_ds])

            print(f"✅ Retrieved HRRR surface data for {hrrr_time.strftime('%Y-%m-%d %H:%M')}", flush=True)
            print(f"Available surface variables: {list(sfc_ds.data_vars.keys())}", flush=True)
            
            # Flatten the x,y grid
            ds_z = ds.stack(z=("x", "y"))
            sfc_z = sfc_ds.stack(z=("x", "y"))
            
            # locate the closest lat/lon to the reqested location [lat,lon]
            i_sort = np.argsort((ds_z['latitude'].values - LATITUDE)**2 + (ds_z['longitude'].values - LONGITUDE)**2)
            # reduce the dataset to the four closest lat/lon pairs
            ds_z = ds_z.sel(z=ds_z['z'].values[i_sort[:4]])
            
            # flatten the x,y grid to a single dimension
            sfc_ds_z = sfc_ds.stack(z=("x", "y"))
            # locate the closest lat/lon to the reqested location [lat,lon]
            i_sort_bl = np.argsort((sfc_ds_z['latitude'].values - LATITUDE)**2 + (sfc_ds_z['longitude'].values - LONGITUDE)**2)
            # reduce the dataset to the four closest lat/lon pairs
            sfc_ds_z = sfc_ds_z.sel(z=sfc_ds_z['z'].values[i_sort[:4]])
            
            # interpolate the variable(s) to the new latitude and longitude
            # using 4 point interpolation [1, x, y, xy]
            data_var_lst = ['t','gh','r']
            data_var_dct = {}
            for var in data_var_lst:
                # location
                lats = ds_z['latitude'].values
                lons = ds_z['longitude'].values
                
                inv_mat = np.linalg.inv(np.matrix([np.ones(lats.size),lats,lons,lats*lons],).T)
                f_mat = np.matrix(ds_z[var].values).T
                input_mat = np.matrix([1,LATITUDE,LONGITUDE,LATITUDE*LONGITUDE])
                
                output_mat = input_mat*(inv_mat*f_mat)
                data_var_dct[var] = np.array(output_mat).flatten()

            # interpolate the surface data onto MPD lat and lon
            data_var_surf_lst = ['blh','t2m','r2','sp']
            data_var_surf_dct = {}
            for var in data_var_surf_lst:
                # location
                lats = sfc_ds_z['latitude'].values
                lons = sfc_ds_z['longitude'].values
                
                inv_mat = np.linalg.inv(np.matrix([np.ones(lats.size),lats,lons,lats*lons],).T)
                f_mat = np.matrix(sfc_ds_z[var].values).T
                input_mat = np.matrix([1,LATITUDE,LONGITUDE,LATITUDE*LONGITUDE])
                
                output_mat = input_mat*(inv_mat*f_mat)
                data_var_surf_dct[var] = np.array(output_mat).flatten()

            print("   lat/lon interpolation complete")
            
            # interpolate the data from pressure levels to a regularized altitude grid
            pres_arr = ds_z['isobaricInhPa'].values
            pres_alt_arr = np.interp(alt_grid,data_var_dct['gh'],pres_arr)
            temp_alt_arr = np.interp(alt_grid,data_var_dct['gh'],data_var_dct['t'])

            rh_alt_arr = np.interp(alt_grid,data_var_dct['gh'],data_var_dct['r'])


            alt_da = xr.DataArray(alt_grid,dims=('altitude',),attrs={'units':'m','description':'altitude ASL'})
            time_da = xr.DataArray(np.array([np.datetime64(ds_z['valid_time'].values)]),dims=('time',),attrs={'description':'time UTC'})
            pres_level_da = xr.DataArray(pres_arr,dims=('pres_levels',),attrs={'units':'atm','description':'pressure levels represented in the model'})

            attrs_dct = {
                    'forecast_hour':FXX,
                    'latitude':LATITUDE,
                    'longitude':LONGITUDE,
                    'lidar_altitude':ALTITUDE
            }

            alt_da = xr.DataArray(alt_grid,dims=('altitude',),attrs={'units':'m','description':'altitude ASL'})
            time_da = xr.DataArray(np.array([np.datetime64(ds_z['valid_time'].values)]),dims=('time',),attrs={'description':'time UTC'})
            pres_level_da = xr.DataArray(pres_arr,dims=('pres_levels',),attrs={'units':'atm','description':'pressure levels represented in the model'})

            rh_da = xr.DataArray(rh_alt_arr.reshape(1,-1),
                                dims=('time','altitude'),
                                coords={'time':time_da,'altitude':alt_da},
                                attrs={'units':'percent',
                                    'description':'Altitude and Coordinate interpolated relative humidity from HRRR',})

            pres_da = xr.DataArray(pres_alt_arr.reshape(1,-1),
                                dims=('time','altitude'),
                                coords={'time':time_da,'altitude':alt_da},
                                attrs={'units':'atm',
                                    'description':'Altitude and Coordinate interpolated pressure from HRRR',})

            temp_da = xr.DataArray(temp_alt_arr.reshape(1,-1),
                                dims=('time','altitude'),
                                coords={'time':time_da,'altitude':alt_da},
                                attrs={'units':'K',
                                    'description':'Altitude and Coordinate interpolated temperature from HRRR',})
            
            
            gh_da = xr.DataArray(data_var_dct['gh'].reshape(1,-1),
                                dims=('time','pres_levels'),
                                coords={'time':time_da,'pres_levels':pres_level_da},
                                attrs={'units':'m',
                                    'description':'Geopotential height of each pressure level in HRRR',})

            temp_gh_da = xr.DataArray(data_var_dct['t'].reshape(1,-1),
                                dims=('time','pres_levels'),
                                coords={'time':time_da,'pres_levels':pres_level_da},
                                attrs={'units':'K',
                                    'description':'Temperature at each pressure level in HRRR',})

            rh_gh_da = xr.DataArray(data_var_dct['r'].reshape(1,-1),
                                dims=('time','pres_levels'),
                                coords={'time':time_da,'pres_levels':pres_level_da},
                                attrs={'units':'percent',
                                    'description':'Relative Humidity at each pressure level in HRRR',})

            
            hpbl_da = xr.DataArray(data_var_surf_dct['blh'],
                                dims=('time',),
                                coords={'time':time_da,},
                                attrs={'units':'m',
                                    'description':'Planetary Boundary Layer Height according to HRRR',})
            
            t2m_da = xr.DataArray(data_var_surf_dct['t2m'],
                                dims=('time',),
                                coords={'time':time_da,},
                                attrs={'units':'K',
                                    'description':'2-meter Temperature according to HRRR',})
            
            r2_da = xr.DataArray(data_var_surf_dct['r2'],
                                dims=('time',),
                                coords={'time':time_da,},
                                attrs={'units':'percent',
                                    'description':'2-meter Relative Humidity according to HRRR',})
            
            sp_da = xr.DataArray(data_var_surf_dct['sp'],
                                dims=('time',),
                                coords={'time':time_da,},
                                attrs={'units':'atm',
                                    'description':'surface pressure according to HRRR',})

            ds_tmp = xr.Dataset({
                                'Relative_Humidity_HRRR':rh_da,
                                'Pressure_HRRR':pres_da,
                                'Temperature_HRRR':temp_da,
                                'Geopotential_Height_PresLevel_HRRR':gh_da,
                                'Temperature_PresLevel_HRRR':temp_gh_da,
                                'Relative_Humidity_PresLevel_HRRR':rh_gh_da,
                                'HPBL_HRRR':hpbl_da,
                                'T_2_meter_HRRR':t2m_da,
                                'RH_2_meter_HRRR':r2_da,
                                'Pressure_surface_HRRR':sp_da},
                                attrs = attrs_dct)
           

            # Save the hourly file
            ds_tmp.to_netcdf(output_hourly_file)
            print(f"✅ Saved: {output_hourly_file}", flush=True)

            # Cleanup to free memory
            del ds, sfc_ds, ds_z, sfc_z, ds_tmp
            gc.collect()
            time.sleep(5)
            
        except Exception as e:
            print(f"❌ Skipping {hrrr_time.strftime('%Y-%m-%d %H:%M')} UTC due to error: {e}", flush=True)
            traceback.print_exc()
            continue

        # Clean up GRIB2 files after processing all hours in the day
        shutil.rmtree(GRIB_TEMP_DIR, ignore_errors=True)
        
    # Move to the next day
    current_date += datetime.timedelta(days=1)
