function [HWT] = apply_hwt(HWT)
% This function applies the Haar Wavelet Transform (HWT) to the
% normalized aerosol backscatter coefficient to detect vertical
% structures in the atmospheric profile.

% Extract variables
x = HWT.normalizedAerosolBackscatterCoefficient;
t = HWT.time;
r = HWT.rangeAerosolBackscatterCoefficient;

% Define dilation scales (spatial scales) to apply the wavelet
dilation = 6*(r(2)-r(1)) : 2*(r(2)-r(1)) : 24*(r(2)-r(1));

% Preallocate the wavelet transform output array
h = zeros(length(x(:,1))-1, length(x(1,:)), length(dilation));

% Loop over dilation scales
for i = 1:length(dilation)
    [temp, temp_r] = localHWT(x, dilation(i), r); % Apply local Haar Wavelet Transform
    h(:,:,i) = temp; % Save the transform at each dilation

    if i == 1
        rangeHWT = temp_r; % Save range vector (only needs to be done once)
    end
end

% Save outputs to structure
HWT.waveletCovarianceTransformation = h;
HWT.waveletCovarianceTransformationMask = isnan(h);
HWT.rangeHaarWaveletTransformation = rangeHWT;
HWT.dilation = dilation;

% Define a height-dependent preferred dilation (y = 0.25*z + 75)
y = 0.25 * HWT.rangeHaarWaveletTransformation + 75;

% Preallocate outputs for selected Haar coefficients and dilation choices
HWT.haarWaveletTransformation = zeros(length(HWT.rangeHaarWaveletTransformation), length(HWT.time));
HWT.dilationChoice = zeros(size(HWT.rangeHaarWaveletTransformation));

% Loop over heights and select the best dilation at each range bin
for i = 1:length(HWT.rangeHaarWaveletTransformation)
    [~, HWT.dilationChoice(i)] = min(abs(y(i) - HWT.dilation)); % Find dilation closest to preferred
    HWT.haarWaveletTransformation(i,:) = HWT.waveletCovarianceTransformation(i,:,HWT.dilationChoice(i));
end

end

%% Local function for applying the Haar Wavelet Transform
function [H, r] = localHWT(f, a, rData)
% Applies a Haar Wavelet Transform at a specified dilation 'a'

% Define the kernel (wavelet) length based on the dilation and range spacing
kernelLength = round(a / (rData(2) - rData(1)));

% Create the Haar wavelet kernel (step function: -1 in first half, +1 in second half)
kernel = zeros(kernelLength, 1);
kernel(1:kernelLength/2) = -1 / (kernelLength/2);
kernel(kernelLength/2+1:end) = 1 / (kernelLength/2);

% Perform convolution of the input field f with the kernel
H = convn(f, kernel);

% Remove edge effects created by the convolution
H(1:kernelLength/2,:) = [];
H(end-kernelLength/2+1:end,:) = [];

% Set edges to NaN
H(1:kernelLength/2,:) = NaN;
H(end-kernelLength/2+1:end,:) = NaN;

% Create output range vector as midpoints between input range levels
r = (rData(2:end) + rData(1:end-1)) / 2;

end