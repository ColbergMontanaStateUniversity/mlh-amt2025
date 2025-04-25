%%%%% Code for M2HATS radiosonde MLh retrieval

%% Initialization
clear all; close all;

% Set up directory paths
Path.home = pwd;  % Current working directory

% Path to folder containing radiosonde .nc files
Path.radiosondeDataFoldername = strcat(Path.home, "\radiosonde_data");

% Path to folder containing surface station data
Path.surfaceDataFoldername = strcat(Path.home, "\surface_data");

%% Load and organize data

% Specify filenames for radiosonde and surface data
% Note: Use only ascending radiosondes (filename includes "_asc")
Path.radiosondeDataFilename = "NCAR_M2HATS_ISS1_RS41_v1_20230726_221559_asc.nc";
Path.surfaceDataFilename     = "iss2_m2hats_sfcmet_3mtower_20230726.nc";

% Load radiosonde profile into structure: Radiosonde
Radiosonde = load_radiosonde_data(Path);

% Load corresponding surface weather station data into structure: SurfaceData
SurfaceData = load_surface_data(Path);

%% Operations on radiosonde data

% convert the altitude to height
Radiosonde.height = Radiosonde.alt - Radiosonde.referenceAlt;

%% Apply the radiosonde methods

% parcel method
[Radiosonde] = compute_mlh_parcel_standard(Radiosonde,SurfaceData);

% parcel method +1 K
[Radiosonde] = compute_mlh_parcel_offset1K(Radiosonde,SurfaceData);

% bulk Richardson method 
% critical bulk Richardson number of 0.25
[Radiosonde] = compute_mlh_bulk_ri(Radiosonde,SurfaceData);

%% Create figure with virtual potential temperature and Bulk Richardson Number profiles
figure(1)

% --- Left panel: Virtual potential temperature profile ---
subplot(1,2,1)
p(1) = plot(Radiosonde.thetaV,Radiosonde.height,'-','linewidth',2);
hold on
p(2) = yline(Radiosonde.mlhParcelStandard,':','linewidth',1.25);
p(3) = yline(Radiosonde.mlhParcelOffset1K,'-.','linewidth',1.25);
p(4) = yline(Radiosonde.mlhBulkRichardsonMethod,'--','linewidth',1.25);
ylim([0 6000])
legend([p(2) p(3) p(4)],'Parcel','Offset Parcel','Bulk Richardson','Location','Best')
grid on
ylabel('Range [m]')
xlabel('Virtual Potential Temperature [K]')

% --- Right panel: Bulk Richardson number profile ---
subplot(1,2,2)
p(1) = plot(Radiosonde.bulkRichardsonNumber,Radiosonde.height,'-','linewidth',2);
hold on
p(2) = yline(Radiosonde.mlhParcelStandard,':','linewidth',1.25);
p(3) = yline(Radiosonde.mlhParcelOffset1K,'-.','linewidth',1.25);
p(4) = yline(Radiosonde.mlhBulkRichardsonMethod,'--','linewidth',1.25);
ylim([0 6000])
legend([p(2) p(3) p(4)],'Parcel','Offset Parcel','Bulk Richardson','Location','Best')
grid on
ylabel('Range [m]')
xlabel('Bulk Richardson Number [Unitless]')
