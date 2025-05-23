# Radiosonde MLH Diagnostics

This folder contains MATLAB code for retrieving the mixed layer height (MLH) from radiosonde data using the parcel method and bulk Richardson number method.

## Requirements

- MATLAB (tested with R2024a)
  
## Data Download

Radiosonde and surface meteorological data used in this project can be downloaded from the National Center for Atmospheric Research (NCAR).

- [Radiosonde Data](https://doi.org/10.26023/WKM7-HNCF-FX0B)  
  Example filename: `NCAR_M2HATS_ISS1_RS41_v1_YYYYMMDD_HHMMSS_asc.nc`

- [Surface Meteorology Data](https://doi.org/10.26023/30XE-MB6C-SC14)  
  Example filename: `iss2_m2hats_sfcmet_3mtower_YYYYMMDD.nc`

Place the downloaded files in the corresponding folders:

- [`radiosonde_data/`](./radiosonde_data/) — Put all radiosonde `.nc` files here  
- [`surface_data/`](./surface_data/) — Put all surface data `.nc` files here

## Running the Code

The main script is written in MATLAB:
diagnose_radiosonde_mlh.m

This script:
- Loads radiosonde and surface data
- Applies multiple MLH retrieval methods
- Plots profiles

To run:
1. Open the `radiosondes/` folder in MATLAB.
2. Run the script: diagnose_radiosonde_mlh
   
---

## Notes

- The critical bulk Richardson number used is 0.25.
- Only use ascending radiosondes, designated with 'asc' in filename.
- Note that this code uses a local gravitational constant for Tonopah, Nevada, USA in `compute_mlh_bulk_ri.m`. Do not use for other datasets without changing this.
