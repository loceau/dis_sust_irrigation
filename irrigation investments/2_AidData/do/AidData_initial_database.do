/****************************************************************************************************************
Paper:			The role of development institutions in advancing sustainable irrigation

Authors:		Cesar Augusto Lopez, Rosamond L. Naylor, and James Holland Jones
				
Dataset(s):		TUFF: Tracking Underreported Financial Flows 
Source: 		https://www.aiddata.org/methods/tracking-underreported-financial-flows

Description: 	Creating our initial database for the review paper using the AidData's TUFF datasets for 
				China, India, Qatar and  Saudi Arabia
			
Last modified: 	March 7, 2023
****************************************************************************************************************/


/* Directory and globals */
clear all
set more off

	* MAC Directory
	cd "/Users/cesaraugusto/Desktop/irrigation investments/2_AidData" 				// apply your directory
	global userdir "/Users/cesaraugusto/Desktop/irrigation investments/2_AidData"
	
		global out_files "$userdir/data/out"
		global in_files  "$userdir/data/in"


**** STEP 1: Import csv files and save them .dta files

	* Qatar 		// data covers the years 2010-2013
	import delimited "$in_files/original_data/Qatar_TUFFDonorDataset_Level1_v1.0.csv", clear
	save "$in_files/qatar_original.dta", replace

	* Saudi Arabia 	// data covers the years 2010-2013
	import delimited "$in_files/original_data/SaudiArabia_TUFFDonorDataset_Level1_v1.0.csv", clear
	save "$in_files/saudi_original.dta", replace
	
	* China			// data covers the years 2000-2017
	import excel "$in_files/original_data/AidDatas_Global_Chinese_Development_Finance_Dataset_Version_2_0/AidDatasGlobalChineseDevelopmentFinanceDataset_v2.0.xlsx", sheet("Global_CDF2.0") firstrow clear
	save "$in_files/china_original.dta", replace
	
	* India			// data covers the years 2007-2014
	// main data already available in .dta format
	import excel "$in_files/original_data/Indian_Development_Finance_Dataset_Version_1.0/ind_aid_global_longdescription", firstrow clear	// Data with project descriptions
	save "$in_files/india_original_descriptions.dta", replace
	
	

	
	
**** STEP 2: Cleaning individual datasets and preparing them for the initial database

	* Qatar
	use "$in_files/qatar_original.dta", clear
	
		* Identifying projects that include the substring "irrig" in title or description
		gen irrigation_title =  strpos(lower(title), "irrig") > 0		// "irrig" in the project title
			tab irrigation_title										// no projects include "irrig" in the title
		
		gen irrigation_descr =  strpos(lower(description), "irrig") > 0	// "irrig" in the description
			tab irrigation_descr										// no projects include "irrig" in the description
		
		/* NO projects in the Qatar data identified as having the substring "irrig"
		within the projects' titles or descriptions. Our initial database for the review
		paper will not include any of the projects from this dataset.
		*/
		
		
	* Saudi Arabia
	use "$in_files/saudi_original.dta", clear

		* Identifying projects that include the substring "irrig" in title or description
		gen irrigation_title =  strpos(lower(title), "irrig") > 0		// "irrig" in the project title
			tab irrigation_title										// n=1 project
		
		gen irrigation_descr =  strpos(lower(description), "irrig") > 0	// "irrig" in the description
			tab irrigation_descr										// n=8 projects
			
		* Keeping projects with the substring "irrig" in the title or descriptions
		gen irrigation_keyword = (irrigation_title == 1 | irrigation_descr == 1)
			tab irrigation_keyword										// n=8 projects
		
		* Saving our Saudi Arabia's initial database
		keep if irrigation_keyword == 1
		compress
		save "$out_files/saudi_initial_database.dta", replace			// n=8
		
	
	* China
	use "$in_files/china_original.dta", clear
	
		* Identifying projects that include the substring "irrig" in title or description
		gen irrigation_title =  strpos(lower(Title), "irrig") > 0		// "irrig" in the project title
			tab irrigation_title										// n=46 projects
	
		gen irrigation_descr =  strpos(lower(Description), "irrig") > 0	// "irrig" in the description
			tab irrigation_descr										// n=220 projects
	
		* Keeping projects with the substring "irrig" in the title or descriptions
		gen irrigation_keyword = (irrigation_title == 1 | irrigation_descr == 1)
			tab irrigation_keyword										// n=221 projects
	
		* Saving our China initial database
		keep if irrigation_keyword == 1
		compress
		save "$out_files/china_initial_database.dta", replace			// n=221
	
	
	* India
	use "$in_files/original_data/Indian_Development_Finance_Dataset_Version_1.0/ind_aid_global_locations_releaseV1.dta", clear
	merge m:1 aiddata_project_id using "$in_files/india_original_descriptions.dta"	
	
		* Identifying projects that include the substring "irrig" in title or description
		gen irrigation_title =  strpos(lower(project_title), "irrig") > 0	// "irrig" in the project title
			tab irrigation_title											// n=12 projects
			
		gen irrigation_descr =  strpos(lower(longdescription), "irrig") > 0	// "irrig" in the project title
			tab irrigation_descr											// n=57 projects			
			
		* Keeping projects with the substring "irrig" in the title or descriptions
		gen irrigation_keyword = (irrigation_title == 1 | irrigation_descr == 1)
			tab irrigation_keyword											// n=57 projects
			
		
		* saving our Indian initial data database
		keep if irrigation_keyword == 1
		compress
		save "$out_files/india_initial_database.dta", replace				// n=57
		
	
	
	
**** STEP 3: Saving dataset for screening process

	* Saudi Arabia
	use "$out_files/saudi_initial_database.dta", clear
	gen dataset = "TUFF-Saudi Arabia"
	gen data_amount_unit = "2009 USD"
	order dataset project_id sources donor title description year recipient_condensed usd_defl data_amount_unit
	keep dataset project_id sources donor title description year recipient_condensed usd_defl data_amount_unit
	save "$out_files/tuff_saudi.dta", replace
	export excel using "$out_files/tuff_saudi.xls", firstrow(variables) replace

	
	* India
	use "$out_files/india_initial_database.dta", clear
	gen dataset = "TUFF-India"
	gen data_amount_unit = "2014 USD"
	gen donor = "India"
	order dataset aiddata_project_id donor project_title longdescription recipientname year usd_commitment_pt_con data_amount_unit
	keep dataset aiddata_project_id donor project_title longdescription recipientname year usd_commitment_pt_con data_amount_unit
	save "$out_files/tuff_india.dta", replace
	export excel using "$out_files/tuff_india.xls", firstrow(variables) replace

	
	* China
	use "$out_files/china_initial_database.dta", clear
	gen dataset = "TUFF-China"
	gen data_amount_unit = "2017 USD"
	order dataset AidDataTUFFProjectID SourceURLs FinancierCountry Title Description Recipient CommitmentYear AmountConstantUSD2017 data_amount_unit
	keep dataset AidDataTUFFProjectID SourceURLs FinancierCountry Title Description Recipient CommitmentYear AmountConstantUSD2017 data_amount_unit
	save "$out_files/tuff_china.dta", replace
	export excel using "$out_files/tuff_china.xls", firstrow(variables) replace	
	
	
	
	
	
	