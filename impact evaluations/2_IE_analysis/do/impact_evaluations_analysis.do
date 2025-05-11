/****************************************************************************************************************
Paper:			The role of development institutions in advancing sustainable irrigation

Authors:		Cesar Augusto Lopez, Rosamond L. Naylor, and James Holland Jones

Description: 	Analyzing impact evaluation studies (data from systematic search of published literature)	
			
Last modified: 	January, 2024
****************************************************************************************************************/


/* Directory and globals */
clear all
set more off

	* MAC Directory
	cd "/Users/cesaraugusto/Desktop/impact evaluations/2_IE_analysis" // apply your directory
	global userdir "/Users/cesaraugusto/Desktop/impact evaluations/2_IE_analysis"

	global do_files  "$userdir/do" 
	global log_files "$userdir/log"
	global data_files "$userdir/data"
	global out_files "$userdir/data/out"
	global in_files  "$userdir/data/in"
	global tables_files  "$userdir/tables"

	
	
*** STEP 1: Converting data to .dta format

	* Module 3 (extended version)
	import excel "$in_files/chapter1_onlyCAL_rawData_Module3_extended_10052023.xlsx", sheet("Sheet1") firstrow clear
	
		* Reshaping data wide to long					// We will merge our outcome classifications with this data using the outcome names (later)
		reshape long outcome, i(key) j(outcome_no)
		
		* Drop empty rows
		drop if outcome == ""
	
	save "$in_files/chapter1_onlyCAL_rawData_Module3_extended_10052023.dta", replace
	
	
	* Module 3 (decisions)	// These are all the  outcomes for the papers in Module 3; 
							// we've manually classified each raw outcome to "outcome categories" based on 3ie's taxonomy of outcomes
	import excel "$in_files/chapter1_onlyCAL_rawData_Module3_Decisions_10052023.xlsx", sheet("Sheet1") firstrow clear
	save "$in_files/chapter1_onlyCAL_rawData_Module3_Decisions_10052023.dta", replace

	
	* Outcome groups
	import excel "$in_files/outcome_groups.xlsx", sheet("Sheet1") firstrow clear
	save "$in_files/outcome_groups.dta", replace
	
	
	* Module 1 (extended version)
	import excel "$in_files/chapter1_onlyCAL_rawData_Module1_extended_10052023.xlsx", sheet("Sheet1") firstrow clear
	save "$in_files/chapter1_onlyCAL_rawData_Module1_extended_10052023.dta", replace

	
	* Module 1
	import excel "$in_files/chapter1_onlyCAL_rawData_Module1_10052023.xlsx", sheet("Sheet1") firstrow clear
	save "$in_files/chapter1_onlyCAL_rawData_Module1_10052023.dta", replace
	
	


*** STEP 2: Creating Table 1 (Typology of impact evaluation studies)
			
			*** Exclude papers that did not meet the Inclusion/exclusion criteria
			
				* Exclude papers that were not found
				tab notFound, m
				drop if notFound == 1
				
				* Exclude papers not in the English language
				tab notEnglish, m
				drop if notEnglish == 1
				
				* Exclude papers that are not in LMICs
				tab notLMIC, m
				drop if notLMIC == 1
				
				* Exclude papers that are not about a specific country
				tab country, m
				drop if country == "999"
				
				* Exclude duplicated papers
				tab irr_infra_dev pub_type3, m
				drop if pub_type3 == 1
				
				* Exclude papers that were not related to irrigation infrastructure
				tab irr_infra_dev, m
				drop if irr_infra_dev == 2
			
				* Exclude papers that do not involve an IE study
				tab ie, m
				keep if ie == 1
				
					
					
					* Saving no. studies to create maps with number of papers
					preserve
					
						keep key country irrig_program 
						
						* Checking countries data
						tab country, m	// We have 2 papers that examine impacts in 2 separate countries (Ethiopia & Tanzania)
						
							* Generating duplicates for each paper above (assigning Tanzania)
							input 
							"IJZJIH97" "Ethiopia" 1
							"AK7PT7P8" "Ethiopia" 1
							end
							
							* Replacing names from the two papers above
							replace country = "Tanzania" if country == "Ethiopia and Tanzania"
						
											
						* Studies by country
						
							* Total
							gen tot = 1
							egen n_study = total(tot), by(country)
							label variable n_study "No. studies (total)"
							
							* Studies with an intervention
							gen inter = (irrig_program == 1)
							egen n_stu_inter = total(inter), by(country)
							label variable n_stu_inter "No. studies (intervention)"
						
							* Studies without an intervention
							gen n_stu_Nointer = n_study - n_stu_inter
							label variable n_stu_Nointer "No. studies (NO intervention)"
							
							
						* Keeping one obs. per country
						bysort country: gen country_n = _n
						keep if country_n == 1
						
						
						* Renaming variables to match our map data
						rename country country_name
							
							
						* Saving
						drop key tot inter country_n irrig_program 	// no longer necessary
						save "$out_files/studies_to_create_maps.dta", replace

					restore


		/*NOTE: There are some papers in our dataset that report using
		multiple IE methodologies, analyzing different units of observation,
		looking at different timeframes, estimating various causal estimands,
		etc. In our raw dataset, we've recorded all of this information.
		A portion of our paper/table will reflect this information. 
		e.g., a paper that asseses impact of SMALL and LARGE irrigation
		infrastructure; the final table will show both results, but that does
		not mean that we have two papers, instead we have a single paper
		that estimates both. 
		*/
		
		
	* Experimental vs. quasi-experimental // Impact evaluation design
	table ie_d, statistic(frequency) stat(percent)  nformat(%2.0f) m			// (1 = experimental, 2 = quasi-experimental)
	
		
	* Published or grey literature	(pub_type2 = 1 if doc is latest version, 2 = not latest version)
	tab pub_type pub_type2, m			// published vs gray literature
	tab pub_type2 pub_type3, m			// (pub_type3 = 1 if duplicated; 2 = not duplicated)
	tab pub_type3 if pub_type2 == 2, m	// gray papers, not the latest version
	tab pub_type3 pub_type4, m			// (pub_type4 = 1 if newest version is a WP or 2 if newest is a published paper);
										// 1 = published; 1 a working paper
		
	
	* Program or intervention
	table irrig_program, statistic(frequency) stat(percent)  nformat(%2.0f) m	// (1 = yes, 2 = no)
	
		* How many without an intervention are estimating long-term or dynamic effects?
		tab horizon irrig_program, m col 
		tab horizon if irrig_program == 2, m 
		tab ie_d2 if irrig_program == 2 & horizon == "5", m
	
	
	* Region
		
		* Merge region names
		replace country = "United Republic of Tanzania" if country == "Tanzania"
		gen ADMIN = country
		replace ADMIN = "United Republic of Tanzania" if ADMIN == "Ethiopia and Tanzania"
		merge m:1 ADMIN using "$in_files/world.dta", keepusing(REGION_WB)
		keep if _merge == 3		// Match should be 100%
		drop _merge ADMIN
		rename REGION_WB region
		
			* Abbreviations
			replace region = "SA" if region == "South Asia"
			replace region = "SSA" if region == "Sub-Saharan Africa"
			replace region = "LAC" if region == "Latin America & Caribbean"
			replace region = "CA" if region == "Europe & Central Asia"
			replace region = "EAP" if region == "East Asia & Pacific"
		
		* Distribution of regions
		table region, statistic(frequency) stat(percent)  nformat(%2.0f) m
		
		* Regions and intervention
		tab region irrig_program, m col row
		
		* Scale and region if NO intervention
		tab scale region if irrig_program == 2, m
		
		* Timeframe and region if NO intervention
		tab horizon region if irrig_program == 2, m row
		
		
		/*** Examining studies from SSA ***/
		
			* Interventions in SSA
			tab region irrig_program, m	row // nearly 80% of studies from SSA do not involve an intervention
						
			* Timeframe in SSA
			tab region horizon, m row
			
			* Estimands for studies from SSA with uncertain timeframe and without an intervention
			tab irrig_program estimand if region == "SSA" & horizon == "5" & irrig_program == 2, m	
			// 36 (34 coded as "2" + 2 coded as "1,2") estimating ATT out of 46 where no intervention is involved
			
			* Methods for studies from SSA with uncertain timeframe and without an intervention
			tab ie_d2 estimand if region == "SSA" & horizon == "5" & irrig_program == 2, m		
			
			* Timeframe in SSA
			tab region horizon , m row
			
			
	
	* Scale
	table scale, statistic(frequency) stat(percent)  nformat(%2.0f) m			// (1=micro, 2=small, 3=medium/large, 4=uncertain)
	tab scale horizon, m	// n=6 uncertain (2 from EAP, 1 from SA, and 3 from SSA)
			

	* Unit of observation
	table unit, statistic(frequency) stat(percent)  nformat(%2.0f) m			// (1=plot, 2=pixel, 3=individual, 4=household, 5=community, 6=district, 7=state)
	tab unit horizon, m
	
	
	* Timeframe
	tab horizon, m	// none missing
	table horizon, statistic(frequency) stat(percent)  nformat(%2.0f) m			//1=short, 2=medium, 3=long, 4=dynamic, 5=uncertain)
	table horizon region
	
		* Checking charactersitics of those studies where time frame is uncertain
		tab estimand if horizon == "5"
		tab unit if horizon == "5"
		tab scale if horizon == "5"
	
	* Causal estimand
	tab estimand, m 				// none missing
	tab estimand horizon, m 		// none missing

	table estimand, statistic(frequency) stat(percent)  nformat(%2.0f) m		// (1=ATE, 2=ATT, 3=ITT, 4=LATE)

	
	
	** Studies examining LONG and DYNAMIC effects
	tab horizon, m	// 1 "Short" 2 "Medium" 3 "Long" 4 "Dynamic" 5 "Uncertain"
	br if (horizon == "1, 3" | horizon == "2, 4" | horizon == "3" | horizon == "3, 4")
	
	
	


