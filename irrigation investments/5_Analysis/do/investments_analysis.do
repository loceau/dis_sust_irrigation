/****************************************************************************************************************
Paper:			The role of development institutions in advancing sustainable irrigation

Authors:		Cesar Augusto Lopez, Rosamond L. Naylor, and James Holland Jones

Description: 	Data analysis (investments)
			
Last modified: 	March, 2024
****************************************************************************************************************/


/* Directory and globals */
clear all
set more off

	* MAC Directory
	cd "/Users/cesaraugusto/Desktop/irrigation investments/5_Analysis" 				// apply your directory
	global userdir "/Users/cesaraugusto/Desktop/irrigation investments/5_Analysis/"

	global do_files  "$userdir/do" 
	global csv_files "$userdir/csv"
	global log_files "$userdir/log"
	global data_files "$userdir/data"
	global out_files "$userdir/data/out"
	global in_files  "$userdir/data/in"
	global tables_files  "$userdir/tables"


	
*** STEP 1: Loading data
	
	* TUFF's database
	import excel "$in_files/original/tuff_final_combined.xlsx", sheet("Sheet1") firstrow clear
	replace country_name = "Syrian Arab Republic" if country_name == "Syria"
	replace country_name = "Kyrgyzstan" if country_name == "Kyrgyz Republic"
	save "$in_files/original/tuff_final_combined.dta", replace
	
	
	* CRS database
	import excel "$in_files/original/combined.xlsx", sheet("main") firstrow clear
	save "$in_files/original/combined.dta", replace
	destring q1_3c, replace


	* Appending datasets
	append using "$in_files/original/tuff_final_combined.dta", force
	
	
		* Checking country names
		tab country_name, m
		replace country_name = "Lao People's Democratic Republic" if country_name == "Laos"
	



