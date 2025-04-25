function [HRRRData] = load_hrrr_data(Path,foldername)
%LOAD_HRRR_DATA Loads HRRR hourly NetCDF files for a given date

% This function loads all hourly HRRR NetCDF files for a specified day
% from the directory defined in the Path structure.

% INPUTS:
%   Path       - structure containing directory paths
%   foldername - string specifying the date folder

% OUTPUT:
%   HRRRData - structure containing pressure-level and surface-level
%              variables across all hours for the specified day

% NOTE:
%   This function applies a pressure cutoff (default: 875 hPa) to filter out
%   data beneath the ground. 875 hPa is appropriate for Tonopah

% Set the pressure cutoff in hPa
pressureCutoff = 875;

% Navigate to the HRRR NetCDF folder
cd(Path.hrrr_data)
cd(foldername)

% List all NetCDF files for the day
directory = dir("hrrr*.nc");

% Load pressure levels for the first file and apply the cutoff
tmpVar = ncread(directory(1).name,"pres_levels");
log = tmpVar < pressureCutoff;
presLevels = tmpVar(log);

% Load geopotential heights for first file and apply the cutoff
tmpVar = ncread(directory(1).name,"Geopotential_Height_PresLevel_HRRR");
geopotentialHeight = tmpVar(log);

% --- Initialize arrays to store concatenated data ---
temperature = [];
relativeHumidity = [];
time = [];
pblhDefault = [];
temperature2Meter = [];
relativeHumidity2Meter = [];
pressureHumidity2Meter = [];

% --- Loop through all hourly files ---
for i = 1:numel(directory)
    % Load pressure levels and apply mask
    tmpVar = ncread(directory(i).name,"pres_levels");
    log = tmpVar < pressureCutoff;

    % Load and append temperature (pressure-level)
    tmpVar = ncread(directory(i).name,"Temperature_PresLevel_HRRR");
    temperature = [temperature, tmpVar(log)];

    % Load and append relative humidity (pressure-level)
    tmpVar = ncread(directory(i).name,"Relative_Humidity_PresLevel_HRRR");
    relativeHumidity = [relativeHumidity, tmpVar(log)];

    % Track time (as hour offset)
    time = [time, i - 1];

    % Load and append surface-level variables
    pblhDefault = [pblhDefault, ncread(directory(i).name,"HPBL_HRRR")];
    temperature2Meter = [temperature2Meter, ncread(directory(i).name,"T_2_meter_HRRR")];
    relativeHumidity2Meter = [relativeHumidity2Meter, ncread(directory(i).name,"RH_2_meter_HRRR")];
    pressureHumidity2Meter = [pressureHumidity2Meter, ncread(directory(i).name,"Pressure_surface_HRRR")];
end

% --- Store variables in output structure ---
HRRRData.presLevels               = presLevels;
HRRRData.geopotentialHeight      = geopotentialHeight;
HRRRData.temperature             = temperature;
HRRRData.relativeHumidity        = relativeHumidity;
HRRRData.time                    = time;
HRRRData.pblhDefault             = pblhDefault;
HRRRData.temperature2Meter       = temperature2Meter;
HRRRData.relativeHumidity2Meter = relativeHumidity2Meter;
HRRRData.pressureHumidity2Meter = pressureHumidity2Meter;

% Return to original folder
cd(Path.home)

end