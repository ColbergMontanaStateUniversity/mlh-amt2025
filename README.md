# MLH_AMT_Paper
Code and data processing scripts supporting the paper "Mixed Layer Height Retrievals Using MicroPulse Differential Absorption Lidar," submitted to Atmospheric Measurement Techniques. Includes retrieval algorithms for MPD-aerosol, MPD-thermodynamic, DWL, radiosondes, and the HRRR model.

The study presents and compares multiple algorithms for estimating the mixed layer height from remote sensing and model data collected during the M²HATS campaign in Tonopah, Nevada.

## Repository Structure

Each folder below contains code and a README with additional detail:

- [`MPD`](MPD/) – Haar wavelet method for aerosol backscatter gradient-based MLH retrieval. Parcel method applied to virtual potential temperature profiles retrieved from MPD.
- [`DWL`](DWL/) – Doppler wind lidar vertical velocity variance method.
- [`radiosonde`](radiosonde/) – Bulk Richardson number and parcel MLH retrievals from radiosondes.
- [`HRRR`](HRRR/) – HRRR MLH estimates.

Each subdirectory includes:
- Required scripts or notebooks
- Example input/output data (or links to data repository)
- Instructions for running the method

## Citation

If you use this code, please cite:

Colberg, L., Repasky, K. S., Spuler, S. M., Hayman, M., & Stillwell, R. A. (2025). Mixed Layer Height Retrievals Using MicroPulse Differential Absorption Lidar. Manuscript submitted to Atmospheric Measurement Techniques.
[10.5194/egusphere-2025-1989]

## Contact

For questions, please contact:  
Luke Colberg – `lukecolberg@montana.edu`

## Colormap Attribution

This project uses perceptually uniform scientific colormaps developed by Fabio Crameri. These colormaps are designed to accurately represent data, minimize visual distortion, and remain accessible to those with color vision deficiencies.

The colormaps are distributed under the [MIT License](https://github.com/GenericMappingTools/cpt-city/blob/master/cpt/Crameri/LICENSE), and are described in the following publication:

> Crameri, F., Shephard, G. E., & Heron, P. J. (2020). The misuse of colour in science communication. *Nature Communications*, 11, 5444. https://doi.org/10.1038/s41467-020-19160-7
