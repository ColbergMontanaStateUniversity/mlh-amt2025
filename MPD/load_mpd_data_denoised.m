function [MPDDenoised] = load_mpd_data_denoised(Path,filename)

% navigate to the folder with the MPD data
cd(Path.data)

% load the data
MPDDenoised.time                                        = h5read(filename, '/time');
MPDDenoised.range                                       = h5read(filename, '/range');
MPDDenoised.temperature                                 = h5read(filename, '/Temperature');
MPDDenoised.temperatureMask                            = h5read(filename, '/Temperature_mask');
MPDDenoised.temperatureUncertainty                     = h5read(filename, '/Temperature_uncertainty');
MPDDenoised.absoluteHumidity                           = h5read(filename, '/Absolute_Humidity');
MPDDenoised.absoluteHumidityMask                      = h5read(filename, '/Absolute_Humidity_mask');
MPDDenoised.absoluteHumidityUncertainty               = h5read(filename, '/Absolute_Humidity_uncertainty');
MPDDenoised.backscatterRatio                           = h5read(filename, '/Backscatter_Ratio');
MPDDenoised.backscatterRatioMask                      = h5read(filename, '/Backscatter_Ratio_mask');
MPDDenoised.backscatterRatioUncertainty               = h5read(filename, '/Backscatter_Ratio_uncertainty');
MPDDenoised.aerosolBackscatterCoefficient             = h5read(filename, '/Aerosol_Backscatter_Coefficient');
MPDDenoised.aerosolBackscatterCoefficientMask        = h5read(filename, '/Aerosol_Backscatter_Coefficient_mask');
MPDDenoised.aerosolBackscatterCoefficientUncertainty = h5read(filename, '/Aerosol_Backscatter_Coefficient_uncertainty');
MPDDenoised.pressureEstimate                           = h5read(filename, '/Pressure_Estimate');
MPDDenoised.pressureEstimateMask                      = h5read(filename, '/Pressure_Estimate_mask');
MPDDenoised.pressureEstimateUncertainty               = h5read(filename, '/Pressure_Estimate_uncertainty');
MPDDenoised.surfaceAbsoluteHumidity                   = h5read(filename, '/Surface_Absolute_Humidity');
MPDDenoised.surfaceTemperature                         = h5read(filename, '/Surface_Temperature');
MPDDenoised.surfacePressure                            = h5read(filename, '/Surface_Pressure');
MPDDenoised.relativeHumidity                           = h5read(filename, '/Relative_Humidity');
MPDDenoised.relativeHumidityMask                      = h5read(filename, '/Relative_Humidity_mask');
MPDDenoised.relativeHumidityUncertainty               = h5read(filename, '/Relative_Humidity_uncertainty');

%navigate back to the home folder
cd(Path.home)

end