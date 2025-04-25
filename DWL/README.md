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
conda env create -f DWL_env_full.yml
conda activate herbie_env
```

This will install all required packages, including:
- `netCDF4` and `hdf5` for reading atmospheric data files
- `numpy` for numerical operations
- `cftime` for time handling in climate data

### Step 3. Download the DWL data

The DWL data is available here: https://doi.org/10.26023/R75F-FGJ8-VG12

Download the data. There will be 24 hourly files per day. naming convention: `Stare_122_YYYYMMDD_hh_.hpl
These files will be in folders labeled 'pwd/YYYYMM/YYYYMMDD'

### Step 4. Run the python DWL decoding script

make sure that 'halo_dl_decode.py' is in the same directory as the YYYYMM folders run the code.
***Note*** This code was throwing errors when ran from spyder, but had no issues when ran directly from anaconda prompt

This code will convert the .hpl files into netCDF files in the same folders named: 'fp_YYYYMMDD_hhmmss.nc'

### Step 5. Run the MATLAB condensing code

This code will convert the 24 netCDF files into a .mat file containing the data integrated to 30 meters and 10 s
