function [MLH] = find_nearest_peak_constrained(MLH, HWT)
% find_nearest_peak_constrained - Finds the nearest strong peak in Haar wavelet data
 
% Inputs:
%   MLH - Structure containing constrained tracking density and time
%   HWT - Structure containing Haar wavelet transformation

% Outputs:
%   MLH - Updated structure with mlhPoints, mlhIndex, and mlh

%% Initialize output fields
MLH.mlhIndex = NaN(size(MLH.time)); % Index of nearest HWT peak
MLH.mlh = NaN(size(MLH.time));      % Physical height (range) corresponding to the nearest peak

newPoints = []; % Preallocate storage for detected points

%% Step 1: Find strongest density points
for i = 1:length(MLH.time)
    if (sum(MLH.aerosolLayerConstrainedTrackingDensity(:,i))) > 0
        [~, idx] = max(MLH.aerosolLayerConstrainedTrackingDensity(:,i));
        newPoints = [newPoints; [idx, i]]; % Store (y,x) = (range bin, time index)
    end
end

%% Step 2: Remove invalid points near the bottom (range bin < 2)
toDelete = newPoints(:,1) < 2;
col1 = newPoints(~toDelete,1);
col2 = newPoints(~toDelete,2);
newPoints = [col1, col2];

MLH.mlhPoints = newPoints; % Save the cleaned points

%% Step 3: Refine each point using nearby Haar wavelet peaks
for i = 1:length(newPoints(:,1))
    j = newPoints(i,2); % Current time index

    temp = HWT.haarWaveletTransformation(:,j); % Haar wavelet transformation at this time

    [~, locs] = findpeaks(temp); % Find all peaks in HWT

    layerInd = newPoints(i,1); % Initial estimate of layer location

    % Keep only peaks within 10 bins of initial location
    locs(abs(locs - layerInd) >= 10) = [];

    % Limit search to below topLimiter
    topLimiterIndex = MLH.topLimiter(j);
    locs(locs > topLimiterIndex) = [];

    if ~isempty(locs)
        [~, idx] = min(abs(locs - layerInd)); % Find closest refined peak
        MLH.mlhIndex(j) = locs(idx);           % Save refined index
        MLH.mlh(j) = MLH.rangeHWT(locs(idx));  % Save physical height
    else
        continue
    end
end

end