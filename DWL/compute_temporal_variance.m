% This function loads the Halo DWL data and applies the autocovariance
% extrapolation to zero-lag to extract temporal variance

clear all; close all;

%% Define file paths
Path.home         = pwd;
Path.haloData     = strcat(pwd,'\DWL_Data');

%% Create a directory of processed Halo DWL data files
cd(Path.haloData)
Directory = dir("*_processed_data.mat");
cd(Path.home)

%% Loop over each day's file
for i = 1:length(Directory)

    %% Load the Halo DWL data
    cd(Path.haloData)
    load(Directory(i).name)

    % Load the corresponding cloud and mask file
    filename = strcat([Directory(i).name(1:8),'_DWL_masks_and_clouds.mat']);
    load(filename)
    clear filename

    cd(Path.home)

    %% Apply the zero-lag autocovariance extrapolation to the vertical wind data
    [TemporalVariance] = compute_autocovariance_extrapolation(HaloData,Mask);

    %% Create figure of variance
    figure(1);
    set(gcf, 'Position', [100, 100, 1600, 600]);

    % Load the colormap
    cd('..')
    cd('Colormaps')
    cmap1 = crameri('nuuk');
    cd(Path.home)

    % Plot the smoothed temporal variance
    h = imagesc(TemporalVariance.time, TemporalVariance.range, smoothdata(TemporalVariance.varianceMasked, 2, 'movmean', 30));
    set(gca, 'ydir', 'normal')
    colorbar

    % Set transparency for NaN regions
    alphaData = ~isnan(TemporalVariance.varianceMasked);
    set(h, 'AlphaData', alphaData);

    colormap(flipud(cmap1))
    clim([0 1])  % Set color limits
    ylim([0 6000]) % Set y-axis limits
    ylabel('Range (m)')
    xlim([0 24])   % Set x-axis limits (Local time)
    xlabel('Time (Local)')
    title('$\sigma_{w}^2$ ($\frac{m^2}{s^2}$)', 'Interpreter', 'latex', 'FontSize', 18)

    %% Save the computed TemporalVariance structure
    cd(Path.haloData)
    filename = strcat([Directory(i).name(1:8),'_DWL_variance.mat']);
    save(filename, 'TemporalVariance');
    cd(Path.home)

    % Close the figure
    close(figure(1))

    % Display progress
    disp(i)
end