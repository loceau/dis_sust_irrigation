/****************************************************************************************************************
Paper:			The role of development institutions in advancing sustainable irrigation

Authors:		Cesar Augusto Lopez, Rosamond L. Naylor, and James Holland Jones
				
Dataset(s):		CRS: Creditor Reporting System
Source: 		https://data-explorer.oecd.org/

Description: 	Compiling CRS dataset of aid-related activities for the period 2000-2022
			
Last modified: 	November 2023
****************************************************************************************************************/

clear all
set more off



***** STEP 1: Convert files from .txt to .dta files & appending all the CRS datasets

	* Define text files to include 					// this do-file is located in the same folder as the .txt files
	local filepath = "`c(pwd)'" 					// Save path to current folder in a local
	di "`c(pwd)'" 									// Display path to current folder

	local files : dir "`filepath'" files "*.txt" 	// Save name of all files in folder ending with .csv in a local
	di `"`files'"' 									// Display list of files to import data from


	* Loop over all files to import and append each file
	tempfile master 								// Generate temporary save file to store data in
	save `master', replace empty

	foreach x of local files {
		di "`x'" 									// Display file name

		* Import each file and generate id var (filename without ".txt")
		qui: import delimited "`x'",  stringcols(3 5 6 7 10 12 14 16 20 44 45 47 49 51 52 54 57 58 59 78 81 83 84) ///
		numericcols(1 2 4 8 9 11 13 15 17 18 19 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 46 48 50 53 55 56 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 79 80 82 85 86 87 88 89 90 91 92 93) clear charset(utf8) // Each .txt file is structured the same way (variables names and order are the same), so we're specifying which variables are string and numeric
		qui: gen id = subinstr("`x'", ".txt", "", .)

		* Appending each file to our master file
		append using `master', force
		save `master', replace
	}	
	
	count // n=4,712,357

	
	* Checking list of countries		
	tab recipientname, m				// we have some entries that are regional-level investments
	rename recipientname country_name
	drop if (country_name == "Africa, regional" | country_name == "America, regional" | country_name == "Asia, regional" | 	country_name == "Bilateral, unspecified" | 	///
	country_name == "Caribbean & Central America, regional" | country_name == "Caribbean, regional" | country_name == "Central America, regional" | country_name == 	///
	"Central Asia, regional" | country_name == "Eastern Africa, regional" | country_name == "Europe, regional" | country_name == "Far East Asia, regional" | 			///
	country_name == "Melanesia, regional" | country_name == "Micronesia, regional" | country_name == "Middle Africa, regional" | country_name == 						///
	"Middle East, regional " | country_name == "North of Sahara, regional" | country_name == "Oceania, regional" | country_name == "Polynesia, regional" | 				///
	country_name == "South & Central Asia, regional" | country_name == "South America, regional" | country_name == "South Asia, regional" | country_name == 			///
	"South of Sahara, regional" | country_name == "Southern Africa, regional" | country_name == "States Ex-Yugoslavia unspecified" | country_name == 					///
	"Western Africa, regional" | country_name == "Middle East, regional")			// drop non-country (e.g., regional-level) records
	
		* Rename some countries with errors
		replace country_name = "Côte d'Ivoire" if country_name == "CÃ´te d'Ivoire"
		replace country_name = "Türkiye" if country_name == "TÃ¼rkiye"
		
	* Exporting final data		
	sort year country_name
	count	// n=3,893,706
	save "CRS_combined_2000_2022.dta", replace


	
	
	
***** STEP 2: Data cleaning and creating our initial (pre-universe) dataset

	* Projects without an identification number
	tab projectnumber if projectnumber == "", m		// recorsd without a project number. We will exclude them from the analysis
	drop if projectnumber == ""

	* Combining invesments-related commitments by country
	egen crs_total = total(usd_commitment_defl), by(country_name)				// Data already deflated (constant 2021 USD, millions)
	replace crs_total = crs_total * 1000000										// converting to dollar units
	label variable crs_total "CRS: total commitments 2000-2022 (constant 2021 USD)"

	
	* Identifying projects that include the substring "irrig" in title, description or have CRS 5-digit code 31140
	gen irrigation_title =  strpos(lower(projecttitle), "irrig") > 0		// "irrig" in the project title
	gen irrigation_descr =  strpos(lower(longdescription), "irrig") > 0		// "irrig" in the project long description
	gen irrigation_shortDes = strpos(lower(shortdescription), "irrig") > 0	// "irrig" in the project short description
	gen irrigation_crs = (purposecode == 31140)								// 5-digit CRS code for 31140 = Agricultural water resources
	
		* Number of projects with the substring "irrig" in the title or description
		gen irrig_tit_des = (irrigation_title == 1 | irrigation_descr == 1 | irrigation_shortDes == 1)
		tab irrig_tit_des			// records with the substring "irrig" in the project title or project description
		
		* Number of projects with CRS purpose code 31140
		tab irrigation_crs, m		// projects with this code
		tab irrigation_crs irrig_tit_des
		
		* Number of projects with substring "irrig" in the the project title, project description, or with CRS purpose code 31140
		gen irrigation_keyword = (irrigation_title == 1 | irrigation_descr == 1 | irrigation_shortDes == 1 | irrigation_crs == 1) 
		tab irrigation_keyword		// (1.57% of the 3.3 million projects in the dataset)
		
	gen irrigation_commitments = usd_commitment_defl if irrigation_keyword == 1										
	egen crs_irri_total = total(irrigation_commitments), by(country_name)		// Data already deflated (constant 2021 USD, millions)
	replace crs_irri_total = crs_irri_total * 1000000
	label variable crs_irri_total "CRS: Irrigation-related commitments 2000-2022 (constant 2021 USD)"
	replace crs_irri_total = . if crs_irri_total == 0							// no data for these countries
	
	
		* PRELIMINARY graph of irrigation-related investments based on the CRS dataset (2000-2022)
		preserve
		
			egen crs_year_irri = total(irrigation_commitments), by(year)
			replace crs_year_irri = (crs_year_irri * 1000000)/1000000000
			label variable crs_year_irri "Irrigation-related commitments (constant 2021 USD, billions)"
		
			* One ob. per years
			bysort year: gen one_year = _n
			keep if one_year == 1
			
			* scatter plot
			twoway connected crs_year_irri year
		
		restore

		
		

		* Saving number of irrigation projects by country
		preserve
		
			* Number of irrigation projects by country
			egen num_irri_projects = total(irrigation_keyword), by(country_name)
			label variable num_irri_projects "Number of irrigation projects by country"
			
			* Keeping 1 obs. per country 
			bysort country_name: keep if _n == 1			
			count	// n=158
			keep country_name crs_total crs_irri_total num_irri_projects
			
			* Saving data
			label variable country_name ""
			save "OECD_irrigation_2000_2022.dta", replace	// n=158
		
		restore



