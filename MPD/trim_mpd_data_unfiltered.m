function [MPD] = trim_mpd_data_unfiltered(MPD)
% This function trims the MPD unfiltered dataset to a fixed time window.
% It keeps data between -2 and 26 hours (local time).

% Input:
%   MPD - Structure containing concatenated unfiltered MPD data

% Output:
%   MPD - Trimmed structure, retaining only the relevant time window

% ---------------------------
% Find the indices for the desired time window
% ---------------------------
indLow  = find(MPD.time >= -2, 1, 'first');  % First index where time >= -2 hr
indHigh = find(MPD.time <= 26, 1, 'last');   % Last index where time <= 26 hr

% ---------------------------
% Trim the time vector
% ---------------------------
MPD.time = MPD.time(indLow:indHigh);

% ---------------------------
% Trim each data field accordingly
% ---------------------------
MPD.aerosolBackscatterCoefficient = MPD.aerosolBackscatterCoefficient(:, indLow:indHigh);
MPD.backscatterRatio              = MPD.backscatterRatio(:, indLow:indHigh);
MPD.aerosolBackscatterCoefficientMask = MPD.aerosolBackscatterCoefficientMask(:, indLow:indHigh);
MPD.backscatterRatioMask          = MPD.backscatterRatioMask(:, indLow:indHigh);

end
