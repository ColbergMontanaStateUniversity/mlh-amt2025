function [Radiosonde] = compute_mlh_bulk_ri(Radiosonde,SurfaceData)
% Estimate PBL height using the Bulk Richardson Number method.

% A critical Bulk Richardson number threshold of 0.25 is used
% to define the top of the mixed layer, consistent with these references.

%% Compute the reference virtual potential temperature (thetaVRef)

% Interpolate surface air temperature at radiosonde launch [K]
tRef = interp1(SurfaceData.time / 3600, SurfaceData.airTemp, Radiosonde.launchTimeUtc) + 273.15;

% Interpolate surface relative humidity [%] and pressure [hPa]
rhRef = interp1(SurfaceData.time / 3600, SurfaceData.rh, Radiosonde.launchTimeUtc);
pRef  = interp1(SurfaceData.time / 3600, SurfaceData.pressure, Radiosonde.launchTimeUtc);

% Compute potential temperature using Poisson's equation [K]
thetaRef = tRef .* (1000 ./ pRef) .^ (287 / 1004);

% Compute saturation vapor pressure using Tetens equation [hPa]
tRef_C = tRef - 273.15;
if tRef_C > 0
    esRef = 6.1078*exp((17.27 *(tRef_C)) ./((tRef_C) + 237.3));
else
    esRef  = 6.1078*exp((21.875*(tRef_C))  ./((tRef_C)  + 265.5));
end

% Compute actual vapor pressure [hPa]
eRef = (rhRef ./ 100) .* esRef;

% Compute water vapor mixing ratio [kg/kg dry air]
mixingRatio = 0.622 * eRef / (pRef - eRef);

% Compute surface virtual potential temperature [K]
thetaVRef = thetaRef .* (1 + 0.61 * mixingRatio./(1 + mixingRatio));

%% Compute the reference horizontal wind components

% Interpolate wind speed and direction at the surface at launch time
windSpeedRef = interp1(SurfaceData.time / 3600, SurfaceData.windAvg, Radiosonde.launchTimeUtc);     % [m/s]
windDirRef   = interp1(SurfaceData.time / 3600, SurfaceData.windDirAct, Radiosonde.launchTimeUtc);  % [deg]

% Convert wind direction to Cartesian components [m/s]
uRef = -windSpeedRef * sin(windDirRef);
vRef = -windSpeedRef * cos(windDirRef);

%% Calculate the Bulk Richardson Number profile

% Gravitational acceleration at Tonopah, NV [m/s²]
g = 9.791;

% Compute the BRN at each level using:
% Ri = (g / thetaV0) * (thetaV(z) - thetaV0) * z / [(u(z) - u0)^2 + (v(z) - v0)^2]
Radiosonde.bulkRichardsonNumber = ...
    ((g ./ thetaVRef) .* (Radiosonde.thetaV - thetaVRef) .* Radiosonde.height) ./ ...
    ((Radiosonde.windU - uRef).^2 + (Radiosonde.windV - vRef).^2);

%% Identify MLH from Bulk Richardson profile

% Remove levels below 100 m (typically noisy near-surface gradients)
h_ind_1 = find(Radiosonde.height >= 100, 1, 'first');
bulkRichardsonNumber = Radiosonde.bulkRichardsonNumber;
bulkRichardsonNumber(1:h_ind_1) = NaN;

% Find first height where BRN exceeds the critical threshold of 0.25
ind = [];
log = (bulkRichardsonNumber > 0.25);

% require BRN > 0.25 for at least 5 consecutive levels
while isempty(ind)
    ind = find(log == 1, 1, 'first');
    if sum(log(ind+1 : ind+5)) < 5
        log(ind) = 0;
        ind = [];
    end
end

% Save the MLH estimate [m]
Radiosonde.mlhBulkRichardsonMethod = Radiosonde.height(ind);

% Save the time of MLH estimate [decimal hours UTC]
Radiosonde.mlhBulkRichardsonMethodTime = Radiosonde.launchTimeUtc + ...
                                         Radiosonde.time(ind) / 3600;
 

end
