function [HaloData] = load_halo_netCDF(Path, subfolderpath)
% load_halo_netCDF

% This function loads Halo Doppler lidar data from NetCDF files in a given subfolder.

% INPUTS:
%   Path - structure containing base paths (specifically, Path.home for returning)
%   subfolderpath - cell array containing one path to the specific subfolder

% OUTPUTS:
%   HaloData - structure containing time, vertical velocity, intensity, backscatter, and range
%   If no files are found, returns an empty HaloData.

% Navigate to the specific subfolder
cd(subfolderpath{1})

% Look for all NetCDF files starting with "fp_"
Directory = dir("fp_*.nc");

% If files are found
if ~isempty(Directory)

    % Read the hour vector and range vector from the first file
    hour  = h5read(Directory(1).name, "/hour"); 
    range = h5read(Directory(1).name, "/range") / 10;  % Convert range from m to km

    % Set up indexing to track where each file's data starts and ends in the time series
    inc = [1, length(hour)];

    % Loop through remaining files and concatenate hour vectors
    for i = 2:length(Directory)
        hour = [hour; h5read(Directory(i).name, "/hour")];
        inc  = [inc, [inc(end)+1, length(hour)]];
    end

    % Preallocate arrays for velocity, intensity, and backscatter
    velocity    = zeros(length(range), length(hour));
    intensity   = zeros(length(range), length(hour));
    backscatter = zeros(length(range), length(hour));
    
    % Loop through each file and load the data into the preallocated arrays
    for i = 1:length(Directory)
        velocity(:, inc(2*i-1):inc(2*i))    = h5read(Directory(i).name, "/velocity");
        intensity(:, inc(2*i-1):inc(2*i))   = h5read(Directory(i).name, "/intensity");
        backscatter(:, inc(2*i-1):inc(2*i)) = h5read(Directory(i).name, "/backscatter");
    end

    % Save loaded variables into the HaloData structure
    HaloData.time                = hour;
    HaloData.windW               = velocity;
    HaloData.intensity           = intensity;
    HaloData.attenuatedBackscatter = backscatter;
    HaloData.range               = range;

    % Return to the home path
    cd(Path.home)

    % Perform additional integration/smoothing if needed
    [HaloData] = integrate_halo_data(HaloData);

else
    % If no files found, return an empty structure
    cd(Path.home)
    HaloData = [];
end

end
