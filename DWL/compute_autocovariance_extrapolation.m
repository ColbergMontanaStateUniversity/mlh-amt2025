function [TemporalVariance] = compute_autocovariance_extrapolation(HaloData, Mask)
% This function computes the zero-lag extrapolated temporal variance
% from Halo Doppler wind lidar (DWL) vertical velocity data.

%% Load vertical velocity data
r = HaloData.range(3:200);     % Range bins (limited to 3-200)
t = HaloData.time;             % Time vector
x = HaloData.meanW(3:200,:);    % Vertical velocity

% Fill missing values by nearest neighbor interpolation
x = fillmissing(x,'nearest',1); % Fill vertically
x = fillmissing(x,'nearest',2); % Fill horizontally

%% Define indices for the main analysis window
indLow = find(t > -1.5, 1, 'first');   % first valid time index
indHigh = find(t < 25.5, 1, 'last');   % last valid time index
tWin = 180;  % Window size = 180 samples (~30 minutes)

%% Preallocate output arrays
var      = NaN(length(r), length(x(1,:))); % extrapolated variance
noiseVar = NaN(length(r), length(x(1,:))); % noise variance
deltaVar = NaN(length(r), length(x(1,:))); % difference between real variance and noise variance

xNew = NaN(size(x)); % Preallocate for despiked vertical velocity
tNew = NaN(size(t)); % Preallocate for adjusted time vector

%% Outlier removal and signal cleaning
for i = indLow:indHigh

    % Extract a temporary window around the current time
    xTmp = x(:,i-tWin/2:i+tWin/2);
    tTmp = t(i-tWin/2:i+tWin/2);

    % Remove 3-sigma outliers at each range gate
    for j = 1:length(r)
        q = xTmp(j,:);
        sigma = std(q);
        mu = mean(q);
        if isinf(mu) || isnan(mu)
            continue
        end
        lowLimit  = mu - 3*sigma;
        highLimit = mu + 3*sigma;
        ind = (q > highLimit | q < lowLimit);
        xTmp(j,ind) = NaN;
    end
    
    % Save the despiked value at the center of the window
    xNew(:,i) = xTmp(:,tWin/2+1);
    tNew(i)   = tTmp(tWin/2+1);
    
end

clear q mu sigma tTmp xTmp

%% Perform autocovariance extrapolation
for i = indLow:indHigh
    xTmp = xNew(:,i-50:i+50); % Extract a 100-sample window (~17 minutes)

    for j = 1:length(r)
        
        % Define lags for autocovariance
        lag = -10:10;
    
        % Extract and clean the signal
        q = xTmp(j,:);
        ind = isnan(q);
        q(ind) = [];
        
        % Detrend (zero mean)
        q = q - mean(q);
        
        % Initialize autocovariance array
        acv = zeros(1,length(lag));
        
        % Compute autocovariance manually at each lag
        for k = 1:length(lag)
            if lag(k) < 0
                pos1 = [1 length(q)+lag(k)];
                pos2 = [1-lag(k) length(q)];
            elseif lag(k) == 0
                pos1 = [1 length(q)];
                pos2 = [1 length(q)];
            else
                pos1 = [1+lag(k) length(q)];
                pos2 = [1 length(q)-lag(k)];
            end
            
            xc = q(pos1(1):pos1(2))';
            xr = q(pos2(1):pos2(2));
            
            acv(k) = (xr*xc)/length(q); % normalized autocovariance
        end
        
        % Extrapolate to zero lag using a linear fit in log-log space
        x_fit = lag(12:16).^(2/3); % Lag values
        y_fit = acv(12:16);        % Corresponding autocovariances
        P = polyfit(x_fit, y_fit, 1); % Linear fit
        
        % Save extrapolated zero-lag variance
        var(j,i) = P(2);

        % Save estimated noise floor
        noiseVar(j,i) = acv(11) - P(2);

        % Estimate variance uncertainty (deltaVar)
        deltaVar(j,i) = abs(2 * abs(sqrt(var(j,i))) * abs(sqrt(noiseVar(j,i))) + noiseVar(j,i));
    end
end

%% Package output structure
TemporalVariance.range    = r;
TemporalVariance.time     = t;
TemporalVariance.variance = var;
TemporalVariance.varianceNoise = noiseVar;
TemporalVariance.varianceDelta = deltaVar;

% Apply smoothing to the mask and store
M = smoothdata(Mask.combinedMask(3:200,:), 2, "movmean", 91);
TemporalVariance.Mask = (M > 0);

% Mask out variance inside cloudy/precipitating/missing regions
TemporalVariance.varianceMasked = TemporalVariance.variance;
TemporalVariance.varianceMasked(TemporalVariance.Mask == 1) = NaN;

end