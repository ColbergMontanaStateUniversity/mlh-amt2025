function [MLH] = remove_points_below_clouds(MLH, HWT, CloudData)
% remove_points_below_clouds - Removes MLH points that are invalid based on cloud base proximity

% Inputs:
%   MLH       - Structure containing MLH indices and heights
%   HWT       - Structure containing Haar wavelet transformation
%   CloudData - Structure containing cloud base index

% Outputs:
%   MLH       - Updated structure with invalid points set to NaN

%% Loop over all time steps
for i = 1:length(MLH.mlhIndex)

    % Skip if MLH point is already NaN
    if isnan(MLH.mlhIndex(i))
        continue
    end

    % Skip if no cloud base information
    if isnan(CloudData.cloudBaseIndex(i))
        continue
    end

    % If MLH point is above cloud base, remove it
    if MLH.mlhIndex(i) > CloudData.cloudBaseIndex(i)
        MLH.mlhIndex(i) = NaN;
        MLH.mlh(i) = NaN;
        continue
    end
    
    % If MLH point is below cloud base but top limiter is above cloud base
    if MLH.mlhIndex(i) < CloudData.cloudBaseIndex(i) && MLH.topLimiter(i) > CloudData.cloudBaseIndex(i)
        % Check the Haar wavelet strength at that point
        if HWT.haarWaveletTransformation(MLH.mlhIndex(i), i) < 0.08
            MLH.mlhIndex(i) = NaN;
            MLH.mlh(i) = NaN;
            continue
        else
            continue
        end
    else
        continue
    end

end

end