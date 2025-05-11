/****************************************************************************************************************
Paper:			The role of development institutions in advancing sustainable irrigation

Authors:		Cesar Augusto Lopez, Rosamond L. Naylor, and James Holland Jones

Datasets used:  (1) AQUASTAT (irrigation potential & AEI)
				(2) FAOSTAT (cropland)
				
Description: 	Figures for appendix (irrigation potential)
				for countries with missing data
			
Last modified: 	April, 2024
****************************************************************************************************************/


/* Directory and globals */
clear all
set more off

	* MAC Directory
	cd "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/un_irrigation_data" 				// apply your directory
	global userdir "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/un_irrigation_data/"
	

	global do_files  "$userdir/do" 
	global log_files "$userdir/log"
	global data_files "$userdir/data"
	global out_files "$userdir/data/dta_data_collection"
	global in_files  "$userdir/data/ifis_data_collection_individual"


	
*** STEP 1: Create dataset

	* Import FAOSTAT data (cropland in 2000 and 2021)
	import delimited "$data_files/un_data/FAOSTAT_data_en_4-15-2024.csv", clear
	
		* Drop countries without data for 2000 and 2021
		quietly bysort areacodem49: gen dup = cond(_N==1,0,_n)
		drop if dup == 0					// Countries with data for only 2000 or 2021
		drop dup flag* note	yearcode		// no longer necessary)
		sort areacodem49 year
	
		* Long to wide
		reshape wide value, i(areacodem49) j(year)
		
		* Saving data
		rename area country
		save "$out_files/FAOSTAT_data_en_4-15-2024.dta", replace
		
		
	* Merge AQUASTAT data (irrigation potential in/near 2000)
	use "$out_files/un_potential.dta", clear
		
		* Keep if data is for 2000
		tab year
		keep if year == 2000
		
		* Merge FAOSTAT data
		merge 1:1 country using "$out_files/FAOSTAT_data_en_4-15-2024.dta"
		keep if _merge == 3 	// keep obs. that merge
		drop _merge				// no longer necessary
		
	



*** STEP 2: Creating figures

	* Converting values to natural log
	gen cropL2000_ln = log(value2000)
	gen cropL2021_ln = log(value2021)
	gen potential_ln = log(potential)
	
	* Set scheme
	set scheme s1mono

	
	* Figure 1: Cropland in 2000 and 2021
	reg cropL2021_ln cropL2000_ln
	local r2: display %5.4f e(r2)
	twoway (lfit cropL2000_ln cropL2021_ln) (scatter cropL2000_ln cropL2021_ln, msymbol(o) msize(small) mcolor(black)), note(R-squared=`r2') legend(off)	///
	xtitle("Cropland in 2021 (log)")

	* Figure 2: Cropland in 2021 and irrigation potential in 2000
	reg cropL2000_ln potential_ln
	local r2b: display %5.4f e(r2)
	twoway (lfit cropL2000_ln potential_ln) (scatter cropL2000_ln potential_ln, msymbol(o) msize(small) mcolor(black)), note(R-squared=`r2b') legend(off)	///
	xtitle("Irrigation potential in 2000 (log)")




		
	

