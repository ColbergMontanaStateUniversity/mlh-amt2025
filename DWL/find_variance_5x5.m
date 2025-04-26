function [Clouds] = find_variance_5x5(HaloData)
% FIND_VARIANCE_5X5 computes the spatiotemporal variance in a 5x5 neighborhood
% around each cell for both attenuated backscatter and vertical wind velocity.

% Inputs:
%   HaloData - Structure containing fields:
%       attenuatedBackscatter : 2D matrix of attenuated backscatter values
%       meanW                 : 2D matrix of mean vertical velocity

% Outputs:
%   Clouds - Structure containing fields:
%       attenuatedBackscatterVariance5x5 : Variance of backscatter over 5x5 windows
%       windVariance5x5                  : Variance of vertical wind over 5x5 windows

%% Process Attenuated Backscatter

% Extract backscatter field
x = HaloData.attenuatedBackscatter;

% Preallocate variance matrix
v = NaN(size(x));

% Define the 5x5 kernel size
kernelSize = 5;

% Compute the local mean over a 5x5 window
localMean = conv2(x, ones(kernelSize) / kernelSize^2, 'same');

% Compute the local mean of the squared field
localSquaredMean = conv2(x.^2, ones(kernelSize) / kernelSize^2, 'same');

% Compute variance: Var(X) = E[X^2] - (E[X])^2
localVariance = localSquaredMean - localMean.^2;

% Assign variance, avoiding boundary artifacts (only safe inner region)
v(3:end-2, 3:end-2) = localVariance(3:end-2, 3:end-2);

% Fill edge values using nearest neighbor interpolation
v = fillmissing(v, 'nearest', 1);
v = fillmissing(v, 'nearest', 2);

% Save backscatter variance into output structure
Clouds.attenuatedBackscatterVariance5x5 = v;

%% Process Vertical Wind Velocity

% Extract vertical wind velocity field
x = HaloData.meanW;

% Preallocate variance matrix
v = NaN(size(x));

% Compute the local mean over a 5x5 window
localMean = conv2(x, ones(kernelSize) / kernelSize^2, 'same');

% Compute the local mean of the squared field
localSquaredMean = conv2(x.^2, ones(kernelSize) / kernelSize^2, 'same');

% Compute variance: Var(X) = E[X^2] - (E[X])^2
localVariance = localSquaredMean - localMean.^2;

% Assign variance, avoiding boundary artifacts
v(3:end-2, 3:end-2) = localVariance(3:end-2, 3:end-2);

% Fill edge values
v = fillmissing(v, 'nearest', 1);
v = fillmissing(v, 'nearest', 2);

% Save vertical wind variance into output structure
Clouds.windVariance5x5 = v;

end