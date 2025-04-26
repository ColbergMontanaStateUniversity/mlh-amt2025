function [Halo_Data] = trim_halo_data(Halo_Data)
% trim_halo_data
% ---------------------------
% This function trims the Halo Doppler lidar dataset to a specific time window.
%
% INPUT:
%   Halo_Data - structure containing Halo data fields:
%               - time
%               - meanW (vertical velocity)
%               - attenuatedBackscatter
%               - signalToNoiseRatio
%
% OUTPUT:
%   Halo_Data - same structure but limited to the desired time range
%
% NOTE:
%   - The time vector is expected to be in local time (e.g., PDT).
%   - Data is trimmed between -2 hours and 26 hours local time to match a
%     full day plus margins.

% ---------------------------
% Find indices corresponding to the time window
% ---------------------------
indLow  = find(Halo_Data.time >= -2, 1, 'first'); % Find first time ≥ -2 hours
indHigh = find(Halo_Data.time <= 26, 1, 'last');  % Find last time ≤ 26 hours

% ---------------------------
% Trim time and corresponding data arrays
% ---------------------------
Halo_Data.time = Halo_Data.time(indLow:indHigh);

Halo_Data.meanW = Halo_Data.meanW(:, indLow:indHigh);

Halo_Data.attenuatedBackscatter = Halo_Data.attenuatedBackscatter(:, indLow:indHigh);

Halo_Data.signalToNoiseRatio = Halo_Data.signalToNoiseRatio(:, indLow:indHigh);

end
