# Radiosonde MLH Diagnostics

This repository contains MATLAB code for retrieving the mixed layer height (MLH) from radiosonde data using the parcel method and bulk Richardson number method.

## Data Download

Radiosonde and surface meteorological data used in this project can be downloaded from the National Center for Atmospheric Research (NCAR).

- Radiosonde Data:  
  [Provide link to NCAR sounding archive, e.g., CLASS or FTP]  
  Example filename: `NCAR_M2HATS_ISS1_RS41_v1_YYYYMMDD_HHMMSS_asc.nc`

- Surface Station Data:  
  [Provide link to 3m tower or surface meteorological data source from NCAR]  
  Example filename: `iss2_m2hats_sfcmet_3mtower_YYYYMMDD.nc`

Place the downloaded files in the corresponding folders:

- [`radiosonde_data/`](./radiosonde_data/) — Put all radiosonde `.nc` files here  
- [`surface_data/`](./surface_data/) — Put all surface data `.nc` files here

## Running the Code

The main script is:
diagnose_radiosonde_MLH.m

This script:
- Loads radiosonde and surface data
- Applies multiple MLH retrieval methods
- Plots profiles and saves the results

To run:
1. Open the `radiosondes/` folder in MATLAB.
2. Run the script: diagnose_radiosonde_mlh
   
## Function Descriptions

### `diagnose_radiosonde_mlh.m`
Main script that coordinates data loading, MLH calculation, and plotting.

### `load_radiosonde_data.m`
Loads a single radiosonde profile into a structured format from a NetCDF file.

### `load_surface_data.m`
Loads surface station data from a 3-meter tower into a structured format.

### `compute_mlh_parcel_standard.m`
Applies the standard Holzworth (1964)-style parcel method using virtual potential temperature.

### `compute_mlh_parcel_offset1K.m`
Modified parcel method using a +1 K offset to account for uncertainty or early layer growth.

### `compute_mlh_bulk_ri.m`
Implements the bulk Richardson number method using a critical threshold of 0.25 to estimate MLH.

---

## Notes

- The critical bulk Richardson number used is 0.25.
- Note that this code uses a local gravitational constant for Tonopah, Nevada, USA in `compute_mlh_bulk_ri.m`. Do not use for other datasets without changing this.

## License

This project is released under the MIT License. See LICENSE file for details
