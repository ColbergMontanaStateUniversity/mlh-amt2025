% This script retrieves the MLH DWL data using the vertical velocity
% variance method and iterative thresholding based on flux estimates. 

clear all; close all;

%% Pre-code

% ---------------------------
% Define paths to the datasets
% ---------------------------
Path.home     = pwd;
Path.haloData = strcat(pwd,'\DWL_Data');     % Halo Doppler lidar data
Path.fluxData = strcat(pwd,'\ISFS_Data');    % Flux tower data

% ---------------------------
% Create directories of filenames
% ---------------------------
cd(Path.haloData)
Directory = dir("*_DWL_variance.mat");
cd(Path.home)

% ---------------------------
% Read sunrise and sunset table
% ---------------------------
T = readtable('SunriseSunsetTable.csv');

% ---------------------------
% Main loop over each day
% ---------------------------
for i = 1:length(Directory)
    
    %% Load data
    % Load flux tower data
    cd(Path.fluxData)
    load(strcat(Directory(i).name(1:8),'_flux_tower_data.mat'));
    cd(Path.home)

    % Load DWL data
    cd(Path.haloData)
    load(Directory(i).name)
    load(strcat(Directory(i).name(1:8),'_DWL_masks_and_clouds.mat'));
    load(strcat(Directory(i).name(1:8),'_processed_data.mat'));
    cd(Path.home)
    
    %% Convert sunrise/sunset to lidar timebase
    [Sunrise] = convert_sunrise_sunset(T, HaloData, Directory(i).name(1:8));
    
    %% Find periods with positive surface buoyancy flux
    [FluxData] = find_positive_flux(FluxData, HaloData);

    %% Initial MLH estimate
    MLH = [];
    [MLH] = diagnose_mlh_vertical_velocity_variance(HaloData, TemporalVariance, CloudData, Sunrise, FluxData, 0, MLH);

    %% Iterative MLH refinement based on dynamic threshold
    change = 1;
    iter = 1;

    while change == 1 && iter <= 5
        [MLHNew] = diagnose_mlh_vertical_velocity_variance(HaloData, TemporalVariance, CloudData, Sunrise, FluxData, 1, MLH);

        try
            % Check if MLH changed
            if sum(MLH.mlhWVar(~isnan(MLH.mlhWVar)) ~= MLHNew.mlhWVar(~isnan(MLHNew.mlhWVar))) == 0
                change = 0;
            end
        catch
            % If arrays don't match size, continue iterating
        end

        MLH = MLHNew;
        iter = iter + 1;
    end

    %% Create figure
    figure(1)
    set(gcf, 'Position', [100, 100, 1600, 600]);
    set(gcf, 'Renderer', 'opengl');
    
    % Load colormap
    cd('..')
    cd('Colormaps')
    cmap1 = flipud(crameri('davos'));
    cd(Path.home)

    % Plot vertical velocity variance
    h = imagesc(TemporalVariance.time, TemporalVariance.range, TemporalVariance.varianceMasked);
    set(gca, 'ydir', 'normal')
    colorbar
    alphaData = ~isnan(TemporalVariance.varianceMasked); % Transparency where data exists
    set(h, 'AlphaData', alphaData);
    colormap(cmap1)
    clim([0 1])
    ylim([0 5000])
    ylabel('Range (m)')
    xlim([0 24])
    xlabel('Time (Local)')
    set(gca, 'FontSize', 18)
    title('$\sigma_{w}^2$ ($\frac{m^2}{s^2}$)', 'Interpreter', 'latex', 'FontSize', 24)
    
    hold on
    % Plot cloud base, raw MLH, and smoothed MLH
    p(1) = plot(MLH.time, CloudData.cloudBaseHeight, 'ks', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'MarkerSize', 10);
    p(2) = plot(MLH.time, MLH.mlhWVar, 'ko', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k', 'MarkerSize', 12);
    p(3) = xline(Sunrise.sunriseTime, '--k', 'linewidth', 1.5);
    p(4) = xline(Sunrise.sunsetTime, '--k', 'linewidth', 1.5);
    p(5) = plot(MLH.time, MLH.mlhWVarSmooth, 'ko', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'k', 'MarkerSize', 7);
    
    legend([p(1) p(2) p(5)], 'Cloud Base', 'Vertical Velocity Variance MLH', 'Smoothed Vertical Velocity Variance MLH', 'location', 'northwest')

    %% Save MLH output
    cd(Path.haloData)

    filename = strcat(Directory(i).name(1:8), '_MLH.mat');
    save(filename, 'MLH');
 
    cd(Path.home)
    
    %% Close figure and clean workspace for next day
    close(figure(1))
    disp(i)

    clear alphaData change CloudData cmap1 filename FluxData h HaloData iter Mask MLH MLHNew p Sunrise TemporalVariance
end