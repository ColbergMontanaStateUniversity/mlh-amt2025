% This script locates clouds in Halo Doppler wind lidar (DWL) data
% It creates masks for clouds, precipitation, and missing data,
% finds the cloud base height, and saves daily results.

clear all; close all;

%% Pre-code Setup
% Define file paths
Path.home                   = pwd;
Path.haloData               = strcat(pwd,'\DWL_Data');               % Path to Halo data
Path.surfacemeteorologyData = strcat(pwd,'\ISS_Data');               % Path to surface meteorology data

% Create a directory listing of processed Halo files
cd(Path.haloData)
Directory = dir("*_processed_data.mat");
cd(Path.home)

% Loop over each day's data
for i = 1:length(Directory)

    %% Load Data
    % Load Halo DWL data
    cd(Path.haloData)
    load(Directory(i).name)
    cd(Path.home)

    % Load surface meteorology data for corresponding day
    cd(Path.surfacemeteorologyData)
    load(strcat(Directory(i).name(1:8),'_surface_meteorology_data.mat'))
    cd(Path.home)

    %% Find Clouds and Create Masks
    % Apply spatiotemporal variance operator to backscatter ratio
    [CloudData] = find_variance_5x5(HaloData);
    
    % Create initial cloud mask based on variance
    [Mask, CloudData] = create_cloud_mask(CloudData, HaloData);

    % Create precipitation mask using rain gauge data and DWL vertical velocity
    [Mask] = create_precipitation_mask(Mask, HaloData, SurfaceMeteorologyData);

    % Create missing data mask based on backscatter gaps
    [Mask] = create_missing_data_mask(Mask, HaloData);

    % Combine all masks into a final mask
    Mask.combinedMask = (Mask.cloudMask + Mask.precipitationMask + Mask.missingDataMask) > 0;

    % Find cloud base height using lowest detected cloud per profile
    [CloudData] = find_cloud_bottom(CloudData, HaloData);

    % Save Halo time and range into CloudData structure
    CloudData.time  = HaloData.time;
    CloudData.range = HaloData.range;

    %% Plot Results
    figure(1)
    set(gcf, 'Position', [100, 100, 1600, 600]);

    % Load colormap
    cd('..')
    cd('Colormaps')
    cmap1 = crameri('batlow');
    cd(Path.home)

    % Fill missing values in backscatter for plotting
    tmp = fillmissing(HaloData.attenuatedBackscatter, 'nearest', 1);
    tmp = fillmissing(tmp, 'nearest', 2);

    % Create the plot
    imagesc(HaloData.time, HaloData.range, tmp);
    set(gca, 'YDir', 'normal');
    colorbar;
    colormap(cmap1);
    clim([0 0.05]);
    hold on;

    % Plot the retrieved cloud base heights
    p(1) = plot(HaloData.time, CloudData.cloudBaseHeight, 's', ...
                'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');

    xlabel('Time (Local)');
    ylabel('Range (m)');
    title('Backscatter and Cloud Base');
    legend(p(1), 'Cloud Base');
    xlim([0 24]);
    ylim([0 5000]);
    set(gca, 'FontSize', 16);

    %% Save Results
    cd('DWL_Data')
    filename = strcat(Directory(i).name(1:8), '_DWL_masks_and_clouds.mat');
    save(filename, 'CloudData', 'Mask');
    cd(Path.home)

    % Clean up
    close(figure(1))
    clear HaloData cmap1 CloudData tmp filename SurfaceMeteorologyData p Mask
    disp(i)

end