*** STEP 2: Data cleaning


	** INTERMEDIATE OUTCOME AND IMPACT INDICATORS (treemap - Figure 2c)
		*tab q2_03				// No. of public documents reporting at least one intermediate outcome/impact indicator
		*tab q2_04a q2_03, m	// First outcome
		*table q2_04b			// Second outcome (if any)
		*table q2_04c			// 3rd outcome (if any)
		*table q2_04d			// 4th outcome (if any)
		*table q2_04e			// 5th outcome (if any). Some have more than one outcome, separated by either a comma or semicolon
	
	
	/*	
		* Saving original list
		preserve
		sort q2_04e q2_04d q2_04c q2_04b q2_04a
		keep entry_no dataset project_data_id project_no q2_04a q2_04b q2_04c q2_04d q2_04e
		keep if q2_04a != ""
		
			* Split q2_04e into separate variables
			split q2_04e, p("," ";")
			drop q2_04e		// no longer necessary
			
			* Reshape data to long format
			reshape long q2_04, i(project_data_id) j(variable_id) string
			
			* Drop missing values
			drop if missing(q2_04)
			
			* Remove leading/trailing blanks
			replace q2_04 = strtrim(q2_04)		// Remove leading and trailing blanks
			replace q2_04 = stritrim(q2_04)		// Remove all consecutive, internal blanks collapsed to one blank
			
			* Checking list
			tab q2_04, m			// Nearly 1,600 outcome/impact indicators; we have duplicates (documents reporting the same indicator)
			
			
			* Removing duplicated outcome/impact indicators		// We only need to code them once
			quietly bysort q2_04:  gen dup = cond(_N==1,0,_n)
			keep if (dup == 0 | dup == 1)						// Over 700 to code
			drop dup 	// no longer necessary
		
			save "$out_files/dfis_indicators_raw_unique.dta", replace	// TThis file will be used to manually classify our outcomes using an Excel document
			
			
			* Classified data into outcome categories (performed separately using Excel)
			import excel "$out_files/dfis_indicators_raw_unique_ManualCoding.xlsx", sheet("Raw data_decisions") firstrow clear
			save "$out_files/dfis_indicators_raw_unique_ManualCoding_final.dta", replace
			
			
		restore
		
		
		* Combining final datasets (raw outcomes and our classification)
		preserve
		sort q2_04e q2_04d q2_04c q2_04b q2_04a
		keep donorname entry_no dataset project_data_id project_no q2_04a q2_04b q2_04c q2_04d q2_04e
		keep if q2_04a != ""
		
			* Split q2_04e into separate variables
			split q2_04e, p("," ";")
			drop q2_04e		// no longer necessary
			
			* Reshape data to long format
			reshape long q2_04, i(project_data_id) j(variable_id) string
			
			* Drop missing values
			drop if missing(q2_04)
			
			* Remove leading/trailing blanks
			replace q2_04 = strtrim(q2_04)		// Remove leading and trailing blanks
			replace q2_04 = stritrim(q2_04)		// Remove all consecutive, internal blanks collapsed to one blank
			
			* Checking list
			tab q2_04, m			// Nearly 1,600 outcome/impact indicators; we have duplicates (documents reporting the same indicator)
						
			
			* Merge Classified data into outcome categories (performed separately using Excel)
			merge m:m q2_04 using "$out_files/dfis_indicators_raw_unique_ManualCoding_final.dta"
			drop _merge		// Merge must be 100%
			
			* Generate outcome groups
			gen outcome_group = ""
			
				* Groups
				replace outcome_group = "Food security" if (outcome_choice == "Anxiety about food" | outcome_choice == "Coping strategy index" | outcome_choice == "Dietary diversity" | outcome_choice == "Food consumption" | outcome_choice == "Food security index" | outcome_choice == "Height" | outcome_choice == "Weight")
				replace outcome_group = "Income" if (outcome_choice == "Income from agriculture" | outcome_choice == "Overall household income" | outcome_choice == "Income from non-farm employment")
				replace outcome_group = "Expenditures" if (outcome_choice == "Overall agricultural expenditure" | outcome_choice == "Overall household expenditure")
				replace outcome_group = "Production" if (outcome_choice == "Crop yield" | outcome_choice == "Overall crop production" | outcome_choice == "Cropping intensity" | outcome_choice == "Index of crop losses" | outcome_choice == "Overall post-harvest crop losses" | outcome_choice == "Index of adoption of recommended practices" | outcome_choice == "Adoption of recommended water/irrigation practices")
				replace outcome_group = "Market access & sales" if (outcome_choice == "Value sold of agricultural products" | outcome_choice == "Volume sold of agricultural products")
				replace outcome_group = "Poverty" if (outcome_choice == "Index of household poverty" | outcome_choice == "Poverty status" | outcome_choice == "Index of household wealth or assets")
				replace outcome_group = "Land use" if (outcome_choice == "Area allocated to crops" | outcome_choice == "Area allocated to agriculture" | outcome_choice == "Crop diversification")
				replace outcome_group = "Irrigated land" if (outcome_choice == "Irrigated land for agricultural production" )
				replace outcome_group = "Health" if (outcome_choice == "Access to clean water")
				replace outcome_group = "Environmental" if (outcome_choice == "Water pollution due to agricultural activities" | outcome_choice == "Greenhouse gas emissions from agriculture/composting" |outcome_choice == "Water productivity" | outcome_choice == "Forest coverage")
				replace outcome_group = "Social development" if (outcome_choice == "Social empowerment")
				replace outcome_group = "Employment" if (outcome_choice == "Employment hours" | outcome_choice == "Employment status")
				
			tab outcome_group, m
							
			
			* Treemap					
			treemap entries, by(outcome_group outcome_choice) addtitles labsize(4) format(%15.0fc) ///
			palette(CET L10) xsize(5) ysize(2) titlegap(0.12) labcond(10) colorprop linew(0.3 0.05) linec(black black)

			
				* Old
				treemap entries, by(outcome_group outcome_choice) addtitles labsize(3) format(%15.0fc) ///
				palette(CET L10) xsize(4) ysize(5) titlegap(0.19) labgap(0.9) labcond(10) colorprop
				
				treemap entries, by(outcome_group outcome_choice) addtitles labsize(3) format(%15.0fc) ///
				palette(CET L11) xsize(4) ysize(5) titlegap(0.19) labgap(0.5) labcond(10) colorprop
				
				treemap entries, by(outcome_group outcome_choice) addtitles labsize(3) format(%15.0fc) ///
				palette(CET L12) xsize(5) ysize(3) titlegap(0.15) labgap(0.9) labcond(4)

			
				
			* Generating table for the Supplementary materials
			bysort outcome_group outcome_choice: gen dup = cond(_N==1,0,_n)
			keep if (dup == 0 | dup == 1)
			order outcome_group outcome_choice
			
			
		restore		
	
	*/



	** INVESTMENTS 
	
		* Multi-country investments
		tab country_multipleInvest, m			// multi-country projects. We will skip this information for now
		drop if country_multipleInvest != ""
		
		
		* Q1.0: Duplicated records?
		tab q1_0, m						// 1=duplicated record; 2=unique record
		drop if q1_0 == 1				// excluding duplicated records
		
		
		* Q1.1: Donor has a "PROJECTS" webpage?
		tab q1_1, m						// 1=Yes (about 25% of the records); 2=No	
							
							
			*** Records from donors that DO NOT have a "PROJECTS" webpage (relevant questions Q1.2 to Q1_4c)
			
				* Q1.2: After screening titles & descriptions, can we tell if the records are irrigation-related?
				tab q1_2 if q1_1 == 2, m		// 1=Yes, 2=No, 3=Unsure

					* Q1_2b" Why unsure?
					tab q1_2b if q1_2 == 3, m		// Mostly related to LIMITED information
					
				drop if q1_1 == 2 & q1_2 != 1		/* 	Excluding records from donors wihout a "PROJECS" webpage & with limited information
														to determine whether they are irrigation-related or not */
		
				
				
				* Irrigation-related investments (2021 US dollars)
				gen invest_irr = . 
				gen invest_irr_units = ""	
				
					* Q1.3: Are the investments 100% irrigation-related
					tab q1_3 if q1_1 == 2 & q1_2 == 1	// Nearly 100% of the records are 100% related to irrigation-related
					
					
						*** IF records are 100% related to irrigation
						tab dataset_approved_yr if q1_3 == 1 & q1_1 == 2 & q1_2 == 1, m	// All projects approved between 2000 and 2022
						tab commitment_amount if q1_3 == 1 & q1_1 == 2 & q1_2 == 1, m	// all amounts are positive, none missing
						tab data_amount_unit if q1_3 == 1 & q1_1 == 2 & q1_2 == 1, m	// no missing units, in 2009, 2014, and 2021 US dollars
						
							* Q1.3b: Is the amount reported in the dataset correct? (1=Yes; 2=NO)
							tab q1_3b if q1_3 == 1 & q1_1 == 2 & q1_2 == 1, m			// Almost 100% report "YES"
							
								* Yes, reported amount is correct
								replace invest_irr = commitment_amount if q1_3b == 1 & q1_3 == 1 & q1_1 == 2 & q1_2 == 1
								replace invest_irr_units = data_amount_unit if q1_3b == 1 & q1_3 == 1 & q1_1 == 2 & q1_2 == 1
								
								
								* No, reported amount is not correct (n=1)
								
									* Q1.3c: What is the correct amount?
									tab q1_3c if q1_3b == 2 & q1_3 == 1 & q1_1 == 2 & q1_2 == 1, m	// amount
									tab q1_3d if q1_3b == 2 & q1_3 == 1 & q1_1 == 2 & q1_2 == 1, m	// units (in 2021 US$)
									
									replace invest_irr = q1_3c if invest_irr == . & q1_3b == 2 & q1_3 == 1 & q1_1 == 2 & q1_2 == 1
									replace invest_irr_units = q1_3d if invest_irr_units == "" & q1_3b == 2 & q1_3 == 1 & q1_1 == 2 & q1_2 == 1
						
						
						
						*** IF records are NOT 100% related to irrigation but only a component
						tab q1_4 if q1_3 == 2 & q1_1 == 2 & q1_2 == 1, m			// amount	
						tab q1_4b if q1_3 == 2 & q1_1 == 2 & q1_2 == 1, m			// no missing units, in 2012, 2014, and 2021 US dollars
						
						replace invest_irr = q1_4 if invest_irr == . & q1_3 == 2 & q1_1 == 2 & q1_2 == 1
						replace invest_irr_units = q1_4b if invest_irr_units == "" & q1_3 == 2 & q1_1 == 2 & q1_2 == 1
						
											
					* Approval year
					gen approval_year = dataset_approved_yr if q1_3b == 1 & q1_3 == 1 & q1_1 == 2 & q1_2 == 1							// 100% irrigation-related investments & correct amount reported
					replace approval_year = dataset_approved_yr if approval_year == . & q1_3b == 2 & q1_3 == 1 & q1_1 == 2 & q1_2 == 1	// 100% irrigation BUT incorrect amount
					replace approval_year = dataset_approved_yr if approval_year == . & q1_3 == 2 & q1_1 == 2 & q1_2 == 1				// Only a portion of the investmets are irrigation-related

			
			
			*** Records from donors that DO have a "PROJECTS" webpage
			
				* Q1.5: Records have a profile webpage? (1=Yes, 2=No)
				tab q1_5 if q1_1 == 1, m			// Almost all have a a profile page
				
				
					*** NO, the records DO NOT have a profile page
					tab q1_2 if q1_5 == 2 & q1_1 == 1, m			// All records are classified as not related to irrigation or unsure
					drop if	q1_5 == 2 & q1_1 == 1					// Excluding the records above since they are not about irrigation
					
					
					
					*** YES, the records DO have a profile page
					
						* Project approved before 2000? (1=Yes, 2=No)
						tab q1_10b if q1_5 == 1 & q1_1 == 1, m			// ~25% of the records were approved before 2000
						drop if q1_10b == 1 & q1_5 == 1 & q1_1 == 1		// Excluding projects approved before 2000     <<***** CONTINUE HERE
						
			
						* Is it an "IRRIGATION-RELATED" project? (1=Yes, 2=No)
						tab q1_15 if q1_5 == 1 & q1_1 == 1, m			// About 30% are not related to irrigation
						drop if q1_15 == 2 & q1_5 == 1 & q1_1 == 1		// Excluding non-irrigation projects
				
				
						* Projects have publicly available documentation? (1=Yes; 2=No)
						tab q1_16 if q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m	// ~35% of the projects DO NOT have a public documentation
			
			
			
							*** NO, records without public documentation (relevant questions: Q1.17 to Q1.20)
							
								* Is the reported amount the CORRECT amount? (1=Yes; 2=No)
								tab q1_17 if q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m
								
									** YES, it is the correct amount
									
										* Is the investment 100% related? (1=Yes; 2=No)
										tab q1_19 if q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m	// Almost all are 100% irrigation related
											
											** YES, 100% irrigation related
											replace invest_irr = commitment_amount if invest_irr == . & q1_19 == 1 & q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
											replace invest_irr_units = data_amount_unit if invest_irr_units == "" & q1_19 == 1 & q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
											
												* Approval year
												tab q1_9 if q1_19 == 1 & q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m
												replace approval_year = dataset_approved_yr if approval_year == . & q1_9 == 1 & q1_19 == 1 & q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1	// reported year
												replace approval_year = q1_10 if approval_year == . & q1_9 == 2 & q1_19 == 1 & q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1					// corrected year
												tab approval_year if q1_19 == 1 & q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m															// All between 2000 and 2022
											
											
											
											** NO, not 100% irrigation related
											tab q1_20 if q1_19 == 2 & q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1		// none reported as "UNSURE" (i.e., coded as 9999999999999999)
											tab q1_20b if q1_19 == 2 & q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1		// none missing currency unit
											replace invest_irr = q1_20 if invest_irr == . & q1_19 == 2 & q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
											replace invest_irr_units = q1_20b if invest_irr_units == "" & q1_19 == 2 & q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
											
												* Approval year	
												tab q1_9 if q1_19 == 2 & q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m										// All approval dates corrected
												replace approval_year = q1_10 if approval_year == . & q1_19 == 2 & q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1	// corrected year
												tab approval_year if q1_19 == 2 & q1_17 == 1 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1									// After 2000
											
				
									
									** NO, it is NOT the correct amount
									tab q1_18 if q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m	// none missing an amount
									tab q1_18b if q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m	// none missing currency unit
									
										* Is the investment 100% related? (1=Yes; 2=No)
										tab q1_19 if q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m	// Almost all are 100% irrigation related 
									
											** YES, 100% irrigation related
											replace invest_irr = q1_18 if invest_irr == . & q1_19 == 1 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
											replace invest_irr_units = q1_18b if invest_irr_units == "" & q1_19 == 1 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
											
												* Approval year
												tab q1_9 if q1_19 == 1 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
												replace approval_year = dataset_approved_yr if approval_year == . & q1_9 == 1 & q1_19 == 1 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1	// reported year
												replace approval_year = q1_10 if approval_year == . & q1_9 == 2 & q1_19 == 1 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1					// corrected year
												tab approval_year if q1_19 == 1 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1																// All between 2000 and 2022
												
												
												
											** NO, not 100% irrigation related
											tab q1_20 if q1_19 == 2 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1		// none reported as "UNSURE" (i.e., coded as 9999999999999999)
											tab q1_20b if q1_19 == 2 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1		// none missing currency unit
											replace invest_irr = q1_20 if invest_irr == . & q1_19 == 2 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
											replace invest_irr_units = q1_20b if invest_irr_units == "" & & q1_19 == 2 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
								
												* Approval year
												tab q1_9 if q1_19 == 2 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m		// Some projects with correct and others with incorrect approval year					
												replace approval_year = dataset_approved_yr if approval_year == . & q1_9 == 1 & q1_19 == 2 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
												replace approval_year = q1_10 if approval_year == . & q1_9 == 2 & q1_19 == 2 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
												tab approval_year if q1_19 == 2 & q1_17 == 2 & q1_16 == 2 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1	// Approved between 2000 and 2022
								
								

								
							
							*** YES, records have public documentation (relevant questions: Q1.21 and forward)
							
								* Is the reported amount the CORRECT amount? (1=Yes; 2=No)
								tab q1_22 if q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m			// Most records (~95%) have a different amount (e.g., total cost > commitment amount)
			
			
									** YES, it is the correct amount
									
										* Is the investment 100% related? (1=Yes; 2=No)
										tab q1_24 if q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m	// Almost all are 100% irrigation related
										
											** YES, 100% irrigation related
											replace invest_irr = commitment_amount if invest_irr == . & q1_24 == 1 & q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
											replace invest_irr_units = data_amount_unit if invest_irr_units == "" & q1_24 == 1 & q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
			
			
												* Approval year
												tab q1_9 if q1_24 == 1 & q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m
												replace approval_year = dataset_approved_yr if approval_year == . & q1_9 == 1 & q1_24 == 1 & q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1	// reported year
												replace approval_year = q1_10 if approval_year == . & q1_9 == 2 & q1_24 == 1 & q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1					// corrected year
												tab approval_year if q1_24 == 1 & q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m															// All between 2000 and 2022
											
											
											
											** NO, not 100% irrigation related											
											tab q1_24b if q1_24 == 2 & q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m		// none reported as "UNSURE" (i.e., coded as 9999999999999999)
											tab q1_24c if q1_24 == 2 & q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m		// none missing currency unit
											replace invest_irr = q1_24b if invest_irr == . & q1_24 == 2 & q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
											replace invest_irr_units = q1_24c if invest_irr_units == "" & q1_24 == 2 & q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
			
												* Approval year	
												tab q1_9 if q1_24 == 2 & q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m			// All approval dates as reported
												replace approval_year = dataset_approved_yr if approval_year == . & q1_24 == 2 & q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
												tab approval_year if q1_24 == 2 & q1_22 == 1 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m	// Approved between 2000 and 2022
											
				
									
									** NO, it is NOT the correct amount
									tab q1_23 if q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m	// none missing an amount
									tab q1_23b if q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m	// none missing currency unit
		
		
										* Is the investment 100% related? (1=Yes; 2=No)
										tab q1_24 if q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m	// ~65% are 100% irrigation-related
		
											** YES, 100% irrigation related
											replace invest_irr = q1_23 if invest_irr == . & q1_24 == 1 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
											replace invest_irr_units = q1_23b if invest_irr_units == "" & q1_24 == 1 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
											
												* Approval year
												tab q1_9 if q1_24 == 1 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1	
												replace approval_year = dataset_approved_yr if approval_year == . & q1_9 == 1 & q1_24 == 1 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1	// reported year
												replace approval_year = q1_10 if approval_year == . & q1_9 == 2 & q1_24 == 1 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1					// corrected year
												tab approval_year if q1_24 == 1 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m															// All between 2000 and 2022
												
												
												
											** NO, not 100% irrigation related		
											tab q1_24b if q1_24 == 2 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m		// none reported as "UNSURE" (i.e., coded as 9999999999999999)
											tab q1_24c if q1_24 == 2 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m		// none missing currency unit
											replace invest_irr = q1_24b if invest_irr == . & q1_24 == 2 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
											replace invest_irr_units = q1_24c if invest_irr_units == "" & q1_24 == 2 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1
		
		
												* Approval year
												tab q1_9 if q1_24 == 2 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m
												replace approval_year = dataset_approved_yr if approval_year == . & q1_9 == 1 & q1_24 == 2 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1	// reported year
												replace approval_year = q1_10 if approval_year == . & q1_9 == 2 & q1_24 == 2 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1					// corrected year
												tab approval_year if q1_24 == 2 & q1_22 == 2 & q1_16 == 1 & q1_15 == 1 & q1_5 == 1 & q1_1 == 1, m															// All between 2000 and 2022





