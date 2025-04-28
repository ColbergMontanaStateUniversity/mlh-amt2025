% This script determines the PBLH from the HSRL data
clear all; close all;

%% Pre-code: Setup paths and directories

% Create paths
Path.home       = pwd;
Path.dataMPD    = strcat(pwd, '\MPD_Data_Denoised');
Path.dataClouds = strcat(pwd, '\MPD_Data_Unfiltered');

% Move up one directory and get HRRR processed data path
cd('..')
cd('HRRR\Processed_HRRR_Data')
Path.dataHRRR   = pwd;
cd(Path.home)

% Create a directory list of all MPD Denoised files
cd(Path.dataMPD)
Directory = dir("*_MPD_Denoised.mat");
cd(Path.home)

% Read sunrise and sunset times table
T = readtable('SunriseSunsetTable.csv');

%% Main loop: process each MPDDenoised dataset
for i = 1:length(Directory)
    
    %% Load necessary data
    cd(Path.dataMPD)
    load(Directory(i).name)
    load(strcat(Directory(i).name(1:8), '_MPD_HWT.mat'))
    cd(Path.dataClouds)
    load(strcat(Directory(i).name(1:8), '_Cloud_Data.mat'))
    cd(Path.dataHRRR)
    load(strcat(Directory(i).name(1:8), '.mat'))
    cd(Path.home)

    %% Process each file: determine PBLH
    % Convert sunrise/sunset times to indices
    [Sunrise] = convert_sunrise_sunset(T, MPDDenoised, Directory(i).name(1:8));

    % Transfer time and range vectors from MPD to MLH structure
    MLH.time      = MPDDenoised.time;
    MLH.rangeMPD  = MPDDenoised.range;
    MLH.rangeHWT  = HWT.rangeHaarWaveletTransformation;

    % --- Layer Tracking Steps ---
    % 1. Find HWT peaks
    [MLH] = find_HWT_peaks(MLH, HWT, CloudData);

    % 2. Find all aerosol layers by tracking peaks
    [MLH] = find_all_aerosol_layers(MLH, CloudData);
    MLH.aerosolLayerTrackingDensity(1:2,:) = NaN; % Remove near-surface noise

    % 3. Set Top Limiter using HRRR PBLH
    [MLH] = set_top_limiter(MLH, HWT, Sunrise, HRRRData);

    % 4. Find first set of MLH candidate points
    [MLH] = find_mlh_candidate_points(MLH, HWT, Sunrise);

    % 5. If candidates found, do constrained tracking
    if isempty(MLH.mlhCandidatePoints)
        % If no candidates, initialize empty outputs
        PBLH_denisty = [];
        PBLH_Index = [];
        PBLH_Range = [];
    else
        % 5a. Constrained tracking based on cloud data and wavelet
        [MLH] = find_aerosol_layers_constrained(MLH, CloudData, Sunrise, HWT);

        % 5b. Find nearest HWT peak to each constrained layer
        [MLH] = find_nearest_peak_constrained(MLH, HWT);

        % 5c. Remove points that are below or too close to clouds
        [MLH] = remove_points_below_clouds(MLH, HWT, CloudData);

        % 5d. Remove isolated single points
        [MLH] = remove_single_points(MLH, HWT);
    end

    %% Create Figures

    % Create figure window
    figure(1);
    set(gcf, 'Position', [100, 100, 1600, 600]);

    % Load colormap
    cd('..')
    cd('Colormaps')
    cmap1 = crameri('roma');
    cd(Path.home)

    % Plot HWT data
    dataForPlot = HWT.haarWaveletTransformation;
    h = imagesc(HWT.time, HWT.rangeHaarWaveletTransformation, dataForPlot, 'AlphaData', ~isnan(dataForPlot));
    set(gca, 'ydir', 'normal')
    colorbar
    alphaData = ~isnan(HWT.haarWaveletTransformation);
    set(h, 'AlphaData', alphaData);
    colormap(flipud(cmap1))
    clim([-.1 .1])
    ylim([0 6000])
    ylabel('Range (m)')
    xlim([0 24])
    xlabel('Time (Local)')
    title('H($\beta_{aer}$) (unitless)', 'interpreter', 'latex', 'FontSize', 18)

    hold on

    % Plot cloud base, top limiter, and MLH points
    p(1) = plot(MLH.time, CloudData.cloudBaseHeight, 'ks', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k', 'MarkerSize', 10);
    p(2) = plot(MLH.time(~isnan(MLH.topLimiter)), HWT.rangeHaarWaveletTransformation(MLH.topLimiter(~isnan(MLH.topLimiter))), 'ko', 'MarkerFaceColor', '[0 1 1]', 'MarkerEdgeColor', 'k', 'MarkerSize', 10);
    try
        p(3) = plot(MLH.time, MLH.mlh, 'k^', 'MarkerFaceColor', '[1 0 1]', 'MarkerEdgeColor', 'k', 'MarkerSize', 12);
    catch
        % If no MLH points found
        p(3) = plot([0 24], [10000 10000], 'k^', 'MarkerFaceColor', '[1 0 1]', 'MarkerEdgeColor', 'k', 'MarkerSize', 12);
    end

    % Plot sunrise and sunset times
    p(4) = xline(Sunrise.sunriseTime, '--w');
    p(5) = xline(Sunrise.sunsetTime, '--w');

    legend([p(1) p(3) p(2)], 'Cloud Bottom', 'Aerosol PBLH', 'Top Limiter', 'location', 'Northwest')

    %% Save Data
    filename = strcat(Directory(i).name(1:8), '_MLH_Aerosol.mat');
    cd(Path.dataMPD)
    save(filename, 'CloudData', 'HWT', 'MPDDenoised', 'MLH', 'Sunrise')
    cd(Path.home)

    disp(i) % Display progress

    %% Clean up for next iteration
    close(figure(1))
    clear alphaData CloudData cmap1 dataForPlot filename h HRRRData HWT MPDDenoised MLH Sunrise

end