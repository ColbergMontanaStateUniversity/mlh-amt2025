% This script loads Halo Doppler lidar NetCDF files, 
% converts time to local, processes the data, saves variables as .mat files, 
% and generates figures of vertical velocity (w_median).

clear all; close all;

%% 0. Pre-code: Set up paths and folder structure

% Define base path
Path.home = pwd;

% Define the main folders to look in (can expand later if needed)
mainFolders = {'202309'};

% Initialize a cell array to store all subfolder paths
allSubfolderPaths = {};


% Loop through each main folder
for i = 1:length(mainFolders)
    mainDir = mainFolders{i};
    items = dir(mainDir);  % Get directory contents
    
    % Identify only subfolders (exclude '.' and '..')
    isFolder = [items.isdir];
    folderNames = {items(isFolder).name};
    subfolders = folderNames(~ismember(folderNames, {'.', '..'}));
    
    % Get full paths to each subfolder
    for j = 1:length(subfolders)
        subfolderPath = fullfile(mainDir, subfolders{j});
        allSubfolderPaths{end+1} = subfolderPath;
    end
end


Path.subfolders = allSubfolderPaths;

% Clean up temporary variables
clear folderNames isFolder items mainDir mainFolders subfolderPath allSubfolderPaths subfolders i j

%% 1. Loop through each subfolder (one day per subfolder)

for i = 1:length(Path.subfolders)
    
    %% Load the Halo lidar data for two consecutive days
    [HaloData1] = load_halo_netCDF(Path, Path.subfolders(i));     % Current day
    [HaloData2] = load_halo_netCDF(Path, Path.subfolders(i+1));   % Next day

    % If either file is missing, skip to the next iteration
    if isempty(HaloData1) || isempty(HaloData2)
        continue
    end

    % Concatenate the two days into one dataset
    [HaloData] = concatenate_halo_data(HaloData1, HaloData2);
    clear HaloData1 HaloData2

    % Trim the concatenated dataset to the desired time window
    [HaloData] = trim_halo_data(HaloData);

    %% Create Figures
    figure(1)
    set(gcf, 'Position', [100, 100, 1600, 600]); % Set figure size

    % Load colormap
    cd('..')
    cd('Colormaps')
    cmap1 = crameri('vik');  % Use perceptually uniform 'vik' colormap
    cd(Path.home)

    % Plot vertical velocity
    h = imagesc(HaloData.time, HaloData.range, HaloData.meanW);
    set(gca, 'ydir', 'normal')  % Set y-axis to normal orientation (low to high)
    colorbar
    alphaData = ~isnan(HaloData.meanW);  % Mask NaN values
    set(h, 'AlphaData', alphaData);
    colormap(cmap1)
    xlabel('Time (Local)')
    ylabel('Range (m)')
    ylim([0 5000])
    clim([-5 5])  % Set color limits
    xlim([0 24])  % 0-24 local time
    title('Vertical Winds (m/s)')

    %% Save Processed Data

    % Move to the save directory
    cd(Path.Save_Data)

    % Generate a clean filename from the subfolder name
    temp = allSubfolderPaths{i};
    temp = temp(8:end);  % Trim first 7 characters (adjust depending on structure)

    % Save processed Halo data
    save(temp, 'HaloData');

    cd(Path.home)

   

    % Clean up variables to avoid memory issues
    clear HaloData cmap1 temp filename
    close(figure(1))  % Close the figure
end
