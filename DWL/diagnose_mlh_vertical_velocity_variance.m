function [MLH] = diagnose_mlh_vertical_velocity_variance(HaloData, TemporalVariance, CloudData, Sunrise, FluxData, sw, MLHOld)
% This function diagnoses the mixed layer height (MLH) using vertical wind velocity variance.
%
% Inputs:
%   HaloData          - Structure containing Halo Doppler lidar data
%   TemporalVariance  - Structure containing vertical velocity variance estimates
%   CloudData         - Structure containing cloud base height data
%   Sunrise           - Structure containing sunrise and sunset indices
%   FluxData          - Structure containing buoyancy flux estimates
%   sw                - Switch to choose thresholding method (0 = static, 1 = dynamic)
%   MLHOld            - Structure containing previous MLH estimates (for dynamic thresholding)
%
% Output:
%   MLH               - Structure containing diagnosed MLH estimates

    % ---------------------------
    % Set variance threshold
    % ---------------------------
    if sw == 0
        % Static threshold
        thr = 0.072 * ones(size(HaloData.time));
    else
        % Dynamic threshold based on w* and previous MLH
        wStar = abs((FluxData.gWThetaVByThetaV0AvgSmooth .* ...
            smoothdata(MLHOld.mlhWVar, 'movmean', 720, 'omitnan')).^(1/3)); % 2-hour smoothing
        
        wStar(isnan(wStar)) = 0;
        thr = (1.8 * 0.04 * wStar.^2).^2;
        
        % Enforce a minimum threshold
        thr(thr < 0.072) = 0.072;
    end

    % ---------------------------
    % Create time and range vectors
    % ---------------------------
    MLH.time  = TemporalVariance.time;
    MLH.range = TemporalVariance.range;

    % Preallocate MLH outputs
    MLH.mlhIndexWVar    = NaN(size(MLH.time));
    MLH.cloudBaseIndex  = NaN(size(MLH.time));
    MLH.mlhWVar         = NaN(size(MLH.time));
    MLH.cloud_base_height = NaN(size(MLH.time));

    % ---------------------------
    % Loop from sunrise to sunset
    % ---------------------------
    for i = Sunrise.sunriseInd:Sunrise.sunsetInd

        % ---------------------------
        % Check for clouds at this time
        % ---------------------------
        if ~isnan(CloudData.cloudBaseHeight(i))
            if CloudData.cloudBaseHeight(i) < 500
                cloudSwitch = 2; % Clouds below 500 m
            elseif CloudData.cloudBaseHeight(i) < 6000
                cloudSwitch = 1; % Clouds between 500 m and 6000 m
            else
                cloudSwitch = 0; % Clouds above 6000 m
            end
        else
            cloudSwitch = 0; % No clouds
        end

        % ---------------------------
        % Switch behavior based on cloud conditions
        % ---------------------------
        switch cloudSwitch

            % --- Case 0: No clouds or high clouds (>6000 m)
            case 0
                wVar = TemporalVariance.varianceMasked(:,i);

                if sum(wVar(1:5) > thr(i)) == 0
                    continue % No sufficient turbulence near surface
                else
                    try
                        ind  = find(wVar(1:5) > thr(i), 1, 'first');
                        ind2 = find(wVar(ind:end) < thr(i), 1, 'first');
                        MLH.mlhIndexWVar(i) = ind2 + ind - 1;
                        MLH.mlhWVar(i) = MLH.range(ind2 + ind - 1);
                    catch
                        continue % Skip if something goes wrong
                    end
                end

            % --- Case 1: Clouds between 500 m and 6000 m
            case 1
                % Record cloud base
                MLH.cloudBaseIndex(i) = find(CloudData.cloudBaseHeight(i) == MLH.range);
                MLH.cloudBaseHeight(i) = CloudData.cloudBaseHeight(i);

                wVar = TemporalVariance.varianceMasked(:,i);

                if sum(wVar(1:10) > thr(i)) == 0
                    continue
                else
                    try
                        ind  = find(wVar(1:5) > thr(i), 1, 'first');
                        ind2 = find(wVar(ind:end) < thr(i), 1, 'first');
                        MLH.mlhIndexWVar(i) = ind2 + ind - 1;
                        MLH.mlhWVar(i) = MLH.range(ind2 + ind - 1);

                        % Check if cloud is inside mixed layer
                        if MLH.mlhWVar(i) > CloudData.cloudBaseHeight(i)
                            % Cloud interferes, invalidate MLH
                            MLH.mlhIndexWVar(i) = NaN;
                            MLH.mlhWVar(i) = NaN;
                        else
                            continue
                        end
                    catch
                        continue
                    end
                end

            % --- Case 2: Clouds below 500 m
            otherwise
                try
                    MLH.cloudBaseIndex(i) = find(CloudData.CBH(i) == MLH.range);
                    MLH.cloud_base_height(i) = CloudData.cloudBaseHeight(i);
                catch
                    MLH.cloudBaseIndex(i) = 1;
                    MLH.cloud_base_height(i) = MLH.range(1);
                end
                continue

        end % end switch

    end % end for loop

    % ---------------------------
    % Smooth MLH time series
    % ---------------------------
    MLH.mlhWVarSmooth = smoothdata(MLH.mlhWVar, 'movmedian', 90, 'omitnan'); % 15-minute smoothing window

end