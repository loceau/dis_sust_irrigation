/****************************************************************************************************************
Paper:			The role of development institutions in advancing sustainable irrigation

Authors:		Cesar Augusto Lopez, Rosamond L. Naylor, and James Holland Jones
				
Dataset(s):		WB Open Data portal - Land area
Source: 		https://data.worldbank.org/

Description: 	WB estimates of Land Area and Agricultural land (sq. km) for 2021	
			
Last modified: 	March, 2024
****************************************************************************************************************/


/* Directory and globals */
clear all
set more off

	* MAC Directory
	cd "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/WB_land" // apply your directory
	global userdir "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/WB_land/"

	global do_files  "$userdir/do" 
	global log_files "$userdir/log"
	global out_files "$userdir/data/out"
	global in_files  "$userdir/data/in"
	


*** Import data
import excel "$in_files/land_clean.xls", sheet("Data") firstrow


*** Data cleaning

	* Rounding to 2 decimal places
	
		* Land area
		replace land_area_km2 = round(land_area_km2/1000000, 0.001)
		label variable land_area_km2 "Land area (km2, millions)"
		
		* Agriculural land
		replace ag_land_km2 = round(ag_land_km2/1000000, 0.001)
		label variable ag_land_km2 "Agriculural land (km2, millions)"
	
	

*** Saving data
keep country_name land_area_km2 ag_land_km2
compress
save "$out_files/wb_land.dta", replace
export delimited using "$out_files/wb_land.csv", replace
	