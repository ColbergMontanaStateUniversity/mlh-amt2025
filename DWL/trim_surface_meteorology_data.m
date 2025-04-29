function [SurfaceMeteorologyData] = trim_surface_meteorology_data(SurfaceMeteorologyData)
% TRIM_SURFACE_METEOROLOGY_STATION
% Trims surface meteorology data to a 28-hour window (-2 to 26 local hours).

% Inputs:
%   - SurfaceMeteorologyData: Structure containing concatenated surface meteorology variables

% Outputs:
%   - SurfaceMeteorologyData: Same structure, but time and all fields trimmed to the desired time window

% Find indices corresponding to the trimming window
indLow  = find(SurfaceMeteorologyData.time >= -2, 1, 'first');
indHigh = find(SurfaceMeteorologyData.time <= 26, 1, 'last');

% Trim each field accordingly
SurfaceMeteorologyData.time                         = SurfaceMeteorologyData.time(indLow:indHigh);
SurfaceMeteorologyData.temperatureAir               = SurfaceMeteorologyData.temperatureAir(indLow:indHigh);
SurfaceMeteorologyData.relativeHumidity             = SurfaceMeteorologyData.relativeHumidity(indLow:indHigh);
SurfaceMeteorologyData.pressureAir                  = SurfaceMeteorologyData.pressureAir(indLow:indHigh);
SurfaceMeteorologyData.windSpeed                    = SurfaceMeteorologyData.windSpeed(indLow:indHigh);
SurfaceMeteorologyData.precipitationIntensityCS125  = SurfaceMeteorologyData.precipitationIntensityCS125(indLow:indHigh);
SurfaceMeteorologyData.precipitationIntensityWS800  = SurfaceMeteorologyData.precipitationIntensityWS800(indLow:indHigh);
SurfaceMeteorologyData.windDirection                = SurfaceMeteorologyData.windDirection(indLow:indHigh);

end