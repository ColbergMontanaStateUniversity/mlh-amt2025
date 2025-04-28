## Requirements

This section of the project uses both **Python** and **MATLAB**:

- Python is required to download HRRR model data using the Herbie library.
- MATLAB is used for processing the HRRR data and performing operations on the data.
---

## Python Setup

This project uses **Miniconda** and was developed with **Python 3.12.9**. You’ll need either [Miniconda or Anaconda](https://docs.conda.io/en/latest/miniconda.html#latest-miniconda-installer-links) installed to recreate the environment.

Miniconda is recommended if you prefer a lightweight installation.

To set up the Python environment:

## MATLAB Setup

Tested with **MATLAB R2024a**  
No additional toolboxes are required.

### Step 1: Download the environment file

Download `herbie_env_full.yml` from this repository.

### Step 2: Create and activate the environment

```bash
conda env create -f herbie_env_full.yml
conda activate herbie_env
```

This will install all required packages, including:
- `herbie` for accessing HRRR model output
- `cfgrib` for reading GRIB2 files
- `xarray`, `pyproj`, `metpy`, and other scientific packages

## Step 3. Run the python script for downloading HRRR files

**Note:** the lattitude, longitude, and altitude are set to the M^2HATS site

Run the Python script `download_hrrr_files.py`.  
This will create new folders for each day processed.

```
HRRR_data/YYYYMMDD/
```

Each folder contains hourly NetCDF files from the HRRR model.  
**Note:** HRRR times are in **UTC**, not local time.

## Step 4. Run the matlab script to process the HRRR data

**Note:** `load_hrrr_data` has a pressure cutoff of 875 hPa (This is below the ground in Tonopah)
**Note:** `load_hrrr_data` has a time zone shift of UTC -7, which is spcific to PDT, local time for Tonopah, Nevada during the M^2HATS experiment
**Note:** `concatenate_hrrr_data` has an elevation input, which is set to the M^2HATS site

Run the main script `diagnose_mlh_hrrr` and set Path.date1 to the YYYYMMDD of the desired day and Path.date2 to the next day 

---
