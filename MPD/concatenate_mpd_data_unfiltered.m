function [MPD] = concatenate_mpd_data_unfiltered(MPD_Data1, MPD_Data2)
% This function concatenates two days of unfiltered MPD data into a single structure.
% It applies a UTC to PDT (UTC-7) time correction and adjusts the second day to avoid overlap.

% Inputs:
%   MPD_Data1 - Structure containing the first day's MPD data
%   MPD_Data2 - Structure containing the second day's MPD data

% Output:
%   MPD       - Combined structure with corrected time and concatenated data fields

% ---------------------------
% Apply UTC to PDT time correction
% ---------------------------
timeCorrection = -7; % PDT is UTC - 7 hours

% Copy the range vector (assumed identical for both days)
MPD.range = MPD_Data1.range;

% Concatenate and correct the time vectors:
% - First day: convert seconds to hours and shift by timeCorrection
% - Second day: same conversion, but add 24 hours to separate the days, then apply timeCorrection
MPD.time = [MPD_Data1.time/3600 + timeCorrection; ...
            MPD_Data2.time/3600 + 24 + timeCorrection];

% ---------------------------
% Concatenate the aerosol and backscatter data
% ---------------------------
MPD.aerosolBackscatterCoefficient = [MPD_Data1.aerosolBackscatterCoefficient, MPD_Data2.aerosolBackscatterCoefficient];

MPD.backscatterRatio = [MPD_Data1.backscatterRatio, MPD_Data2.backscatterRatio];

% ---------------------------
% Concatenate the masks
% ---------------------------
MPD.aerosolBackscatterCoefficientMask = [MPD_Data1.aerosolBackscatterCoefficientMask, MPD_Data2.aerosolBackscatterCoefficientMask];

MPD.backscatterRatioMask = [MPD_Data1.backscatterRatioMask, MPD_Data2.backscatterRatioMask];

end