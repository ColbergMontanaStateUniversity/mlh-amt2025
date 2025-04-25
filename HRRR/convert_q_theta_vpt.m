function [HRRRData] = convert_q_theta_vpt(HRRRData)
% CONVERT_Q_THETA_VPT Computes specific humidity, potential temperature,
% and virtual potential temperature from HRRR fields
%
% INPUT:
%   HRRRData - structure containing:
%     .temperature               [range x time] in K
%     .temperature2Meter         [1 x time] in K
%     .relativeHumidity          [range x time] in %
%     .relativeHumidity2Meter    [1 x time] in %
%     .pressure                  [range x time] in hPa
%     .pressureHumidity2Meter    [1 x time] in Pa
%
% OUTPUT:
%   HRRRData - updated with additional fields:
%     .specificHumidity                [range x time] in g/kg
%     .potentialTemperature            [range x time] in K
%     .potentialTemperatureSurface     [1 x time] in K
%     .virtualPotentialTemperature     [range x time] in K
%     .virtualPotentialTemperatureSurface [1 x time] in K

%% 1. Compute specific humidity from RH, T, and P

% Extract input variables from structure
relativeHumidity         = HRRRData.relativeHumidity;
relativeHumiditySurface  = HRRRData.relativeHumidity2Meter;
temperature              = HRRRData.temperature;
temperatureSurface       = HRRRData.temperature2Meter;
pressure                 = HRRRData.pressure;  % hPa
pressureSurface          = HRRRData.pressureHumidity2Meter / 100;  % Pa → hPa

% Saturation vapor pressure (Tetens' formula)
vaporPressure = zeros(size(pressure));
% For T >= 0°C
vaporPressure(temperature >= 273.15) = ...
    6.1078 .* exp((17.27 .* (temperature(temperature >= 273.15) - 273.15)) ./ ...
    ((temperature(temperature >= 273.15) - 273.15) + 237.3));
% For T < 0°C
vaporPressure(temperature < 273.15) = ...
    6.1078 .* exp((21.875 .* (temperature(temperature < 273.15) - 273.15)) ./ ...
    ((temperature(temperature < 273.15) - 273.15) + 265.5));

% Repeat for surface temperature
vaporPressureSurface = zeros(size(temperatureSurface));
vaporPressureSurface(temperatureSurface >= 273.15) = ...
    6.1078 .* exp((17.27 .* (temperatureSurface(temperatureSurface >= 273.15) - 273.15)) ./ ...
    ((temperatureSurface(temperatureSurface >= 273.15) - 273.15) + 237.3));
vaporPressureSurface(temperatureSurface < 273.15) = ...
    6.1078 .* exp((21.875 .* (temperatureSurface(temperatureSurface < 273.15) - 273.15)) ./ ...
    ((temperatureSurface(temperatureSurface < 273.15) - 273.15) + 265.5));

% Compute actual vapor pressure using RH
vaporPressure         = vaporPressure .* relativeHumidity / 100;
vaporPressureSurface  = vaporPressureSurface .* relativeHumiditySurface / 100;

% Compute specific humidity (g/kg)
specificHumidity        = (0.622 .* vaporPressure)         ./ (pressure - 0.378 .* vaporPressure) * 1000;
specificHumiditySurface = (0.622 .* vaporPressureSurface)  ./ (pressureSurface - 0.378 .* vaporPressureSurface) * 1000;

%% 2. Compute potential temperature
% θ = T * (1000 / P)^(R/cp), where R=287.05 J/kg/K and cp=1004 J/kg/K
potentialTemperature        = temperature .* (1000 ./ pressure) .^ (287.05 / 1004);
potentialTemperatureSurface = temperatureSurface .* (1000 ./ pressureSurface) .^ (287.05 / 1004);

%% 3. Compute virtual potential temperature
% θ_v = θ * (1 + 0.61 * q)
virtualPotentialTemperature        = potentialTemperature        .* (1 + 0.61 .* specificHumidity / 1000);
virtualPotentialTemperatureSurface = potentialTemperatureSurface .* (1 + 0.61 .* specificHumiditySurface / 1000);

%% 4. Store results in structure
HRRRData.specificHumidity                  = specificHumidity;
HRRRData.potentialTemperature              = potentialTemperature;
HRRRData.potentialTemperatureSurface       = potentialTemperatureSurface;
HRRRData.virtualPotentialTemperature       = virtualPotentialTemperature;
HRRRData.virtualPotentialTemperatureSurface = virtualPotentialTemperatureSurface;

end