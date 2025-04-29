function [HRRRData] = compute_mlh_parcel_hrrr_offset1K(HRRRData)
% COMPUTE_MLH_PARCEL_HRRR_OFFSET1K Estimates the mixed layer height
% using the parcel method with a 1-K offset.

% INPUT:
%   HRRRData - structure containing:
%       .virtualPotentialTemperature        [range x time] in K
%       .virtualPotentialTemperatureSurface [1 x time] in K
%       .range                              [1 x range] in m
%       .time                               [1 x time] in hr

% OUTPUT:
%   HRRRData - same structure with added field:
%       .mlhParcelOffset1K                  [1 x time] in m

% METHOD:
%   For each time step, this method finds the highest altitude at which 
%   the virtual potential temperature is still less than the surface 
%   virtual potential temperature plus 1 K. This threshold represents 
%   a lifted parcel and marks the base of the stable layer above.

% Extract required variables
time = HRRRData.time;
virtualPotentialTemperature = HRRRData.virtualPotentialTemperature;
virtualPotentialTemperatureSurface = HRRRData.virtualPotentialTemperatureSurface;
range = HRRRData.range;

% Preallocate output
mlhParcel = NaN(size(time));

% Loop through each time step to compute MLH
for i = 1:numel(time)
    tempProfile = virtualPotentialTemperature(:,i);

    % Find the last index where the profile is less than the surface + 1 K
    I1 = find(tempProfile < virtualPotentialTemperatureSurface(i) + 1, 1, 'last');

    if ~isempty(I1)
        mlhParcel(i) = range(I1);  % Assign MLH if threshold crossing is found
    end
end

% Save MLH result back into structure
HRRRData.mlhParcelOffset1K = mlhParcel;

end