***** STEP 3: Saving datasets
		
	* Saving the ENTIRE initial/pre-universe dataset: Keeping projects that have either the substring "irrig" or CRS code 31140
	compress
	keep if irrigation_keyword == 1
	
		* Excluding projects approved before 2000
		gen commitment_year = real(substr(commitmentdate,1,4))		// they have a missing year of approval
		tab commitment_year, m		
		tab commitment_year if (commitment_year >= 1900 & commitment_year < 2000), m	// projects approved before 2000
		drop if commitment_year >= 1900 & commitment_year < 2000
	
		* Excluding duplicated project numbers
		sort donorcode projectnumber year
		quietly by donorcode projectnumber: gen dup = cond(_N==1,0,_n)
		tab dup, m									// tons of duplicated project numbers. This is because the CRS dataset includes commitments, disbursements, etc
		
			/*Assigning commitment amount (total out of all entries) to each duplicate
			This way, once we exclude duplicates, we have the actual commitment amount for each project number 
			regardless of which duplicate was dropped.*/
			egen usd_commitment_defl_total = total(usd_commitment_defl), by(projectnumber)
			label variable usd_commitment_defl_total "Total commitments (constant 2021 USD)"	
		
		keep if (dup == 0 | dup == 1)	// (20,787 observations deleted)
		
		
			* Identifying projects that include the substring "irrig" in title, description or have CRS 5-digit code 31140
			tab irrig_tit_des, m		// Projects with substring "irrig" in title or project description
			tab irrigation_crs, m		// Projects with CRS code 31140
			tab irrig_tit_des irrigation_crs
			tab irrigation_keyword, m	// Project with substring or CRS
			
			
	save "CRS_initial_database.dta", replace
	tab projectnumber if projectnumber == "", m
	count	// // n=8,654
	
	
	* Saving our donors' list
	preserve
	
		* Keep 1 obs. per donor name and donor agencycode
		drop dup
		quietly bysort donorcode agencycode: gen dup = cond(_N==1,0,_n)
		keep if (dup == 0 | dup == 1)			// (8,456 observations deleted)
		
		* Saving dataset
		keeporder donorcode donorname agencycode agencyname 
		save "CRS_initial_database_DonorsList.dta", replace	
		count // n=198
		
			/*
			NOTE: We'll use this list to manually identify donors that have an online "projects" web page to simplify the screening process
			*/

	restore
	
	
		* Converting our MANUALLY checked donors' websites from Excel to .dta format
		preserve
		
			* OECD's donors' profiles
			import excel "CRS_initial_database_DonorsList_OnlineProjectsProfiles.xlsx", sheet("donorForStata") firstrow clear
			save "CRS_initial_database_DonorsList_OnlineProjectsProfiles_DONORS.dta", replace
			
			* OECD's agencies' pages
			import excel "CRS_initial_database_DonorsList_OnlineProjectsProfiles.xlsx", sheet("agencyForStata") firstrow clear
			save "CRS_initial_database_DonorsList_OnlineProjectsProfiles_AGENCIES.dta", replace			
		
		restore
	
	
	
	
	* Saving the initial/pre-universe dataset BY DONOR:
	
		* Merge donors and agencies names/websites
		merge m:1 donorcode using "CRS_initial_database_DonorsList_OnlineProjectsProfiles_DONORS.dta"
		drop if _merge == 2
		drop _merge
		
		merge m:1 donorcode agencycode using "CRS_initial_database_DonorsList_OnlineProjectsProfiles_AGENCIES.dta"
		drop if _merge == 2
		drop _merge
		
		
		
		* Ordering variables to speed up the screening process
		gen dataset = "CRS"
		gen project_descrip = "Short: " + shortdescription + " " + "Long: " + longdescription
		gen data_amount_unit = "USD, constant 2021"
		gen source_url = ""
		replace usd_commitment_defl_total = usd_commitment_defl_total * 1000000	// Data reports amount in millions; we're converting to dollar units
		order dataset crsid source_url donorcode donorname oecd_website agencycode agencyname agency_web agency_projectspage	///
		projecttitle project_descrip projectnumber country_name commitment_year usd_commitment_defl_total data_amount_unit
		sort country_name projectnumber commitment_year
		
		
		* Saving data in individual files by donor code
		program split_obs
			// make up the file name using the value from the first observation
			local fname = donorcode[1]
			export delimited using "./CRS_initial_database_byDonor/`fname'", replace
			// no need to accumulate results
			drop _all
		end

		runby split_obs, by(donorcode) verbose
