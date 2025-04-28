function [CloudData] = find_cloud_bottom(CloudData,MPDUnfiltered)
% This function locates the cloud base

% logical operator that finds the profiles containing clouds
cloudTimeIndex = sum(CloudData.Mask,1)>1;

%preallocate
CloudData.cloudBaseHeight = NaN(size(MPDUnfiltered.time));
CloudData.cloudBaseIndex = NaN(size(MPDUnfiltered.time));

% for loop to determine CBH
for i = 1:length(cloudTimeIndex)
    if cloudTimeIndex(i) == 0
        continue
    else
        ind = find(CloudData.Mask(:,i) == 1,1,'first');
        CloudData.cloudBaseHeight(i) = MPDUnfiltered.range(ind);
        CloudData.cloudBaseIndex(i) = ind;
    end
end

end