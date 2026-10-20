/*****************************************************************
	Paper title: Sibling Spillover Effects of Parental Leave Benefits
	
	Author: Anton Barabasch 
	
***********************************************************/

// global globals
*****************
version 19
clear all
set maxvar 12000
set more off
set linesize 120
set varabbrev off, permanently
set seed 589487 
set sortseed 698417
set scheme s1mono


// graph globals
****************
graph set window fontface "Times New Roman"

// global for date
******************
gen date_current_temp = date("`c(current_date)'","DMY") 
format date_current_temp %tdCCYYNNDD
global date = string(date("`c(current_date)'","DMY"),"%tdCCYYNNDD") 
drop date_current_temp
di "$date"


********************************************************************************
* Set paths
********************************************************************************
	
global path 	"C:\Users\yq18epit\Desktop\PPL\SOEP_PPL"
cd "$path"

		
global data_soep "${path}\origdata" 											// path for original SOEP data (version 39)
global data "${path}\data" 														// path for working data
global do "${path}\do" 															// path for do-files
global log "${path}\log" 														// path for log-files
global graphs "${path}\graphs" 													// path for graphs
global results "${path}\results" 												// path for results
global laws "${path}\schooling_laws" 												// path for schooling laws


*generate folders
cd "$path"
cap mkdir data
cap mkdir do
cap mkdir log
cap mkdir graphs
cap mkdir results

********************************************************************************
* Adofiles
********************************************************************************
/*
ssc install parmest, replace
ssc install distinct, replace
ssc install ivreg2, replace
ssc install ranktest, replace
ssc install rddensity, replace
ssc install rdrobust, replace
ssc install palettes, replace
ssc install heatplot, replace
ssc install colrspace, replace
ssc install grstyle, replace
ssc install estout, replace
ssc install regsave, replace
ssc install touch, replace
ssc install coefplot, replace
ssc install boottest, replace
ssc install matsave, replace
ssc install carryforward, replace
ssc install tabout, replace
ssc install xtable, replace
net install grc1leg, from("http://www.stata.com/users/vwiggins/") 			
*/

/*******************************************************************************
* DATA AND SAMPLE PREPARATION
*******************************************************************************/
do "$laws\000_schooling_laws_west_new.do"
do "$laws\000_schooling_laws_east_new.do"
do "$laws\000_schooling_laws_merge.do"
do "$laws\000_schooling_laws_runningvariable.do"



/********************************************************************
1. Person-level birth information
********************************************************************/
do "$do\1_bdate_prep.do"


/********************************************************************
2. Federal state 
********************************************************************/
do "$do\2_bula_birth.do"


/********************************************************************
3. Sibling/focal-child construction
********************************************************************/
do "$do\3_biosib_prep_new.do"


/********************************************************************
4. Parent identifiers
********************************************************************/
do "$do\4_parents.do"



/********************************************************************
5. Prep school entry and health/development outcomes 
********************************************************************/
do "$do\5a_prep_schoolentry.do" // school entry
do "$do\5b_prep_development.do" // health and development

/********************************************************************
6. Create sample 
********************************************************************/
do "$do\6_sample.do"



/*******************************************************************************
* ANALYSIS
*******************************************************************************/


/********************************************************************
7. Analyze older siblings
********************************************************************/
** Table 1 (descriptives) and Table 4 (balancing tests)
do "$do\7a_oldsib_descr_balancing.do"

** Table 6
do "$do\7b_oldsib_analysis.do" // School entry timing of older siblings

/********************************************************************
7. Analyze focal children
********************************************************************/
do "$do\8a_focal_development.do" // health + development














			





