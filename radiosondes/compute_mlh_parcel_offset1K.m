function [Radiosonde] = compute_mlh_parcel_offset1K(Radiosonde,SurfaceData)

%COMPUTE_MLH_PARCEL_STANDARD Estimate the PBL height using the parcel method.

% This function estimates the planetary boundary layer height (PBLH) using
% a version of the parcel method described by Holzworth (1964), modified to
% use virtual potential temperature instead of potential temperature and
% with a 1-K offset applied. 

% INPUTS:
%   Radiosonde   - structure containing the radiosonde profile (with
%   .thetaV, .height, etc.)
%   SurfaceData  - structure containing surface meteorological data (T, RH,
%   P, etc.)

% OUTPUTS:
%   Radiosonde.mlhParcel      - Estimated mixed layer height [m]
%   Radiosonde.mlhParcelTime  - Time of the MLH estimate [decimal hours UTC]

%% Compute the reference virtual potential temperature (thetaVRef)

% Interpolate surface air temperature to the radiosonde launch time [°C → K]
tRef = interp1(SurfaceData.time/3600, SurfaceData.airTemp, Radiosonde.launchTimeUtc) + 273.15;  % Reference temperature [K]

% Interpolate surface relative humidity to the radiosonde launch time [%]
rhRef = interp1(SurfaceData.time/3600, SurfaceData.rh, Radiosonde.launchTimeUtc);  % Reference relative humidity [%]

% Interpolate surface pressure to the radiosonde launch time [hPa]
pRef = interp1(SurfaceData.time/3600, SurfaceData.pressure, Radiosonde.launchTimeUtc);  % Reference pressure [hPa]

% Compute potential temperature using Poisson's equation [K]
thetaRef = tRef .* (1000 ./ pRef) .^ (287 / 1004);  % Dry potential temperature [K]

% Compute saturation vapor pressure using Tetens equation [hPa]
tRef_C = tRef - 273.15;
if tRef_C > 0
    esRef = 6.1078*exp((17.27 *(tRef_C)) ./((tRef_C) + 237.3));
else
    esRef  = 6.1078*exp((21.875*(tRef_C))  ./((tRef_C)  + 265.5));
end

% Compute actual vapor pressure using RH [hPa]
eRef = (rhRef ./ 100) .* esRef;

% mixing ratio
mixingRatio = 0.622 * eRef / (pRef - eRef);

% Compute virtual potential temperature [K]
% Includes correction for lower density of moist air: thetaV = theta * (1 + 0.61 * (e / (p - e)))
thetaVRef = thetaRef .* (1 + 0.61 * mixingRatio);  % Virtual potential temperature [K]


%% remove data below 100 m

% Find the index of the first data point above 100 meters AGL
ind100m = find(Radiosonde.height >= 100, 1, 'first');

% Compute the difference between the virtual potential temperature profile and the surface (reference) value
deltaThetaV = Radiosonde.thetaV - thetaVRef;  % [K]

% Set all values below 100 m to NaN (ignore near-surface variability)
deltaThetaV(1:ind100m) = NaN;

%% Find the mixing layer height (MLH) using the parcel method

% Logical array: true where the parcel is warmer than the surface
log = (deltaThetaV > 1);
ind = [];

% Search for the first index where thetaV exceeds the reference value,
% and the next 5 consecutive points also do — avoids spikes or shallow anomalies
while isempty(ind)
    ind = find(log == 1, 1, 'first');
    if sum(log(ind+1 : ind+5)) < 5
        log(ind) = 0;  % Reset the logical operator
        ind = [];      % clear index
    end
end

% Store the MLH value as the height of the identified mlh [m]
Radiosonde.mlhParcelOffset1K = Radiosonde.height(ind);

% Store the time of the MLH in decimal hours since midnight [hours]
Radiosonde.mlhParcelOffset1KTime = Radiosonde.launchTimeUtc + ...
                                   Radiosonde.time(ind) / 3600;  % Add elapsed seconds from launch

end