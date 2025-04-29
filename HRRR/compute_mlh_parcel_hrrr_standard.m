function [HRRRData] = compute_mlh_parcel_hrrr_standard(HRRRData)
% COMPUTE_MLH_PARCEL_HRRR_STANDARD Estimates the mixed layer height
% using the standard parcel method without offset.

% INPUT:
%   HRRRData - structure with fields:
%       .virtualPotentialTemperature        [range x time] in K
%       .virtualPotentialTemperatureSurface [1 x time] in K
%       .range                              [1 x range] in m
%       .time                               [1 x time] in hr

% OUTPUT:
%   HRRRData - same structure with added field:
%       .mlhParcelStandard                  [1 x time] in m

% METHOD:
%   At each time step, this method finds the last height where the
%   virtual potential temperature is still less than the surface value.
%   This threshold marks the top of the mixed layer under the parcel method.

% Extract relevant fields
time = HRRRData.time;
virtualPotentialTemperature = HRRRData.virtualPotentialTemperature;
virtualPotentialTemperatureSurface = HRRRData.virtualPotentialTemperatureSurface;
range = HRRRData.range;

% Preallocate output array
mlhParcel = NaN(size(time));

% Loop over all time points
for i = 1:numel(time)
    profile = virtualPotentialTemperature(:,i);

    % Find the last height where virtual potential temperature < surface value
    I1 = find(profile < virtualPotentialTemperatureSurface(i), 1, 'last');

    if ~isempty(I1)
        mlhParcel(i) = range(I1);  % Store MLH if found
    end
end

% Store result in structure
HRRRData.mlhParcelStandard = mlhParcel;

end