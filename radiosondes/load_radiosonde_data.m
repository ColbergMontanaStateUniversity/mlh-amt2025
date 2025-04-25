function [Radiosonde] = load_radiosonde_data(Path)

% LOAD_RADIOSONDE_DATA Load and organize radiosonde profile from M2HATS
% dataset.

% Reads a single radiosonde NetCDF file from the M2HATS campaign and 
% returns its contents as a structured variable. The output structure 
% includes vertical profiles of thermodynamic and kinematic variables, as
% well as launch metadata.

% INPUT:
%   Path – structure with fields:
%       .radiosondeDataFoldername – full path to folder containing the 
%                                   NetCDF file
%       .radiosondeDataFilename   – name of the NetCDF file

% OUTPUT:
%   Radiosonde – structure with radiosonde profile and reference values


% Navigate to radiosonde data directory
cd(Path.radiosondeDataFoldername)

% Parse filename
filenameChar = char(Path.radiosondeDataFilename);

% Extract launch date and UTC time from filename
Radiosonde.launchDate = str2double(filenameChar(26:33));
Radiosonde.launchTimeUtc =         str2double(filenameChar(35:36)) + ...
                           1/60  * str2double(filenameChar(37:38)) + ...
                           1/3600* str2double(filenameChar(39:40));

% Read NetCDF variables and assign to lowerCamelCase fields
Radiosonde.referenceTime     = ncread(filenameChar, 'launch_time');  % Seconds since reference time
Radiosonde.time              = ncread(filenameChar, 'time');         % Time since launch [s]
Radiosonde.pres              = ncread(filenameChar, 'pres');         % Pressure [hPa]
Radiosonde.tDry              = ncread(filenameChar, 'tdry');         % Dry-bulb temperature [°C]
Radiosonde.dewPoint          = ncread(filenameChar, 'dp');           % Dew point temperature [°C]
Radiosonde.rh                = ncread(filenameChar, 'rh');           % Relative humidity [%]
Radiosonde.windU             = ncread(filenameChar, 'u_wind');       % Zonal wind component (east-west) [m/s]
Radiosonde.windV             = ncread(filenameChar, 'v_wind');       % Meridional wind component (north-south) [m/s]
Radiosonde.windW             = ncread(filenameChar, 'w_wind');       % Vertical wind component [m/s]
Radiosonde.windSpeed         = ncread(filenameChar, 'wspd');         % Wind speed magnitude [m/s]
Radiosonde.windDirection     = ncread(filenameChar, 'wdir');         % Wind direction [degrees from north]
Radiosonde.ascentRate        = ncread(filenameChar, 'dz');           % Vertical velocity [m/s]
Radiosonde.mixingRatio       = ncread(filenameChar, 'mr');           % Water vapor mixing ratio [g/kg]
Radiosonde.virtualTemp       = ncread(filenameChar, 'vt');           % Virtual temperature [K]
Radiosonde.theta             = ncread(filenameChar, 'theta');        % Potential temperature [K]
Radiosonde.thetaE            = ncread(filenameChar, 'theta_e');      % Equivalent potential temperature [K]
Radiosonde.thetaV            = ncread(filenameChar, 'theta_v');      % Virtual potential temperature [K]
Radiosonde.lat               = ncread(filenameChar, 'lat');          % Latitude [decimal degrees]
Radiosonde.lon               = ncread(filenameChar, 'lon');          % Longitude [decimal degrees]
Radiosonde.alt               = ncread(filenameChar, 'alt');          % Geopotential or geometric altitude above MSL [m]
Radiosonde.gpsAlt            = ncread(filenameChar, 'gpsalt');       % GPS-reported altitude above MSL [m]

% Reference (launch-level surface) conditions
Radiosonde.referenceTime     = ncread(filenameChar, 'reference_time');  % Absolute reference time [s since launch time]
Radiosonde.referencePres     = ncread(filenameChar, 'reference_pres');  % Surface pressure at launch [hPa]
Radiosonde.referenceTDry     = ncread(filenameChar, 'reference_tdry');  % Surface dry temperature [°C]
Radiosonde.referenceRh       = ncread(filenameChar, 'reference_rh');    % Surface relative humidity [%]
Radiosonde.referenceWdir     = ncread(filenameChar, 'reference_wdir');  % Surface wind direction [degrees]
Radiosonde.referenceLat      = ncread(filenameChar, 'reference_lat');   % Launch site latitude
Radiosonde.referenceLon      = ncread(filenameChar, 'reference_lon');   % Launch site longitude
Radiosonde.referenceAlt      = ncread(filenameChar, 'reference_alt');   % Launch site altitude [m]

% Return to original working directory
cd(Path.home)

end