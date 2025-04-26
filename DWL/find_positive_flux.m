function [FluxData] = find_positive_flux(FluxData, HaloData)
% This function identifies the longest continuous period where the buoyancy flux is positive
% and resamples the flux variables to the HaloData time base.
%
% Inputs:
%   FluxData - Structure containing flux-related variables
%   HaloData - Structure containing time vector to interpolate onto
%
% Output:
%   FluxData - Updated structure with positive flux region and interpolated fields

    % ---------------------------
    % Find the largest positive buoyancy flux region
    % ---------------------------
    
    % Identify where buoyancy flux is positive
    buoyancyPositive = FluxData.wThetaVAvgSmooth > 0;

    % Find start and end indices of each positive region
    d = diff([false; buoyancyPositive; false]); % Pad with false to capture edges
    startIndices = find(d == 1);          % Region starts
    endIndices = find(d == -1) - 1;       % Region ends

    % Compute lengths of all positive regions
    lengths = endIndices - startIndices + 1;

    % Find the largest (longest duration) positive region
    [~, idx] = max(lengths);
    largestRegionStart = startIndices(idx);
    largestRegionEnd = endIndices(idx);

    % Create a new logical array marking only the largest positive region
    buoyancyPositive = false(size(FluxData.wThetaVAvgSmooth));
    buoyancyPositive(largestRegionStart:largestRegionEnd) = true;

    % Clear temporary variables
    clear largestRegionStart largestRegionEnd lengths endIndices...
        startIndices d idx

    % ---------------------------
    % Interpolate onto the HaloData time base
    % ---------------------------
    
    % Save old and new time vectors
    oldTime = FluxData.time;
    newTime = HaloData.time;
    FluxData.time = newTime;

    % Interpolate buoyancyPositive mask
    FluxData.buoyancyPositive = ...
        interp1(oldTime, double(buoyancyPositive), newTime, "linear", "extrap");
    FluxData.buoyancyPositive(FluxData.buoyancyPositive > 0.5) = true; % Convert back to logical

    % Interpolate flux variables
    FluxData.gWThetaVByThetaV0Avg = ...
        interp1(oldTime, FluxData.gWThetaVByThetaV0Avg, newTime);
    FluxData.gWThetaVByThetaV0AvgSmooth = ...
        interp1(oldTime, FluxData.gWThetaVByThetaV0AvgSmooth, newTime);
    FluxData.wThetaVAvg = ...
        interp1(oldTime, FluxData.wThetaVAvg, newTime);
    FluxData.wThetaVAvgSmooth = ...
        interp1(oldTime, FluxData.wThetaVAvgSmooth, newTime);

end