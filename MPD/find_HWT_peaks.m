function [MLH] = find_HWT_peaks(MLH, HWT, CloudData)
% find_HWT_peaks - Find peaks in Haar wavelet transformation profile
%
% Inputs:
%   HWT       - Structure containing the Haar wavelet transformation field
%   CloudData - Structure containing cloud base indices
%
% Outputs:
%   MLH       - Updated structure with fields:
%                 - weight: scaled Haar wavelet transformation
%                 - peaksHWT: [height_bin, time_step] for each detected peak

% Scale Haar wavelet transformation to create weights
MLH.weight = HWT.haarWaveletTransformation * 10;

% Preallocate a cell array to store peaks for each time step
peaksHWTCell = cell(1, length(HWT.time));

% Loop over each time step
for i = 1:length(HWT.time)
    temp = MLH.weight(:,i);

    % Find peaks in the current profile
    [pks, locs] = findpeaks(temp);

    % Keep only peaks with height >= 0.5
    valid = pks >= 0.5;
    locs = locs(valid);

    % Store valid peaks if any found
    if ~isempty(locs)
        peaksHWTCell{i} = [locs, i*ones(size(locs))];
    end
end

% Concatenate all peaks into a single array
peaksHWT = vertcat(peaksHWTCell{:});

% Remove peaks that are above the cloud base
if ~isempty(peaksHWT)
    cloudIndices = CloudData.cloudBaseIndex;

    % Logical array: true if peak is above cloud base
    aboveCloud = arrayfun(@(row) ...
        ~isnan(cloudIndices(peaksHWT(row,2))) && ...
         peaksHWT(row,1) >= cloudIndices(peaksHWT(row,2)), ...
         1:size(peaksHWT,1));

    % Keep only peaks below cloud base
    peaksHWT = peaksHWT(~aboveCloud,:);
end

% Store peaks into output structure
MLH.peaksHWT = peaksHWT;

end