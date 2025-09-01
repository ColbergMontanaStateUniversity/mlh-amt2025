% This code loads data from MPD netCDF files, converts the time to local time,
% processes and trims the data, and saves the useful variables into .mat files.

clear all; close all;

%% Pre-code: Set up paths and file directory
Path.home = pwd;                                    % Save the current working directory
Path.data = strcat(pwd, '\MPD_Data_Unfiltered');    % Define the path to the unfiltered MPD data

% Create a directory list of all MPD netCDF files
cd(Path.data)
Directory = dir("mpd03*.nc");                       % Find all files matching 'mpd03*.nc' pattern
cd(Path.home)

%% Loop over each day of data
for i = 1:length(Directory) - 1

    %% Load two consecutive days of MPD data
    [MPDUnfilteredData1] = load_mpd_data_unfiltered(Path, Directory(i).name);
    [MPDUnfilteredData2] = load_mpd_data_unfiltered(Path, Directory(i+1).name);

    % Concatenate and trim the two days into a single structure
    [MPDUnfiltered] = concatenate_mpd_data_unfiltered(MPDUnfilteredData1, MPDUnfilteredData2);
    [MPDUnfiltered] = trim_mpd_data_unfiltered(MPDUnfiltered);

    clear MPDUnfilteredData1 MPDUnfilteredData2

    %% Save processed data as a .mat file
    cd(Path.data)
    filename = strcat([Directory(i).name(7:14), '_MPD_unfiltered.mat']); % Create filename based on date
    save(filename, 'MPDUnfiltered');
    cd(Path.home)

    %% Clear structures and variables for the next loop iteration
    clear MPDUnfiltered filename


end