*** STEP 3: Converting investment amounts to constant 2022 US$			

	* Currency units
	tab invest_irr_units, m		// Currency: Euros, Kuwaiti Dinar, Pounds, Francs, USD, and Yen
	replace invest_irr_units = "Euro" if invest_irr_units == "Euros"
	replace invest_irr_units = "Euro" if invest_irr_units == "Euro, 2019 units"
	replace invest_irr_units = "Swiss Francs" if invest_irr_units == "Swiss Franc"
	replace invest_irr_units = "USD, constant 2021" if invest_irr_units == "2021 USD (constant)"
	
	
		** Step 3A: Converting all entries to nominal US$ 		/* Exchange Rate data from the World Bank (Based on IMF data) - https://data.worldbank.org/indicator/PA.NUS.FCRF?end=2022&start=2000
																Official exchange rate refers to the exchange rate determined by national authorities or to the rate determined in the legally sanctioned exchange market. 
																It is calculated as an annual average based on monthly averages (local currency units relative to the U.S. dollar).
																*/
		
			* Euros to US$
			tab approval_year if invest_irr_units == "Euro", m		// From 2003 to 2021
			
				/* Exchange Rate
				
					year	mean exchange rate (1 US$ to Euro)
					2000	1.082705081
					2001	1.116533086
					2002	1.057558996
					2003	0.8840479272
					2004	0.8039216477
					2005	0.8038001922
					2006	0.7964327309
					2007	0.7296724
					2008	0.67992268
					2009	0.716957702
					2010	0.7543089901
					2011	0.7184138987
					2012	0.7783381204
					2013	0.7529451227
					2014	0.7527281969
					2015	0.9012964234
					2016	0.9034214363
					2017	0.8852055083
					2018	0.8467726671
					2019	0.8932762571
					2020	0.875506397
					2021	0.8454941389
					2022	0.9496237532
				
				*/
			
				replace invest_irr = invest_irr/0.8840479272 if approval_year == 2003 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.8039216477 if approval_year == 2004 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.8038001922 if approval_year == 2005 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.7296724 if approval_year == 2007 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.67992268 if approval_year == 2008 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.716957702 if approval_year == 2009 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.7543089901 if approval_year == 2010 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.7184138987 if approval_year == 2011 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.7783381204 if approval_year == 2012 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.7529451227 if approval_year == 2013 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.7527281969 if approval_year == 2014 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.9012964234 if approval_year == 2015 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.9034214363 if approval_year == 2016 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.8852055083 if approval_year == 2017 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.8467726671 if approval_year == 2018 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.8932762571 if approval_year == 2019 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.87550639 if approval_year == 2020 & invest_irr_units == "Euro"
				replace invest_irr = invest_irr/0.8454941389 if approval_year == 2021 & invest_irr_units == "Euro"

				replace invest_irr_units = "USD" if invest_irr_units == "Euro"
			
			
			
			
			
			* Kuwaiti Dinar to US$ 
			tab approval_year if invest_irr_units == "Kuwaiti Dinar", m		// From 2000 to 2019
			
				/* Exchange Rate
					year	mean exchange (1 US$ to Kuwaiti Dinar)
					2000	0.3067515833
					2001	0.3066816667
					2002	0.3039142517
					2003	0.2980115211
					2004	0.2947
					2005	0.292
					2006	0.290176225
					2007	0.2842139583
					2008	0.2688283667
					2009	0.2877854167
					2010	0.2866065917
					2011	0.2759789444
					2012	0.2799355583
					2013	0.2835894417
					2014	0.2845671417
					2015	0.300852025
					2016	0.3021374412
					2017	0.3033497583
					2018	0.3019564935
					2019	0.303611163
					2020	0.3062331218
					2021	0.3016431108
					2022	0.3062501544
				
				*/
			
				replace invest_irr = invest_irr/0.3067515833 if approval_year == 2000 & invest_irr_units == "Kuwaiti Dinar"
				replace invest_irr = invest_irr/0.3039142517 if approval_year == 2002 & invest_irr_units == "Kuwaiti Dinar"
				replace invest_irr = invest_irr/0.2947 if approval_year == 2004 & invest_irr_units == "Kuwaiti Dinar"
				replace invest_irr = invest_irr/0.290176225 if approval_year == 2006 & invest_irr_units == "Kuwaiti Dinar"
				replace invest_irr = invest_irr/0.2688283667 if approval_year == 2008 & invest_irr_units == "Kuwaiti Dinar"
				replace invest_irr = invest_irr/0.2877854167 if approval_year == 2009 & invest_irr_units == "Kuwaiti Dinar"
				replace invest_irr = invest_irr/0.2866065917 if approval_year == 2010 & invest_irr_units == "Kuwaiti Dinar"
				replace invest_irr = invest_irr/0.2759789444 if approval_year == 2011 & invest_irr_units == "Kuwaiti Dinar"
				replace invest_irr = invest_irr/0.2835894417 if approval_year == 2013 & invest_irr_units == "Kuwaiti Dinar"
				replace invest_irr = invest_irr/0.2845671417 if approval_year == 2014 & invest_irr_units == "Kuwaiti Dinar"
				replace invest_irr = invest_irr/0.300852025 if approval_year == 2015 & invest_irr_units == "Kuwaiti Dinar"
				replace invest_irr = invest_irr/0.3021374412 if approval_year == 2016 & invest_irr_units == "Kuwaiti Dinar"
				replace invest_irr = invest_irr/0.3019564935 if approval_year == 2018 & invest_irr_units == "Kuwaiti Dinar"
				replace invest_irr = invest_irr/0.303611163 if approval_year == 2019 & invest_irr_units == "Kuwaiti Dinar"
				
				replace invest_irr_units = "USD" if invest_irr_units == "Kuwaiti Dinar"
			
			
			
			
			
			* Pounds to US$ 
			tab approval_year if invest_irr_units == "Pounds", m		// 2012				
			
				/* Exchange Rate
					year	mean exchange (1 US$ to Pounds)
					2012	0.6330469889
				
				*/			
				
				replace invest_irr = invest_irr/0.6330469889 if approval_year == 2012 & invest_irr_units == "Pounds"
				
				replace invest_irr_units = "USD" if invest_irr_units == "Pounds"
			
			
			
			
			
			* Swiss Francs to US$ 
			tab approval_year if invest_irr_units == "Swiss Francs", m		// From 2007 to 2020
			
				/* Exchange Rate
					year	mean exchange (1 US$ to Francs)
					2000	1.6888425
					2001	1.687615
					2002	1.5586075
					2003	1.346650833
					2004	1.243495833
					2005	1.245176667
					2006	1.253843333
					2007	1.200365833
					2008	1.08309
					2009	1.088141696
					2010	1.042905646
					2011	0.8880420282
					2012	0.9376844807
					2013	0.9269035478
					2014	0.9161510473
					2015	0.962381328
					2016	0.9853943942
					2017	0.9846916667
					2018	0.9778916667
					2019	0.9937091667
					2020	0.938965
					2021	0.9138458333
					2022	0.9548325
				
				*/
				
				replace invest_irr = invest_irr/1.200365833 if approval_year == 2007 & invest_irr_units == "Swiss Francs"
				replace invest_irr = invest_irr/1.088141696 if approval_year == 2009 & invest_irr_units == "Swiss Francs"
				replace invest_irr = invest_irr/1.042905646 if approval_year == 2010 & invest_irr_units == "Swiss Francs"
				replace invest_irr = invest_irr/0.8880420282 if approval_year == 2011 & invest_irr_units == "Swiss Francs"
				replace invest_irr = invest_irr/0.9376844807 if approval_year == 2012 & invest_irr_units == "Swiss Francs"
				replace invest_irr = invest_irr/0.9269035478 if approval_year == 2013 & invest_irr_units == "Swiss Francs"
				replace invest_irr = invest_irr/0.9161510473 if approval_year == 2014 & invest_irr_units == "Swiss Francs"
				replace invest_irr = invest_irr/0.962381328 if approval_year == 2015 & invest_irr_units == "Swiss Francs"
				replace invest_irr = invest_irr/0.9846916667 if approval_year == 2017 & invest_irr_units == "Swiss Francs"
				replace invest_irr = invest_irr/0.9778916667 if approval_year == 2018 & invest_irr_units == "Swiss Francs"
				replace invest_irr = invest_irr/0.9937091667 if approval_year == 2019 & invest_irr_units == "Swiss Francs"
				replace invest_irr = invest_irr/0.938965 if approval_year == 2020 & invest_irr_units == "Swiss Francs"
				
				replace invest_irr_units = "USD" if invest_irr_units == "Swiss Francs"
			
			
			
			
			
			* Yens to US$ 
			tab approval_year if invest_irr_units == "Yen", m		// From 2001 to 2021		
			
				/* Exchange Rate
					year	mean exchange (1 US$ to Yen)
					2000	107.7654983
					2001	121.5289475
					2002	125.3880192
					2003	115.9334642
					2004	108.1925692
					2005	110.2182117
					2006	116.2993117
					2007	117.7535292
					2008	103.359494
					2009	93.57008909
					2010	87.779875
					2011	79.80701983
					2012	79.79045542
					2013	97.59565828
					2014	105.944781
					2015	121.0440257
					2016	108.7929
					2017	112.1661411
					2018	110.4231793
					2019	109.0096659
					2020	106.7745823
					2021	109.7543238
					2022	131.4981404
				
				*/
				
				
				replace invest_irr = invest_irr/121.5289475 if approval_year == 2001 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/125.3880192 if approval_year == 2002 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/115.9334642 if approval_year == 2003 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/108.1925692 if approval_year == 2004 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/110.2182117 if approval_year == 2005 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/116.2993117 if approval_year == 2006 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/117.7535292 if approval_year == 2007 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/103.359494 if approval_year == 2008 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/87.779875 if approval_year == 2010 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/79.80701983 if approval_year == 2011 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/79.79045542 if approval_year == 2012 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/97.59565828 if approval_year == 2013 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/105.944781 if approval_year == 2014 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/121.0440257 if approval_year == 2015 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/108.7929 if approval_year == 2016 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/112.1661411 if approval_year == 2017 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/110.4231793 if approval_year == 2018 & invest_irr_units == "Yen"
				replace invest_irr = invest_irr/109.7543238 if approval_year == 2021 & invest_irr_units == "Yen"
				
				replace invest_irr_units = "USD" if invest_irr_units == "Yen"

				
			
			
			
			
			
			
		** Step 3B: Converting nominal to real 2022 US$
			
			* Year of our nominal values
			tab invest_irr_units, m
			gen temp_year = approval_year if invest_irr_units == "USD"				// Using the APPROVAL YEAR as the year for units reported in USD
			replace temp_year = 2009 if invest_irr_units == "2009 USD"
			replace temp_year = 2012 if invest_irr_units == "2012 USD"
			replace temp_year = 2014 if invest_irr_units == "2014 USD"
			replace temp_year = 2021 if invest_irr_units == "USD, constant 2021"	// Values in 2021 US$
			tab temp_year, m														// none missing
		
			* Units of our nominal values
			gen temp_units = "USD"													// Everything in US dollar
			
			* Inflating nominal to real US$
				* ssc install inflate		// user-written command to inflate (or deflate) nominal values
				* inflate, update			// To update the CPI series stored locally to the most recent release
			inflate invest_irr, year(temp_year) end(2022) generate(irrg_invest_real) keepcpi
			label variable irrg_invest_real "Irrig. investments 2000-22 (real 2022 USD)"
			
			* Drop temp variables
			drop temp_year temp_units invest_irr_units
		
		
			* Number of donors in the data
			replace donorname = "China" if dataset == "TUFF-China" & donorname == ""
			egen donors_in_data = group(donorname)
			distinct donors_in_data	// 64 aid donors
		
		
			gen agency_name = donorname + " " + agencyname
			egen agency_in_data = group(agency_name)
			distinct agency_in_data	// 158 aid agencies		
		
		
		
		
