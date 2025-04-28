function [Sunrise] = convert_sunrise_sunset(T, MPDDenoised, filename)
% convert_sunrise_sunset - Converts sunrise and sunset times to match lidar time vector
%
% Inputs:
%   T           - Table containing month, day, sunrise time, and sunset time
%   MPDDenoised - Structure containing the lidar time vector
%   filename    - String representing the filename with embedded date information
%
% Outputs:
%   Sunrise     - Structure containing time vector, sunrise and sunset times (hours),
%                 and sunrise and sunset indices into the lidar time vector

    % Initialize Sunrise structure and copy time vector
    Sunrise.time = MPDDenoised.time;
    
    % Find the table row corresponding to the date from filename
    cond1 = table2array(T(:,1)) == str2double(filename(5:6)); % Month matches
    cond2 = table2array(T(:,2)) == str2double(filename(7:8)); % Day matches
    ind = find(cond1 & cond2); % Combined condition to find the correct row in the table
    
    % Extract sunrise and sunset times as character arrays
    sunriseChar = char(T{ind,3}); % Sunrise time as character array
    sunsetChar  = char(T{ind,4}); % Sunset time as character array

    % Convert sunrise time from HH:MM:SS string to decimal hours
    Sunrise.sunriseTime = str2double(sunriseChar(1:2)) + ...
                          str2double(sunriseChar(4:5))/60 + ...
                          str2double(sunriseChar(7:8))/3600;

    % Convert sunset time from HH:MM:SS string to decimal hours (plus 12 for PM times)
    Sunrise.sunsetTime  = str2double(sunsetChar(1:2)) + ...
                          str2double(sunsetChar(4:5))/60 + ...
                          str2double(sunsetChar(7:8))/3600 + 12;

    % Find the indices in the time vector closest to sunrise and sunset
    [~, Sunrise.sunriseInd] = min(abs(Sunrise.sunriseTime - Sunrise.time));
    [~, Sunrise.sunsetInd]  = min(abs(Sunrise.sunsetTime  - Sunrise.time));

end