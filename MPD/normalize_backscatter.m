function [HWT] = normalize_backscatter(MPDDenoised, CloudData)
% This function normalizes the aerosol backscatter coefficient
% to the maximum value found between 300 m and 4000 m for each time step.
% It also masks out clouds before normalization.

    % Apply the combined mask to remove cloud-contaminated data
    CloudData = CloudData.Mask(11:162, :); % Select the corresponding height range
    temp = MPDDenoised.aerosolBackscatterCoefficient;
    temp(CloudData == 1) = NaN; % Set cloud-contaminated values to NaN

    % Normalize the aerosol backscatter profile
    [HWT.normalizedAerosolBackscatterCoefficient, ~] = normalize_x(temp, MPDDenoised.range);

    % Save range and time vectors
    HWT.rangeAerosolBackscatterCoefficient = MPDDenoised.range;
    HWT.time = MPDDenoised.time;

end

%% Local function that normalizes X to its low-altitude value
function [xN, xDiv] = normalize_x(x, r)
% This function normalizes each profile of x (aerosol backscatter)
% by the maximum value between 300 m and 4000 m.

    % Find the indices corresponding to 300 m and 4000 m
    rHigh = find(r < 4000, 1, 'last');
    rLow  = find(r > 300,  1, 'first');

    % Remove low-altitude data (below 300 m)
    x(1:rLow-1, :) = NaN;
    xTemp = x;

    % Remove high-altitude data (above 4000 m) from each profile
    for i = 1:size(x, 2)
        xTemp(rHigh:end, i) = NaN;
    end

    % Find the maximum value in the valid altitude range for each profile
    xLowAvg = max(xTemp, [], 1);

    % Fill missing values by nearest neighbor interpolation
    xLowAvgNew = fillmissing(xLowAvg, 'nearest');

    % Create a divisor matrix
    xDiv = repmat(xLowAvgNew, length(x(:,1)), 1);

    % Normalize the original x
    xN = x ./ xDiv;

end