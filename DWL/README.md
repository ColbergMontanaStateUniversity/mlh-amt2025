## Requirements

This section of the project uses both **Python** and **MATLAB**:

- Python is required to download HRRR model data using the Herbie library.
- MATLAB is used for processing the HRRR data and performing operations on the data.
---

## Python Setup

This project uses **Miniconda** and was developed with **Python 3.12.9**. You’ll need either [Miniconda or Anaconda](https://docs.conda.io/en/latest/miniconda.html#latest-miniconda-installer-links) installed to recreate the environment.

Miniconda is recommended if you prefer a lightweight installation.

To set up the Python environment:

## MATLAB Setup

Tested with **MATLAB R2024a**  
No additional toolboxes are required.

### Step 1: Download the environment file

Download `herbie_env_full.yml` from this repository.

### Step 2: Create and activate the environment

```bash
conda env create -f DWL_env_full.yml
conda activate herbie_env
```

This will install all required packages, including:
- `netCDF4` and `hdf5` for reading atmospheric data files
- `numpy` for numerical operations
- `cftime` for time handling in climate data

### Step 3. Download the data

The DWL data is available here: https://doi.org/10.26023/R75F-FGJ8-VG12

Download the data. There will be 24 hourly files per day. naming convention: `Stare_122_YYYYMMDD_hh_.hpl
These files will be in folders labeled 'pwd/YYYYMM/YYYYMMDD'. put these folders in the 'DWL_Data' folder

The surface weather station data is available here: https://doi.org/10.26023/30XE-MB6C-SC14

Download the data. There will be one netCDF file per day. Naming convention: 'iss2_m2hats_sfcmet_3mtower_YYYYMMDD.nc'
put these files into the 'ISS_Data' folder

### Step 4. Run the python DWL decoding script

make sure that 'halo_dl_decode.py' is in the same directory as the YYYYMM folders run the code.

***Note*** This code was throwing errors when ran from spyder, but had no issues when ran directly from anaconda prompt

This code will convert the .hpl files into netCDF files in the same folders named: 'fp_YYYYMMDD_hhmmss.nc'

### Step 5. Run the MATLAB DWL processing code

The script 'process_halo_netCDF.m' code will convert the 24 netCDF files into a .mat file containing the wind and backscatter data integrated to 30 meters and 10 s in local time

***Note*** The function 'concatenate_halo_data.m' contains a time correction variable unique for PDT (UTC-7)

### Step 6. Run the MATLAB surface weather station processing code

The script 'process_surface_meteorology_data.m' will extract relevant variables from the ISS netCDF files and save them as a .mat file in local time

***Note*** The function 'concatenate_halo_data.m' contains a time correction variable unique for PDT (UTC-7)

### Step 7. Run the MATLAB ISFS processing code

The script 'process_surface_meteorology_data.m' will extract relevant variables from the ISFS netCDF files and save them as a .mat file in local time

***Note*** The function 'concatenate_halo_data.m' contains a time correction variable unique for PDT (UTC-7)

***Note*** The function 'compute_average_flux.m' contains the gravitational constant for Tonopah, Nevada

### Step 8. Run the MATLAB mask code

The script 'create_masks_halo.m' generates masks for clouds, precipitation, and missing data, and identifies cloud locations. However, the code was written as a quick fix and may not work well for other datasets.

***Note*** keep the 'betaAvg.mat' file in the same folder as the main script.

### Step 9. Run the MATLAB temporal variance extraction code

The script 'compute_temporal_variance.m' performs an autocovariance extrapolation to extract the real wind variance from noisy lidar data. 

***Note*** the function 'compute_autocovariance_extrapolation.m' contains a line that sets the time window to 180 time steps, which correponds to 30 minutes for the processed DWL data.

***Caution*** This script is prone to causing MATLAB to crash, even on high-performance systems.

### Step 10. Run the MATLAB MLH code

The script 'find_mlh_dwl.m' will diagnose the mlh from the vertical velocity variance data.

***Note*** SunriseSunsetTable.csv is a table of the sunrise and sunset times for Tonopah, Nevada during the M2HATS experiment. Keep it in the same directory.

### File Descriptions
### MATLAB Functions, Scripts, and Files

'betaAvg.mat'
Clear sky attenuated backscatter used for a reference to diagnose clouds in the DWL data.

'compute_autocovariance_extrapolation.m'
Computes vertical velocity variance from DWL data using autocovariance extrapolation to remove noise bias.

'compute_average_flux.m'
Converts flux tower measurements into average buoyancy flux.

'compute_temporal_variance.m'
Applies autocovariance extrapolation to retrieve temporal variance from DWL data.

'concatenate_flux_tower_data.m'
Concatenates two consecutive days of flux tower data into a single structure with local time correction.

'concatenate_halo_data.m'
Concatenates two consecutive days of Halo lidar data into a single structure with local time correction.

'concatenate_surface_meteorology_data.m'
Concatenates two consecutive days of surface meteorology data into a single structure with local time correction.

'convert_sunrise_sunset.m'
Finds sunrise and sunset times for the day of DWL data.

'create_cloud_mask.m'
Creates a cloud mask based on backscatter, signal-to-noise ratio, variance of backscatter.

'create_masks_halo.m'
Script that creates and combines cloud, precipitation, and missing data masks for DWL data.

'create_missing_data_mask.m'
Identifies missing data regions.

'create_precipitation_mask.m'
Creates a precipitation mask based on surface rain sensors and vertical velocity.

'diagnose_mlh_vertical_velocity_variance.m'
Diagnoses the MLH using vertical velocity variance. Special conditions applied for clouds.

'find_cloud_bottom.m'
Finds the cloud base height by locating the first cloud detection in the vertical column.

'find_mlh_dwl.m'
Retrieves MLH estimates from DWL data.

'find_positive_flux.m'
Identifies the continuous time period of positive buoyancy flux for daytime boundary layer retrieval.

'find_variance_5x5.m'
Calculates 5x5 spatial variance of backscatter and vertical velocity fields for cloud detection.

'integrate_halo_data.m'
Integrates DWL variables to 10-s and 30-meter data.

'load_flux_tower_data.m'
Loads flux tower NetCDF files into MATLAB structures.

'load_halo_netCDF.m'
Loads Halo Doppler lidar NetCDF data into MATLAB structures.

'load_surface_meteorology_data.m'
Loads surface meteorological station NetCDF data into MATLAB structures.

'process_flux_tower_data.m'
Extracts useful variables for ISFS netCDF files, trims them, and crops them.

'process_halo_netCDF.m'
Extracts useful variables for DWL netCDF files, trims them, and crops them.

'process_surface_meteorology_data.m'
Extracts useful variables for surface meteorology netCDF files, trims them, and crops them.

'trim_flux_tower_data.m'
Crops flux tower data to the analysis time window (e.g., from sunrise - 2 hr to sunset + 2 hr).

'trim_surface_meteorology_data.m'
Crops surface meteorology data to match analysis time window.

### Python Scripts and environments
'halo_dl_decode.py'
Python decoder for raw Halo Doppler lidar hpl files into NetCDF files.

'DWL_env_full.yml'
YAML environment file for Python (e.g., conda environment setup for DWL data processing).

### Other Files
'SunriseSunsetTable.csv'
Table listing sunrise and sunset times for each date, used to constrain daytime analyses.

---

## License

This project is released under the MIT License. See LICENSE file for details
