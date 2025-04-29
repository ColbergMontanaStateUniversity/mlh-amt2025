function [CloudData] = find_variance_5x5(MPDUnfiltered)

% this function applies an operator which determines the spatiotemporal
% variance of the region surrounding the cell. The operator takes the
% variance of a 5x5 bin of cells and sets the value of the center cell to
% the variance of the 5x5 grid.

X = MPDUnfiltered.backscatterRatio;

% Preallocate V
V = NaN(size(X));

% Define the size of the kernel
kernelSize = 5;

% Compute the local mean
localMean = conv2(X, ones(kernelSize) / kernelSize^2, 'same');

% Compute the local squared mean
localSquaredMean = conv2(X.^2, ones(kernelSize) / kernelSize^2, 'same');

% Compute the local variance using the formula: Var(X) = E[X^2] - (E[X])^2
localVariance = localSquaredMean - localMean.^2;

% Assign the local variance to the center of the kernel
V(3:end-2, 3:end-2) = localVariance(3:end-2, 3:end-2);

% Fix data at the edges of cells
V = fillmissing(V, 'nearest', 1);
V = fillmissing(V, 'nearest', 2);

% store the variance in the CloudData Structure

CloudData.variance = V;

end