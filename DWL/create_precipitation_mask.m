function [Mask] = create_precipitation_mask(Mask, HaloData, SurfaceMeteorologyData)
% CREATE_PRECIPITATION_MASK builds a precipitation mask by combining surface rain rates
% and vertical motion from a Halo Doppler lidar. The mask grows outward to connected areas 
% with strong downward motion, simulating precipitation regions.

% Inputs:
%   Mask                  - Structure containing previous masks
%   HaloData              - Structure with Halo wind lidar data
%   SurfaceMeteorologyData- Structure with surface rain gauge data

% Output:
%   Mask - Updated structure including the precipitation mask

%% 1. Smooth the rain rate time series
rrCS125Smooth = smoothdata(SurfaceMeteorologyData.precipitationIntensityCS125, 'movmean', 10, 'omitnan');
rrWS800Smooth = smoothdata(SurfaceMeteorologyData.precipitationIntensityWS800, 'movmean', 10, 'omitnan');

% Identify times where both sensors detect rain and at least one exceeds 0.05 mm/hr
precip = (rrCS125Smooth > 0) & (rrWS800Smooth > 0) & ...
         (rrCS125Smooth > 0.05 | rrWS800Smooth > 0.05);

%% 2. Interpolate precipitation times onto the Halo time grid
precip = interp1(SurfaceMeteorologyData.time, double(precip), HaloData.time, 'linear', 'extrap');
precip = precip > 0;  % Logical conversion

% Expand to match the Halo range-time grid
Mask.precipitationMask = repmat(precip, [length(HaloData.range), 1]);

%% 3. Smooth Halo vertical velocity field
wSmooth = smoothdata(HaloData.meanW, 1, 'movmean', 5);   % Smooth vertically (range)
wSmooth = smoothdata(wSmooth, 2, 'movmean', 60);         % Smooth horizontally (time)

%% 4. Initialize flood-fill algorithm
isPrecip = Mask.precipitationMask;        % Starting mask (logical matrix)
threshold = wSmooth < -1;                  % Downward motion threshold for precipitation

% Get seed points where rain is already detected
[seedRows, seedCols] = find(isPrecip);
queue = [seedRows, seedCols];

% Define 8-connected neighborhood offsets
neighborOffsets = [
    -1, -1;  -1,  0;  -1,  1;
     0, -1;           0,  1;
     1, -1;   1,  0;  1,  1];

% Get grid size
[nRows, nCols] = size(isPrecip);

%% 5. Perform region growing (flood fill)
head = 1;  % Initialize queue pointer
while head <= size(queue,1)
    r = queue(head,1);
    c = queue(head,2);
    head = head + 1;
    
    % Loop through all 8 neighbors
    for k = 1:8
        rr = r + neighborOffsets(k,1);
        cc = c + neighborOffsets(k,2);
        
        % Check bounds
        if rr >= 1 && rr <= nRows && cc >= 1 && cc <= nCols
            % If neighbor meets downward motion condition and is not already flagged
            if threshold(rr,cc) && ~isPrecip(rr,cc)
                isPrecip(rr,cc) = true;
                queue(end+1,:) = [rr,cc]; %#ok<AGROW> (small dynamic allocation penalty, acceptable here)
            end
        end
    end
end

%% 6. Save updated mask
Mask.precipitationMask = isPrecip;

end