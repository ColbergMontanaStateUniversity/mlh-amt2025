function SurfaceData = load_surface_data(Path)

%LOAD_SURFACE_DATA Load surface meteorological station data for M2HATS.

% This function reads a NetCDF file containing surface weather station data
% collected during the M2HATS campaign and stores the contents in a 
% structured variable.

% INPUT:
%   Path – structure with:
%       .surfaceDataFoldername – path to the folder containing the NetCDF 
%                                file
%       .surfaceDataFilename   – name of the NetCDF file to load

% OUTPUT:
%   SurfaceData – structure containing meteorological variables and 
%   metadata

% Navigate to the surface data directory
cd(Path.surfaceDataFoldername)

% Parse the filename
filenameChar = char(Path.surfaceDataFilename);

% Load variables from the NetCDF file into the SurfaceData structure
SurfaceData.time         = ncread(filenameChar, 'time');               % Time [seconds since 00:00 UTC]
SurfaceData.airTemp      = ncread(filenameChar, 'T_ws800_3m');         % Air temperature [°C]
SurfaceData.dewPoint     = ncread(filenameChar, 'Td_ws800_3m');        % Dew point temperature [°C]
SurfaceData.windChill    = ncread(filenameChar, 'Tchill_ws800_3m');    % Wind chill temperature [°C]
SurfaceData.rh           = ncread(filenameChar, 'RH_ws800_3m');        % Relative humidity [%]
SurfaceData.pressure     = ncread(filenameChar, 'P_ws800_3m');         % Pressure [hPa]
SurfaceData.windSpeed    = ncread(filenameChar, 'Spd_ws800_3m');       % 3-meter wind speed [m/s]
SurfaceData.precipTotal  = ncread(filenameChar, 'raina_ws800_3m');     % Accumulated precipitation [mm]
SurfaceData.precipRate   = ncread(filenameChar, 'rainr_ws800_3m');     % Precipitation rate [mm/hr]
SurfaceData.windMin      = ncread(filenameChar, 'Sn_ws800_3m');        % Minimum wind speed [m/s]
SurfaceData.windMax      = ncread(filenameChar, 'Sx_ws800_3m');        % Maximum wind speed [m/s]
SurfaceData.windAvg      = ncread(filenameChar, 'Sg_ws800_3m');        % Average wind speed [m/s]
SurfaceData.windVector   = ncread(filenameChar, 'Sv_ws800_3m');        % Vector wind speed [m/s]
SurfaceData.windDirAct   = ncread(filenameChar, 'Da_ws800_3m');        % Actual wind direction [deg]
SurfaceData.windDirMin   = ncread(filenameChar, 'Dn_ws800_3m');        % Minimum wind direction [deg]
SurfaceData.windDirMax   = ncread(filenameChar, 'Dx_ws800_3m');        % Maximum wind direction [deg]
SurfaceData.windDirCa    = ncread(filenameChar, 'Ca_ws800_3m');        % Calibrated wind direction [deg]
SurfaceData.radGlobal    = ncread(filenameChar, 'Ga_ws800_3m');        % Actual global radiation [W/m²]
SurfaceData.radMin       = ncread(filenameChar, 'Gn_ws800_3m');        % Minimum global radiation [W/m²]
SurfaceData.radMax       = ncread(filenameChar, 'Gx_ws800_3m');        % Maximum global radiation [W/m²]
SurfaceData.radAvg       = ncread(filenameChar, 'Gg_ws800_3m');        % Average global radiation [W/m²]
SurfaceData.enthalpy     = ncread(filenameChar, 'Ea_ws800_3m');        % Specific enthalpy [kJ/kg]
SurfaceData.wetBulbTemp  = ncread(filenameChar, 'Ba_ws800_3m');        % Wet bulb temperature [°C]
SurfaceData.airDensity   = ncread(filenameChar, 'Ad_ws800_3m');        % Air density [kg/m³]
SurfaceData.laVoltage    = ncread(filenameChar, 'La_ws800_3m');        % Leaf wetness [mV]
SurfaceData.leafWetness  = ncread(filenameChar, 'Lb_ws800_3m');        % Leaf wetness state (0 = dry, 1 = wet)
SurfaceData.windDirVec   = ncread(filenameChar, 'Dir_ws800_3m');       % Vector wind direction [deg]
SurfaceData.gpsNumSats   = ncread(filenameChar, 'GPSnsat');            % Number of GPS satellites tracked
SurfaceData.gpsStatus    = ncread(filenameChar, 'GPSstat');            % GPS status: 1 = OK, 0 = warning
SurfaceData.gpsTimeDiff  = ncread(filenameChar, 'GPSdiff');            % GPS time correction [s]
SurfaceData.systemStatus = ncread(filenameChar, 'Status_3m');          % System status code
SurfaceData.visibility   = ncread(filenameChar, 'Vis_3m');             % Visibility [m]
SurfaceData.particleRate = ncread(filenameChar, 'Part_3m');            % Particle counts [counts/min]
SurfaceData.precipRate2  = ncread(filenameChar, 'Rainr_3m');           % Rain gage precipitation rate [mm/hr]
SurfaceData.Temp         = ncread(filenameChar, 'T_3m');               % Temperature sensor [°C]

% Return to original working directory
cd(Path.home)

end