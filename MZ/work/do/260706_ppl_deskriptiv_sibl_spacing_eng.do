/********************************************************************************************************************/
/*** Compute descriptive statistics for analysis sample								  ***/
/********************************************************************************************************************/


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
log using "$log\ppl_deskriptiv_spacing_sibl_$date.log", replace

* Load dataset - Maximum birth spacing of 10 years
use "$data_prep\mz_sample_sibl_spacing.dta", clear





/*********		Means by yob x born in first or second half of a year 		**********/
					
******** This creates the means that are displayed in Figure 2
** Figure 2 itself was created locally after exporting the excel-file
					
					
cap drop half_a
gen half_a= 1 if inrange(mob_a,1,6)
replace half_a = 2 if inrange(mob_a,7,12)


cap drop group
egen group = group(yob_a half_a) 
tabstat yob_a half_a grund haupt real nonacademic gym gesamt sonder other yob mob spacing_m male, statistics(mean count semean) by (group) save



*/

* Step 1
putexcel set "$results/means_by_halfyearyob_spacing_$date.xlsx", replace
putexcel A1 = "Gruppe"
putexcel B1 = "Geburtsjahr (focal)"
putexcel C1 = "Geburtsquartal (focal)"
putexcel D1 = "grund"
putexcel E1 = "grund (se)"
putexcel F1 = "haupt"
putexcel G1 = "haupt (se)"
putexcel H1 = "real"
putexcel I1 = "real (se)"
putexcel J1 = "nonacademic"
putexcel K1 = "nonacademic (se)"
putexcel L1 = "gym"
putexcel M1 = "gym (se)"
putexcel N1 = "gesamt"
putexcel O1 = "gesamt (se)"
putexcel P1 = "sonder"
putexcel Q1 = "sonder (se)"
putexcel R1 = "other"
putexcel S1 = "other (se)"
putexcel T1 = "yob"
putexcel U1 = "mob"
putexcel V1 = "spacing (monate)"
putexcel W1 = "male"
putexcel X1 = "N"

* Step 2
		foreach num of numlist 1(1)10 {
				local zeile = `num'+1
				putexcel A`zeile'= "`num'"
				matrix gruppe`num' = r(Stat`num')[1,1] , r(Stat`num')[1,2] , 	r(Stat`num')[1,3], r(Stat`num')[3,3], ///
																				r(Stat`num')[1,4], r(Stat`num')[3,4], /// 
																				r(Stat`num')[1,5], r(Stat`num')[3,5], ///
																				r(Stat`num')[1,6], r(Stat`num')[3,6], ///
																				r(Stat`num')[1,7], r(Stat`num')[3,7], /// 
																				r(Stat`num')[1,8], r(Stat`num')[3,8], /// 
																				r(Stat`num')[1,9], r(Stat`num')[3,9], /// 
																				r(Stat`num')[1,10], r(Stat`num')[3,10], /// 
									r(Stat`num')[1,11], r(Stat`num')[1,12], r(Stat`num')[1,13], r(Stat`num')[1,14], r(Stat`num')[2,1]
				putexcel B`zeile'=matrix(gruppe`num')

		}

*Step 3 
matrix total = . , . ,  r(StatTotal)[1,3], . , r(StatTotal)[1,4], . , r(StatTotal)[1,5], . , r(StatTotal)[1,6], . , r(StatTotal)[1,7], . , r(StatTotal)[1,8], . , r(StatTotal)[1,9], . , r(StatTotal)[1,10], . , r(StatTotal)[1,11], r(StatTotal)[1,12], r(StatTotal)[1,13], r(StatTotal)[1,14], r(StatTotal)[2,1]
putexcel B12=matrix(total) 
putexcel A12= "Total"

/*



log close