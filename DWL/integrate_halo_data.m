function [HaloData] = integrate_halo_data(HaloData)
% integrate_halo_data

% This function averages the Halo Doppler lidar data into 10-second intervals
% and vertically averages the range data every 10 gates.

% INPUT:
%   HaloData - structure containing time, vertical wind (windW), 
%              attenuated backscatter, and intensity

% OUTPUT:
%   HaloData - updated structure with:
%              - time vector (10-s averaged)
%              - mean vertical velocity (meanW)
%              - mean attenuated backscatter
%              - signal-to-noise ratio (SNR)

% NOTE: The original raw fields (windW, attenuatedBackscatter, intensity, time)
%       are removed after processing.

% ---------------------------
% Define new 10-second averaged time bins
% ---------------------------
timeLow  = (0:10:24*60*60-10)/(60*60);    % Lower bound of each bin in hours
timeHigh = (10:10:24*60*60)/(60*60);      % Upper bound of each bin in hours
time = (timeLow + timeHigh) / 2;          % Midpoints of time bins

% ---------------------------
% Preallocate matrices for results
% ---------------------------
meanW    = NaN(ceil(length(HaloData.range)/20), length(time));
attenuatedBackscatter = NaN(size(meanW));
signalToNoiseRatio    = NaN(size(meanW));

% ---------------------------
% Loop through each time bin
% ---------------------------
for i = 1:length(time)

    % Find indices in the original data that fall within the current time bin
    ind1 = find(HaloData.time > timeLow(i), 1, 'first');
    ind2 = find(HaloData.time < timeHigh(i), 1, 'last');

    if ~isempty(ind1) && ~isempty(ind2)
        % Loop through vertical levels grouped in chunks of 10 gates
        for j = 1:length(HaloData.range)/20

            % Average vertical velocity
            meanW(j,i) = mean(HaloData.windW(10*(j-1)+1:10*j, ind1:ind2), 'all');

            % Average attenuated backscatter
            attenuatedBackscatter(j,i) = mean(HaloData.attenuatedBackscatter(10*(j-1)+1:10*j, ind1:ind2), 'all');

            % Average SNR, corrected by the number of samples
            signalToNoiseRatio(j,i) = mean(HaloData.intensity(10*(j-1)+1:10*j, ind1:ind2) - 1, 'all') * ...
                                       sqrt(numel(ind1:ind2) * numel(10*(j-1)+1:10*j));

        end
    end
end

% ---------------------------
% Adjust the range vector
% ---------------------------
HaloData.range = mean(reshape(HaloData.range, 10, []));  % Average every 10 gates
HaloData.range = HaloData.range(1:ceil(length(HaloData.range)/2)); % Match to data dimensions

% ---------------------------
% Clean up and save new variables
% ---------------------------
HaloData = rmfield(HaloData, {'time', 'windW', 'attenuatedBackscatter', 'intensity'});

HaloData.time                = time;
HaloData.meanW               = meanW;
HaloData.attenuatedBackscatter = attenuatedBackscatter;
HaloData.signalToNoiseRatio  = signalToNoiseRatio;

end