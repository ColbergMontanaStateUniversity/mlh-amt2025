function [CloudData] = find_cloud_bottom(CloudData, HaloData)
% FIND_CLOUD_BOTTOM identifies the cloud base height (CBH) from a cloud mask.
% For each time step, it finds the lowest range bin where a cloud is detected.

% Inputs:
%   CloudData - Structure containing the logical cloudMask (range x time)
%   HaloData  - Structure containing the range vector

% Outputs:
%   CloudData - Updated structure including the cloudBaseHeight (1 x time)


%% 1. Find indices of cloud detections
% Get row (range) and column (time) indices where clouds are detected
[rows, cols] = find(CloudData.cloudMask);

%% 2. Preallocate the cloud base height array
% Initialize CBH with NaN (for times with no cloud)
CloudData.cloudBaseHeight = NaN(1, size(CloudData.cloudMask, 2));

%% 3. Assign the lowest detected cloud base for each time
% Use 'unique' to find the first detected cloud (lowest range) at each time
[~, firstRowIdx] = unique(cols, 'first');  % Get first occurrence in each time column
CloudData.cloudBaseHeight(cols(firstRowIdx)) = HaloData.range(rows(firstRowIdx));

end
