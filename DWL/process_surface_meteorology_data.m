% This script processes 3-meter tower surface meteorology NetCDF data:
% - Loads and concatenates data across two consecutive files
% - Trims the data to a specified time window
% - Creates a quick plot of precipitation intensity
% - Saves the concatenated and trimmed data into .mat files

clear all; close all;

%% Pre-code: Setup paths and locate data
Path.home = pwd; % Current working directory
Path.data = strcat(pwd,'\ISS_Data'); % Path to folder containing NetCDF files

% Create a directory listing of all NetCDF files matching pattern
cd(Path.data)
Directory = dir("iss2_m2hats_sfcmet_3mtower_*.nc");
cd(Path.home)

%% Loop over the NetCDF files
for i = 1 : length(Directory)-1

    %% Load the 3-meter tower data from two consecutive days
    try
        [Data1] = load_surface_meteorology_data(Path, Directory(i).name);
        [Data2] = load_surface_meteorology_data(Path, Directory(i+1).name);
    catch
        continue
    end

    %% Concatenate and trim the tower data
    [SurfaceMeteorologyData] = concatenate_surface_meteorology_data(Data1, Data2);
    [SurfaceMeteorologyData] = trim_surface_meteorology_data(SurfaceMeteorologyData);

    clear Data1 Data2

    %% Create a quick figure of precipitation intensity
    figure(1)
    set(gcf, 'Position', [100, 100, 1600, 600]);

    % Plot CS125 rain rate (smoothed)
    p(1) = plot(SurfaceMeteorologyData.time, ...
        smoothdata(SurfaceMeteorologyData.precipitationIntensityCS125, 'movmean', 10), ...
        'k', 'linewidth', 1.5);
    hold on

    % Plot WS800 rain rate (smoothed)
    p(2) = plot(SurfaceMeteorologyData.time, ...
        smoothdata(SurfaceMeteorologyData.precipitationIntensityWS800, 'movmean', 10), ...
        '--b', 'linewidth', 1.5);

    % Set plot labels and limits
    xlabel('Time (hr)')
    ylabel('Rain Rate (mm/hr)')
    xlim([0 24])
    ylim([-1 max([SurfaceMeteorologyData.precipitationIntensityCS125; SurfaceMeteorologyData.precipitationIntensityWS800]) + 1])
    yline(0.05, ':r') % Light rain threshold
    legend([p(1) p(2)], 'CS125', 'WS800', 'location', 'best')

    %% Save the processed data
    cd('ISS_Data')
    tmp = Directory(i).name(28:35); % Extract the date from the filename
    save(strcat(tmp, '_surface_meteorology_data'), 'SurfaceMeteorologyData');
    cd(Path.home)

    %% Cleanup for next iteration
    close(figure(1))
    disp(i)
end