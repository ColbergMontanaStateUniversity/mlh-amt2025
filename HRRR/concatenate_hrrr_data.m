function HRRRData = concatenate_hrrr_data(HRRRData1, HRRRData2)
% CONCATENATE_HRRR_DATA Combines two HRRR data structures into one

% INPUTS:
%   HRRRData1 - structure containing the first day's HRRR data
%   HRRRData2 - structure containing the second day's HRRR data

% OUTPUT:
%   HRRRData  - combined structure with time-adjusted and trimmed data

% Note:
%   Time is converted from UTC to Pacific Daylight Time (UTC-7), 
%   which was the local time zone for the M2HATS experiment.
%   The final time vector is trimmed to include only hours -2 to 26 
%   relative to the first radiosonde launch.

% ---------------------------
% Time zone correction [UTC → PDT]
% ---------------------------
timeCorrection = -7;

% ---------------------------
% Static variables (copied from first day)
% ---------------------------
HRRRData.presLevels = HRRRData1.presLevels;
HRRRData.geopotentialHeight = HRRRData1.geopotentialHeight;

% ---------------------------
% Time vector (concatenate and adjust for local time)
% ---------------------------
HRRRData.time = [HRRRData1.time + timeCorrection, ...
                 HRRRData2.time + 24 + timeCorrection];  % second day + 24 hr offset

% ---------------------------
% Concatenate fields
% ---------------------------
HRRRData.temperature             = [HRRRData1.temperature,             HRRRData2.temperature];
HRRRData.relativeHumidity        = [HRRRData1.relativeHumidity,        HRRRData2.relativeHumidity];
HRRRData.pblhDefault             = [HRRRData1.pblhDefault,             HRRRData2.pblhDefault];
HRRRData.temperature2Meter       = [HRRRData1.temperature2Meter,       HRRRData2.temperature2Meter];
HRRRData.relativeHumidity2Meter = [HRRRData1.relativeHumidity2Meter,  HRRRData2.relativeHumidity2Meter];
HRRRData.pressureHumidity2Meter = [HRRRData1.pressureHumidity2Meter,  HRRRData2.pressureHumidity2Meter];

% ---------------------------
% Trim to desired time window [-2 to 26 hours local time]
% ---------------------------
indLow  = find(HRRRData.time == -2);
indHigh = find(HRRRData.time == 26);

HRRRData.time                    = HRRRData.time(indLow:indHigh);
HRRRData.temperature             = HRRRData.temperature(:, indLow:indHigh);
HRRRData.relativeHumidity        = HRRRData.relativeHumidity(:, indLow:indHigh);
HRRRData.pblhDefault             = HRRRData.pblhDefault(indLow:indHigh);
HRRRData.temperature2Meter       = HRRRData.temperature2Meter(indLow:indHigh);
HRRRData.relativeHumidity2Meter = HRRRData.relativeHumidity2Meter(indLow:indHigh);
HRRRData.pressureHumidity2Meter = HRRRData.pressureHumidity2Meter(indLow:indHigh);

end
