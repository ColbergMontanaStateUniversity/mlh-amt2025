% This function loads the denoised MPD data and applies a Haar wavelet
% covariance transformation to the normalized aerosol backscatter coefficient.
% It saves the HWT output and generates a plot for each day.

clear all; close all;

%% Pre-code: Define paths and file directories
Path.home        = pwd;                                  % Save current working directory
Path.mpdData     = strcat(pwd,'\MPD_Data_Denoised');      % Path to denoised MPD data
Path.cloudData   = strcat(pwd,'\MPD_Data_Unfiltered');    % Path to unfiltered MPD data

% Create a list of denoised MPD data files
cd(Path.mpdData)
Directory = dir("*_MPD_Denoised.mat");
cd(Path.home)

%% Main loop: process each day's data
for i = 1:length(Directory)
    
    %% Load MPD data and corresponding cloud mask
    cd(Path.mpdData)
    load(Directory(i).name)                      % Load denoised MPD data
    cd(Path.cloudData)
    filename = strcat([Directory(i).name(1:8),'_Cloud_Data.mat']);
    load(filename)                               % Load unfiltered cloud data
    clear filename
    cd(Path.home)

    %% Apply the Haar Wavelet Covariance Transformation
    % Normalize the aerosol backscatter coefficient
    [HWT] = normalize_backscatter(MPDDenoised,CloudData);
    % Apply Haar wavelet transformation
    [HWT] = apply_HWT(HWT);

    %% Create figure of Haar Wavelet Transformation
    figure(1);
    set(gcf, 'Position', [100, 100, 1600, 600]);
    
    % Load colormap
    cd('..')
    cd('Colormaps')
    cmap1 = crameri('roma');
    cd(Path.home)
    
    % Plot Haar wavelet transformation
    h = imagesc(HWT.time, HWT.rangeHaarWaveletTransformation, HWT.haarWaveletTransformation);
    set(gca,'ydir','normal')
    colorbar
    alphaData = ~isnan(HWT.haarWaveletTransformation); % Make NaN regions transparent
    set(h, 'AlphaData', alphaData);
    colormap(flipud(cmap1))
    clim([-.1 .1])
    ylim([0 6000])
    ylabel('Range (m)')
    xlim([0 24])
    xlabel('Time (Local)')
    title('H($\beta_{aer}$) (unitless)','interpreter','latex','FontSize',18)

    %% Save the HWT data
    cd(Path.mpdData)
    filename = strcat([Directory(i).name(1:8),'_MPD_HWT.mat']);
    save(filename, 'HWT');
    cd(Path.home)
    
    %% Clean up for next iteration
    clear alphaData CloudData cmap1 HWT MPDDenoised
    close(figure(1))

end