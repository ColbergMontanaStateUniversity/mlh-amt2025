function [MPDDenoised] = trim_mpd_data_denoised(MPDDenoised)
% Trims MPD denoised data structure to time window [-2, 26] hours.

% Find trimming indices
indLow  = find(MPDDenoised.time >= -2, 1, 'first');
indHigh = find(MPDDenoised.time <= 26, 1, 'last');

% List of 1D fields to trim
fields1D = {'time', 'surfacePressure', 'surfaceTemperature', 'surfaceAbsoluteHumidity'};

% List of 2D fields to trim
fields2D = {
    'temperature', 'temperatureMask', 'pressureEstimateUncertainty', ...
    'pressureEstimateMask', 'pressureEstimate', ...
    'aerosolBackscatterCoefficientUncertainty', 'aerosolBackscatterCoefficientMask', ...
    'aerosolBackscatterCoefficient', 'backscatterRatioUncertainty', ...
    'backscatterRatioMask', 'backscatterRatio', ...
    'absoluteHumidityUncertainty', 'absoluteHumidityMask', 'absoluteHumidity', ...
    'temperatureUncertainty', 'relativeHumidity', ...
    'relativeHumidityMask', 'relativeHumidityUncertainty'
};

% Trim 1D fields
for k = 1:numel(fields1D)
    f = fields1D{k};
    MPDDenoised.(f) = MPDDenoised.(f)(indLow:indHigh);
end

% Trim 2D fields
for k = 1:numel(fields2D)
    f = fields2D{k};
    MPDDenoised.(f) = MPDDenoised.(f)(:, indLow:indHigh);
end

end
