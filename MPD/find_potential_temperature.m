function [MPDDenoised] = find_potential_temperature(MPDDenoised)
% Computes potential temperature, virtual potential temperature,
% and their differences relative to the surface from denoised MPD data.

% Input:
%   MPDDenoised - Structure containing temperature, pressure, and humidity fields
%
% Output:
%   MPDDenoised - Updated structure including potential temperature (theta),
%                 virtual potential temperature (thetaV), and differences
%                 from surface values.

% ---------------------------
% Compute potential temperature
% ---------------------------
theta = MPDDenoised.temperature .* (1 ./ MPDDenoised.pressureEstimate).^0.2854;
thetaSurface = MPDDenoised.surfaceTemperature .* (1 ./ MPDDenoised.surfacePressure).^0.2854;

% ---------------------------
% Convert absolute humidity (g/m^3) to specific humidity (kg/kg)
% ---------------------------
vaporPressure        = MPDDenoised.absoluteHumidity       .*.4615.*MPDDenoised.temperature;
vaporPressureSurface = MPDDenoised.surfaceAbsoluteHumidity.*.4615.*MPDDenoised.surfaceTemperature;

q        = 0.622*vaporPressure       ./(MPDDenoised.pressureEstimate*101325-(1-0.622).*vaporPressure);
qSurface = 0.622*vaporPressureSurface./(MPDDenoised.surfacePressure *101325-(1-0.622).*vaporPressureSurface);

% ---------------------------
% Compute virtual potential temperature
% ---------------------------
thetaV = theta .* (1 + 0.61 * q);
thetaVSurface = thetaSurface .* (1 + 0.61 * qSurface);

% ---------------------------
% Compute difference from surface values
% ---------------------------
thetaDifference = theta - repmat(thetaSurface', [length(MPDDenoised.range), 1]);
thetaVDifference = thetaV - repmat(thetaVSurface', [length(MPDDenoised.range), 1]);

% ---------------------------
% Store outputs into structure
% ---------------------------
MPDDenoised.theta = theta;
MPDDenoised.thetaSurface = thetaSurface;
MPDDenoised.thetaV = thetaV;
MPDDenoised.thetaVSurface = thetaVSurface;
MPDDenoised.thetaDiff = thetaDifference;
MPDDenoised.thetaVDiff = thetaVDifference;


end