*** STEP 4: Aggregating data by country

	** Duplicated projects across donors? (1=Yes)
	tab q4_04, m			/* 	These records have been manually identified as duplicates; their commitments/disburstments are already included
								under a different record.
								
								When discussing investments, we should exclude these duplicates. 
								
								However, when discussing the total number of projects/records, those with public documentation, etc., 
								we should include these duplicates as they are a different source of information.
							*/
				

		* RECORDS INFORMATION
		
			* Number of irrigation-related investment records	
			gen numA = 1
			egen no_proj = total(numA), by(country_name)
			label variable no_proj "Irrigation investment projects (n)"
			drop numA 						// no longer necessary
		
			
			* Number of records with publicly available documentation
			tab q1_15 q1_16, m
			gen numP = (q1_16 == 1)
			egen no_public = total(numP), by(country_name)
			label variable no_public "Projects w/ public docs (n)"
			drop numP						// no longer necessary
				
				* Donors that disclose project-related documentation
				tab donorname if q1_16 == 1	// Mostly dev. banks (AfDB, ADB, IDB, WB), bilateral agencies (Belgium, France, Japan), other development agencies (IFAD).
			
			* Records with an infrastructure component
			tab q1_16 q3_01, m
			gen numI = (q3_01 == 1)
			egen no_infra = total(numI), by(country_name)
			label variable no_infra "Projects w/ infra component (n)"
			drop numI						// no longer necessary
			
			* Documents discussing the use of a participatory approach
			tab q3_01 q3_02
			gen numPa = (q3_02 == 1)
			egen no_partici = total(numPa), by(country_name)
			label variable no_partici "Docs discussing participatory approach (n)"
			drop numPa						// no longer necessary
			
			* Documents that mention impact evaluation
			tab q1_16 q2_01, m
			gen numImp = (q2_01 == 1)
			egen no_impact= total(numImp), by(country_name)
			label variable no_impact "Docs mentioning impact evaluation (n)"
			drop numImp						// no longer necessary
			
			* Documents that mention social network
			tab q1_16 q3_03, m
			gen numSoc = (q3_03 == 1)
			egen no_social = total(numSoc), by(country_name)
			label variable no_social "Docs mentioning social network (n)"
			drop numSoc						// no longer necessary	
			
			* Results framework
			tab q1_16 q2_03, m
			gen numRe = (q2_03 == 1)
			egen no_frame = total(numRe), by(country_name)
			label variable no_frame "Docs w/ results framework (n)"
			drop numRe						// no longer necessary
			
	
	
		* INVESTMENTS INFORMATION
		drop if q4_04 == 1		// excluding duplicates
	
			* Total investments (in US dollars)
			egen irr_investments = total(irrg_invest_real), by(country_name)
			format irr_investments %12.0fc	// Convert figures from scientific notation to actual numbers
			label variable irr_investments "Irrig. investments 2000-22 (real 2022 USD)"							
							
				* Investments trend between 2000 and 2022
				preserve
				
				tab approval_year
				format approval_year %ty
				gen irrg_invest_real_bil = irrg_invest_real/1000000000		// converting to billions
				set scheme white_tableau
				graph set window fontface "Arial Narrow"
				graph bar (sum) irrg_invest_real_bil, over(approval_year) 	///
				ytitle(Investments (US$, billions)) ylabel(, format(%12.0fc))
				
					* Merge region information
					
						* Renaming countries to match the datasets
						replace country_name = "Republic of Cabo Verde" if country_name == "Cabo Verde"
						replace country_name = "China" if country_name == "China (People's Republic of)"
						replace country_name = "Côte d'Ivoire" if country_name == "C√¥te d'Ivoire"
						replace country_name = "Dem. Rep. Korea " if country_name == "Democratic People's Republic of Korea"
						replace country_name = "Kingdom of eSwatini" if country_name == "Eswatini"
						replace country_name = "The Gambia" if country_name == "Gambia"
						replace country_name = "Lao PDR" if country_name == "Lao People's Democratic Republic"
						replace country_name = "São Tomé and Principe" if country_name == "Sao Tome and Principe"
						replace country_name = "Syria" if country_name == "Syrian Arab Republic"
						replace country_name = "Turkey" if country_name == "T√ºrkiye"
						replace country_name = "Vietnam" if country_name == "Viet Nam"
						replace country_name = "Palestine" if country_name == "West Bank and Gaza Strip"
						replace country_name = "Dem. Rep. Korea" if country_name == "Dem. Rep. Korea "

						merge m:1 country_name using "$in_files/shapefile/ne_50m_admin_0_countries/country_regions.dta"
						drop if _merge == 2		// 100% merge
						drop _merge 			// no longer necessary
						
					
					* generating graph
					tab REGION_WB
					
						* Ordering of the bars
						gen order = 1 if REGION_WB == "South Asia"
						replace order = 2 if REGION_WB == "East Asia & Pacific"
						replace order = 3 if REGION_WB == "Sub-Saharan Africa"
						replace order = 4 if REGION_WB == "Middle East & North Africa"
						replace order = 5 if REGION_WB == "Europe & Central Asia"
						replace order = 6 if REGION_WB == "Latin America & Caribbean"
						
						set scheme tab1 
						graph bar (sum) irrg_invest_real_bil, over(REGION_WB, sort(order)) ///
						over(approval_year, label(labsize(large)) gap(*.4))  ///
						ytitle("Irrigation investments" "(US$, billions)", size(vlarge)) ylabel(, format(%12.0fc) nogrid labsize(vlarge)) asyvars stack 		///
						legend(title("{bf:Region}", size(vlarge) span)	///
						order(5 "South Asia" 1 "East Asia & Pacific" 6 "Sub-Saharan Africa" 4 "Middle East & North Africa" ///
						2 "Europe & Central Asia" 3 "Latin American & the Caribbean") position(11) ring(0) rows(3) size(large))		///
						bar(5, color("189 30 36") fintensity(*0.9) lcolor(black) lwidth(small)) 	///
						bar(1, color("233 118 0") fintensity(*0.9) lcolor(black) lwidth(small)) 	///
						bar(6, color("246 199 0") fintensity(*0.9) lcolor(black) lwidth(small)) ///
						bar(4, color("0 114 86") fintensity(*0.9) lcolor(black) lwidth(small)) ///
						bar(2, color("0 103 167") fintensity(*0.9) lcolor(black) lwidth(small)) ///
						bar(3, color("150 79 142") fintensity(*0.9) lcolor(black) lwidth(small)) ///
						ylabel(0(2)10) xsize(10) ysize(6) // saving(Investments_trend, replace)
						
						
					* Investments by decade
					egen invest_year = total(irrg_invest_real_bil), by(approval_year)
						
						* Average investment 1st decade
						sum invest_year if (approval_year >= 2000 & approval_year <= 2009)
						
						* Average investment 2nd decade
						sum invest_year if (approval_year >= 2010 & approval_year <= 2019)
						
						* Total investment in 2019
						sum invest_year if (approval_year == 2019)	// 4.94 billion
						
						* Total investment in 2000
						sum invest_year if (approval_year == 2020)	// 1.55 billion
						
						* Total investment in 2022
						sum invest_year if (approval_year == 2022)	// 0.698
						
				restore


			  
			* Total investments between 2015-2022 (readl 2022 USD)
			replace irrg_invest_real = . if (approval_year >= 2015 & approval_year <= 2022)
			egen irr_investments15_22 = total(irrg_invest_real), by(country_name)
			label variable irr_investments15_22 "Irrig. investments 2015-22 (real 2022 USD)"
			drop irrg_invest_real			// no longer necessary
			
			
				
	* Keeping one observation per country
	bysort country_name: gen country_n = _n
	keep if country_n == 1
	drop country_n				// no longer necessary
		
		
		
		
		

			
