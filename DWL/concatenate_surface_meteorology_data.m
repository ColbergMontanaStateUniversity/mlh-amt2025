function [SurfaceMeteorologyData] = concatenate_surface_meteorology_data(Data1, Data2)
% CONCATENATE_SURFACE_METEOROLOGY_STATION
% Concatenates two consecutive days of 3-meter tower surface meteorology data.
%
% Inputs:
%   - Data1: Structure for the first day of data
%   - Data2: Structure for the second day of data
%
% Outputs:
%   - SurfaceMeteorologyData: Structure containing concatenated meteorological variables
%
% Notes:
%   - Converts time from seconds to local time (hours) with a UTC-7 shift for Pacific Daylight Time (PDT).
%   - Data2 is assumed to follow Data1 (adds 24 hours for the second day).

timeCorrection = -7; % Hours to shift from UTC to Pacific Daylight Time (PDT)

% Concatenate time vectors and adjust for local time
SurfaceMeteorologyData.time                        = [Data1.time/3600 + timeCorrection; Data2.time/3600 + 24 + timeCorrection];

% Concatenate meteorological variables
SurfaceMeteorologyData.temperatureAir              = [Data1.temperatureAir             ; Data2.temperatureAir             ];
SurfaceMeteorologyData.relativeHumidity            = [Data1.relativeHumidity           ; Data2.relativeHumidity           ];
SurfaceMeteorologyData.pressureAir                 = [Data1.pressureAir                ; Data2.pressureAir                ];
SurfaceMeteorologyData.windSpeed                   = [Data1.windSpeed                  ; Data2.windSpeed                  ];
SurfaceMeteorologyData.precipitationIntensityCS125 = [Data1.precipitationIntensityCS125; Data2.precipitationIntensityCS125];
SurfaceMeteorologyData.precipitationIntensityWS800 = [Data1.precipitationIntensityWS800; Data2.precipitationIntensityWS800];
SurfaceMeteorologyData.windDirection               = [Data1.windDirection              ; Data2.windDirection              ];

end