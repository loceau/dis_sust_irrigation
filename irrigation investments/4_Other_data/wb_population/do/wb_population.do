/****************************************************************************************************************
Paper:			The role of development institutions in advancing sustainable irrigation

Authors:		Cesar Augusto Lopez, Rosamond L. Naylor, and James Holland Jones
				
Dataset(s):		WB Open Data portal - population, total
Source: 		https://databank.worldbank.org/source/population-estimates-and-projections

Description: 	Average population, by country, for the period 2000-2021
			
Last modified: 	February 2023
****************************************************************************************************************/

/* Directory and globals */
clear all
set more off

	* MAC Directory		
	cd "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/wb_population" 				// apply your directory
	global userdir "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/wb_population/"

		global do_files  "$userdir/do" 
		global log_files "$userdir/log"
		global out_files "$userdir/data/out"
		global in_files  "$userdir/data/in"


***** STEP 1: Importing data
import excel "$in_files/population_clean.xls", sheet("Data") firstrow



***** STEP 2: Data cleaning

	* Average (period 2000-2022) 
	egen pop_mean = rmean(y_2000 - y_2022)
	replace pop_mean = round(pop_mean, 1)					// rounding to nearest whole number
	label variable pop_mean "Population mean (2000-2022)" 
	

* Saving data
keep country_name country_code pop_mean
compress
save "$out_files/wb_population_mean.dta", replace
export delimited using "$out_files/wb_population_mean.csv", replace
	