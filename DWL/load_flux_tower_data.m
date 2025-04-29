function [Data] = load_flux_tower_data(Path, Filename)
% This function loads flux tower data from a specified NetCDF file.
% It extracts time, temperature, pressure, and water vapor measurements 
% at different times of the day and returns them in a structure.

% Inputs:
%   Path     - Structure containing folder paths
%   Filename - Name of the NetCDF file to load

% Outputs:
%   Data     - Structure containing the extracted variables

% Change directory to the data folder
cd(Path.data)

% Load time variable
Data.time = ncread(Filename, 'time');

% Load flux, temperature, pressure, and water vapor variables at each timestamp
Data.wTc4mT0  = ncread(Filename, 'w_tc__4m_t0'); 
Data.wH2o4mT0 = ncread(Filename, 'w_h2o__4m_t0'); 
Data.tc4mT0   = ncread(Filename, 'tc_4m_t0');     
Data.p4mT0    = ncread(Filename, 'P_4m_t0');      
Data.h2o4mT0  = ncread(Filename, 'h2o_4m_t0');

Data.wTc4mT2  = ncread(Filename, 'w_tc__4m_t2'); 
Data.wH2o4mT2 = ncread(Filename, 'w_h2o__4m_t2'); 
Data.tc4mT2   = ncread(Filename, 'tc_4m_t2');     
Data.p4mT2    = ncread(Filename, 'P_4m_t2');      
Data.h2o4mT2  = ncread(Filename, 'h2o_4m_t2');

Data.wTc4mT5  = ncread(Filename, 'w_tc__4m_t5'); 
Data.wH2o4mT5 = ncread(Filename, 'w_h2o__4m_t5'); 
Data.tc4mT5   = ncread(Filename, 'tc_4m_t5');     
Data.p4mT5    = ncread(Filename, 'P_4m_t5');      
Data.h2o4mT5  = ncread(Filename, 'h2o_4m_t5');

Data.wTc4mT8  = ncread(Filename, 'w_tc__4m_t8'); 
Data.wH2o4mT8 = ncread(Filename, 'w_h2o__4m_t8'); 
Data.tc4mT8   = ncread(Filename, 'tc_4m_t8');     
Data.p4mT8    = ncread(Filename, 'P_4m_t8');      
Data.h2o4mT8  = ncread(Filename, 'h2o_4m_t8');

Data.wTc4mT11 = ncread(Filename, 'w_tc__4m_t11'); 
Data.wH2o4mT11= ncread(Filename, 'w_h2o__4m_t11'); 
Data.tc4mT11  = ncread(Filename, 'tc_4m_t11');    
Data.p4mT11   = ncread(Filename, 'P_4m_t11');     
Data.h2o4mT11 = ncread(Filename, 'h2o_4m_t11');

Data.wTc4mT14 = ncread(Filename, 'w_tc__4m_t14'); 
Data.wH2o4mT14= ncread(Filename, 'w_h2o__4m_t14'); 
Data.tc4mT14  = ncread(Filename, 'tc_4m_t14');    
Data.p4mT14   = ncread(Filename, 'P_4m_t14');     
Data.h2o4mT14 = ncread(Filename, 'h2o_4m_t14');

Data.wTc4mT17 = ncread(Filename, 'w_tc__4m_t17'); 
Data.wH2o4mT17= ncread(Filename, 'w_h2o__4m_t17'); 
Data.tc4mT17  = ncread(Filename, 'tc_4m_t17');    
Data.p4mT17   = ncread(Filename, 'P_4m_t17');     
Data.h2o4mT17 = ncread(Filename, 'h2o_4m_t17');

Data.wTc4mT20 = ncread(Filename, 'w_tc__4m_t20'); 
Data.wH2o4mT20= ncread(Filename, 'w_h2o__4m_t20'); 
Data.tc4mT20  = ncread(Filename, 'tc_4m_t20');    
Data.p4mT20   = ncread(Filename, 'P_4m_t20');     
Data.h2o4mT20 = ncread(Filename, 'h2o_4m_t20');

