function [HRRRData] = convert_pressure_to_altitude(HRRRData)
% CONVERT_PRESSURE_TO_ALTITUDE Interpolates HRRR pressure-level data to a fixed altitude grid

% This function converts pressure-level variables (temperature and RH) to
% altitude above ground level (AGL), using geopotential height minus the site elevation.
% It interpolates all values onto a fixed vertical grid in 37.5 m steps.

% INPUT:
%   HRRRData - structure containing HRRR data fields on pressure levels:
%              .geopotentialHeight, .presLevels, .temperature, .relativeHumidity, .time

% OUTPUT:
%   HRRRData - updated structure with pressure-based fields replaced by:
%              .range               - altitude vector (AGL) [m]
%              .pressure            - interpolated pressure on fixed alt grid [hPa]
%              .temperature         - temperature [K] on fixed alt grid [range x time]
%              .relativeHumidity    - RH [%] on fixed alt grid [range x time]
%              .elevation           - elevation of site [m]

% Notes:
%   - Assumes fixed site elevation (e.g., Tonopah, NV = 1641 m)
%   - Deletes original pressure-level fields (presLevels, geopotentialHeight)

% ---------------------------
% INPUT: Site elevation (in meters)
% ---------------------------
elevation = 1641;

% ---------------------------
% Convert geopotential height to altitude AGL
% ---------------------------
rAGL = HRRRData.geopotentialHeight - elevation;

% ---------------------------
% Generate new fixed altitude grid (37.5 m spacing)
% ---------------------------
r = 0:37.5:max(rAGL);  % altitude grid [m]
t = HRRRData.time;     % time vector

% ---------------------------
% Create meshgrids for interpolation
% ---------------------------
[rMeshHRRR, tMeshHRRR] = meshgrid(rAGL, t);     % original grid (pressure-based)
[rMesh,     tMesh]     = meshgrid(r,    t);     % new grid (altitude-based)

% ---------------------------
% Interpolate pressure to altitude grid (1D interpolation)
% ---------------------------
pressureInterp = interp1(rAGL, HRRRData.presLevels, r);  % [range]
pressureInterp = repmat(pressureInterp', [1, length(t)]);  % replicate across time

% ---------------------------
% Interpolate temperature and RH to altitude grid (2D interpolation)
% ---------------------------
temperatureInterp      = interp2(rMeshHRRR, tMeshHRRR, HRRRData.temperature',      rMesh, tMesh)';
relativeHumidityInterp = interp2(rMeshHRRR, tMeshHRRR, HRRRData.relativeHumidity', rMesh, tMesh)';

% ---------------------------
% Store results in updated structure
% ---------------------------
HRRRData.elevation         = elevation;
HRRRData.range             = r;
HRRRData.pressure          = pressureInterp;
HRRRData.temperature       = temperatureInterp;
HRRRData.relativeHumidity  = relativeHumidityInterp;
HRRRData.time              = t;

% ---------------------------
% Remove fields no longer needed (pressure-level based)
% ---------------------------
HRRRData = rmfield(HRRRData, {'presLevels', 'geopotentialHeight'});

end