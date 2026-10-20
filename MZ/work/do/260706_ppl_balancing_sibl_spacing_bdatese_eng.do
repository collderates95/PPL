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
log using "$log\ppl_spacing_balancing_sibl_$date.log", replace


* Load dataset
use "$data_prep\mz_sample_sibl_spacing.dta", clear




global base i.reform_a i.after_a i.cohort_a i.mob_a

est drop _all

/*********		This file performs the Balancing tests for Table 4				   **********/

** Further the balancing table notes the means of each variable, which are used for the descriptive statistics in Table 1


gen mage_b_mis = mage_b == 0
gen fage_b_mis = fage_b == 0
replace mage_b = . if mage_b == 0
replace fage_b = . if fage_b == 0

global a 12
global b 17


tab bula, gen(bulas_)

*************************Regression***********************************



**One separate regression for each federal state
		foreach num of numlist 1(1)14 {
			eststo bulas_`num': reg bulas_`num' $base, vce(clust bdate_se)

			*Store lower confidence interval bound
			scalar ci_ll = r(table)[5,2]
			qui estadd scalar ci_ll
			
			*Store upper confidence interval bound
			scalar ci_ul = r(table)[6,2]
			qui estadd scalar ci_ul
			
			*Store mean of dependent variable in analysis sample
			qui sum bulas_`num' if e(sample)
			scalar y_mean = r(mean)
			qui estadd scalar y_mean
		}


** One regression for other variables 	
		foreach var of varlist mob yob male twin birtho spacing_m singpar age_q peduc_haupt peduc_real peduc_gym pmigback mage_b fage_b mage_b mage_b_mis fage_b fage_b_mis {	
			eststo did_`var': reg `var' $base  							if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
		
			scalar ci_ll = r(table)[5,2]
			qui estadd scalar ci_ll
			
			*Store upper confidence interval bound
			scalar ci_ul = r(table)[6,2]
			qui estadd scalar ci_ul
			
			*Store mean of dependent variable in analysis sample
			qui sum `var' if e(sample)
			scalar y_mean = r(mean)
			qui estadd scalar y_mean
			
		}
		
	
esttab did_mob did_yob did_age_q did_male did_twin did_birtho did_spacing_m did_singpar bulas_*  did_mage_b did_mage_b_mis did_fage_b did_fage_b_mis did_peduc_haupt did_peduc_real did_peduc_gym did_pmigback using "${results}\spacing_balancing_sibl_bdatese_$date", replace scsv keep(1.reform_a) cells(b(fmt(6) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Balancing Tests") stats(N y_mean, labels("Observations" "Mean of outcome") fmt(0 3))		


*/


******************************Adjustment of p-values for MHT (last column of Table 4)*****************************************************

local placebo 	bulas_1 bulas_2 bulas_3 bulas_4 bulas_5 bulas_6 bulas_7 bulas_8 ///
				bulas_9 bulas_10 bulas_11 bulas_12 bulas_13 bulas_14 ///
				yob mob age_q  male twin birtho spacing_m ///
				singpar mage_b mage_b_mis fage_b fage_b_mis   ///
				peduc_haupt peduc_real peduc_gym pmigback

*Romano-Wolf 
rwolf2 ///
    (reg yob           reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg mob           reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///	
    (reg age_q         reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg male          reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg twin          reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg birtho        reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg spacing_m     reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg singpar       reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_1       reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_2       reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_3       reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_4       reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_5       reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_6       reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_7       reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_8       reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_9       reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_10      reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_11      reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_12      reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_13      reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg bulas_14      reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///	
    (reg mage_b        reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg mage_b_mis    reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg fage_b        reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg fage_b_mis    reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg peduc_haupt   reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg peduc_real    reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg peduc_gym     reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)) ///
    (reg pmigback      reform_a i.after_a i.cohort_a i.mob_a, vce(clust bdate_se)), ///
    indepvars( ///
        reform_a, reform_a, reform_a, reform_a, reform_a, reform_a, ///
        reform_a, reform_a, reform_a, reform_a, reform_a, reform_a, ///
        reform_a, reform_a, reform_a, reform_a, reform_a, reform_a, ///
        reform_a, reform_a, reform_a, reform_a, reform_a, reform_a, ///
        reform_a, reform_a, reform_a, reform_a, reform_a, reform_a  ///
    ) ///
    reps(1000) ///
    seed(123456) ///
    usevalid

	

putexcel set "${results}\rwolf_balancing_sibl_bdatese_$date.xlsx", replace
putexcel A1 = "Korrektur der p-Werte wg. multiple hypothesis Testing"

putexcel A4 = "year of birth"
putexcel A5 = "month of birth"
putexcel A6 = "age in quarters"
putexcel A7 = "male"
putexcel A8 = "twin"
putexcel A9 = "birthorder"
putexcel A10 = "spacing in motnhs"
putexcel A11 = "single"
putexcel A12 = "bula 1"
putexcel A13 = "bula 2"
putexcel A14 = "bula 3"
putexcel A15 = "bula 4"
putexcel A16 = "bula 5"
putexcel A17 = "bula 6"
putexcel A18 = "bula 7"
putexcel A19 = "bula 8"
putexcel A20 = "bula 9"
putexcel A21 = "bula 10"
putexcel A22 = "bula 11"
putexcel A23 = "bula 12"
putexcel A24 = "bula 13"
putexcel A25 = "bula 14"
putexcel A26 = "maternal age at birth"
putexcel A27 = "maternal age at birth missing"
putexcel A28 = "paternal age at birth"
putexcel A29 = "paternal age at birth missing"
putexcel A30 = "parents hauptschule"
putexcel A31 = "parents realschule"
putexcel A32 = "parents gym"
putexcel A33 = "parents migback"


putexcel B2 = "Model p-value"
putexcel C2 = "Resample p-value"
putexcel D2 = "Romano-Wolf p-value"

matrix list e(RW)
putexcel B4 = matrix(e(RW))


log close