*** STEP 3: Creating dataset to generate Figure 3 (outcome group-methodologies-regions) using R

	* Merge outcome data with our decision data
	use "$in_files/chapter1_onlyCAL_rawData_Module3_extended_10052023.dta", clear
	merge m:1 outcome using "$in_files/chapter1_onlyCAL_rawData_Module3_Decisions_10052023.dta"
	drop _merge

	* Merge country names
	merge m:m key using "$in_files/chapter1_onlyCAL_rawData_Module1_extended_10052023.dta", keepusing(country ie_d ie_d2 ie_d3 irrig_program)
	keep if _merge == 3
	drop _merge 	
	
	* Merge region names
	replace country = "United Republic of Tanzania" if country == "Tanzania"
	gen ADMIN = country
	merge m:1 ADMIN using "$in_files/world.dta", keepusing(REGION_WB)
	keep if _merge == 3	
	drop _merge ADMIN
	rename REGION_WB region
	
		* Abbreviations
		replace region = "SA" if region == "South Asia"
		replace region = "SSA" if region == "Sub-Saharan Africa"
		replace region = "LAC" if region == "Latin America & Caribbean"
		replace region = "CA" if region == "Europe & Central Asia"
		replace region = "EAP" if region == "East Asia & Pacific"
		
	
	* Coding methodologies
	tab ie_d2 ie_d, m	
	gen method = "OLS" if ie_d == 1		// These are randomized controlled trials
	replace method = "RD" if ie_d2 == "1" & method == ""
	replace method = "DiD" if ie_d2 == "2" & method == ""
	replace method = "FE" if ie_d2 == "3" & method == ""
	replace method = "Matching" if ie_d2 == "4" & method == ""
	replace method = "IV" if ie_d2 == "5" & method == ""
	replace method = "SC" if ie_d2 == "6" & method == "" 
	replace method = "Weighting" if ie_d2 == "7" & method == "" 
	replace method = "ESR" if ie_d2 == "8" & method == ""
	replace method = "HTS" if ie_d2 == "9" & method == ""
	replace method = "ERM" if ie_d2 == "10 (ERM, extended regression model)" & method == ""
	
	* Merge outcome group data
	merge m:1 outcome_choice using "$in_files/outcome_groups.dta"
	keep if _merge == 3		// Match should be 100%
	drop _merge
	
		* Number of indicators per outcome group
		tab outcome_group, sort												

		
		* Treemap
		//net install treemap, from("https://raw.githubusercontent.com/asjadnaqvi/stata-treemap/main/installation/") replace
		set scheme white_tableau
		graph set window fontface "Arial Narrow"
			
			* Re-labeling outcome groups variable to make the graph easiert to understand
			gen outcome_group2 = outcome_group
			replace outcome_group2 = "Market" if outcome_group2 == "Market access & sales"
			replace outcome_group2 = "Social dev." if outcome_group2 == "Social development"
			replace outcome_group2 = "Urban" if outcome_group2 == "Urbanization"
			replace outcome_group2 = "Envi." if outcome_group2 == "Environmental"
			replace outcome_group2 = "Misc." if outcome_group2 == "Miscellaneous"
	
		gen var_num = 1
		treemap var_num, by(outcome_group2 outcome_choice) addtitles labsize(3) format(%15.0fc) ///
		palette(CET L10) xsize(5) ysize(3) labprop titlegap(0.15) labgap(0.9)
	
		
		
		***** Outcome categories and groups per unique combination  *****
		
			* Unique studies per outcome category
			by key_original outcome_choice, sort: gen dupCAT = cond(_N==1,0,_n)
			tab outcome_choice if (dupCAT == 0 | dupCAT == 1), m sort			// papers per "outcome categories"
			display r(r)	// 60 outcome categories	
			
			* Unique studies per outcome group
			by key_original outcome_group, sort: gen dupGRO = cond(_N==1,0,_n)
			tab outcome_group if (dupGRO == 0 | dupGRO == 1), m sort			// papers per "outcome groups"
			display r(r)	// 15 outcome categories	
			
	
	* Number of studies implementing two or more methodologies
	quietly bysort key_original method: gen dupMethod = cond(_N==1,0,_n)
	tab key_original if (dupMethod == 0 | dupMethod == 1)	
	display r(r) 	//n=104
	
	* Keeping one observation (paper-outcome group) per paper
	quietly bysort key outcome_group: gen dup = cond(_N==1,0,_n)
	tab outcome_group if (dup == 0 | dup == 1)
	
		* Keeping one observation (paper-method-outcome group) per paper
		quietly bysort key_original method outcome_group: gen dup2 = cond(_N==1,0,_n)
		tab outcome_group if (dup2 == 0 | dup2 == 1)		
			
	keep if (dup2 == 0 | dup2 == 1)
	
		* Number of papers per outcome group
		tab outcome_group, m sort

	* Saving dataset to create our final figure
	keep key outcome_no outcome outcome_choice outcome_group region method irrig_program
	sort key outcome_group
	compress
	save "$out_files/chapter1_onlyCAL_rawData_Outcomes_10052023.dta", replace
		
		
				
		

		

