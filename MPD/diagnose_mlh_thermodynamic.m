% This script retrieves the PBLH from the MPD data using the Parcel Method
% and the Bulk Richardson Method.

clear all; close all;

%% Setup

% Create directory paths
Path.home       = pwd;
Path.dataMPD    = strcat(pwd, '\MPD_Data_Denoised');
Path.dataClouds = strcat(pwd, '\MPD_Data_Unfiltered');

% Create a list of all MPD denoised data files
cd(Path.dataMPD)
Directory = dir("*_MPD_Denoised.mat");
cd(Path.home)

% Read sunrise and sunset times table
T = readtable('SunriseSunsetTable.csv');

%% Loop over each MPD file
for i = 1:length(Directory)
    
    %% Load Data
    cd(Path.dataMPD)
    load(Directory(i).name) % Load MPDDenoised
    load(strcat(Directory(i).name(1:8), '_MPD_Denoised.mat')) % Redundant but kept (maybe historical reason)
    cd(Path.dataClouds)
    load(strcat(Directory(i).name(1:8), '_Cloud_Data.mat'))
    cd(Path.home)
    
    %% Process Data: Find PBLH
    
    % Convert sunrise/sunset times into time indices
    [Sunrise] = convert_sunrise_sunset(T, MPDDenoised, Directory(i).name(1:8));

    % Find PBLH using Parcel Method (1 K offset)
    offset = 1;
    [MLH] = find_mlh_parcel(MPDDenoised, CloudData, Sunrise, offset); 

    %% Plot Results

    figure(1)
    set(gcf, 'Position', [100, 100, 1600, 600]);

    % Load colormap
    cd('..')
    cd('Colormaps')
    cmap2 = crameri('bam');
    cd(Path.home)

    % Plot thetaV difference
    tmp = MPDDenoised.thetaVDiff;
    imagesc(MPDDenoised.time, MPDDenoised.range, tmp, 'AlphaData', ~isnan(tmp));
    set(gca, 'ydir', 'normal')
    colormap(cmap2)
    hold on

    % Plot cloud base height
    p(1) = plot(CloudData.time, CloudData.cloudBaseHeight, 'kv', ...
                'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'MarkerSize', 10);

    % Plot Parcel Method MLH
    p(2) = plot(MLH.time, MLH.mlhParcelMethod, 'ks', ...
                'MarkerFaceColor', '#FF5722', 'MarkerEdgeColor', 'k', 'MarkerSize', 12);

    % Add legend
    legend([p(1) p(2)], 'Cloud Base', ...
        ['Parcel Method MLH (offset = ', num2str(offset), 'K)'], ...
        'location', 'northwest');

    % Add labels and limits
    xlabel('Time (Local)')
    ylabel('Range (m)')
    ylim([0 6000])
    xlim([0 24])
    colorbar
    clim([-3 3])
    title('Virtual Potential Temperature (Surface - Atmosphere) (K)')
    drawnow

    %% Save Results
    cd(Path.dataMPD)
    filename = strcat([Directory(i).name(1:8), '_MLH_Thermodynamic.mat']);
    save(filename, 'CloudData', 'MPDDenoised', 'MLH', 'Sunrise');
    cd(Path.home)

    %% Clean Up
    close all
    clear CloudData cmap2 filename MLH MPDDenoised Sunrise tmp p offset
    disp(i)
end