*** STEP 5: Merge complementary data & creating additional variables
	
	
	** Merge datasets
	
		* (1) World Bank's classification of LMICs
		
			* Adjusting country names to match the WB's classification 
			replace country_name = "China" if country_name == "China (People's Republic of)"
			replace country_name = "Congo, Dem. Rep." if country_name == "Democratic Republic of the Congo"
			replace country_name = "Egypt, Arab Rep." if country_name == "Egypt"
			replace country_name = "Gambia, The" if country_name == "Gambia"
			replace country_name = "Iran, Islamic Rep." if country_name == "Iran"
			replace country_name = "Kyrgyz Republic" if country_name == "Kyrgyzstan"
			replace country_name = "Türkiye" if country_name == "T√ºrkiye"
			replace country_name = "Lao PDR" if country_name == "Lao People's Democratic Republic"
			replace country_name = "Vietnam" if country_name == "Viet Nam"	
			replace country_name = "Yemen, Rep." if country_name == "Yemen"
			replace country_name = "São Tomé and Príncipe" if country_name == "Sao Tome and Principe"
			replace country_name = "Côte d'Ivoire" if country_name == "C√¥te d'Ivoire"
			replace country_name = "Korea, Dem. Rep." if country_name == "Democratic People's Republic of Korea"	
			replace country_name = "St. Lucia" if country_name == "Saint Lucia"
			replace country_name = "West Bank and Gaza" if country_name == "West Bank and Gaza Strip"
		
		merge m:1 country_name using "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/lmics_classification/data/out/wb_lmic_classification.dta"
		tab country_name if _merge == 1		// British islands not matching, fine to drop from the dataset
		keep if _merge == 3		// 100% matched
		drop _merge acronym		// no longer necessary
		tab lmic, m				// 100% of our observations are LMICs
			
			
			
			
		* (2) Population data from the United Nations Population Division (World Population Prospects: 2022 Revision)
			
			* Adjusting country names to match original WB dataset 
			replace country_name = "Sao Tome and Principe" if country_name == "São Tomé and Príncipe"
			replace country_name = "Turkiye" if country_name == "Türkiye"
			replace country_name = "Cote d'Ivoire" if country_name == "Côte d'Ivoire"
			replace country_name = "Korea, Dem. People's Rep." if country_name == "Korea, Dem. Rep."
			
		merge m:1 country_name using "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/wb_population/data/out/wb_population_mean.dta"
		keep if _merge == 3		// 100% matched
		drop _merge 			// no longer necessary
		
		
		
		* (3) Land area (ha) and Agricultural Land (ha) from FAO
		merge m:1 country_name using "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/WB_land/data/out/wb_land.dta"
		keep if _merge == 3		// 100% matched
		drop _merge 			// no longer necessary
		

		
		
	** Creating additional variables
		
		* Irrigation investments per capita
		gen irr_inv_pc = irr_investments/pop_mean
		label variable irr_inv_pc "Irrig. investments 2000-22 (real 2022 USD per capita)"
		gen irr_inv_pc2 = round(irr_inv_pc, 1)		// rounding
		
		
		* Irrigation invement levels (in billions of constant 2022 USD)
		gen irr_inv_levels = irr_investments/1000000000
		replace irr_inv_levels = round(irr_inv_levels, .01)
		
		
		* Saving data
		
			* Adjusting country names to match our shapefile
			replace country_name = "Democratic Republic of the Congo" if country_name == "Congo, Dem. Rep."
			replace country_name = "Egypt" if country_name == "Egypt, Arab Rep."
			replace country_name = "Kingdom of eSwatini" if country_name == "Eswatini"
			replace country_name = "The Gambia" if country_name == "Gambia, The"
			replace country_name = "Iran" if country_name == "Iran, Islamic Rep."
			replace country_name = "Kyrgyzstan" if country_name == "Kyrgyz Republic"
			replace country_name = "São Tomé and Principe" if country_name == "Sao Tome and Principe"
			replace country_name = "Turkey" if country_name == "Turkiye"
			replace country_name = "Yemen" if country_name == "Yemen, Rep."
			replace country_name = "Republic of Cabo Verde" if country_name == "Cabo Verde"
			replace country_name = "Côte d'Ivoire" if country_name == "Cote d'Ivoire"
			replace country_name = "Dem. Rep. Korea" if country_name == "Korea, Dem. People's Rep."
			replace country_name = "Saint Lucia" if country_name == "St. Lucia"
			replace country_name = "Syria" if country_name == "Syrian Arab Republic"
			replace country_name = "Palestine" if country_name == "West Bank and Gaza"
			
		
	**  Saving dataset
	compress
	save "$out_files/irrigation_investments_data_final.dta", replace
	
	
	
	
	** Preparing Map-related data

		// Install the following packages as required
		*ssc install spmap, replace    		// maps package
		*ssc install geo2xy, replace		// change coordinate systems
		*ssc install palettes, replace   	// color palettes
		*ssc install colrspace, replace  	// expand color base

		clear all
		set more off
		cd "$data_files/in/shapefile/ne_50m_admin_0_countries" 		// apply your directory
		spshape2dta ne_50m_admin_0_countries, replace saving(world)

	
		* Cleaning and saving shapefile data in Stata format

			* Loading original shapefile data
			use world_shp, clear
			scatter _Y _X, msize(tiny) msymbol(point)
			
			* Merge attributes table
			merge m:1 _ID using world
			drop if NAME == "Antarctica"	 	// we don't need Antarctica
			scatter _Y _X, msize(tiny) msymbol(point)
			drop _CX - _merge					// no longer necessary
			
			* Changing map's project to Google Web Mercator
			*geo2xy _Y _X, proj (web_mercator) replace
			scatter _Y _X, msize(tiny) msymbol(point)
			
			* Saving data
			sort _ID
			save, replace
		
		
			* Saving shapefile label data
				
				* Loading complete data
				use world, clear
				
				* Data cleaning
				rename WB_A3 country_code
				rename NAME_LONG country_name
				drop if country_name == "Antarctica"			// we don't need Antarctica
				
				* Saving data
				keep _ID _CX _CY country_name country_code
				*geo2xy _CY _CX, proj(web_mercator) replace  	// Changing map's project to Google Web Mercator
				compress
				save world_label.dta, replace



	** Merge Map and investment data
	
		* Loading MAP
		use world, clear
		rename NAME_LONG country_name             
		drop if country_name == "Antarctica"				// we don't need Antarctica
		rename WB_A3 country_code
		
		
		* Merge the investment data
		merge 1:m country_name using "$out_files/irrigation_investments_data_final.dta"
		drop if _merge == 2		// 100% matched
		drop _merge				// no longer necessary
		
    
		* Merge LMIC countries dummies
		drop lmic

		gen acronym = ADM0_A3_US
		replace acronym = "SSD" if country_name == "South Sudan"
		replace acronym = "XKX" if country_name == "Kosovo"
		replace acronym = "PSE" if country_name == "Palestine"
		merge m:1 acronym using "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/lmics_classification/data/out/wb_lmic_classification.dta"
		tab country_name if _merge==2 			// Unmached units can be excluded
		drop if _merge == 2
		drop _merge								// no longer necessary
		
		
				
		* Merge AREA UNDER IRRIGATION data
		replace UN_A3 = "578" if SOVEREIGNT == "Norway"	
		merge m:1 UN_A3 using "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/un_irrigation_data/data/out/share_irrigation_equipped.dta"	// 100% merge
		tab country_name if _merge==1 & irr_inv_pc != . & lmic == 1		// We do not have sufficient data for 2 countries (Kosovo, Vanuatu) 
		drop _merge	// no longer necessary
		
	
		
		
		
		
			
