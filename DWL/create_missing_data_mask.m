function [Mask] = create_missing_data_mask(Mask, HaloData)
% CREATE_MISSING_DATA_MASK generates a mask that flags times with missing or invalid data.
% It identifies missing data by checking the smoothed vertical wind signal over the lowest ~200 range bins.

% Inputs:
%   Mask     - Structure containing existing masks
%   HaloData - Structure with Halo Doppler lidar data

% Output:
%   Mask - Updated structure including the missing data mask

%% 1. Smooth the vertical velocity field
% Smooth over time (horizontal direction) with a 60-point moving average
wSmooth = smoothdata(HaloData.meanW, 2, 'movmean', 60, 'omitnan');

%% 2. Sum vertical velocities in the lower part of the profile
% Sum the first 199 range bins (close to the surface)
sumWSmooth = sum(wSmooth(1:199,:), 1);

%% 3. Identify time indices where the sum is NaN
% If the sum is NaN, it indicates missing data across much of the low levels
missingData = isnan(sumWSmooth);

%% 4. Expand missing data times to the full range profile
% Create a 2D mask: one value per (range, time) pair
Mask.missingDataMask = repmat(missingData, [length(HaloData.range), 1]);

end