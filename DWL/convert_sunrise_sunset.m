function [Sunrise] = convert_sunrise_sunset(T, HaloData, filename)
% This function converts sunrise and sunset times from a lookup table into numerical time
% and finds the corresponding indices in the HaloData time vector.
%
% Inputs:
%   T         - Table containing month, day, sunrise time, and sunset time
%   HaloData  - Structure containing the 'time' vector (in hours)
%   filename  - Filename string containing the date (MMDD format at positions 5–8)
%
% Output:
%   Sunrise   - Structure containing sunrise/sunset times and corresponding indices

    % Initialize Sunrise structure with time vector
    Sunrise.time = HaloData.time;
    
    % Find the table row corresponding to the date in the filename
    cond1 = table2array(T(:,1)) == str2double(filename(5:6)); % Month match
    cond2 = table2array(T(:,2)) == str2double(filename(7:8)); % Day match
    ind = find(cond1 & cond2); % Combined condition to find correct row
    
    % Extract sunrise and sunset times as character arrays
    sunriseChar = char(T{ind,3});
    sunsetChar  = char(T{ind,4});

    % Convert sunrise time string (hh:mm:ss) into decimal hours
    Sunrise.sunriseTime = str2double(sunriseChar(1:2)) +...
                          str2double(sunriseChar(4:5))/60 +...
                          str2double(sunriseChar(7:8))/3600;
    
    % Convert sunset time string (hh:mm:ss) into decimal hours
    % (Adding 12 to shift PM times correctly)
    Sunrise.sunsetTime  = str2double(sunsetChar(1:2)) +...
                          str2double(sunsetChar(4:5))/60 +...
                          str2double(sunsetChar(7:8))/3600 + 12;

    % Find the index in the HaloData time vector closest to sunrise
    [~, Sunrise.sunriseInd] = min(abs(Sunrise.sunriseTime - Sunrise.time));
    
    % Find the index in the HaloData time vector closest to sunset
    [~, Sunrise.sunsetInd]  = min(abs(Sunrise.sunsetTime  - Sunrise.time));

end