*** STEP 6: Generating information for tables/figures


	* Appendix Table 3.1 (aggregating data by region)
	preserve
	
		* Investments/information per region
	
			* Aggregating data by region and converting to billions to dollars
			egen irr_inv_reg = total(irr_investments), by(REGION_WB)
			gen irr_inv_reg_billion = irr_inv_reg/1000000000			// converting values to billions of US$
			
			* Projects by region
			egen projec_reg = total(no_proj), by(REGION_WB)
			
			* Projects with public docs
			egen public_doc_reg = total(no_public), by(REGION_WB)
			
			* Projects with infrastructure component
			egen infra_reg = total(no_infra), by(REGION_WB)
			
			* Projects mentioning participatory approaches
			egen parti_reg = total(no_partici), by(REGION_WB)
			
			* Projects mentioning impact evaluation
			egen impact_reg = total(no_impact), by(REGION_WB)
			
			* Projects mentioning social network
			egen social_reg = total(no_social), by(REGION_WB)
			
			* projects with a results framework
			egen framework_reg = total(no_frame), by(REGION_WB)
	

		
		* Generating graph for Figure 1 (Our investment data VS. CRS data)
	
			* Keeping 1 obs. per region
			bysort REGION_WB: gen region_id = _n
			keep if region_id == 1
			order REGION_WB irr_inv_reg_billion projec_reg public_doc_reg infra_reg 	///
			framework_reg impact_reg parti_reg social_reg , last
			drop if REGION_WB == "North America" | REGION_WB == "Antarctica"
					
					* Organizing variables
					gen data_source = "ours"
					rename irr_inv_reg_billion regional_values
					keep REGION_WB regional_values data_source
			

			
			* Appending the CRS-related agricultural water resouces data by region
			append using "/Users/cesaraugusto/Desktop/irrigation investments/4_Other_data/ODA_CRS/CRS-agricultural water resources/data/out/crs_commitments_awr_region_2000_2022.dta"
			
			
			
			* Creating graph
			
				* Recode REGION_WB into a new variable with the desired order
				gen region_order = .
				replace region_order = 1 if REGION_WB == "South Asia"
				replace region_order = 2 if REGION_WB == "East Asia & Pacific"
				replace region_order = 3 if REGION_WB == "Sub-Saharan Africa"
				replace region_order = 4 if REGION_WB == "Middle East & North Africa"
				replace region_order = 5 if REGION_WB == "Europe & Central Asia"
				replace region_order = 6 if REGION_WB == "Latin America & Caribbean"

				* Graph
				replace data_source = `""Agricultural" "water resources" "(CRS database)""' if data_source == "crs"
				replace data_source = "Irrigation" if data_source == "ours"
				graph hbar (sum) regional_values, ///
					over(REGION_WB, sort(region_order) label(labsize(vlarge))) ///
					over(data_source, label(labsize(vlarge))) ///
					asyvars stack ///
					ytitle("Investments (US$, billions)", size(vlarge)) ///
					ylabel(0(20)120, format(%12.0fc) nogrid labsize(vlarge)) ///
					legend(title("{bf:Region}", size(vlarge) span) ///
						   order(5 "South Asia" 1 "East Asia & Pacific" 6 "Sub-Saharan Africa" ///
								 4 "Middle East & North Africa" 2 "Europe & Central Asia" ///
								 3 "Latin America & Caribbean") ///
						   position(3) ring(2) rows(6) size(large)) ///
					bar(5, color("189 30 36") fintensity(*0.9) lcolor(black) lwidth(small)) ///
					bar(1, color("233 118 0") fintensity(*0.9) lcolor(black) lwidth(small)) ///
					bar(6, color("246 199 0") fintensity(*0.9) lcolor(black) lwidth(small)) ///
					bar(4, color("0 114 86") fintensity(*0.9) lcolor(black) lwidth(small)) ///
					bar(2, color("0 103 167") fintensity(*0.9) lcolor(black) lwidth(small)) ///
					bar(3, color("150 79 142") fintensity(*0.9) lcolor(black) lwidth(small)) ///
					xsize(13) ysize(6)


		

restore



*** MAP of number of irrigation-related records (2000-2022) by country
	
	* Map
	colorpalette HCL heat2, n(8) nograph reverse
	local colors `r(p)'				
	spmap no_proj if lmic == 1 using world_shp, id(_ID) cln(8) 								///
	clmethod(custom) clbreaks(0 1 3 5 10 15 30 50 110) fcolor("`colors'")					///
	ocolor(white ..) osize(vvthin ..) ndfcolor(black) ndocolor(white)						///
	ndsize(0.03 ..) ndlabel("No data") legend(pos(6) size(*1) row(1) stack colgap(0)) 		///
	legstyle(1) polygon(data(world_shp) osize(vvthin)) legorder(lohi)
			
	




*** MAP of number of public records (2000-2022) by country
	
	* Map
	colorpalette YlGn, n(9) nograph
	local colors `r(p)'				
	spmap no_public if lmic == 1 using world_shp, id(_ID) cln(9) 							///
	clmethod(custom) clbreaks(0 1 3 5 10 15 25 35 47) fcolor("`colors'")					///
	ocolor(white ..) osize(vvthin ..) ndfcolor(black) ndocolor(white)						///
	ndsize(0.03 ..) ndlabel("No data") legend(pos(6) size(*1) row(1) stack colgap(0)) 		///
	legstyle(1) polygon(data(world_shp) osize(vvthin)) legorder(lohi)
	

	
		
		
			
