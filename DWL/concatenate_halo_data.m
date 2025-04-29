function [HaloData] = concatenate_halo_data(HaloData1, HaloData2)
% concatenate_halo_data
% ---------------------------
% This function concatenates two days of Halo Doppler lidar data
% and applies a time zone correction (UTC → PDT).

% INPUTS:
%   HaloData1 - structure containing the first day's processed Halo data
%   HaloData2 - structure containing the second day's processed Halo data

% OUTPUT:
%   HaloData - combined structure spanning two days, with corrected local time

% NOTE:
%   - Assumes both days have been pre-processed into 10-second averaged format
%   - Assumes HaloData1 and HaloData2 share the same vertical grid

% ---------------------------
% Time zone correction [UTC → PDT]
% ---------------------------
timeCorrection = -7; % Hours to shift from UTC to Pacific Daylight Time (PDT)

% ---------------------------
% Concatenate the variables
% ---------------------------
HaloData.range = HaloData1.range; % Use the same range grid

% Concatenate time arrays
% - Shift the first day's time by -7 hours
% - Shift the second day's time by 24 hours (next day) and then apply -7 hours
HaloData.time = [HaloData1.time + timeCorrection, HaloData2.time + 24 + timeCorrection];

% Concatenate vertical velocity
HaloData.meanW = [HaloData1.meanW, HaloData2.meanW];

% Concatenate attenuated backscatter
HaloData.attenuatedBackscatter = [HaloData1.attenuatedBackscatter, HaloData2.attenuatedBackscatter];

% Concatenate signal-to-noise ratio
HaloData.signalToNoiseRatio = [HaloData1.signalToNoiseRatio, HaloData2.signalToNoiseRatio];

end
