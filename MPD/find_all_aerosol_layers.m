function [MLH] = find_all_aerosol_layers(MLH, CloudData)
% find_all_aerosol_layers - Tracks aerosol layer structures forward and backward in time

% Inputs:
%   MLH       - Structure containing Haar wavelet transformed MPD data and peak locations
%   CloudData - Structure containing cloud base heights

% Outputs:
%   MLH.aerosolLayerTrackingDensity - 2D matrix showing density of tracked aerosol layer paths

%% Forward tracking

% Define cost as inverse of the HWT
MLH.cost = 1 ./ MLH.weight;
p = zeros(size(MLH.cost)); % Preallocate density matrix

hwtPeaks = MLH.peaksHWT; % Initial peak points
m = MLH.cost;
m(isnan(m)) = inf; % Mark invalid entries
m(m < 0) = inf;    % Mark negative costs as invalid

maxJump = 4; % Maximum allowed vertical jump (in bins)

% Insert cloud base constraints into the cost matrix
valid = ~isnan(CloudData.cloudBaseHeight) & ...
        CloudData.cloudBaseHeight > 500 & ...
        CloudData.cloudBaseHeight < 5500;
if any(valid)
    tmp = find(valid);
    for j = 1:length(tmp)
        i = tmp(j);
        [~, idx] = min(abs(CloudData.cloudBaseHeight(i) - MLH.rangeHWT));
        m(idx,i) = 0.01; % Favor paths near cloud bases
    end
end

[row, col] = size(m); % Size of the matrix

