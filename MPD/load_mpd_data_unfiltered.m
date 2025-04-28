function [MPDUnfiltered] = load_mpd_data_unfiltered(Path,filename)
% This function loads unfiltered MPD data from an HDF5 (.h5) file.
% It extracts several key variables and saves them into a structure.
%
% Inputs:
%   Path     - Structure containing the path to the data folder
%   filename - String, the name of the HDF5 file to load
%
% Output:
%   MPD_15s  - Structure containing time, range, backscatter coefficients,
%              and associated masks/variances

% Navigate to the folder containing the MPD data
cd(Path.data)

% Read variables from the HDF5 file
MPDUnfiltered.time                                    = h5read(filename, '/time');                                 % Time vector (s since midnight UTC)
MPDUnfiltered.range                                   = h5read(filename, '/range');                                % Range vector (m)
MPDUnfiltered.aerosolBackscatterCoefficient           = h5read(filename, '/Aerosol_Backscatter_Coefficient');      % Aerosol backscatter coefficient (m^-1 sr^-1)
MPDUnfiltered.backscatterRatio                        = h5read(filename, '/Backscatter_Ratio');                    % Backscatter ratio (unitless)
MPDUnfiltered.aerosolBackscatterCoefficientMask       = h5read(filename, '/Aerosol_Backscatter_Coefficient_mask'); % Data quality mask for aerosol backscatter
MPDUnfiltered.backscatterRatioMask                    = h5read(filename, '/Backscatter_Ratio_mask');               % Data quality mask for backscatter ratio

% Return to the code directory
cd(Path.home)

end