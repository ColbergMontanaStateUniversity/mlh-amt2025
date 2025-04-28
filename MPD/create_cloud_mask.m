function [CloudData] = create_cloud_mask(CloudData,MPDUnfiltered)
% This function creates the cloud mask

% Three conditions need to be satisified to locate a cloud:
% 1) the variance of the 5x5 grid of cells surrounding the cell of interest
% must have a variance greater than 10
% 2) the backscatter ratio of the cell must be greater than 10


%create logical operators
condition1 = CloudData.variance > 100;
condition2 = MPDUnfiltered.backscatterRatio > 10;

cloudLocation = condition1 & condition2;
[seedY, seedX] = find(cloudLocation);

g = CloudData.sobelOperator;

CloudData.Mask = flood_fill(g, seedX, seedY, 10);

rMaxInd = find( MPDUnfiltered.range>6000,1,'first');
rMinInd = find( MPDUnfiltered.range<400,1,'last');

CloudData.Mask(rMaxInd:end,:) = 0;
CloudData.Mask(1:rMinInd,:) = 0;

end

function [mask] = flood_fill(g, seedX, seedY, threshold)
    % G: data matrix (double)
    % seed_x, seed_y: vectors of seed points (column and row indices)
    % threshold: value for region growing condition (e.g., G <= threshold)

    [rows, cols] = size(g);
    mask = false(rows, cols);        % Region mask
    visited = false(rows, cols);     % Track visited pixels

    % Initialize queue with all seed points
    queue = [seedY(:), seedX(:)];  % Ensure column vectors (row, col)

    % 4-connectivity directions: [row_offset, col_offset]
    directions = [0 1; 0 -1; 1 0; -1 0];

    while ~isempty(queue)
        % Pop the first point
        current = queue(1, :);
        queue(1, :) = [];  % Dequeue

        r = current(1);
        c = current(2);

        % Skip if out of bounds or already visited
        if r < 1 || r > rows || c < 1 || c > cols || visited(r, c)
            continue;
        end

        visited(r, c) = true;

        % Check threshold condition
        if g(r, c) >= threshold
            mask(r, c) = true;

            % Enqueue all valid neighbors
            for k = 1:size(directions, 1)
                rNew = r + directions(k, 1);
                cNew = c + directions(k, 2);
                if rNew >= 1 && rNew <= rows && cNew >= 1 && cNew <= cols && ~visited(rNew, cNew)
                    queue = [queue; rNew, cNew];
                end
            end
        end
    end
end