*** STEP 4: Clustering section

	*** STEP 4.1: Saving data for analysis in R
	
		* Load complete data (module 1 extended)
		use "$in_files/chapter1_onlyCAL_rawData_Module1_extended_10052023.dta", clear
		
			*** Exclude papers that did not meet the Inclusion/exclusion criteria
			
				* Exclude papers that were not found
				tab notFound, m
				drop if notFound == 1
				
				* Exclude papers not in the English language
				tab notEnglish, m
				drop if notEnglish == 1
				
				* Exclude papers that are not in LMICs
				tab notLMIC, m
				drop if notLMIC == 1
				
				* Exclude papers that are not about a specific country
				tab country, m
				drop if country == "999"
				
				* Exclude duplicated papers
				tab irr_infra_dev pub_type3, m
				drop if pub_type3 == 1
				
				* Exclude papers that were not related to irrigation infrastructure
				tab irr_infra_dev, m
				drop if irr_infra_dev == 2
			
				* Exclude papers that do not involve an IE study
				tab ie, m
				keep if ie == 1	
		
		* Merge outcome 
		merge 1:m key using "$in_files/chapter1_onlyCAL_rawData_Module3_extended_10052023.dta"
		drop _merge	// merge should be 100%
		
		
		* Merge our outcome decision data
		merge m:1 outcome using "$in_files/chapter1_onlyCAL_rawData_Module3_Decisions_10052023.dta"
		drop _merge	// merge should be 100%
		
		
		* Merge outcome group data
		merge m:1 outcome_choice using "$in_files/outcome_groups.dta"
		drop _merge	// merge should be 100%
		
		
		* Labeling data
		tab irrig_program, m
		
			
			* Generate categorical variables for each "study feature"
			
				* Research design
				tab ie_d, m
				
					* Encoding (string to categorical)
					label define experi 1 "Experimental" 2 "Quasi-Experimental" // Define labels for the values
					label values ie_d experi									// Assign labels to the variable
										
				* Scale
				tab scale, m
				
					* Encoding (string to categorical)
					label define scale_la 1 "Micro" 2 "Small or medium" 3 "Large"
					label values scale scale_la
								
				* Estimand
				tab estimand, m
					
					* Encoding (string to categorical)
					label define esti_la 1 "ATE" 2 "ATT" 3 "ITT" 4 "LATE"
					label values estimand esti_la

				* Timeframe
				tab horizon, m
				
					* Encoding (string to categorical)
					label define hori_la 1 "Short" 2 "Medium" 3 "Long" 4 "Dynamic" 5 "Uncertain"
					label values horizon hori_la				

				* Observation
				tab unit, m
				replace unit = "8" if unit == "River basin level"				// We will skip using both for now
				
					* Encoding (string to categorical)
					destring unit, gen(unit_cat)
					label define unit_la 1 "Parcel" 2 "Pixel" 3 "Individual" 4 "Household" 5 "Community" 6 "District" 7 "State" 8 "River basin"
					label values unit_cat unit_la			

					
				* Encoding the categorical oucome_choice variable
				gen outcome_choice2 = outcome_choice
				sort outcome_choice
				encode outcome_choice, generate(outcome_num)
				tab outcome_choice, generate(outcome)	// Outcome choices are represented by unique numbers under outcome_num
				scalar out_num = r(r)					// number of unique outcome choices

				
				* Encoding other categorical unit variable
				tab unit, generate(unit_)
				tab horizon, gen(horizon_)
				tab estimand, gen(estimand_)
				tab scale, gen(scale_)
				tab irrig_program, gen(irrig_program_)
				
				
		* Preparing data for exporting
		drop outcome_no
		keeporder key key_original ie_d outcome outcome_num outcome_group outcome_choice2 outcome_choice irrig_program scale estimand horizon unit	///
		irrig_program_1 irrig_program_2 scale_1 scale_2 scale_3 scale_4 estimand_1 estimand_2 estimand_3 estimand_4 horizon_1 horizon_2 horizon_3 	///
		horizon_4 horizon_5 unit_1 unit_2 unit_3 unit_4 unit_5 unit_6 unit_7 unit_8 outcome*
					
					
		* Saving dataset
		compress
		save "$out_files/chapter1_onlyCAL_MachineLearning_Data_10052023.dta", replace
		export delimited using "$out_files/chapter1_onlyCAL_MachineLearning_Data_10052023.csv", replace nolabel
		
		
		
		
		
		
	*** STEP 4.2: Importing the results: Post hierarchical clustering analysis
	import delimited "$out_files/chapter1_onlyCAL_MachineLearning_Data_10052023_clusters.csv", clear
	
	
		* Encoding variables
			
			* Research design
			label define experi 1 "Experimental" 2 "Quasi-Experimental"
			label values ie_d experi
			
			* Irrigation intervention
			label define irrigP 1 "Yes" 2 "No"
			label values irrig_program irrigP
									
			* Scale
			label define scale_la 1 "Micro" 2 "Small" 3 "Medium or large"
			label values scale scale_la
							
			* Estimand
			label define esti_la 1 "ATE" 2 "ATT" 3 "ITT" 4 "LATE"
			label values estimand esti_la

			* Timeframe
			label define hori_la 1 "Short" 2 "Medium" 3 "Long" 4 "Dynamic" 5 "Uncertain"
			label values horizon hori_la				

			* Observation
			destring unit, gen(unit_cat)
			label define unit_la 1 "Parcel" 2 "Pixel" 3 "Individual" 4 "Household" 5 "Community" 6 "District" 7 "State" 8 "River basin"	
			label values unit unit_la
			
			
			
	*** STEP 4.3: Defining clusters at different heights

	
		* Number of studies per cluster
		foreach num of numlist 1/7 {
			quietly bysort cluster`num': gen n_obs_cluster`num' = _N
			gen set`num' = 1 if n_obs_cluster`num' >= 2 & n_obs_cluster`num' != .				
			quietly bysort cluster`num' n_obs_cluster`num': gen orderObs`num' = cond(_N==1,0,_n) if set`num' == 1
		
			* Excluding clusters with a single independent study
			quietly bysort cluster`num' n_obs_cluster`num' key_original: gen n_study_clusterX`num' = _n == 1 if set`num' == 1
			quietly bysort cluster`num': egen n_study_cluster`num' = total(n_study_clusterX`num') if set`num' == 1	
			drop n_study_clusterX`num' // no longer necessary
			label variable n_study_cluster`num' "No. independent studies within cluster"			
			gen set_noSingle_`num' = 1 if (n_study_cluster`num' != 1 & n_study_cluster`num' != .)
			
			* Creating cluster identifiers
			egen ID_clust_ht`num' = group(cluster`num') if set_noSingle_`num' == 1
			
			* Cluster includes a study that involves an interventions
			gen inclu`num' = 1 if irrig_program == 1 & ID_clust_ht`num' != .
			bysort ID_clust_ht`num': egen incInter`num' = max(inclu`num') //
			drop inclu`num' // no longer necessary
			
		}
		
		
		
		
		
	*** STEP 4.4: Exploring clusters
	
		* Clusters at different heights (considering clusters that include at least 1 study with an irrigation intervention)
		/* We'll create two LaTeX tables:
		
			1. Summary of number of clusters at different heights
			2. Number of observations, per cluster, from studies that involve an irrigation infrastructure
			
		*/
		
			* Create an empty matrix to store results (summary of no. of clusters)
			clear matrix
			matrix results = J(5, 1, .)		
			
				* Populating the matrix

					* 1st lowest height
					tab ID_clust_ht1 if irrig_program == 1, sort	// height = 0
					di r(r)		// n=22 clusters
					matrix results[1,1] = r(r)
					
					* 2nd lowest height
					tab ID_clust_ht2 if irrig_program == 1, sort 	// height = 2.832434
					di r(r)		// n=25
					matrix results[2,1] = r(r)

					* 3rd lowest height
					tab ID_clust_ht3 if irrig_program == 1, sort	// height = 2.977015
					di r(r)		// n=27
					matrix results[3,1] = r(r)

					* 4th lowest height
					tab ID_clust_ht4 if irrig_program == 1, sort	// height = 3.028594
					di r(r)		// n=29
					matrix results[4,1] = r(r)
					
					* 5th lowest height
					tab ID_clust_ht5 if irrig_program == 1, sort	// height = 3.042650
					di r(r)		// n=31
					matrix results[5,1] = r(r)
					
		
			* Formating matrix's rows and columns names (summary of clusters for each horizontal cut)
			mat rownames results = "1st lowest" "2nd lowest" "3rd lowest" "4th lowest" "5th lowest"	// row names
			mat colnames results = "No clusters"
			esttab matrix(results), eqlabels(,merge) tex substitute(:r1 "")

			
			* Table including number of obs and studies per cluster
			clear matrix
			foreach num of numlist 1/5 {
				
				preserve

				* Subset the data and create a temporary file
				keep if orderObs`num' == 1 & incInter`num' == 1 & set_noSingle_`num' == 1
				keep n_obs_cluster`num' n_study_cluster`num'
				order n_obs_cluster`num' n_study_cluster`num'

				* Sort the data by n_obs_cluster1
				gsort -n_obs_cluster`num' -n_study_cluster`num'

				* Save data in matrix
				mkmat n_obs_cluster`num' n_study_cluster`num', mat(clusObs`num')

				restore
			}

			matrix empty1 = J(31, 1, .)	// empty matrix
			matrix coljoin clusObs = clusObs1 empty1 clusObs2 empty1 clusObs3 empty1 clusObs4 empty1 clusObs5
			mat rownames clusObs = 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
			mat colnames clusObs = "Obs" "Studies" " " "Obs" "Studies" " " "Obs" "Studies" " " "Obs" "Studies" " " "Obs" "Studies"
			matrix list clusObs
			esttab matrix(clusObs), tex	
		
		
		

		
		* Manually inspecting studies within clusters at different horizontal cuts
			
			* 1st lowest height: SET A1 (height = 0) - studies that explicitly involve an irrigation program/intervention
			tab ID_clust_ht1 if irrig_program == 1, sort
			di r(r)		// n=22 clusters
	
	
				* Largest cluster: 12
					br if ID_clust_ht1 == 12
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 12				// cluster's characteristics
					// Outcome category = Divetary diversity; No. obs = 25; No. independent studies = 3
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 12	// Studies attributes
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATT
					
						/* 	Notes 
							1. Studies 25SETWEJ & YLNT8UYS both have the same outcome measure: HDDS (Household Dietary Diversity Score)
							
							HDDS indicator ranges from 0 to 12, where higher values indicate greater food diversity (12 food groups).
							The HDDS is meant to provide an indication of household economic access to food, thus items that require
							household resources to obtain, such as condiments, sugar and sugary foods, and beverages, are included in 
							the score. Individual scores are meant to reflect the nutritional quality of the diet.
							
							According to FAO, There are no established cut-off points in terms of number of food groups to indicate 
							adequate or inadequate dietary diversity for the HDDS and WDDS. Because of this it is recommended to use 
							the mean score or distribution of scores for analytical purposes
							Discrete ordinal variable, can be treated as continous since it has multiple categories (i.e, 12).
								
								- 25SETWEJ uses a DiD framework, reports the number, means and st. devs. of each group for 
								baseline and follow-up, plus the DiD estimate and the stadard error of the estimate.
								
								- YLNT8UYS uses IPW and reports treatment effect estimates, sample size, and whether it is significant
								at the 1%, 5%, or 10% level, but does not provide standard errors, standard deviatons, p-values of C.I.s
						*/
					
					
					
				* 2nd largest cluster: 37
					br if ID_clust_ht1 == 37 // Outcome category: Overall agricultural expenditure; Outcome group = Expenditures
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 37
					// No. obs = 20; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 37
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATE

					/* 	Notes 
						1. Studies QX9FKF7R & XRZV6C7F measure a similar outcome:
							- QX9FKF7R: Paid labor (US$)
							- XRZV6C7F: Labor expenditure (Birr, log)
							
							We may be able to harmonizethese outcomes to ensure the comparability and meaningful synthesis of the findings.
							For example, we can try to perform: (1) conversion to a common currency, (2) adjusting for log transformation,
							(3) consider sensitivity analysis (e.g., robustness check that includes meta-analysis with and wihout the log
							transformation to evaluate the impact of this differnt measurement)	
					*/
					
					
				* 3rd largest cluster: 24
					br if ID_clust_ht1 == 24 // Outcome category: Income from agriculture; Outcome group = Income
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 24
					// No. obs = 13; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 24
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATE
					
					/* 	Notes 
						1. Studies QX9FKF7R & XRZV6C7F measure a similar outcome:
							- QX9FKF7R: Value of production (US$)
							- XRZV6C7F: Crop income (Birr, log)
							
							We may be able to harmonize these outcomes to ensure the comparability and meaningful synthesis of the findings.
							For example, we can try to perform: (1) conversion to a common currency, (2) adjusting for log transformation,
							(3) consider sensitivity analysis (e.g., robustness check that includes meta-analysis with and wihout the log
							transformation to evaluate the impact of this differnt measurement)	
					*/	
					
					
					
				* 4th largest cluster: 4
					br if ID_clust_ht1 == 4 // Outcome category: Crop yield; Outcome group = Production
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 4
					// No. obs = 9; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 4
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATE
					
					/* 	Notes 
						1. No similarities		
					*/					
					
					
				* 5th largest cluster: 13
					br if ID_clust_ht1 == 13 // Outcome category: Domestic food expenditure; Outcome group = Food security
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 13
					// No. obs = 9; No. independent studies = 3
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 13
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATT
					
					/* 	Notes 
					1. Studies BEHE5VDZ, VGSCUGFK, and SMYLJJIZ measure a similar outcome:
							- BEHE5VDZ: Total per capita daily food consumption expenditure, $PPP
							- VGSCUGFK: Expenditure ($) on food items per capita per day
							- SMYLJJIZ: Per capita daily food CE (in PPP)
							
							We may be able to harmonize these outcomes to ensure the comparability and meaningful synthesis of the findings.
							For example, we can try to perform: (1) adjust measure to be PPP.
					*/	
					
					
					
				* 6th largest cluster: 57
					br if ID_clust_ht1 == 57 // Outcome category: Wealth and assets; Outcome group = Wealth & assets
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 57
					// No. obs = 9; No. independent studies = 3
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 57
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATT
					
					/* 	Notes 
						1. No similarities		
					*/					
					
					
					
				* 7th largest cluster: 3
					br if ID_clust_ht1 == 3 // Outcome category: Crop yield; Outcome group = Production
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 3
					// No. obs = 7; No. independent studies = 4
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 3
					// Quasi-experimental, medium or large-scale, household-level data, short-term effects, ATT
					
					/* 	Notes 
					1. Studies 2JXV43UQ, L2BHZGLQ, and RIVYZ5AY measure a similar outcome:
							- 2JXV43UQ: Increase in paddy yield (kg/bigha)
							- L2BHZGLQ: Rice yields (kg/ha) (log)
							- RIVYZ5AY: Ln (Yield) (kg/ha)
							
							We may be able to harmonize these outcomes to ensure the comparability and meaningful synthesis of the findings.
					*/	
					
					
					
				* 8th largest cluster: 48
					br if ID_clust_ht1 == 48 // Outcome category: Overall household income; Outcome group = Income
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 48
					// No. obs = 6; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 48
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATT
					
					/* 	Notes 
						1. No similarities		
					*/						
					

					
				* 9th largest cluster: 30
					br if ID_clust_ht1 == 30 // Outcome category: Income from non-farm employment; Outcome group = Income
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 30
					// No. obs = 5; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 30
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATE
					
					/* 	Notes 
						1. No similarities		
					*/						
					
					
				* 10th largest cluster: 34
					br if ID_clust_ht1 == 34 // Outcome category: Index of household wealth or assets; Outcome group = Wealth & assets
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 34
					// No. obs = 4; No. independent studies = 3
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 34
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATT
					
					/* 	Notes 
						1. Studies 5G8FJWF3, VGSCUGFK, and RIVYZ5AY measure a similar outcome:
							- 5G8FJWF3: Wealth index (constructed via PCA)
							- VGSCUGFK: asset ownership (asset-based wealth index via PCA)
							- YLNT8UYS: Productive asset index (PCA-based index of productive assets)
							
							Wealth indices constructed via PCA. We may be able to combine them
					*/						
					
					
					
				* 11th largest cluster: 41
					br if ID_clust_ht1 == 41 // Outcome category: Overall household expenditure; Outcome group = Expenditures
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 41
					// No. obs = 4; No. independent studies = 3
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 41
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATT
					
					
					/* 	Notes 
						1. Studies BEHE5VDZ, SMYLJJIZ, and VGSCUGFK measure a similar outcome:
							- BEHE5VDZ: Total per capita daily consumption expenditure, $PPP
							- SMYLJJIZ: Total per capita daily CE (consumption expenditure; per capita daily USD at purchasing power parity (PPP))
							- VGSCUGFK: Expenditure ($) per capita per day
							
							We may be able to harmonize these outcomes
					*/					
					
					
					
				* 12th largest cluster: 1
					br if ID_clust_ht1 == 1 // Outcome category: Area allocated to crops; Outcome group = Land use
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 1
					// No. obs = 3; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 1
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATE			
					
					/* 	Notes 
						1. Studies QX9FKF7R and XRZV6C7F measure a similar outcome:
							- QX9FKF7R: Physical cultivated (ha)
							- XRZV6C7F: Crop area
							
							We may be able to harmonize these outcomes
					*/					

					
				* 13th largest cluster: 2
					br if ID_clust_ht1 == 2 // Outcome category: Crop diversification; Outcome group = Land use
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 2
					// No. obs = 3; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 2
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATE			
					
					/* 	Notes 
						1. No similarities		
					*/
					
					
					
				* 14th largest cluster: 18
					br if ID_clust_ht1 == 18 // Outcome category: Food security index; Outcome group = Food security
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 18
					// No. obs = 3; No. independent studies = 3
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 18
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATE			
					
					/* 	Notes 
						1. Studies BEHE5VDZ, SMYLJJIZ, and VGSCUGFK report a related outcome:
							- BEHE5VDZ: Food insecurity score (measure of ability to meet daily household food needs)
							- SMYLJJIZ: Food insecurity score (zero (no problems during the previous year) to one (perpetually unable to meet food needs))
							- VGSCUGFK: Household food insecurity score (Household Food Insecurity Access Scale (HFIAS))
							
						Note that BEHE5VDZ & SMYLJJIZ use the same dataset, so we have to be careful about it. Also, VGSCUGFK uses an experience-based
						food security scale, while the other two studies create a food security score ranging from 0 to 1 based on data on frequency
						of being unable to meet houseold food needs.
					*/				
					
					
					
				* 15th largest cluster: 38
					br if ID_clust_ht1 == 38 // Outcome category: Overall agricultural expenditure; Outcome group = Expenditures
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 38
					// No. obs = 3; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 38
					// Quasi-experimental, medium or large-scale, household-level data, short-term effects, ATT					
					

					/* 	Notes 
						1. No similarities		
					*/
					
					
				
				* 16th largest cluster: 54
					br if ID_clust_ht1 == 54 // Outcome category: Social empowerment; Outcome group = Social development
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 54
					// No. obs = 3; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 54
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATT					
					

					/* 	Notes 
						1. No similarities		
					*/
					
					
					
				* 17th largest cluster: 11
					br if ID_clust_ht1 == 11 // Outcome category: Cropping intensity; Outcome group = Production
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 11
					// No. obs = 2; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 11
					// Quasi-experimental, medium or large-scale, household-level data, short-term effects, ATT					
					

					/* 	Notes 
						1. Studies 2JXV43UQ and L2BHZGLQ report a related outcome:
							- 2JXV43UQ: Increase in double cropping
							- L2BHZGLQ: Cropped more than one season (dummy)
							
						They are both measured as dummies			
					*/
						
						
				* 18th largest cluster: 20
					br if ID_clust_ht1 == 20 // Outcome category: Household meals per day; Outcome group = Food security
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 20
					// No. obs = 2; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 20
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATT							

					/* 	Notes 
						1. No similarities		
					*/				
					
					
				* 19th largest cluster: 29
					br if ID_clust_ht1 == 29 // Outcome category: Income from forestry/fish/livestock; Outcome group = Income
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 29
					// No. obs = 2; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 29
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATT					
					
					/* 	Notes 
						1. Studies QX9FKF7R and XRZV6C7F report a related outcome:
							- QX9FKF7R: Livestock sold (US$)
							- XRZV6C7F: Livestock income (Birr, log)
							
						We may be able to harmonize these outcomes			
					*/					
					
					
					
				* 20th largest cluster: 40
					br if ID_clust_ht1 == 40 // Outcome category: Overall crop production; Outcome group = Production
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 40
					// No. obs = 2; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 40
					// Quasi-experimental, medium or large-scale, household-level data, short-term effects, ATT					
									
					/* 	Notes 
						1. No similarities		
					*/	
					
					
					
				* 21st largest cluster: 52
					br if ID_clust_ht1 == 52 // Outcome category: Overall household income; Outcome group = Income
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 52
					// No. obs = 2; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 52
					// Quasi-experimental, medium or large-scale, household-level data, short-term effects, ATE					
									
					/* 	Notes 
						1. No similarities		
					*/			
					
					
				* 22nd largest cluster: 53
					br if ID_clust_ht1 == 53 // Outcome category: Relative poverty; Outcome group = Poverty
					tab outcome_choice2 n_study_cluster1 if ID_clust_ht1 == 53
					// No. obs = 2; No. independent studies = 2
					sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht1 == 53
					// Quasi-experimental, small-scale, household-level data, short-term effects, ATT					
											
					
					/* 	Notes 
						1. Studies BEHE5VDZ and XRZV6C7F report a related outcome:
							- BEHE5VDZ: Below poverty line (% of households under $1/day poverty line)
							- VGSCUGFK: % of households living on more than Â£1.00 per day per capita (PPP)
							
						Note that while both measure % household, one is looking at hhs under and the other one is looking for hhs above.
						We may be able to combine them. Therefore, we consider these outcomes as not similar enough.
					*/					
						
	
			* 2nd lowest height
			tab ID_clust_ht2 if irrig_program == 1, sort 	// height = 2.832434
			
				* 1st new cluster
				br if ID_clust_ht2 == 17	// Outcome category: Food production; Outcome group = Food security
				tab outcome_choice2 n_study_cluster2 if ID_clust_ht2 == 17
				// No. obs = 2; No. independent studies = 2
				sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht2 == 17
				// Quasi-experimental, small-scale, household-level, ATE, uncertain, 1 involves an intervention but not the other


				* 2nd new cluster
				br if ID_clust_ht2 == 54	// Outcome category: Overall household income; Outcome group = Income
				tab outcome_choice2 n_study_cluster2 if ID_clust_ht2 == 54
				// No. obs = 2; No. independent studies = 2
				sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht2 == 54
				// Quasi-experimental, micro-scale, household-level, ATT, short-term, 1 involves an intervention but not the other


				* 3rd new cluster
				br if ID_clust_ht2 == 57	// Outcome category: Value sold of agricultural products; Outcome group = Market access & sales
				tab outcome_choice2 n_study_cluster2 if ID_clust_ht2 == 57
				// No. obs = 2; No. independent studies = 2
				sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht2 == 57
				// Quasi-experimental, scall-scale, household-level, ATE, uncertain, 1 involves an intervention but not the other
				br
				
					* Generating table for paper
					preserve
					order key_original outcome_group outcome_choice2 outcome key_original irrig_program scale horizon estimand 
					br key_original outcome outcome_group outcome_choice2 irrig_program scale horizon estimand if ///
					(ID_clust_ht2 == 17 | ID_clust_ht2 == 54 | ID_clust_ht2 == 57) // They all use HH-level & quasi-experimental methods
					restore
					
					
						
			* 3rd lowest height
			tab ID_clust_ht3 if irrig_program == 1, sort	// height = 2.977015
			
				* 1st new cluster
				br if ID_clust_ht3 == 42	// Outcome category: Overall crop production; Outcome group: Production
				tab outcome_choice2 n_study_cluster3 if ID_clust_ht3 == 42
				// No. obs = 2; No. independent studies = 2
				sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht3 == 42
				// Quasi-experimental, small-scale, irrigation intervention, ATE, HH-level, 1 short-term & 1 uncertain.
				
				
				* 2nd new cluster
				br if ID_clust_ht3 == 60	// Outcome category: Value sold of agricultural products; Outcome group: Market access & sales
				tab outcome_choice2 n_study_cluster3 if ID_clust_ht3 == 60
				// No. obs = 2; No. independent studies = 2
				sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht3 == 60
				// Quasi-experimental, micro-scale, irrigation intervention, ATT, HH-level, 1 short-term & 1 uncertain.			
			
			
					* Generating table for paper
					preserve
					sort outcome_choice2 horizon
					order key_original outcome_group outcome_choice2 outcome key_original irrig_program scale horizon estimand 
					br key_original outcome outcome_group outcome_choice2 irrig_program scale horizon estimand if ///
					(ID_clust_ht3 == 42 | ID_clust_ht3 == 60)	// They all use HH-level data & quasi-experimental methods
					restore

			
			* 4th lowest height
			tab ID_clust_ht4 if irrig_program == 1, sort	// height = 3.028594
			
				* 1st new cluster
				br if ID_clust_ht4 == 12	// Outcome category: Cropping intensity; Outcome group: Production
				tab outcome_choice2 n_study_cluster4 if ID_clust_ht4 == 12
				// No. obs = 2; No. independent studies = 2
				sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht4 == 12
				// Quasi-experimental, small-scale, irrigation intervention, HH-level, short-term, 1 ATT and 1 ATE
				
					
				* 2nd new cluster
				br if ID_clust_ht4 == 66	// Outcome category: Value sold of agricultural products; Outcome group: Market access & sales
				tab outcome_choice2 n_study_cluster4 if ID_clust_ht4 == 66
				// No. obs = 2; No. independent studies = 2
				sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht4 == 66
				// Quasi-experimental, small-scale, irrigation intervention, HH-level, short-term, 1 ATT and 1 ATE
				
				
					* Generating table for paper
					preserve
					sort outcome_choice2 horizon
					order key_original outcome_group outcome_choice2 outcome key_original irrig_program scale horizon estimand 
					br key_original outcome outcome_group outcome_choice2 irrig_program scale horizon estimand if ///
					(ID_clust_ht4 == 12 | ID_clust_ht4 == 66)	// All studies share similar characteristics, except for the estimand
					restore				
				
				
			* 5th lowest height
			tab ID_clust_ht5 if irrig_program == 1, sort	// height = 3.042650
					
				* 1st new cluster
				br if ID_clust_ht5 == 1	// Outcome category: Anxiety about food; Outcome group: Food security
				tab outcome_choice2 n_study_cluster5 if ID_clust_ht5 == 1
				// No. obs = 2; No. independent studies = 2
				sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht5 == 1
				// All characteristics are the same except for scale (1 is small, 1 is medium/large)
					
					
				* 2nd new cluster
				br if ID_clust_ht5 == 42	// Outcome category: Non-food household expenditures; Outcome group: Expenditures
				tab outcome_choice2 n_study_cluster5 if ID_clust_ht5 == 42
				// No. obs = 2; No. independent studies = 2
				sum irrig_program ie_d scale unit horizon estimand if ID_clust_ht5 == 42
				// All characteristics are the same except for scale (1 is small, 1 is medium/large)
				br
					
					* Generating table for paper
					preserve
					sort outcome_choice2 horizon
					order key_original outcome_group outcome_choice2 outcome key_original irrig_program scale horizon estimand 
					br key_original outcome outcome_group outcome_choice2 irrig_program scale horizon estimand if ///
					(ID_clust_ht5 == 1 | ID_clust_ht5 == 42)	// studies share similar characteristics, except for the estimand
					restore
				


	*** STEP 4.5: Studies WITH an intervention ONLY
	tab irrig_program, m
	preserve
	
		keep if irrig_program == 1
		
		* Outcome groups
		tab outcome_group, m
		bysort outcome_group: generate n_ord_gr = _n						// Order of entries by outcome
		bysort outcome_group: generate n_tot_gr = _N						// N by outcome group		
		bysort outcome_group key_original: gen unq_gr1 = cond(_N==1,0,_n)	// Unique values by outcome
		gen uni_gr2 = (unq_gr1 == 0 | unq_gr1 == 1)
		bysort outcome_group: egen uni_gr_t = total(uni_gr2)				// Unique N studies by outcome group
		drop unq_gr1 uni_gr2	// no longer necessary
		
			* Generating table for paper 		// to be copied/pasted in LaTeX generator
			br outcome_group n_tot_gr uni_gr_t if n_ord_gr == 1
			gsort -n_tot_gr -uni_gr_t
			
				
		* Unique studies per category
		tab outcome_choice2, m
		bysort outcome_choice2: generate n_ord_cat = _n							// Order of entries by outcome
		bysort outcome_choice2: generate n_tot_cat = _N							// N by outcome group		
		bysort outcome_choice2 key_original: gen unq_cat1 = cond(_N==1,0,_n)	// Unique values by outcome
		gen uni_cat2 = (unq_cat1 == 0 | unq_cat1 == 1)
		bysort outcome_choice2: egen uni_cat_t = total(uni_cat2)				// Unique N studies by outcome group
		drop unq_cat1 uni_cat2	// no longer necessary
		
			* Generating table for paper // to be copied/pasted in LaTeX generator
			br outcome_choice2 n_tot_cat uni_cat_t if n_ord_cat == 1
			gsort -n_tot_cat -uni_cat_t
		
		
		* Tables that includes outcome groups and categories with 2 or more independent studies
			
			* Outcome groups
			br outcome_group n_tot_gr uni_gr_t if (n_ord_gr == 1 & uni_cat_t >= 2) 
			gsort -n_tot_gr -uni_gr_t	
			
			* Outcome categories
			br outcome_choice2 n_tot_cat uni_cat_t if (n_ord_cat == 1 & uni_cat_t >= 2)
			gsort -n_tot_cat -uni_cat_t
			
	
		* Inspection & classification of potentially comparable studies (working from the bottom-up)
		br
		sort key_original
		
			* Household agricultural income index
			br if outcome_choice2 == "Household agricultural income index"
				// Not comparable; One is looking at HH income diversification, the other at income inequality
				
			* Anxiety about food
			br if outcome_choice2 == "Anxiety about food"
				// Not comparable; One is a dummy of ability to meet needs, the other a dummy of being worry
				
			* Income from forestry/fish production/forestry/livestock
			br if outcome_choice2 == "Income from forestry/fish production/forestry/livestok"
				// YES, potentially comparable; Income from livestock sales
				
			* Household meals per day
			br if outcome_choice2 == "Household meals per day"
				// Not comparable; One looking at meals prepared at home, other at feedings the previous day
				
			* Index of health status outcomes
			br if outcome_choice2 == "Index of health status outcomes"
				// Not comparable; One related to illness, the other related to an index of psycholigical wellbeing
				
			* Education level
			br if outcome_choice2 == "Education level"
				// Not comparable; One looking at absence, the other at enrollment
				
			* Index of household poverty
			br if outcome_choice2 == "Index of household poverty"
				// Not comparable; One using an index of multidimensional poverty, the other is an score of water insecurity
				
			* Relative poverty
			br if outcome_choice2 == "Relative poverty"
				/* Not comparable; One is looking at the % HH living below the $1/day poverty line, the other at the %
				of HH living on more than £1.0 per day per capita */
			
			* Index of employment
			br if outcome_choice2 == "Index of employment"
				// Not comparable; One is aboout employment days/hh/day, the other about employment per hectare
				
			* Access to credit
			br if outcome_choice2 == "Access to credit"
				// Not comparable; One is a dummy of credit constraints, the other is total credit in dollars
				
			* Weather-related crop losses
			br if outcome_choice2 == "Weather-related crop losses"
				// YES, potentially comparable; Dummy of crop affected by drought
				
			* Growth of rural communities
			br if outcome_choice2 == "Growth of rural communities"
				// Not comparable; One related to conflict, other related to nightime lights as growth
				
			* Volume sold of agricultural products
			br if outcome_choice2 == "Volume sold of agricultural products"
				// YES, potentially comparable; % of production sold
				
			* Index of household wealth or assets
			br if outcome_choice2 == "Index of household wealth or assets"
				// YES, potentially comparable; Asset-based index using PCA (1 outcome about TLU, not comparable)
				
			* Food security index
			br if outcome_choice2 == "Food security index"
				// YES, potentially comparable; 4 studies involving a food security score related outcome indicator
				
			* Non-food household expenditures
			br if outcome_choice2 == "Non-food household expenditures"
				/* Not comparable; five different outcome measures.
				Two indicators related to educational expendictures but not comparable (one in dollars, the other
				in % difference); Two indicatores related to non-food expenditures but not comparable (one is about
				expenditures for a week, the other is about expenditures per capita per day); One about expenditures
				on healthcare. In general, these outcomes are quite different, not just in how they are measured,
				but in what they are looking at. */

			* Weight
			br if outcome_choice2 == "Weight"
				/* YES, potentially comparable; To studies examining weight. One is looking at BMI and the prevalence of
				underweight, while the other ie looking at wasting and WHZ-score. However, the study that examining wasting
				and WHZ-score has two separate samples from two separate countries.
				
				According to Cochrane (23.3.4 How to include multiple groups from one study), it may be possible to combine
				these two groups in a meta-analysis since the comparators (i.e. treatment & control) are different, even
				though it is just one study. Nonetheless, this is the only study that measures these outcomes. */
				
			* Food production
			br if outcome_choice2 == "Food production"
				/* YES, potentially comparable; Two studies measuring Value of Production for own consumption. The other
				indicators are not comaprable (i.e., home consumption (% production), consumption of livestock, per capita
				value of output consumed, per capita valye of vegies consumed.) */
				
			* Income from non-farm employment
			br if outcome_choice2 == "Income from non-farm employment"
				/* Yes, potentially comparable; Two studies have outcome measures associated with non-farm related
				income.
				*/
				
			* Livestock amount
			br if outcome_choice2 == "Livestock amount"
				/* Not comparable; Two studies looking at number of different animals, none of the indicators related
				to the same type of animal. */
				
			* Cropping intensity
			br if outcome_choice2 == "Cropping intensity"
				/* Yes, potentially comparable; All the studies have an indicator related to cropping intensity. Some
				as ratios, some dummy variables */
				
			* Overall crop production
			br if outcome_choice2 == "Overall crop production"
				/* Yes, potentially comparable; 3 studies looking at total value of production in some currency, 2 studies
				looking at amount of crop produced in kilograms but one is rice and the other is maize. 
				Two other indicators are not comparable, including one about technical efficiency, one about kg per capita 
				of rice, and the last one about the probability of cultivating. */
				
			* Overall household expenditure
			br if outcome_choice2 == "Overall household expenditure"
				/* Yes, potentially comparable; 5 studies examining 2 groups of potentially comparable indicators, one
				related to per adult equivalent expenditures and the second one about daily per capita expenditures. */

			* Irrigated land for agricultural production
			br if outcome_choice2 == "Irrigated land for agricultural production"
				/* Yes, potentially comparable; Three studies that examine area under irrigation (two in hectares and
				1 in manzanda). The rest of the outcomes are not so comparable, one a dummy for irrigation, one about
				area in log, other about worked area, share under irrigation, and the remaining are about a specific
				area for a specific crop. */
				
			* Social empowerment
			br if outcome_choice2 == "Social empowerment"
				/* Not comparable; Multiple indicators related to empowerment, but quite different. Some are using
				an index (e.g., A-WEAI), other looking at decisions in percentages, and some are just dummies. However,
				none of the outcomes are similar enough to be comparable. */
				
			* Index of water supply and irrigation for agriculture
			br if outcome_choice2 == "Index of water supply and irrigation for agriculture"
				/* Yes, potentially comparable; 5 studies with a dummy variable for having irrigation. The
				rest are a combination of different types of indicators, including depth of water table, days of use/unused
				water, receiving sufficient water */
				
			* Domestic food expenditure
			br if outcome_choice2 == "Domestic food expenditure"
				/* Yes, potentially comparable; 3 groups of indicators that are related, one on share of expenditures 
				on food, one on expenditures per capita per day, ad one on per capita expenditures.
				The rest are related but are not comparable. */
				
			* Wealth and assets
			br if outcome_choice2 == "Wealth and assets"
				/* Yes, potentially comparable; 3 studies have indicators related to the value of household assets,
				two in dollars, one in Kenyan shillings. The rest are dummies for different assets, or an score related 
				to asset quality. */
				
			* Crop diversification
			br if outcome_choice2 == "Crop diversification"
				/* Yes, potentially comparable. 4 studies that measure crop diversity using some sort of score.
				Two studies looking at horticulture production using a binary indicator. One paper is a working
				paper and there is also the academic journal version of the same paper.
				The rest are using dummies to measure diversity-related indicators, such as producing banana, 
				producing an additional crop, or using percentages for share of traditional to non-
				traditional crops */
				
			* Value sold of agricultural products
			br if outcome_choice2 == "Value sold of agricultural products"
				 /* Yes, potentially comparable; 4 groups of potentially comparable outcomes, including sales
				 per unit of land, total sales, dummy for sells, and net value/profit per ha. The rest are not comparable
				 indicators. */
				 
			* Overall household income
			br if outcome_choice2 == "Overall household income"
				/* Yes, potentially comparable; 3 groups of potentially comparable outcomes, including 4 studies examining 
				household income, 2 with outcomes assoicated with income per capita, and 2 studies with indicators 
				related to the share of wage income. The rest are not comparable indicators related to montly income, per 
				capita daily income, share of different incomes, revenue, profit, */
				
			* Income from agriculture // *** NOTE: Some indicators from here must be RE-CLASSIFIED to CROP PRODUCTION
			br if outcome_choice2 == "Income from agriculture"
				/* Yes potentially comparable. 3 studies looking at gross margins. The rest are not comparable */
				
			* Area allocated to crops
			br if outcome_choice2 == "Area allocated to crops"
				/* Yes, potentially comparable. 6 studies looking at area cultivated; 4 at a dummy for having cultivated
				(dummy variable). The rest are not comparable indicators. In total, 8 studies looking at those indicators. */
				
			* Dietary diversity
			br if outcome_choice2 == "Dietary diversity"
				/* Yes, potentially comparable. 3 groups of related outcomes; 1 associated with dietary diversity-related score;
				1 assocaite with women's dietary scores, and another associated with food diversity using a different type(s) of
				indicators. The rest are not comparable, including multiple dummy variables for the consumption of different 
				foods, or total number fod different foods consumed. In total, 6 studies with potentially comparable outcomes. */
				
			* Crop yield
			br if outcome_choice2 == "Crop yield"
				/* Yes, potentially comparable. 4 groups of related indicators. 1 related to crop value per unit of land;
				1 related to crop weight per unit of land; 1 related to rice yields; and 1 related to profits per unit of land.
				In total, 16 studies examinig yields with pontentially comparable outcomes. */
			
			* Overall agricultural expenditures
			br if outcome_choice2 == "Overall agricultural expenditure"
				/* Yes, potentially comparable. 6 different types of outcomes, including labor expenditures (in currency
				units per unit of land), input expenditures (in currency per unit of land), perstice expenditures, fertilizer
				expenditures, paid labor (in currency unit). The rest are not comparable indicator. In total, 6 studies
				with these outcomes */
				

	restore
	
	
	
	
	