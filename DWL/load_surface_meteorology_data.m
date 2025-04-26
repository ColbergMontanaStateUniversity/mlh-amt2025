function [Data] = load_surface_meteorology_data(Path, Filename)
% LOAD_SURFACE_METEOROLOGY_DATA
% Loads selected surface meteorology variables from a 3-meter tower NetCDF file.
%
% Inputs:
%   - Path: Structure containing directory paths
%   - Filename: Name of the NetCDF file to load
%
% Outputs:
%   - Data: Structure containing selected surface meteorology variables.
%
% Notes:
%   - Unused variables are listed but commented out for future reference.

    % Navigate to the data directory
    cd(Path.data)

    % --- Read variables from NetCDF ---
    % Time variables
    % base_time = ncread(Filename, "base_time"); % seconds since 1970-01-01 00:00:00 00:00
    time = ncread(Filename, "time");             % seconds since YYYY-MM-DD 00:00:00

    % GPS status (not used)
    % GPSnsat = ncread(Filename, "GPSnsat");      % Number of GPS satellites tracked (count)
    % GPSstat = ncread(Filename, "GPSstat");      % GPS receiver status: 1=OK(A), 0=warning(V)
    % GPSdiff = ncread(Filename, "GPSdiff");      % GPS NMEA receipt time difference (s)

    % Status flags (not used)
    % Status_3m = ncread(Filename, "Status_3m");  % System status flag
    % visibility = ncread(Filename, "Vis_3m");    % Visibility (m)
    % Part_3m = ncread(Filename, "Part_3m");      % Particle counts (count/min)
    % Generic_3m = ncread(Filename, "Generic_3m");% Generic code
    % SYNOP_3m = ncread(Filename, "SYNOP_3m");    % SYNOP code

    % Atmospheric variables
    % T_3m = ncread(Filename, "T_3m");            % Temperature (degC)
    temperatureAir = ncread(Filename, "T_ws800_3m");    % Air temperature (degC)
    relativeHumidity = ncread(Filename, "RH_ws800_3m"); % Relative humidity (%)
    pressureAir = ncread(Filename, "P_ws800_3m");        % Air pressure (mb)
    windSpeed = ncread(Filename, "Spd_ws800_3m");        % Wind speed (m/s)
    windDirection = ncread(Filename, "Dir_ws800_3m");    % Wind direction (deg)

    % Rain variables
    precipitationIntensityCS125 = ncread(Filename, "Rainr_3m");          % Rain rate (mm/hr) - CS125 sensor
    precipitationIntensityWS800 = ncread(Filename, "rainr_ws800_3m");    % Rain rate (mm/hr) - WS800 sensor

    % Other meteorological fields (commented out)
    % Td_ws800_3m = ncread(Filename, "Td_ws800_3m");      % Dew point (degC)
    % Tchill_ws800_3m = ncread(Filename, "Tchill_ws800_3m"); % Wind chill (degC)
    % Precipitation_Quantity = ncread(Filename, "raina_ws800_3m"); % Total rain (mm)
    % preciptype_ws800_3m = ncread(Filename, "preciptype_ws800_3m"); % Precip type
    % Sn_ws800_3m, Sx_ws800_3m, Sg_ws800_3m, Sv_ws800_3m = wind speeds
    % Da_ws800_3m, Dn_ws800_3m, Dx_ws800_3m = wind directions
    % Ca_ws800_3m = compass heading
    % Ga_ws800_3m, Gn_ws800_3m, Gx_ws800_3m, Gg_ws800_3m = radiation
    % Ea_ws800_3m, Ba_ws800_3m, Ad_ws800_3m, La_ws800_3m, Lb_ws800_3m = energy, wetness, density

    % --- Store selected variables into output structure ---
    Data.time                        = time;
    Data.temperatureAir              = temperatureAir;
    Data.relativeHumidity            = relativeHumidity;
    Data.pressureAir                 = pressureAir;
    Data.windSpeed                   = windSpeed;
    Data.precipitationIntensityCS125 = precipitationIntensityCS125;
    Data.precipitationIntensityWS800 = precipitationIntensityWS800;
    Data.windDirection               = windDirection;

    % Return to the home directory
    cd(Path.home)

end