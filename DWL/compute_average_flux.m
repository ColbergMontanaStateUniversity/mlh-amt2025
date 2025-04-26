function [FluxData] = compute_average_flux(FluxData)
% COMPUTE_AVERAGE_FLUX computes surface flux quantities from flux tower data
% This function converts temperature, pressure, water vapor, and flux variables
% to consistent units, computes virtual potential temperature and buoyancy flux.
%
% INPUT:
%   FluxData - structure containing flux tower measurements
%
% OUTPUT:
%   FluxData - updated structure with derived fields

%% Constants
g  = 9.793;    % gravitational acceleration at Tonopah (m/s^2)
rD = 287.05;   % specific gas constant for dry air (J/(kg·K))
cP = 1005;     % specific heat capacity of dry air at constant pressure (J/(kg·K))
rV = 461.5;    % specific gas constant for water vapor (J/(kg·K))
p0 = 100000;   % reference pressure at sea level (Pa)

%% Unit Conversions
% Convert temperatures to Kelvin
fieldsTemp = {'tc4mT0','tc4mT2','tc4mT5','tc4mT8','tc4mT11','tc4mT14',...
              'tc4mT17','tc4mT20','tc4mT23','tc4mT26','tc4mT29','tc4mT32',...
              'tc4mT35','tc4mT38','tc4mT41','tc4mT44','tc4mT47'};
for i = 1:length(fieldsTemp)
    FluxData.(['tk' fieldsTemp{i}(3:end)]) = FluxData.(fieldsTemp{i}) + 273.15;
end
FluxData = rmfield(FluxData, fieldsTemp); % Remove original Celsius fields

% Convert pressures from hPa to Pa
fieldsPress = {'p4mT0','p4mT2','p4mT5','p4mT8','p4mT11','p4mT14','p4mT17',...
               'p4mT20','p4mT23','p4mT26','p4mT29','p4mT32','p4mT35','p4mT38',...
               'p4mT41','p4mT44','p4mT47'};
for i = 1:length(fieldsPress)
    FluxData.(fieldsPress{i}) = FluxData.(fieldsPress{i}) * 100;
end

% Convert water vapor flux density and water vapor density to (kg/m^3)
fieldsWater = {'wH2o4mT0','wH2o4mT2','wH2o4mT5','wH2o4mT8','wH2o4mT11','wH2o4mT14',...
               'wH2o4mT17','wH2o4mT20','wH2o4mT23','wH2o4mT26','wH2o4mT29','wH2o4mT32',...
               'wH2o4mT35','wH2o4mT38','wH2o4mT41','wH2o4mT44','wH2o4mT47',...
               'h2o4mT0','h2o4mT2','h2o4mT5','h2o4mT8','h2o4mT11','h2o4mT14',...
               'h2o4mT17','h2o4mT20','h2o4mT23','h2o4mT26','h2o4mT29','h2o4mT32',...
               'h2o4mT35','h2o4mT38','h2o4mT41','h2o4mT44','h2o4mT47'};
for i = 1:length(fieldsWater)
    FluxData.(fieldsWater{i}) = FluxData.(fieldsWater{i}) / 1000;
end

%% Derived Quantities
% Compute water vapor partial pressure
towerNumber = {'T0','T2','T5','T8','T11','T14','T17','T20','T23','T26','T29','T32','T35','T38','T41','T44','T47'};
for i = 1:length(towerNumber)
    eField = ['e4m' towerNumber{i}];
    FluxData.(eField) = FluxData.(['h2o4m' towerNumber{i}]) .* rV .* FluxData.(['tk4m' towerNumber{i}]);
end

% Compute specific humidity
for i = 1:length(towerNumber)
    qField = ['q4m' towerNumber{i}];
    eField = ['e4m' towerNumber{i}];
    pField = ['p4m' towerNumber{i}];
    FluxData.(qField) = 0.622 * FluxData.(eField) ./ (FluxData.(pField) - FluxData.(eField));
end

% Compute potential temperature
for i = 1:length(towerNumber)
    thetaField = ['theta4m' towerNumber{i}];
    FluxData.(thetaField) = FluxData.(['tk4m' towerNumber{i}]) .* (p0 ./ FluxData.(['p4m' towerNumber{i}])).^(rD/cP);
end

% Compute virtual potential temperature
for i = 1:length(towerNumber)
    thetaVField = ['thetaV4m' towerNumber{i}];
    FluxData.(thetaVField) = FluxData.(['theta4m' towerNumber{i}]) .* (1 + 0.61 * FluxData.(['q4m' towerNumber{i}]));
end

% Compute virtual potential temperature and vertical wind covariance
for i = 1:length(towerNumber)
    wThetaVField = ['wThetaV4m' towerNumber{i}];
    FluxData.(wThetaVField) = FluxData.(['wTc4m' towerNumber{i}]) + 0.61 * FluxData.(['wH2o4m' towerNumber{i}]) .* FluxData.(['tk4m' towerNumber{i}]);
end

%% Averages for analysis
% Mean buoyancy flux (g * w'thetaV')/thetaV0
FluxData.gWThetaVByThetaV0Avg = mean(cell2mat(arrayfun(@(tag) ...
    g * FluxData.(['wThetaV4m' tag{:}]) ./ FluxData.(['thetaV4m' tag{:}]), ...
    towerNumber, 'UniformOutput', false)), 2, 'omitnan');
FluxData.gWThetaVByThetaV0AvgSmooth = smoothdata(FluxData.gWThetaVByThetaV0Avg, 'movmean', 24);

% Mean w'thetaV'
FluxData.wThetaVAvg = mean(cell2mat(arrayfun(@(tag) FluxData.(['wThetaV4m' tag{:}]), towerNumber, 'UniformOutput', false)), 2, 'omitnan');
FluxData.wThetaVAvgSmooth = smoothdata(FluxData.wThetaVAvg, 'movmean', 24);

end
