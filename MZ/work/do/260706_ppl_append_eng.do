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
*global dateiname "mz"
*global outputname "ppl"															  

* Create a global macro for the current date
gen date_current_temp = date("`c(current_date)'","DMY")
format date_current_temp %tdYYNNDD
global date = string(date("`c(current_date)'","DMY"),"%tdYYNNDD")
drop date_current_temp
di "$date"

/*** Start logging.                                                                            ***/
cap log close
log using "$log\ppl_append_$date.log", replace






/********************************************************************************************************************/
/***  					 Append annual cross-sectional datasets here										  ***/
/********************************************************************************************************************/

use "$data_prep\mz08_final.dta", clear
append using "$data_prep\mz09_final.dta"
append using "$data_prep\mz10_final.dta"
append using "$data_prep\mz11_final.dta"
append using "$data_prep\mz12_final.dta"
append using "$data_prep\mz13_final.dta"
append using "$data_prep\mz14_final.dta"
append using "$data_prep\mz15_final.dta"
append using "$data_prep\mz16_final.dta"
append using "$data_prep\mz17_final.dta"
append using "$data_prep\mz18_final.dta"
append using "$data_prep\mz19_final.dta"
compress
save "$data_prep\mz_append_temp.dta", replace






