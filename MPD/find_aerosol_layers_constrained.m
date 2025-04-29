function [MLH] = find_aerosol_layers_constrained(MLH, CloudData, Sunrise, HWT)
% find_aerosol_layers_constrained - Track aerosol layers forward and backward through time.

% Inputs:
%   MLH       - Structure containing cost matrix, candidate points, and Haar wavelet transformation
%   CloudData - Structure with cloud base height information
%   Sunrise   - Structure with sunrise and sunset indices
%   HWT       - Haar wavelet transformation data

% Outputs:
%   MLH       - Updated structure including aerosol layer tracking density and mlhPoints

%% Forward tracking: find likely aerosol layer paths moving forward in time
p = zeros(size(MLH.cost)); % Initialize forward path density matrix

startPoints = MLH.mlhCandidatePoints; % Starting points for tracking
m = MLH.cost;
m(isnan(m)) = inf; % Mark invalid or negative cost values
m(m < 0) = inf;

maxJump = 4; % Maximum allowed vertical jump (in bins)

% Favor tracking near cloud base heights
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

% Set cost to infinity outside sunrise-sunset window
outsideSun = (1:length(MLH.time))' < Sunrise.sunriseInd | (1:length(MLH.time))' > Sunrise.sunsetInd;
m(:, outsideSun) = inf;

% Set cost above the top limiter to infinity
validTop = find(~isnan(MLH.topLimiter));
for i = validTop(:)'
    m(MLH.topLimiter(i):end, i) = inf;
end

% Set low-altitude (near-ground) values to infinity
m(1:2,:) = inf;

[row, col] = size(m);

% Loop through each candidate starting point
for i = 1:size(startPoints,1)
    sw = 0; % Switch for early termination
    startRow = startPoints(i,1);
    startCol = startPoints(i,2);

    % Initialize cost matrix for this track
    c = NaN(row, col);
    c(startRow, startCol) = m(startRow, startCol);

    previousRow = NaN(row, col);
    previousCol = NaN(row, col);

    for ii = startCol:col-1
        if ii == col
            continue
        end

        % Handle first step separately
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

        % Main tracking loop
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

        % Remove high cost paths
        valid = c(:, ii+1);
        valid(valid > min(valid,[],'omitnan') + 10) = NaN;
        c(:, ii+1) = valid;
    end

    if sw == 0
        endInd = col;
    end

    % Reconstruct the path from end to start
    [~, endRow] = min(c(:, endInd));
    pathRow = NaN(1, col);
    pathRow(endInd) = endRow;
    for h = endInd-1:-1:startCol
        if ~isnan(pathRow(h+1))
            pathRow(h) = previousRow(pathRow(h+1), h+1);
        end
    end
    pathRow(startCol) = startRow;

    % Save only valid points
    pathCol = 1:col;
    validPath = ~isnan(pathRow);
    pathRow = pathRow(validPath);
    pathCol = pathCol(validPath);

    idx = sub2ind(size(p), pathRow, pathCol);
    idx(isnan(c(idx)) | isinf(c(idx))) = [];
    p(idx) = p(idx) + 1;
end

%% Backward tracking (tracking reversed in time)
p2 = zeros(size(MLH.cost));

% Reverse starting points and matrix
startPoints2 = flipud(startPoints);
log = zeros(size(startPoints2,1),1);
for iii = 1:col
    ind = (startPoints2(:,2) == iii);
    startPoints2(ind & ~log,2) = col+1-iii;
    log(ind & ~log) = 1;
end
clear log ind

m2 = fliplr(m);
m2(isnan(m2)) = inf;
m2(m2<0) = inf;

% favor tracking near cloud base height
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

% Loop over reversed candidate points
for i = 1:size(startPoints2,1)
    sw = 0;
    startRow = startPoints2(i,1);
    startCol = startPoints2(i,2);

    c = NaN(row, col);
    c(startRow, startCol) = m2(startRow, startCol);

    previousRow = NaN(row, col);
    previousCol = NaN(row, col);

    for ii = startCol:col-1
        if ii == col
            continue
        end

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

        valid = c(:, ii+1);
        valid(valid > min(valid,[],'omitnan') + 10) = NaN;
        c(:, ii+1) = valid;
    end

    if sw == 0
        endInd = col;
    end

    % Reconstruct backward path
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

    idx = sub2ind(size(p2), pathRow, pathCol);
    idx(isnan(c(idx)) | isinf(c(idx))) = [];
    p2(idx) = p2(idx) + 1;
end

% Combine forward and backward paths
p = p + fliplr(p2);

MLH.aerosolLayerConstrainedTrackingDensity = p;

%% Find MLH Points
MLH.mlhPoints = [];

for i = Sunrise.sunriseInd:Sunrise.sunsetInd
    if isnan(MLH.topLimiter(i))
        continue
    end

    tmpHWT = HWT.haarWaveletTransformation(1:MLH.topLimiter(i), i);
    tmpDensity = MLH.aerosolLayerConstrainedTrackingDensity(1:MLH.topLimiter(i), i);

    if sum(~isnan(tmpHWT)) == 0 || sum(tmpDensity(~isnan(tmpDensity))) == 0
        continue
    end

    temp = find((tmpDensity >= 3) & (tmpHWT > max(tmpHWT)/2 | tmpHWT > 0.08) & tmpHWT > 0.04, 1, 'first');

    if ~isempty(temp)
        MLH.mlhPoints = [MLH.mlhPoints; [temp, i]];
    end
end

%% Remove isolated or invalid points
toDelete = [];
for i = 1:length(MLH.mlhPoints(:,1))
    if (i == 1 || i == length(MLH.mlhPoints(:,1)))
        neighbor = abs(MLH.mlhPoints(min(i+1, end),1) - MLH.mlhPoints(max(i-1,1),1));
        if neighbor > 5
            toDelete = [toDelete; i];
        end
    else
        if (MLH.mlhPoints(i-1,2)+1 ~= MLH.mlhPoints(i,2)) && (MLH.mlhPoints(i,2)+1 ~= MLH.mlhPoints(i+1,2))
            toDelete = [toDelete; i];
        end
    end
end

% Remove points
MLH.mlhPoints(toDelete,:) = [];

% Remove points above cloud base
toDelete = zeros(size(MLH.mlhPoints(:,1)));
for ii = 1:length(MLH.mlhPoints)
    if ~isnan(CloudData.cloudBaseIndex(MLH.mlhPoints(ii,2))) && MLH.mlhPoints(ii,1) >= CloudData.cloudBaseIndex(MLH.mlhPoints(ii,2))
        toDelete(ii) = 1;
    end
end
MLH.mlhPoints = MLH.mlhPoints(~toDelete,:);

% Remove very low points
MLH.mlhPoints = MLH.mlhPoints(MLH.mlhPoints(:,1) >= 5,:);

%% Gap fill by interpolation
points = MLH.mlhPoints;
y = points(:,1);
x = points(:,2);
xFull = min(x):max(x);
yInterp = interp1(x, y, xFull, 'linear');
MLH.mlhPoints = [yInterp(:), xFull(:)];

end