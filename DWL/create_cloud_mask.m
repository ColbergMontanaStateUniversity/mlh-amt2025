function [Mask, CloudData] = create_cloud_mask(CloudData, HaloData)
% CREATE_CLOUD_MASK creates a logical mask identifying cloud regions in Halo data.

% Inputs:
%   CloudData - Structure containing the 5x5 variance fields
%   HaloData  - Structure containing attenuated backscatter and SNR measurements

% Outputs:
%   Mask      - Structure containing the cloud mask
%   CloudData - Updated structure including the cloud mask

% The cloud identification requires all of the following:
%   1) High variance in 5x5 neighborhood of attenuated backscatter
%   2) High signal-to-noise ratio (SNR)
%   3) High backscatter ratio compared to average molecular backscatter
%   4) Low vertical wind variance (to filter out regions of strong turbulence)

%% Load background molecular backscatter profile
load('betaAvg.mat');         % Load average molecular backscatter
betaAvg = betaAvg(1:200);     % Use only the first 200 range bins

%% Smooth key fields for noise reduction

% Smooth SNR using Gaussian smoothing (first along range, then time)
signalToNoiseRatioSmooth = smoothdata(...
    smoothdata(HaloData.signalToNoiseRatio, 1, 'gaussian', 5), 2, 'gaussian', 30);

% Smooth attenuated backscatter similarly
attenuatedBackscatterSmooth = smoothdata(...
    smoothdata(HaloData.attenuatedBackscatter, 1, 'gaussian', 5), 2, 'gaussian', 30);

% Smooth 5x5 variance of vertical wind
windVariance5x5Smooth = smoothdata(...
    smoothdata(CloudData.windVariance5x5, 1, 'gaussian', 5), 2, 'gaussian', 30);

%% Define cloud detection conditions

% Condition 1: Variance of attenuated backscatter greater than threshold
condition1 = CloudData.attenuatedBackscatterVariance5x5 > 0.0005;

% Condition 2: High signal-to-noise ratio
condition2 = signalToNoiseRatioSmooth > 0.1 | HaloData.signalToNoiseRatio > 0.25;

% Condition 3: Strong backscatter relative to molecular background
ratio = attenuatedBackscatterSmooth ./ repmat(betaAvg, [1, length(HaloData.time)]);
ratioRaw = HaloData.attenuatedBackscatter ./ repmat(betaAvg, [1, length(HaloData.time)]);
condition3 = ratio > 20 | ratioRaw > 40;

% Condition 4: Low variance in vertical wind (to avoid turbulence contamination)
condition4 = CloudData.windVariance5x5 < 0.2 | windVariance5x5Smooth < 0.5;

%% Combine all conditions into a cloud mask
Mask.cloudMask = condition1 & condition2 & condition3 & condition4;

% Save mask also into CloudData structure
CloudData.cloudMask = Mask.cloudMask;

end
