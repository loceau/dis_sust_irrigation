/****************************************************************************************************************
Paper:			The role of development institutions in advancing sustainable irrigation

Authors:		Cesar Augusto Lopez, Rosamond L. Naylor, and James Holland Jones

Description: 	Cleaning United Nations irrigation-related data (% of irrigation potential under irrigation)
			
Last modified: 	March, 2024
****************************************************************************************************************/

/* Directory and globals */
clear all
set more off

	* MAC Directory
	cd "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/un_irrigation_data" 				// apply your directory
	global userdir "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/un_irrigation_data/"

	global do_files  "$userdir/do" 
	global csv_files "$userdir/csv"
	global log_files "$userdir/log"
	global data_files "$userdir/data"
	global out_files "$userdir/data/out"
	global in_files  "$userdir/data/in"
	global tables_files  "$userdir/tables"
	
	
	


*** STEP 1: Data cleaning

import delimited "$in_files/AQUASTAT Statistics Bulk Download (EN).csv", clear
drop symbol symboldescription		// not necessary
	
	
	* Constructing the dataset
		
		* Irrigation potential
		preserve
		keep if variable == "Irrigation potential"									// (808,195 observations deleted)
		rename value potential
		keep v1 country m49 year potential
		save "$out_files/un_potential", replace
		restore
		
		* % of irrigation potential equipped for irrigation - FAO's estimate for our variable of interst
		preserve
		keep if variable == "% of irrigation potential equipped for irrigation"		// (810,905 observations deleted)
		rename value share_un
		keep v1 country m49 year share_un
		save "$out_files/un_share", replace
		restore		
		
		* Area equipped for irrigation
		keep if variable == "Area equipped for irrigation: total" 					// (809,097 observations deleted)
		rename value area_irrigation
		keep v1 country m49 year area_irrigation
		save "$out_files/area_irrigation", replace
		
		* merge datasets 
		merge 1:1 country year using "$out_files/un_potential"
		drop _merge
		merge 1:1 country year using "$out_files/un_share"
		drop _merge
		
		* Number of countries
		bysort country: gen country_n = _n
		tab country_n if country_n == 1, m							// n=181 countries		
		
		* Area equipped with irrigation in 2000 (% potential)
		gen equipped_share1 = (area_irrigation/potential)*100		// (4,572 missing values generated)
		tab equipped_share1 if year == 2000, m						// n=63 countries in 2000 with missing data
		
			* Checking match with FAO's data for this variable
			replace equipped_share1 = round(equipped_share1, 1)
			replace share_un = round(share_un, 1)
			gen error_share = equipped_share/share_un
			replace error_share = 1 if error_share == . & (equipped_share1 == 0 & share_un == 0) & year == 2000
			tab error_share if year == 2000, m						// n=63 countries with missing data, so the UN data and our manual data give the same result
		
		gen equipped_share2 = equipped_share1 if year == 2000
		egen equipped_share3 = max(equipped_share2), by(country)
		tab equipped_share3 if country_n == 1, m											// One country has over 100%, we need to fix this
		tab country if equipped_share3 > 100 & equipped_share3 != .							// Libya
		br if country == "Libya"															// "Irrigation potential has been estimated at 750 000 ha"
																							// Source: https://www.fao.org/3/w4356e/w4356e0j.htm
		replace equipped_share2 = round(((470*1000)/750000)*100, 1) if country == "Libya" & year == 2000 	// (1 real change made) Area under irrigation in 2000 was 470 (unit=1000 hectares)
		br
			
		
			* Assigning values from previous years (if possible)
			gen possible2 = 1 if (area_irrigation != . & potential != .) & equipped_share3 == .
			tab country if (equipped_share3 == . & possible2 == 1)			// Countries: Chile, Ethiopia, Palestine, Qatar, Saint Vinent, Seychelles, South Sudan & Sudan
			tab year country if (equipped_share3 == . & possible2 == 1)		/* Years for which data is available for our variable of interest:
																				
																				1. Chile 			1109 in 2007	| FAOSTAT: 1100 in 2000 -- potential = 2500
																				2. Ethiopia 		151.2 in 2001	| FAOSTAT: 290 in 2000 (too high compared to 2001?) -- potential = 2700
																				3. Palestine		20.07 in 2001	| FAOSTAT: 20 in 2000 -- potential = 80
																				4. Qatar			12.88 in 2000	| FAOSTAT: 12.7 in 2000 -- potential = 52.13
																				5. Saint Vincent 	0.478 in 2003	| FAOSTAT: 0.5 in 2000 -- potential = 0.655
																			
																			Source: FAOSTAT (https://www.fao.org/faostat/en/?#data) & AQUASTAT
																			*/
			
			replace equipped_share2 = round((1100/2500)*100, 1) if country == "Chile" & year == 2000			// (1 real change made)
			replace equipped_share2 = round((151.2/2700)*100, 1) if country == "Ethiopia" & year == 2001 		// (1 real change made)
			replace equipped_share2 = round((20/80)*100, 1) if country == "Palestine" & year == 2000 			// (1 real change made)
			replace equipped_share2 = round((12.88/52.13)*100, 1) if country == "Qatar" & year == 2000 			// (1 real change made) high-income country
			replace equipped_share2 = round((0.5/0.655)*100, 1) if country == "Saint Vincent and the Grenadines" & year == 2003	// (1 real change made)
			egen irri_share = max(equipped_share2), by(country) // (1,879 missing values generated)
			tab irri_share if country_n == 1, m					// n=67 countries in our dataset do not have this variable
			label variable irri_share "Area equipped for irrigation (% potential)"
			
			* Countries that are still missing this variable
			tab country if irri_share == .		// FAO does not have data about these countries' "irrigation potential". 
												// Therefore, we will use "Cropland" area as a proxy of "irrigation potential"; this is not 100% accurate but an approximation
												// Data on "cropland" area will come directly from FAOSTAT (2000 data)
												
			replace irri_share = round((3206/8051)*100, 1) if country == "Afghanistan"
			replace irri_share = round((340/687.53)*100, 1) if country == "Albania"
			replace irri_share = round((125/5719)*100, 1) if country == "Belarus"
			replace irri_share = round((3/132)*100, 1) if country == "Belize"
			replace irri_share = round((27.295/100)*100, 1) if country == "Bhutan"
			replace irri_share = round((3/1116)*100, 1) if country == "Bosnia and Herzegovina"
			replace irri_share = round((124.5/3649.5179)*100, 1) if country == "Bulgaria"
			replace irri_share = round((269.5/4599.1397)*100, 1) if country == "Cambodia"
			replace irri_share = round((1460/2545)*100, 1) if country == "Democratic People's Republic of Korea"
			replace irri_share = round((0.2/23)*100, 1) if country == "Dominica"
			replace irri_share = round((0/30)*100, 1) if country == "Equatorial Guinea"
			replace irri_share = round((3.4/138.6)*100, 1) if country == "Fiji"
			replace irri_share = round((147.05714/449)*100, 1) if country == "Guyana"
			replace irri_share = round((.56/1371)*100, 1) if country == "Latvia"
			replace irri_share = round((0/4.9)*100, 1) if country == "Maldives"
			replace irri_share = round((2.412/14.4)*100, 1) if country == "Montenegro"
			replace irri_share = round((55/458)*100, 1) if country == "North Macedonia"
			replace irri_share = round((76.885714/4824)*100, 1) if country == "Paraguay"
			replace irri_share = round((3.0782857/54)*100, 1) if country == "Cabo Verde"
			replace irri_share = round((3/9.57)*100, 1) if country == "Saint Lucia"
			replace irri_share = round((86.31/2819)*100, 1) if country == "Serbia"
			replace irri_share = round((0/1)*100, 1) if country == "Seychelles"
			replace irri_share = round((.0354/112)*100, 1) if country == "Solomon Islands"
			replace irri_share = round((1498/12413)*100, 1) if country == "South Africa"
			replace irri_share = round((34.916667/1500)*100, 1) if country == "South Sudan"
			replace irri_share = round((1852/2500)*100, 1) if country == "Sudan"
			replace irri_share = round((51.339333/62)*100, 1) if country == "Suriname"
			replace irri_share = round((1235.2875/5726.617)*100, 1) if country == "Syrian Arab Republic"
			replace irri_share = round((31.208333/191.4)*100, 1) if country == "Timor-Leste"
			replace irri_share = round((621.794/1452)*100, 1) if country == "Yemen"
			
			
			
		* Keeping one obs. per year
		keep if country_n == 1	// (7,748 observations deleted)
		rename country country_un
		gen str3 UN_A3 = string(m49,"%03.0f") // to merge wih the shapefile data
		keep country_un UN_A3 irri_share

		* Saving data
		compress
		save "$out_files/share_irrigation_equipped.dta", replace
