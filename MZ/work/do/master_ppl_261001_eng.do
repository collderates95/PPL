/*********************************************************************************************************************
Master file of the project "Sibling Spillover Effects of Parental Leave Benefits"

*********************************************************************************************************************/

clear all

/*** Specify Stata version																							  ***/
version 18   /*** Specify version                                                                                ***/

/*** Configure screen output																					  ***/
set more off
set logtype text
set linesize 255 
set seed 5698753

/*** Specify ado-file path																							  ***/
sysdir set PERSONAL "Z:\Fuerth\GWA61_5015\C_Programme\ado"

mata mata mlib index

/*** Macros for directory paths																							  ***/
global main "Z:\Fuerth\GWA61_5015"				// Project directory
global datenpfad "$main\A_Mikrodaten"		// Original data
global outputpfad "$main\work"					// Project working directory

/*** Create subdirectories in the working directory (= output path)								  ***/
cd "$outputpfad"
cap mkdir data			// For data preparation
cap mkdir results		// For descriptive statistics and regression results
cap mkdir graphs		// For figures
cap mkdir log			// For saving log files
cap mkdir do			// For storing the respective do-files


/*** Macros for paths to output subdirectories																	  ***/
global data_prep "$outputpfad\data"
global results "$outputpfad\results"
global graphs "$outputpfad\graphs"
global log "$outputpfad\log"
global do "$outputpfad\do"


/*** Macros for input and output filenames																			  ***/						
global dateiname "mz"
global outputname "ppl"															  

* Create a global macro for the current date
gen date_current_temp = date("`c(current_date)'","DMY")
format date_current_temp %tdYYNNDD
global date = string(date("`c(current_date)'","DMY"),"%tdYYNNDD")
drop date_current_temp
di "$date"


/*** Start logging.                                                                            ***/
cap log close
*log using "$log\ppl_$date.log", replace


	 
/********************************************************************************************************************/
/*			Do-files																								*/
/********************************************************************************************************************/	 


********************************************************************
*******************Data preparation *****************
********************************************************************


*1. Prepare individual waves
do "$do\260706_ppl_aufbereitung_2008_eng.do"
do "$do\260706_ppl_aufbereitung_2009_eng.do"
do "$do\260706_ppl_aufbereitung_2010_eng.do"
do "$do\260706_ppl_aufbereitung_2011_eng.do"
do "$do\260706_ppl_aufbereitung_2012_eng.do"
do "$do\260706_ppl_aufbereitung_2013_eng.do"
do "$do\260706_ppl_aufbereitung_2014_eng.do"
do "$do\260706_ppl_aufbereitung_2015_eng.do"
do "$do\260706_ppl_aufbereitung_2016_eng.do"
do "$do\260706_ppl_aufbereitung_2017_eng.do"
do "$do\260706_ppl_aufbereitung_2018_eng.do"
do "$do\260706_ppl_aufbereitung_2019_eng.do"


*2. Append datasets 
do "$do\260706_ppl_append_eng.do"

*3. Sample preparation - the following changes:
do "$do\260706_ppl_sample_eng.do"



********************************************************************´
****************Results*********************************
********************************************************************

* Tab. 2 and Fig. 1 (Main regressions + agegroup-specific regression)
do "$do\261001_ppl_reg_sibl_spacing_eng.do" 

* Fig. 2: Seasonality of outcomes 
do "$do\260706_ppl_deskriptiv_sibl_spacing_eng.do" 

* Tab. 4: Balancing Tests 
do "$do\260706_ppl_balancing_sibl_spacing_bdatese_eng.do" 

* Tab. 3 
do "$do\261001_ppl_reg_sibl_heterogeneity_spacing_eng.do" // Heterogeneity


* Tab. 5
do "$do\261001_ppl_reg_sibl_robustness_spacing_eng.do" // Robustness


* Fig. 4
do "$do\261001_ppl_reg_sibl_cohorts_spacing_eng.do" // Control cohorts

* Fig 5.
do "$do\261001_ppl_reg_sibl_placebo_spacing_eng.do"  // Placebo treatment

* Fig 6.
do "$do\261001_ppl_reg_sibl_bula_spacing_eng.do" // Robsutness federal states (leave one out)

* Fig. 7 + 8
do "$do\261001_ppl_reg_focal_channels_spacing_eng.do" // Machanisms

* Tab. 8
do "$do\261001_ppl_reg_focal_spacing_eng.do" // Tracking focal child



cap log close































