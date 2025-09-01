% This code loads data from the MPD netCDF files, converts the time to local time,
% saves useful variables as .mat files, and creates figures
% of the aerosol backscatter coefficient and the surface virtual potential
% temperature minus the atmospheric virtual potential temperature.

clear all; close all;

%% Pre-code: Set up paths and file directory
Path.home = pwd;                                  % Save current working directory
Path.data = strcat(pwd,'\MPD_Data_Denoised');      % Define path to denoised MPD data

% Create a directory list of all MPD netCDF files
cd(Path.data)
Directory = dir("mpd03*.nc");                     % Find all files matching 'mpd03*.nc'
cd(Path.home)

%% For loop to process each day of data
for i = 1:length(Directory)-1

    %% Load two consecutive days of MPD data
    [MPDDenoised1] = load_mpd_data_denoised(Path, Directory(i).name);
    [MPDDenoised2] = load_mpd_data_denoised(Path, Directory(i+1).name);

    % Concatenate two days and trim to 0–24 hr window
    [MPDDenoised] = concatenate_mpd_data_denoised(MPDDenoised1, MPDDenoised2);
    [MPDDenoised] = trim_mpd_data_denoised(MPDDenoised);
    clear MPDDenoised1 MPDDenoised2

    %% Calculate potential temperature and virtual potential temperature
    [MPDDenoised] = find_potential_temperature(MPDDenoised);

    %% Create figures
    % -------------------------------
    % Figure 1: Aerosol Backscatter Coefficient
    % -------------------------------
    figure(1)
    set(gcf, 'Position', [100, 100, 1600, 600]);    % Set figure size

    % Load color map
    cd('..')
    cd('Colormaps')
    cmap1 = crameri('batlow');
    cd(Path.home)

    % Plot aerosol backscatter coefficient
    tmp = MPDDenoised.aerosolBackscatterCoefficient;
    h = imagesc(MPDDenoised.time, MPDDenoised.range, tmp);
    set(gca, 'ydir', 'normal')
    alphaData = ~isnan(tmp);                        % Make NaN areas transparent
    set(h, 'AlphaData', alphaData)
    colormap(cmap1)
    xlabel('Time (Local)')
    ylabel('Range (m)')
    ylim([0 5000])
    xlim([0 24])
    colorbar
    clim([0 5e-7])
    title('Aerosol Backscatter Coefficient (m^{-1} sr^{-1})')

    % -------------------------------
    % Figure 2: Surface - Atmosphere Virtual Potential Temperature Difference
    % -------------------------------
    figure(2)
    set(gcf, 'Position', [100, 100, 1600, 600]);

    % Load color map
    cd('..')
    cd('Colormaps')
    cmap2 = crameri('bam');
    cd(Path.home)

    % Plot virtual potential temperature difference
    h = imagesc(MPDDenoised.time, MPDDenoised.range, MPDDenoised.thetaVDiff);
    set(gca, 'ydir', 'normal')
    alphaData = ~isnan(MPDDenoised.thetaVDiff);     % Make NaN areas transparent
    set(h, 'AlphaData', alphaData)
    cmap2 = [0, 0, 0; cmap2];                       % Add black for missing values
    colormap(cmap2)
    xlabel('Time (Local)')
    ylabel('Range (m)')
    ylim([0 5000])
    xlim([0 24])
    colorbar
    clim([-3 3])
    title('Potential Temperature Difference (Surface - Atmosphere) (K)')

    %% Save processed MPD data as .mat file
    cd(Path.data)
    filename = strcat([Directory(i).name(7:14), '_MPD_denoised.mat']);
    save(filename, 'MPDDenoised');
    cd(Path.home)

    %% Clean up variables and close figures for next iteration
    clear MPDDenoised cmap1 cmap2 temp
    close(figure(1))
    close(figure(2))

    disp(i)   % Display iteration number

end