Data.wTc4mT23 = ncread(Filename, 'w_tc__4m_t23'); 
Data.wH2o4mT23= ncread(Filename, 'w_h2o__4m_t23'); 
Data.tc4mT23  = ncread(Filename, 'tc_4m_t23');    
Data.p4mT23   = ncread(Filename, 'P_4m_t23');     
Data.h2o4mT23 = ncread(Filename, 'h2o_4m_t23');

Data.wTc4mT26 = ncread(Filename, 'w_tc__4m_t26'); 
Data.wH2o4mT26= ncread(Filename, 'w_h2o__4m_t26'); 
Data.tc4mT26  = ncread(Filename, 'tc_4m_t26');    
Data.p4mT26   = ncread(Filename, 'P_4m_t26');     
Data.h2o4mT26 = ncread(Filename, 'h2o_4m_t26');

Data.wTc4mT29 = ncread(Filename, 'w_tc__4m_t29'); 
Data.wH2o4mT29= ncread(Filename, 'w_h2o__4m_t29'); 
Data.tc4mT29  = ncread(Filename, 'tc_4m_t29');    
Data.p4mT29   = ncread(Filename, 'P_4m_t29');     
Data.h2o4mT29 = ncread(Filename, 'h2o_4m_t29');

Data.wTc4mT32 = ncread(Filename, 'w_tc__4m_t32'); 
Data.wH2o4mT32= ncread(Filename, 'w_h2o__4m_t32'); 
Data.tc4mT32  = ncread(Filename, 'tc_4m_t32');    
Data.p4mT32   = ncread(Filename, 'P_4m_t32');     
Data.h2o4mT32 = ncread(Filename, 'h2o_4m_t32');

Data.wTc4mT35 = ncread(Filename, 'w_tc__4m_t35'); 
Data.wH2o4mT35= ncread(Filename, 'w_h2o__4m_t35'); 
Data.tc4mT35  = ncread(Filename, 'tc_4m_t35');    
Data.p4mT35   = ncread(Filename, 'P_4m_t35');     
Data.h2o4mT35 = ncread(Filename, 'h2o_4m_t35');

Data.wTc4mT38 = ncread(Filename, 'w_tc__4m_t38'); 
Data.wH2o4mT38= ncread(Filename, 'w_h2o__4m_t38'); 
Data.tc4mT38  = ncread(Filename, 'tc_4m_t38');    
Data.p4mT38   = ncread(Filename, 'P_4m_t38');     
Data.h2o4mT38 = ncread(Filename, 'h2o_4m_t38');

Data.wTc4mT41 = ncread(Filename, 'w_tc__4m_t41'); 
Data.wH2o4mT41= ncread(Filename, 'w_h2o__4m_t41'); 
Data.tc4mT41  = ncread(Filename, 'tc_4m_t41');    
Data.p4mT41   = ncread(Filename, 'P_4m_t41');     
Data.h2o4mT41 = ncread(Filename, 'h2o_4m_t41');

Data.wTc4mT44 = ncread(Filename, 'w_tc__4m_t44'); 
Data.wH2o4mT44= ncread(Filename, 'w_h2o__4m_t44'); 
Data.tc4mT44  = ncread(Filename, 'tc_4m_t44');    
Data.p4mT44   = ncread(Filename, 'P_4m_t44');     
Data.h2o4mT44 = ncread(Filename, 'h2o_4m_t44');

Data.wTc4mT47 = ncread(Filename, 'w_tc__4m_t47'); 
Data.wH2o4mT47= ncread(Filename, 'w_h2o__4m_t47'); 
Data.tc4mT47  = ncread(Filename, 'tc_4m_t47');    
Data.p4mT47   = ncread(Filename, 'P_4m_t47');     
Data.h2o4mT47 = ncread(Filename, 'h2o_4m_t47');

% Return to the home directory
cd(Path.home)

end