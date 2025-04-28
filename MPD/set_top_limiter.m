function [MLH] = set_top_limiter(MLH, HWT, Sunrise, HRRRData)
% set_top_limiter - Set the top limiter for HWT search based on HRRR PBLH estimates.
%
% Inputs:
%   MLH       - Structure containing MPD time vector
%   HWT       - Structure containing Haar wavelet transformation range vector
%   Sunrise   - Structure containing sunrise and sunset indices
%   HRRRData  - Structure containing HRRR model times and default PBLH values
%
% Outputs:
%   MLH.topLimiter - Vector containing the top limiter index for each time step

    % Preallocate topLimiter with NaNs
    MLH.topLimiter = NaN(size(MLH.time));
    
    % Interpolate HRRR PBLH onto MPD time grid
    pblhHRRR = interp1(HRRRData.time, HRRRData.pblhDefault, MLH.time);

    % Loop through daytime hours between sunrise and sunset
    for j = Sunrise.sunriseInd:Sunrise.sunsetInd

        % If HRRR PBLH is greater than 1000 m, use 1.5x scaling
        if pblhHRRR(j) > 1000
            [~, ind2] = min(abs(1.5 * pblhHRRR(j) - HWT.rangeHaarWaveletTransformation));
        else
            % Otherwise, add 500 m to HRRR PBLH
            [~, ind2] = min(abs((pblhHRRR(j) + 500) - HWT.rangeHaarWaveletTransformation));
        end

        % Assign computed top limiter index
        MLH.topLimiter(j) = ind2;

        % Ensure no limiter exceeds the range bounds
        MLH.topLimiter(MLH.topLimiter > length(HWT.rangeHaarWaveletTransformation)) = length(HWT.rangeHaarWaveletTransformation);

        % Force top limiter to maximum height in the afternoon hours
        MLH.topLimiter(round((Sunrise.sunriseInd + Sunrise.sunsetInd)/2):Sunrise.sunsetInd) = length(HWT.rangeHaarWaveletTransformation);
    end
    
end