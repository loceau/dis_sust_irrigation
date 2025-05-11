/****************************************************************************************************************
Paper:			The role of development institutions in advancing sustainable irrigation

Authors:		Cesar Augusto Lopez, Rosamond L. Naylor, and James Holland Jones
				
Dataset(s):		World Bank historical classification by income  
Source: 		https://datatopics.worldbank.org/world-development-indicators/the-world-by-income-and-region.html

Description: 	Classification of countries as LMICs based on the WB's historical classification from 2000 to 2022	
			
Last modified: 	March 7, 2023
****************************************************************************************************************/


/* Directory and globals */
clear all
set more off

	* MAC Directory
	cd "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/lmics_classification" // apply your directory
	global userdir "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/lmics_classification/"

		global do_files  "$userdir/do" 
		global log_files "$userdir/log"
		global out_files "$userdir/data/out"
		global in_files  "$userdir/data/in"
		



*** Import data
import excel "$in_files/OGHIST_clean.xlsx", sheet("Sheet1") firstrow	// n=218 observations



*** Data cleaning

	/* 	Identifying number of times a country was classified as "High income (H)" vs non-high income
		(i.e., low income (L), lower middle income (LM), and upper middle income (UM).
		For simplicity, we will combine L+LM+UM = LMICs (low- and middle-income countries)			*/
		
	* High income (H) count
	egen high_count = rcount(FY00- FY22), cond(@=="H")
	
	* LMICs count
	egen lmic_count = rcount(FY00- FY22), cond(@=="L" | @=="LM" | @=="UM")
	
	* Missing count
	egen miss_count = rcount(FY00- FY22), cond(@=="")
	
	
	* LMICs classification
	gen lmic = 1 if (lmic_count > high_count) & (miss_count == 0)					// mostly classified as LMIC (80 missing values generated)
	replace lmic = 0 if lmic == . & (lmic_count < high_count) & (miss_count == 0)	// mostly classified as high income (65 real changes made)
	replace lmic = 1 if lmic == . & (high_count == 0)								// missing classification for some years, for the rest classifed as LMIC (6 real changes made)
	replace lmic = 0 if lmic == . & (lmic_count == 0)								// missing classification for some years, for the rest classifed as high income (7 real changes made)
	replace lmic = 1 if lmic == . & acronym == "VEN" 								// Venezuela, classified 21 times as LMIC and 1 as high (1 real change made)
	replace lmic = 0 if lmic == . & acronym == "NRU" 								// Nauro, classified 3 times as high income and 3 as upper middle (1 real change made)
	label variable lmic "LMICs classification 2000-22 (1=yes, 0=no)"

	
*** Saving data
keep acronym country_name lmic
compress
save "$out_files/wb_lmic_classification.dta", replace
export delimited using "$out_files/wb_lmic_classification.csv", replace

	
	
	
