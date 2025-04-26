%% Front Matter
clear all; close all;

% This script loads and processes HRRR netCDF files to generate time-resolved
% profiles of thermodynamic variables and mixed layer height estimates.

% Outputs:
% - Time and range (altitude) vectors
% - 2D arrays [range x time] of:
%     temperature, relative humidity, specific humidity,
%     potential temperature, and virtual potential temperature
% - Time series of PBLH derived from:
%     HRRR default, parcel method, and offset parcel method.
% - Final results saved in a .mat file as structure `HRRRData`

%% 0. Setup paths and date range
clear all; close all;

Path.home = pwd;
Path.hrrr_data = strcat(Path.home,'\HRRR_data'); % Folder where HRRR NetCDF files are located
% IMPORTANT: Path.date1 should be the primary day of interest,
% and Path.date2 must be the following day to ensure full diurnal coverage.
Path.date1 = "20230906"; % Start date (YYYYMMDD)
Path.date2 = "20230907";  % End date (YYYYMMDD)


%% 1. Load HRRR data

% Load HRRR NetCDF data for each day and combine into a single structure
[HRRRData1] = load_hrrr_data(Path, Path.date1);
[HRRRData2] = load_hrrr_data(Path, Path.date2);
[HRRRData]  = concatenate_hrrr_data(HRRRData1, HRRRData2);  % Concatenate and convert to local time

clear HRRRData1 HRRRData2

%% 2. Derive thermodynamic quantities

% Convert pressure levels to altitude using geopotential height
[HRRRData] = convert_pressure_to_altitude(HRRRData);

% Convert RH, temperature, and pressure to:
% - specific humidity
% - potential temperature
% - virtual potential temperature
[HRRRData] = convert_q_theta_vpt(HRRRData);


%% 3. Estimate PBLH using parcel methods

% Compute PBLH using virtual potential temperature with 1K offset parcel method
[HRRRData] = compute_mlh_parcel_hrrr_offset1K(HRRRData);

% Compute PBLH using standard parcel method (no offset)
[HRRRData] = compute_mlh_parcel_hrrr_standard(HRRRData);

%% 4. Save output data

% Create folder if it doesn't exist
if ~exist('Processed_HRRR_Data', 'dir')
    mkdir('Processed_HRRR_Data');
end

cd('Processed_HRRR_Data')
save(strcat(Path.date1, '.mat'), 'HRRRData');  % Save results as .mat file named after the first date
cd(Path.home)

figure(1)

%% 5. Plotting virtual potential temperature difference and mlh
% Plot virtual potential temperature minus surface value (2D time-range field)
imagesc(HRRRData.time, HRRRData.range, ...
    HRRRData.virtualPotentialTemperature - ...
    repmat(HRRRData.virtualPotentialTemperatureSurface, [length(HRRRData.range) 1]));
hold on;
set(gca, 'ydir', 'normal')
xlim([0 24])
ylim([0 6000])
xlabel('Time [Local]')
ylabel('Range [m]')
colorbar
clim([-3 3])  % color limits in K

% Load perceptually uniform colormap
cd('..')
cd('Colormaps')
colormap(crameri('bam'))  % Requires crameri.m or colormap function in path
cd(Path.home)

% Plot PBLH estimates on top of heatmap
p(1) = plot(HRRRData.time, HRRRData.pblhDefault, 'd', ...
    'Color', '#1ACCCC', 'MarkerFaceColor', '#1ACCCC', ...
    'MarkerEdgeColor', 'k', 'MarkerSize', 5.5, 'LineWidth', 1);
p(2) = plot(HRRRData.time, HRRRData.mlhParcelOffset1K, 's', ...
    'Color', '#FF5500', 'MarkerFaceColor', '#FF5500', ...
    'MarkerEdgeColor', 'k', 'MarkerSize', 5.5, 'LineWidth', 1);

legend([p(1) p(2)], 'HRRR Default PBLH', 'HRRR Offset Parcel MLH (Surface + 1K)', 'Location', 'Northwest')
title('Virtual Potential Temperature (Atmosphere - Surface) [K]')