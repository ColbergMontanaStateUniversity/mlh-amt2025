function [MLH] = find_mlh_parcel(MPDDenoised,CloudData,Sunrise,offset)
% Inputs:
%   MPDDenoised - Structure containing virtual potential temperature difference profiles
%   CloudData   - Structure containing cloud base heights and indices
%   Sunrise     - Structure containing sunrise and sunset indices
%   offset      - Scalar offset value (in K) added to parcel method thresholds

% Outputs:
%   MLH - Structure with fields for parcel method mixed layer height
%         and associated indices.

%% Create time and range vectors for MLH
MLH.time  = MPDDenoised.time;
MLH.range = MPDDenoised.range;

%% Preallocate parcel method MLH and index arrays
MLH.mlhParcelMethodIndex = NaN(size(MLH.time));
MLH.mlhParcelMethod      = NaN(size(MLH.time));

%% Top-down parcel method analysis between sunrise and sunset
for i = Sunrise.sunriseInd:Sunrise.sunsetInd

    % Check if a cloud base is reported at this time step
    if ~isnan(CloudData.cloudBaseHeight(i))

        % Case 1: Cloud base is below 6000 m
        if CloudData.cloudBaseHeight(i) < 6000
            cloudSwitch = 1;
        else
            cloudSwitch = 0; % Cloud base above 6000 m
        end

        % Case 2: Cloud base is below 500 m
        if CloudData.cloudBaseHeight(i) < 500
            cloudSwitch = 2;
        end

    else
        cloudSwitch = 0; % No cloud base reported
    end

    % Switch based on cloud presence
    switch cloudSwitch

        case 0 % No clouds or clouds above 6000 m
            thetaVDiff = MPDDenoised.thetaVDiff(:,i);

            % check if any valid points exist
            if sum(thetaVDiff(1:5) < 3) == 0
                continue % skip to next iteration
            else
                try
                    % Find mlh based on offset
                    topind = find(thetaVDiff > 2 + offset, 1, 'first');
                    ind    = find(thetaVDiff(1:topind) < offset, 1, 'first');
                    ind2   = find(thetaVDiff(ind:min([152 topind])) < 1, 1, 'last') + 1;

                    % Record MLH estimates
                    MLH.mlhParcelMethodIndex(i) = ind2 + ind - 1;
                    MLH.mlhParcelMethod(i) = MLH.range(ind2 + ind - 1);
                catch
                    % Skip if any index operation fails
                end
            end

        case 1 % Clouds below 6000 m but above 500 m
            thetaVDiff = MPDDenoised.thetaVDiff(:,i);

            % Check for surface-based convection
            if sum(thetaVDiff(1:5) < 3) == 0
                continue
            else
                try
                    % Find mlh based on offset
                    topind = find(thetaVDiff > 2 + offset, 1, 'first');
                    ind    = find(thetaVDiff(1:topind) < offset, 1, 'first');
                    ind2   = find(thetaVDiff(ind:min([126 topind])) < 1, 1, 'last') + 1;

                    % Record MLH estimates
                    MLH.mlhParcelMethodIndex(i) = ind2 + ind - 1;
                    MLH.mlhParcelMethod(i) = MLH.range(ind2 + ind - 1);
                catch
                    % Skip if any index operation fails
                end
            end
    end
end

%% Post-processing: Remove unrealistic points

% Remove points where parcel MLH is above cloud base
log_1 = ~isnan(CloudData.cloudBaseIndex) & (MLH.mlhParcelMethodIndex > CloudData.cloudBaseIndex);
MLH.mlhParcelMethodIndex(log_1) = NaN;
MLH.mlhParcelMethod(log_1) = NaN;

% Remove points where MLH is greater than 5500 m
log_2 = MLH.mlhParcelMethod > 5500;
MLH.mlhParcelMethodIndex(log_2) = NaN;
MLH.mlhParcelMethod(log_2) = NaN;

end