*** STEP 7: Creating map of irrigation investments for the main text and supplementary materials

	* LMICs without investment data
	tab country_name if irr_inv_pc == . & lmic == 1		// n=29

	
	** Supplementary materials
			
		** Total irrigation investments (2000-2022)
		
			* Map of irrigation investments - total_investments_by_country.pdf
			colorpalette viridis, n(9) nograph reverse
			local colors `r(p)'				
			spmap irr_inv_levels if lmic == 1 using world_shp, id(_ID) cln(9) 							///
			clmethod(custom) clbreaks(0 0.04 0.15 0.35 0.62 1.10 2.06 5.30 11.31) fcolor("`colors'")	///
			ocolor(white ..) osize(vvthin ..) ndfcolor(black) ndocolor(white)							///
			ndsize(0.03 ..) ndlabel("No data") legend(pos(6) size(*1) row(1) stack colgap(0)) 			///
			legstyle(1) polygon(data(world_shp) osize(vvthin)) legorder(lohi)
			

		
		
				* Top 20 countries by total investments in irrigation (2000-2022)
				preserve
					
					* Sort data by irrigation investments (total)
					gsort -irr_investments
					
					* Keep obs. in the top 20
					keep in 1/20
					
					* Convering figures to billions of dollars; rounding to 2 decimal places
					gen irr_investments_top = round(irr_investments/1000000000, 0.01)
					
					* Converting population to millions and rounding to 2 decimal places
					gen pop_top = round(pop_mean/1000000, 0.01)
					
					* Keeping key variables
					order REGION_WB country_name land_area_km2 ag_land_km2 pop_top irri_share irr_investments_top  
					br REGION_WB country_name land_area_km2 ag_land_km2 pop_top irri_share irr_investments_top 

				restore
				
				
				
				
				* Top 5 countries by total investments in irrigation (2000-2022) BY REGION
				tab REGION_WB, m
					
						* South Asia (CA)
						preserve
							
							* Select region
							keep if REGION_WB == "South Asia"
							
							* Sort data by irrigation investments (total)
							gsort -irr_investments
							
							* Keep obs. in the top 5
							keep in 1/5
							
							* Convering figures to billions of dollars; rounding to 3 decimal places
							gen irr_investments_top = round(irr_investments/1000000000, 0.01)	
							
							* Converting population to millions and rounding to 2 decimal places
							gen pop_top = round(pop_mean/1000000, 0.01)
							
							* Keeping key variables
							order REGION_WB country_name land_area_km2 ag_land_km2 irr_investments_top  
							br REGION_WB country_name land_area_km2 ag_land_km2 irr_investments_top 

						restore		
						
						
						* East Asia & Pacific (EAP)
						preserve
							
							* Select region
							keep if REGION_WB == "East Asia & Pacific"
							
							* Sort data by irrigation investments (total)
							gsort -irr_investments
							
							* Keep obs. in the top 5
							keep in 1/5
							
							* Convering figures to billions of dollars; rounding to 3 decimal places
							gen irr_investments_top = round(irr_investments/1000000000, 0.01)	
							
							* Converting population to millions and rounding to 2 decimal places
							gen pop_top = round(pop_mean/1000000, 0.01)
							
							* Keeping key variables
							order REGION_WB country_name land_area_km2 ag_land_km2 irr_investments_top  
							br REGION_WB country_name land_area_km2 ag_land_km2 irr_investments_top 

						restore		
						
						
						
						* Sub-Saharan Africa (SSA)
						preserve
							
							* Select region
							keep if REGION_WB == "Sub-Saharan Africa"
							
							* Sort data by irrigation investments (total)
							gsort -irr_investments
							
							* Keep obs. in the top 5
							keep in 1/5
							
							* Convering figures to billions of dollars; rounding to 3 decimal places
							gen irr_investments_top = round(irr_investments/1000000000, 0.01)	
							
							* Converting population to millions and rounding to 2 decimal places
							gen pop_top = round(pop_mean/1000000, 0.01)
							
							* Keeping key variables
							order REGION_WB country_name land_area_km2 ag_land_km2 irr_investments_top  
							br REGION_WB country_name land_area_km2 ag_land_km2 irr_investments_top 

						restore		
						
						
						
						* Middle East & North Africa (MENA)
						preserve
							
							* Select region
							keep if REGION_WB == "Middle East & North Africa"
							
							* Sort data by irrigation investments (total)
							gsort -irr_investments
							
							* Keep obs. in the top 5
							keep in 1/5
							
							* Convering figures to billions of dollars; rounding to 3 decimal places
							gen irr_investments_top = round(irr_investments/1000000000, 0.01)	
							
							* Converting population to millions and rounding to 2 decimal places
							gen pop_top = round(pop_mean/1000000, 0.01)
							
							* Keeping key variables
							order REGION_WB country_name land_area_km2 ag_land_km2 irr_investments_top  
							br REGION_WB country_name land_area_km2 ag_land_km2 irr_investments_top 

						restore		
			
			
			
						* Central Asia (CA)
						preserve
							
							* Select region
							keep if REGION_WB == "Europe & Central Asia"
							
							* Sort data by irrigation investments (total)
							gsort -irr_investments
							
							* Keep obs. in the top 5
							keep in 1/5
							
							* Convering figures to billions of dollars; rounding to 3 decimal places
							gen irr_investments_top = round(irr_investments/1000000000, 0.01)	
							
							* Converting population to millions and rounding to 2 decimal places
							gen pop_top = round(pop_mean/1000000, 0.01)
							
							* Keeping key variables
							order REGION_WB country_name land_area_km2 ag_land_km2 irr_investments_top  
							br REGION_WB country_name land_area_km2 ag_land_km2 irr_investments_top 

						restore		
						
						
						
						* Latin America & Caribbean (LAC)
						preserve
							
							* Select region
							keep if REGION_WB == "Latin America & Caribbean"
							
							* Sort data by irrigation investments (total)
							gsort -irr_investments
							
							* Keep obs. in the top 5
							keep in 1/5
							
							* Convering figures to billions of dollars; rounding to 3 decimal places
							gen irr_investments_top = round(irr_investments/1000000000, 0.01)	
							
							* Converting population to millions and rounding to 2 decimal places
							gen pop_top = round(pop_mean/1000000, 0.01)
							
							* Keeping key variables
							order REGION_WB country_name land_area_km2 ag_land_km2 irr_investments_top  
							br REGION_WB country_name land_area_km2 ag_land_km2 irr_investments_top 

						restore	
		
		
		
		
		** Irrigation investments per capita (2000-2022)
	
			* Map of irrigation investments
			colorpalette viridis, n(15) nograph reverse
			local colors `r(p)'				
			spmap irr_inv_pc2 if lmic == 1 using world_shp, id(_ID) cln(15) fcolor("`colors'")		///
			ocolor(black ..) osize(vvthin ..) ndfcolor(gs14) ndocolor(gs0) 		///
			ndsize(0.03 ..) ndlabel("No data") legend(pos(7) size(*1)) legstyle(3) ///
			polygon(data(world_shp) osize(vvthin) legenda(on) leglabel("High-income countries")) saving(top10InvestmentsPC, replace)		
		
				* Top 20 countries by total investments in irrigation (2000-2022)
				preserve
					
					* Sort data by irrigation investments (total)
					gsort -irr_inv_pc2
					
					* Keep obs. in the top 10
					keep in 1/20
					
					* Converting population to millions and rounding to 2 decimal places
					gen pop_top = round(pop_mean/1000000, 0.01)
					
					* Keeping key variables
					order REGION_WB country_name pop_top irri_share irr_inv_pc2  
					br REGION_WB country_name pop_top irri_share irr_inv_pc2 

				restore				

				
				* Top 5 countries by total investments in irrigation (2000-2022) BY REGION
				tab REGION_WB, m
					
						* South Asia (CA)
						preserve
							
							* Select region
							keep if REGION_WB == "South Asia"
							
							* Sort data by irrigation investments (total)
							gsort -irr_inv_pc2
							
							* Keep obs. in the top 5
							keep in 1/5
							
							* Converting population to millions and rounding to 2 decimal places
							gen pop_top = round(pop_mean/1000000, 0.01)
							
							* Keeping key variables
							order REGION_WB country_name pop_top irri_share irr_inv_pc2  
							br REGION_WB country_name pop_top irri_share irr_inv_pc2 

						restore
						
						
						* East Asia & Pacific (EAP)
						preserve
							
							* Select region
							keep if REGION_WB == "East Asia & Pacific"
							
							* Sort data by irrigation investments (total)
							gsort -irr_inv_pc2
							
							* Keep obs. in the top 5
							keep in 1/5
							
							* Converting population to millions and rounding to 2 decimal places
							gen pop_top = round(pop_mean/1000000, 0.01)
							
							* Keeping key variables
							order REGION_WB country_name pop_top irri_share irr_inv_pc2  
							br REGION_WB country_name pop_top irri_share irr_inv_pc2 

						restore	
	

						* Sub-Saharan Africa (SSA)
						preserve
							
							* Select region
							keep if REGION_WB == "Sub-Saharan Africa"
							
							* Sort data by irrigation investments (total)
							gsort -irr_inv_pc2
							
							* Keep obs. in the top 5
							keep in 1/5
							
							* Converting population to millions and rounding to 2 decimal places
							gen pop_top = round(pop_mean/1000000, 0.01)
							
							* Keeping key variables
							order REGION_WB country_name pop_top irri_share irr_inv_pc2  
							br REGION_WB country_name pop_top irri_share irr_inv_pc2 

						restore
						
						
						* Middle East & North Africa (MENA)
						preserve
							
							* Select region
							keep if REGION_WB == "Middle East & North Africa"
							
							* Sort data by irrigation investments (total)
							gsort -irr_inv_pc2
							
							* Keep obs. in the top 5
							keep in 1/5
							
							* Converting population to millions and rounding to 2 decimal places
							gen pop_top = round(pop_mean/1000000, 0.01)
							
							* Keeping key variables
							order REGION_WB country_name pop_top irri_share irr_inv_pc2  
							br REGION_WB country_name pop_top irri_share irr_inv_pc2 

						restore	
						
						
						* Central Asia (CA)
						preserve
							
							* Select region
							keep if REGION_WB == "Europe & Central Asia"
							
							* Sort data by irrigation investments (total)
							gsort -irr_inv_pc2
							
							* Keep obs. in the top 5
							keep in 1/5
							
							* Converting population to millions and rounding to 2 decimal places
							gen pop_top = round(pop_mean/1000000, 0.01)
							
							* Keeping key variables
							order REGION_WB country_name pop_top irri_share irr_inv_pc2  
							br REGION_WB country_name pop_top irri_share irr_inv_pc2  

						restore		
						
						
						* Latin America & Caribbean (LAC)
						preserve
							
							* Select region
							keep if REGION_WB == "Latin America & Caribbean"
							
							* Sort data by irrigation investments (total)
							gsort -irr_inv_pc2
							
							* Keep obs. in the top 5
							keep in 1/5
							
							* Converting population to millions and rounding to 2 decimal places
							gen pop_top = round(pop_mean/1000000, 0.01)
							
							* Keeping key variables
							order REGION_WB country_name pop_top irri_share irr_inv_pc2  
							br REGION_WB country_name pop_top irri_share irr_inv_pc2 

						restore			
	
	
	
	
	
		** Irrigation investments per capita (2000-2022) if AEI < 20%
	
				* Top 10 countries by total investments in irrigation (2000-2022) if AEI < 10%
				preserve
					
					* Irrigation share <= 10%
					tab irri_share, m
					keep if (irri_share >= 0 & irri_share <= 10)
					
					* Sort data by irrigation investments (total)
					gsort -irr_inv_pc2
					
					* Keep obs. in the top 10
					keep in 1/10
					
					* Converting population to millions and rounding to 2 decimal places
					gen pop_top = round(pop_mean/1000000, 0.01)
					
					* Keeping key variables
					order REGION_WB country_name ag_land_km2 pop_top irri_share irr_inv_pc2  
					br REGION_WB country_name ag_land_km2 pop_top irri_share irr_inv_pc2 

				restore
				
				
				
				* Top 10 countries by total investments in irrigation (2000-2022) if AEI < 20%
				preserve
					
					* Irrigation share <= 20%
					tab irri_share, m
					keep if (irri_share >= 0 & irri_share <= 20)
					
					* Sort data by irrigation investments (total)
					gsort -irr_inv_pc2
					
					* Keep obs. in the top 10
					keep in 1/10
					
					* Converting population to millions and rounding to 2 decimal places
					gen pop_top = round(pop_mean/1000000, 0.01)
					
					* Keeping key variables
					order REGION_WB country_name land_area_km2 ag_land_km2 pop_top irri_share irr_inv_pc2  
					br REGION_WB country_name land_area_km2 ag_land_km2 pop_top irri_share irr_inv_pc2 

				restore	
			
			
	
	
	
	** INVESTMENTS PER CAPITA MAP (main text Figure 1c)

	
			* Marking high-income countries
			*replace pc_invest = -0.1 if lmic == 1 & pc_invest == .		
			// some code needed to classify LMICs without info OR use "Using" when creating the map, maybe using this guide:
			//https://www.statalist.org/forums/forum/general-stata-discussion/general/1530936-spmaps-%7C-remove-certain-parts-of-a-polygon
	
		* Map without names & viridis palette
		colorpalette viridis, n(10) nograph reverse
		local colors `r(p)'	
		spmap irr_inv_pc using world_shp, id(_ID) cln(10) fcolor("`colors'")		///
		ocolor(white ..) osize(vvthin ..) ndfcolor(gs14) ndocolor(gs15 ..) 		///
		ndsize(0.03 ..) ndlabel("No data") legend(pos(7) size(*1)) legstyle(3) saving(investment_map, replace)
		*title("21st-century irrigation investments per capita (2000-2022)", 	///
		*size(medium)) note("Some possible information cab be here" , size(tiny))
		
			* another sample map
			colorpalette viridis, n(10) nograph reverse
			local colors `r(p)'	
			spmap irr_inv_pc2 if lmic == 1 using world_shp, id(_ID) cln(10) fcolor("`colors'")		///
			ocolor(white ..) osize(vvthin ..) ndfcolor(gs14) ndocolor(gs16) 		///
			ndsize(0.03 ..) ndlabel("No data") legend(pos(7) size(*1)) legstyle(3) ///
			polygon(data(world_shp) osize(vvthin) legenda(on) leglabel("High-income countries")) saving(investment_map2, replace)

			
			* another sample map - invesmtents per capita
			colorpalette viridis, n(8) nograph reverse
			local colors `r(p)'	
			spmap irr_inv_pc2 if lmic == 1 using world_shp, id(_ID) cln(8) fcolor("`colors'")		///
			ocolor(white ..) osize(vvthin ..) ndfcolor(gs14) ndocolor(gs16) 		///
			ndsize(0.03 ..) ndlabel("No data") legend(pos(7) size(*1)) legstyle(3) ///
			polygon(data(world_shp) osize(vvthin) legenda(on) leglabel("High-income countries")) saving(investment_map3, replace)
			
			
			* Investement levels
			colorpalette viridis, n(10) nograph reverse
			local colors `r(p)'				
			spmap irr_inv_levels if lmic == 1 using world_shp, id(_ID) cln(10) fcolor("`colors'")		///
			ocolor(white ..) osize(vvthin ..) ndfcolor(gs14) ndocolor(gs16) 		///
			ndsize(0.03 ..) ndlabel("No data") legend(pos(7) size(*1)) legstyle(3) ///
			polygon(data(world_shp) osize(vvthin) legenda(on) leglabel("High-income countries")) saving(investment_levels, replace)
			
				
		* Map without names & cividis palette
		colorpalette cividis, ipolate(18, power(1.2)) nograph reverse 
		local colors `r(p)'
		spmap irr_inv_pc2 using world_shp, id(_ID) cln(15) fcolor("`colors'")		///
		ocolor(white ..) osize(vvthin ..) ndfcolor(gs14) ndocolor(gs15 ..) 		///
		ndsize(0.03 ..) ndlabel("No data") legend(pos(7) size(*1)) legstyle(2)   
		*title("21st-century irrigation investments per capita (2000-2022)", 	///
		*size(medium)) note("Some possible information cab be here" , size(tiny))
		
		
		
		* Bivariate map (source: https://nariyoo.com/stata-how-to-create-the-bivariate-map-bimap-package/)
		
			/* Step 1: Install packages
			ssc install bimap, replace
			ssc install spmap, replace 
			ssc install palettes, replace
			ssc install colrspace, replace
			ssc install schemepack, replace
			*/
			set scheme white_tableau
			
		
			
			
			* Step 3: Draw the bivariate maps
		
				// Calculate quantiles and create quantile category variable
				egen pctile_invest = cut(irr_inv_pc2), group(10)
				
				tab pctile_invest if lmic == 1
				tab country_name irr_inv_pc2 if pctile_invest == 9 & lmic == 1	// countries with most investments per capita (top decile)
				tab REGION_WB if pctile_invest == 9 & lmic == 1					// countries in top decile by region
				tab country_name irr_inv_pc2 if irri_share <= 20 & pctile_invest == 9 & lmic == 1	// countries with high investments & low irrigation area in 2000
				tab country_name irri_share if irri_share <= 20 & pctile_invest == 9 & lmic == 1		
				
				tab country_name irr_inv_pc2 if irri_share >= 80 & pctile_invest >= 7 & lmic == 1	// countries with high investments & high irrigation area in 2000
				tab country_name irri_share if irri_share >= 80 & pctile_invest >= 7 & lmic == 1		
				
				
				

				// Display the data
				list irr_inv_pc2 pctile_invest, sepby(pctile_invest)
				tab irr_inv_pc2 pctile_invest
	
			
			bimap irr_inv_pc2 irri_share using world_shp if lmic == 1, cuty(0 1 5 11 18 25 43 64 111 502) cutx(0, 20, 40, 60, 80, 100) binx(5) biny(8) ///
			palette(pinkgreen)  ///	
			texty("Investments per capita") textx("Area equipped for irrigation in 2000") texts(3) textlabs(2.5) formatx(%2.0f) formaty(%2.0f) ///
			ocolor(white ..) osize(vvthin ..) ///
			ndfcolor(gs14) ndocolor(gs16) ndsize(0.03 ..) values ///
			polygon(data(world_shp) osize(vvthin) legenda(off)) showleg legenda(off) legend(ring(0) position(7) size(5) bmargin(large)) legstyle(2)
				
	
				
				
				
	
