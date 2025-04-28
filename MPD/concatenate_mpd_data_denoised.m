function [MPDDenoised] = concatenate_mpd_data_denoised(MPDDenoised1, MPDDenoised2)
% Concatenates two MPD denoised data structures into one.

% Copy range
MPDDenoised.range = MPDDenoised1.range;

% UTC to PDT
timeCorrection = -7;

% Concatenate time (adjusting for timezone and day shift)
MPDDenoised.time = [MPDDenoised1.time/3600 + timeCorrection; MPDDenoised2.time/3600 + 24 + timeCorrection];

% List of fields to vertically concatenate
fieldsVertical = {'surfacePressure', 'surfaceTemperature', 'surfaceAbsoluteHumidity'};

% List of fields to horizontally concatenate
fieldsHorizontal = {
    'temperature', 'pressureEstimateUncertainty', 'pressureEstimateMask', ...
    'pressureEstimate', 'aerosolBackscatterCoefficientUncertainty', ...
    'aerosolBackscatterCoefficientMask', 'aerosolBackscatterCoefficient', ...
    'backscatterRatioUncertainty', 'backscatterRatioMask', 'backscatterRatio', ...
    'absoluteHumidityUncertainty', 'absoluteHumidityMask', 'absoluteHumidity', ...
    'temperatureUncertainty', 'temperatureMask', ...
    'relativeHumidity', 'relativeHumidityMask', 'relativeHumidityUncertainty'
};

% Concatenate vertical fields
for k = 1:numel(fieldsVertical)
    f = fieldsVertical{k};
    MPDDenoised.(f) = [MPDDenoised1.(f); MPDDenoised2.(f)];
end

% Concatenate horizontal fields
for k = 1:numel(fieldsHorizontal)
    f = fieldsHorizontal{k};
    MPDDenoised.(f) = [MPDDenoised1.(f), MPDDenoised2.(f)];
end

end