% Loop through each peak to track forward
for i = 1:size(hwtPeaks,1)
    sw = 0; % Switch to exit early if no valid paths
    startRow = hwtPeaks(i,1);
    startCol = hwtPeaks(i,2);

    c = NaN(row, col); % Initialize cost matrix
    c(startRow, startCol) = m(startRow, startCol);

    previousRow = NaN(row, col); % Tracking arrays
    previousCol = NaN(row, col);

    for ii = startCol:col-1
        if ii == col
            continue
        end

        % First step special handling
        if ii == startCol
            multiplier = max(abs((1:row) - startRow)/2, 1);
            multiplier(multiplier > maxJump) = inf;
            costJump = multiplier .* m(:, ii+1)';
            c(:, ii+1) = c(startRow, startCol) + costJump;
            previousRow(:, ii+1) = startRow;
            previousCol(:, ii+1) = startCol;
            c(isinf(c)) = NaN;
            previousRow(isnan(c)) = NaN;
            previousCol(isnan(c)) = NaN;
            continue
        end

        % Main cost update
        validRows = find(~isnan(c(:, ii)));
        if isempty(validRows)
            endInd = ii;
            sw = 1;
            break
        end

        for jj = validRows'
            multiplier = max(abs((1:row) - jj)/2, 1);
            multiplier(multiplier > maxJump) = inf;
            costJump = multiplier .* m(:, ii+1)';

            newCost = c(jj, ii) + costJump;
            better = newCost' < c(:, ii+1) | isnan(c(:, ii+1));

            if any(better)
                c(better, ii+1) = newCost(better');
                previousRow(better, ii+1) = jj;
                previousCol(better, ii+1) = ii;
            end
        end

        % Threshold to remove high-cost paths
        valid = c(:, ii+1);
        valid(valid > min(valid,[],'omitnan') + 10) = NaN;
        c(:, ii+1) = valid;
    end

    if sw == 0
        endInd = col;
    end

    % Path reconstruction
    [~, endRow] = min(c(:, endInd));
    pathRow = NaN(1, col);
    pathRow(endInd) = endRow;
    for h = endInd-1:-1:startCol
        if ~isnan(pathRow(h+1))
            pathRow(h) = previousRow(pathRow(h+1), h+1);
        end
    end
    pathRow(startCol) = startRow;

    pathCol = 1:col;
    validPath = ~isnan(pathRow);
    pathRow = pathRow(validPath);
    pathCol = pathCol(validPath);

    % Add reconstructed path to the forward density matrix
    idx = sub2ind(size(p), pathRow, pathCol);
    idx(isnan(c(idx))|isinf(c(idx))) = [];
    p(idx) = p(idx) + 1;
end

%% Backward tracking

p2 = zeros(size(MLH.cost)); % Preallocate backward density matrix

% Prepare reversed peaks and matrices
hwtPeaks2 = flipud(MLH.peaksHWT);
log = zeros(size(hwtPeaks2,1),1);
for iii = 1:col
    ind = (hwtPeaks2(:,2) == iii);
    hwtPeaks2(ind & ~log,2) = col+1-iii;
    log(ind & ~log) = 1;
end
clear log ind

m2 = fliplr(m); % Flip matrix left-right
m2(isnan(m2)) = inf;
m2(m2<0) = inf;

cloudBaseHeight2 = flipud(CloudData.cloudBaseHeight);

valid = ~isnan(cloudBaseHeight2) & ...
        cloudBaseHeight2 > 500 & ...
        cloudBaseHeight2 < 5500;
if any(valid)
    tmp = find(valid);
    for j = 1:length(tmp)
        i = tmp(j);
        [~, idx] = min(abs(CloudData.cloudBaseHeight(i) - MLH.rangeHWT));
        m(idx,i) = 0.01;
    end
end

[row, col] = size(m2);

% Loop through reversed peaks
for i = 1:size(hwtPeaks2,1)
    sw = 0;
    startRow = hwtPeaks2(i,1);
    startCol = hwtPeaks2(i,2);

    c = NaN(row, col);
    c(startRow, startCol) = m2(startRow, startCol);

    previousRow = NaN(row, col);
    previousCol = NaN(row, col);

    for ii = startCol:col-1
        if ii == col
            continue
        end

        % First step special handling
        if ii == startCol
            multiplier = max(abs((1:row) - startRow)/2, 1);
            multiplier(multiplier > maxJump) = inf;
            costJump = multiplier .* m2(:, ii+1)';
            c(:, ii+1) = c(startRow, startCol) + costJump;
            previousRow(:, ii+1) = startRow;
            previousCol(:, ii+1) = startCol;
            c(isinf(c)) = NaN;
            previousRow(isnan(c)) = NaN;
            previousCol(isnan(c)) = NaN;
            continue
        end

        % Main cost update
        validRows = find(~isnan(c(:, ii)));
        if isempty(validRows)
            endInd = ii;
            sw = 1;
            break
        end

        for jj = validRows'
            multiplier = max(abs((1:row) - jj)/2, 1);
            multiplier(multiplier > maxJump) = inf;
            costJump = multiplier .* m2(:, ii+1)';

            newCost = c(jj, ii) + costJump;
            better = newCost' < c(:, ii+1) | isnan(c(:, ii+1));

            if any(better)
                c(better, ii+1) = newCost(better');
                previousRow(better, ii+1) = jj;
                previousCol(better, ii+1) = ii;
            end
        end

        % Threshold to remove high-cost paths
        valid = c(:, ii+1);
        valid(valid > min(valid,[],'omitnan') + 10) = NaN;
        c(:, ii+1) = valid;
    end

    if sw == 0
        endInd = col;
    end

    % Path reconstruction
    [~, endRow] = min(c(:, endInd));
    pathRow = NaN(1, col);
    pathRow(endInd) = endRow;
    for h = endInd-1:-1:startCol
        if ~isnan(pathRow(h+1))
            pathRow(h) = previousRow(pathRow(h+1), h+1);
        end
    end
    pathRow(startCol) = startRow;

    pathCol = 1:col;
    validPath = ~isnan(pathRow);
    pathRow = pathRow(validPath);
    pathCol = pathCol(validPath);

    % Add reconstructed path to the backward density matrix
    idx = sub2ind(size(p2), pathRow, pathCol);
    idx(isnan(c(idx))|isinf(c(idx))) = [];
    p2(idx) = p2(idx) + 1;
end

% Combine forward and backward tracking results
p = p + fliplr(p2);

% Save output
MLH.aerosolLayerTrackingDensity = p;

end
