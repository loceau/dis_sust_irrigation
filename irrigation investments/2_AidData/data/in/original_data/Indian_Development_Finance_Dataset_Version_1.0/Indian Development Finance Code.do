********************************************************************************

**** Paper:  Does India Use Development Finance to Compete With China? A Subnational Analysis
**** Authors: Gerda Asmus, Vera Z. Eichenauer, Andreas Fuchs, and Brad Parks
****
**** This version: 3.3.2022, release V1.0
**** This do-file collapses the project-level data for release to the levels of the country, adm1, and adm2 regional units

*******************************************************************************

*set up workspace 
clear
version 14
set more off
clear matrix
set mem 3500m

*local directory
local DIR = "C:\Users\Asmus\Dropbox\India China Finance\Analysis\" // Gerda (change to your DIR)
* local DIR = "C:\Users\veraei\Dropbox\Indian diaspora\Analysis" // Vera (change to your DIR)
*local DIR = "C:\Users\afuchs.UG-UWVW500-C138\Dropbox\Forschung\P Indian diaspora\Analysis"  // Andi (change to your DIR)

cd "`DIR'"

********************************************************************************

*** Now collapse to ADM2 level by year

********************************************************************************

*load full location data with all precision code levels
use "processed\ind_aid_global_locations_releaseV1.dta", clear

*collapse to adm2 level
collapse (first)	recipientname name_0 ///
		 (sum) 		usd_commitment_con usd_disbursment_con project_count, by(iso3c id_0 year) 

*relabel variables
	*lab var aiddata_project_id "AidData project ID"
	lab var iso3c "ISO3 country code of project location"
	lab var year "Reported year of commitment"
	lab var recipientname "Recipient name of project"

	lab var name_0 "Name of ADM0 region (GADM2.8)"
	lab var id_0 "ID of ADM0 region (GADM2.8)"
	*lab var name_1 "Name of ADM1 region (GADM2.8)"
	*lab var id_1 "ID of ADM1 region (GADM2.8)"
	*lab var name_2 "Name of ADM2 region (GADM2.8)"
	*lab var id_2 "ID of ADM2 region (GADM2.8)"	
	*lab var place_name "Name of project location"
	*lab var project_locas "Number of project locations"
	*lab var project_title "Project title as provided by the agency"
	*lab var precision_code "Geographic precision code "

	lab var usd_commitment_con "Project location (even-split) commitment amount (constant 2014 USD)"
	*lab var usd_commitment_pt_con "Project total commitment amount (constant 2014 USD)"
	lab var usd_disbursment_con	"Project location (even-split) disbursement amount (constant 2014 USD)"
	*lab var usd_disbursment_pt_con	"Project total disbursement amount (constant 2014 USD)"

	*lab var crs_sector "3-digit sector classification based on OECD sector codes"
	*lab var crs_sector_name "Name of the 3-digit sector classification based on OECD sector codes"
	*lab var flow_class "Categories: ODA(-like), OOF(-like)"
	*lab var agencyname "Name of Indian government agency"

	lab var project_count "Count of Indian aid project by country and year"					 
					 
*save
saveold "processed\ind_aid_global_country_releaseV1.dta", replace
export excel "processed\ind_aid_global_country_releaseV1.xlsx", replace firstrow(variables)

********************************************************************************

*** Now collapse to ADM1 level by year

********************************************************************************

*load full location data with all precision code levels
use "processed\ind_aid_global_locations_releaseV1.dta", clear
keep if precision_code < 5

*collapse to adm1 level
collapse (first)	recipientname name_0 name_1 ///
		 (sum) 		usd_commitment_con usd_disbursment_con project_count, by(iso3c id_0 id_1 year) 

*relabel variables
	*lab var aiddata_project_id "AidData project ID"
	lab var iso3c "ISO3 country code of project location"
	lab var year "Reported year of commitment"
	lab var recipientname "Recipient name of project"

	lab var name_0 "Name of ADM0 region (GADM2.8)"
	lab var id_0 "ID of ADM0 region (GADM2.8)"
	lab var name_1 "Name of ADM1 region (GADM2.8)"
	lab var id_1 "ID of ADM1 region (GADM2.8)"
	*lab var name_2 "Name of ADM2 region (GADM2.8)"
	*lab var id_2 "ID of ADM2 region (GADM2.8)"	
	*lab var place_name "Name of project location"
	*lab var project_locas "Number of project locations"
	*lab var project_title "Project title as provided by the agency"
	*lab var precision_code "Geographic precision code "

	lab var usd_commitment_con "Project location (even-split) commitment amount (constant 2014 USD)"
	*lab var usd_commitment_pt_con "Project total commitment amount (constant 2014 USD)"
	lab var usd_disbursment_con	"Project location (even-split) disbursement amount (constant 2014 USD)"
	*lab var usd_disbursment_pt_con	"Project total disbursement amount (constant 2014 USD)"

	*lab var crs_sector "3-digit sector classification based on OECD sector codes"
	*lab var crs_sector_name "Name of the 3-digit sector classification based on OECD sector codes"
	*lab var flow_class "Categories: ODA(-like), OOF(-like)"
	*lab var agencyname "Name of Indian government agency"

	lab var project_count "Count of Indian aid project by adm1 region and year"
					 
*save
saveold "processed\ind_aid_global_adm1regions_releaseV1.dta", replace
export excel "processed\ind_aid_global_adm1regions_releaseV1.xlsx", replace firstrow(variables)

********************************************************************************

*** Now collapse to ADM2 level by year

********************************************************************************

*load full location data with all precision code levels
use "processed\ind_aid_global_locations_releaseV1.dta", clear
keep if precision_code < 4

*collapse to adm2 level
collapse (first)	recipientname name_0 name_1 name_2 ///
		 (sum) 		usd_commitment_con usd_disbursment_con project_count, by(iso3c id_0 id_1 id_2 year) 

*relabel variables
	*lab var aiddata_project_id "AidData project ID"
	lab var iso3c "ISO3 country code of project location"
	lab var year "Reported year of commitment"
	lab var recipientname "Recipient name of project"

	lab var name_0 "Name of ADM0 region (GADM2.8)"
	lab var id_0 "ID of ADM0 region (GADM2.8)"
	lab var name_1 "Name of ADM1 region (GADM2.8)"
	lab var id_1 "ID of ADM1 region (GADM2.8)"
	lab var name_2 "Name of ADM2 region (GADM2.8)"
	lab var id_2 "ID of ADM2 region (GADM2.8)"	
	*lab var place_name "Name of project location"
	*lab var project_locas "Number of project locations"
	*lab var project_title "Project title as provided by the agency"
	*lab var precision_code "Geographic precision code "

	lab var usd_commitment_con "Project location (even-split) commitment amount (constant 2014 USD)"
	*lab var usd_commitment_pt_con "Project total commitment amount (constant 2014 USD)"
	lab var usd_disbursment_con	"Project location (even-split) disbursement amount (constant 2014 USD)"
	*lab var usd_disbursment_pt_con	"Project total disbursement amount (constant 2014 USD)"

	*lab var crs_sector "3-digit sector classification based on OECD sector codes"
	*lab var crs_sector_name "Name of the 3-digit sector classification based on OECD sector codes"
	*lab var flow_class "Categories: ODA(-like), OOF(-like)"
	*lab var agencyname "Name of Indian government agency"

	lab var project_count "Count of Indian aid project by adm2 region and year"					 
					 
*save
saveold "processed\ind_aid_global_adm2regions_releaseV1.dta", replace
export excel "processed\ind_aid_global_adm2regions_releaseV1.xlsx", replace firstrow(variables)

********************************************************************************