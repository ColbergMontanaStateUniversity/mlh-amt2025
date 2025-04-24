# MLH_AMT_Paper
Code and data processing scripts supporting the paper "Mixed Layer Height Retrievals Using MicroPulse Differential Absorption Lidar," submitted to Atmospheric Measurement Techniques. Includes retrieval algorithms for MPD-aerosol, MPD-thermodynamic, Doppler wind lidar (DWL), radiosondes, and the HRRR model.

The study presents and compares multiple algorithms for estimating the mixed layer height (MLH) from remote sensing and model data collected during the M²HATS campaign in Tonopah, Nevada.

## Repository Structure

Each folder below contains code and a README with additional detail:

- [`MPD-aerosol`](MPD-aerosol/) – Haar wavelet method for aerosol backscatter gradient-based MLH retrieval.
- [`MPD-thermodynamic`](MPD-thermodynamic/) – Parcel method applied to virtual potential temperature profiles retrieved from MPD.
- [`DWL`](DWL/) – Doppler wind lidar vertical velocity variance method.
- [`radiosonde`](radiosonde/) – Bulk Richardson number and parcel-based MLH retrievals from radiosondes.
- [`HRRR`](HRRR/) – HRRR-derived MLH estimates.

## Getting Started

Each subdirectory includes:
- Required scripts or notebooks
- Example input/output data (if applicable)
- Instructions for running the method

## Citation

If you use this code, please cite:

Colberg, L., Repasky, K. S., Spuler, S. M., Hayman, M., & Stillwell, R. A. (2025). Mixed Layer Height Retrievals Using MicroPulse Differential Absorption Lidar. Manuscript submitted to Atmospheric Measurement Techniques.
[DOI or preprint link here]

## Contact

For questions, please contact:  
Luke Colberg – `lukecolberg@montana.edu`
