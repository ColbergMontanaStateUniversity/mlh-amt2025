function [MLH] = remove_single_points(MLH, HWT)
% remove_single_points - Removes isolated MLH points and fills small gaps
%
% Inputs:
%   MLH - Structure containing mlhIndex and mlh
%   HWT - Structure containing Haar wavelet transformation (not used directly here)
%
% Outputs:
%   MLH - Updated structure with cleaned mlhIndex and mlh

%% Step 1: Remove isolated or single MLH points
for i = 1:length(MLH.mlhIndex(:,1))
    if i == 1
        % First point handling
        if isnan(MLH.mlhIndex(i))
            continue
        end
        if isnan(MLH.mlhIndex(i+1))
            MLH.mlhIndex(i) = NaN;
        else
            diff = abs(MLH.mlhIndex(i) - MLH.mlhIndex(i+1));
            if diff <= 20
                continue
            else
                MLH.mlhIndex(i) = NaN;
            end
        end
    elseif i == length(MLH.mlhIndex(:,1))
        % Last point handling
        if isnan(MLH.mlhIndex(i))
            continue
        end
        if isnan(MLH.mlhIndex(i-1))
            MLH.mlhIndex(i) = NaN;
        else
            diff = abs(MLH.mlhIndex(i) - MLH.mlhIndex(i-1));
            if diff <= 20
                continue
            else
                MLH.mlhIndex(i) = NaN;
            end
        end
    else
        % Middle points
        if isnan(MLH.mlhIndex(i))
            continue
        end
        if isnan(MLH.mlhIndex(i+1)) && isnan(MLH.mlhIndex(i-1))
            MLH.mlhIndex(i) = NaN;
        else
            diff = min([abs(MLH.mlhIndex(i) - MLH.mlhIndex(i+1)), abs(MLH.mlhIndex(i) - MLH.mlhIndex(i-1))]);
            if diff <= 20
                continue
            else
                MLH.mlhIndex(i) = NaN;
            end
        end
    end
end

%% Step 2: Fill small gaps between valid MLH points

% Find NaN points that are surrounded by non-NaN points
idx = isnan(MLH.mlhIndex) & ...
      ~isnan([NaN; MLH.mlhIndex(1:end-1)]) & ...
      ~isnan([MLH.mlhIndex(2:end); NaN]);

% Smooth and round the MLH indices using a Gaussian window of size 5
smData = round(smoothdata(MLH.mlhIndex, 'g', 5, 'omitnan'));

% Fill these gaps with smoothed estimates
MLH.mlhIndex(idx) = smData(idx);

% Update mlh field: set mlh to NaN where mlhIndex is NaN
MLH.mlh(isnan(MLH.mlhIndex)) = NaN;

% Where filled, recompute mlh from the rangeHWT vector
MLH.mlh(idx) = MLH.rangeHWT(MLH.mlhIndex(idx));

end