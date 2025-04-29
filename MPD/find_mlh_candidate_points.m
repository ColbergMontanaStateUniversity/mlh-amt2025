function [MLH] = find_mlh_candidate_points(MLH, HWT, Sunrise)
% find_mlh_candidate_points - Identify initial candidate points for MLH retrieval based on aerosol layer density.

% Inputs:
%   MLH     - Structure containing top limiter indices and aerosol layer density
%   HWT     - Structure containing Haar wavelet transformation
%   Sunrise - Structure containing sunrise and sunset indices

% Outputs:
%   MLH.mlhCandidatePoints - Nx2 array of [range_index, time_index] for candidate MLH points

    % Initialize output array
    MLH.mlhCandidatePoints = [];

    % Loop over each time index during daytime
    for i = Sunrise.sunriseInd:Sunrise.sunsetInd

        % Skip if no valid top limiter
        if isnan(MLH.topLimiter(i))
            continue
        end

        % Extract Haar wavelet and aerosol layer density up to top limiter
        tempHWT = HWT.haarWaveletTransformation(1:MLH.topLimiter(i), i);
        tempAerosolLayerDensity = MLH.aerosolLayerTrackingDensity(1:MLH.topLimiter(i), i);

        % Skip if no valid Haar wavelet data
        if sum(~isnan(tempHWT)) == 0
            continue
        end

        % Skip if no valid aerosol layer density
        if sum(tempAerosolLayerDensity(~isnan(tempAerosolLayerDensity))) == 0
            continue
        end

        % Find maximum aerosol layer density
        [~, temp] = max(tempAerosolLayerDensity);

        % If a maximum exists, store [range_index, time_index]
        if ~isempty(temp)
            MLH.mlhCandidatePoints = [MLH.mlhCandidatePoints; [temp, i]];
        end

    end

end