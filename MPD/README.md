## Requirements

This section of the project uses **MATLAB**

## MATLAB Setup

Tested with **MATLAB R2024a**  
No additional toolboxes are required.

### Step 1: Download the MPD Data

The Denoised MPD data is found here: https://doi.org/10.26023/Z6F4-1NVX-VX09

Save the data and put it in the `MPD_Data_Denoised` folder

The Unfiltered data is found here: https://doi.org/10.26023/2286-1446-JV0E

Save the data and put it in the `MPD_Data_Unfiltered` folder

### Step 2: Run the netCDF processing code

The `process_MPD_data_denoised.m` script converts the denoised data netCDF file to a day of data in local time.
***Note*** the function `concatenate_MPD_data_denoised` contains a PDT to UTC time correction.
The `process_MPD_data_unfiltered.m` script converts the denoised data netCDF file to a day of data in local time.
***Note*** the function `concatenate_MPD_data_unfiltered` contains a PDT to UTC time correction.

### Step 3. Run the cloud detection and masking code

The `locate_clouds_and_create_mask.m` script will locate clouds within the unfiltered MPD data and create a cloud mask.

### Step 4. Run the HWT code



### Step 5. Run the MPD-Aerosol code



### Step 6. Run the MPD-Thermodynamic code



### File Descriptions
### MATLAB Functions, Scripts, and Files


### Other Files
`SunriseSunsetTable.csv`
Table listing sunrise and sunset times for each date, used to constrain daytime analyses.

---
