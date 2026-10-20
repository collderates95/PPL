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
log using "$log\ppl_spacing_spacing_sibl_robustness_$date.log", replace



*************************Robustness test (Table 5)************************************

** Table 5 reports all results relating to m1
use "$data_prep\mz_sample_sibl_spacing.dta", clear

gen mage_b_mis = mage_b == 0
gen fage_b_mis = fage_b == 0

tab mob_a, gen(mob_a_)


*******************robust SE
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																								if inrange(age,$a,$b) & school_miss == 0, vce(robust)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
	

*M2
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(robust)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean

*M3
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(robust)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
*M4
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(robust)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
	
*M5
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(robust)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
			
	
	esttab m* ///
		using "$results\spacing_sibl_all_se_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("Siblings at the age from $a to $b samp: `var' - SE: robust SE")
}



******************* Household SE
cap erase "$results\spacing_sibl_all_se_$date.csv"
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																								if inrange(age,$a,$b) & school_miss == 0, vce(clust hhnr)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
	

*M2
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust hhnr)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean

*M3
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust hhnr)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
*M4
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust hhnr)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
	
*M5
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust hhnr)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
			
	
	esttab m* ///
		using "$results\spacing_sibl_all_se_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("Siblings at the age from $a to $b samp: `var' - SE: household level")
}



***************************** Panel A****************************
preserve
keep if inrange(cohort_a,2003,2007) 
keep if inrange(age,11,17)
drop if inlist(mob_a,12,1)

cap erase "$results\spacing_sibl_ohne_DezJan_$date.csv"
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a  mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 																							if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
	

*M2
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 							i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean

*M3
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
*M4
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
	
*M5
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
	
	
	esttab m* ///
		using "$results\spacing_sibl_ohne_DezJan_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("ohne Dez-Jan")
}
restore




*****************************Panel B****************************
preserve
keep if inrange(cohort_a,2003,2007) 
keep if inrange(age,11,17)
drop if inlist(mob_a,4,5,6,7,8,9)

cap erase "$results\spacing_sibl_Q4Q1_$date.csv"
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_10 mob_a_11 																								if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
	

*M2
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_10 mob_a_11 							i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean

*M3
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_10 mob_a_11 							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
*M4
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_10 mob_a_11 							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
	
*M5
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_10 mob_a_11 							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
		
	
	esttab m* ///
		using "$results\spacing_sibl_Q4Q1_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("Q4/Q1")
}
restore





*****************************Panel C****************************

** no twins
preserve
drop if twin_a == 1
cap erase "$results\spacing_sibl_notwins_$date.csv"
eststo clear
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																								if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
	

*M2
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean

*M3
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
*M4
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
	
*M5
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
			
	
	esttab m* ///
		using "$results\spacing_sibl_notwins_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("KEINE Zwillinge")
}

restore



*****************************Panel D****************************
preserve
keep if inrange(cohort_a,2003,2007) 
keep if inrange(age,12,17)

** Identify and keep closest sibling in age
bys hhnr: egen spacing_min = min(spacing_m)
gen sib_closest = spacing_min == spacing_m
keep if sib_closest == 1

** Remove cases in which the closest siblings are twins
drop if twin == 1


cap erase "$results\spacing_sibl_closest_$date.csv"
foreach var of varlist gym real haupt other   { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																								if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	

*M2
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean

*M3
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
*M4
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
	
*M5
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean

	
	
	esttab m* ///
		using "$results\spacing_sibl_closest_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("Closest sibling")
}

restore




/***************Panel E************/
preserve

cap drop nonacademic 
gen nonacademic = (haupt == 1 | real == 1 | schule == 5)

cap erase "$results\spacing_sibl_nonacademic_$date.csv"
foreach var of varlist nonacademic { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																								if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
	

*M2
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean

*M3
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
*M4
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
	
*M5
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
	
	esttab m* ///
		using "$results\spacing_sibl_nonacademic_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("Nonacademic vs academic vs other")
}

restore






***************************Panel F*************************************


*********SIBLINGS*******

*Spacing of 11 years
preserve
use "$data_prep\mz_sample_sibl.dta", clear
drop if spacing_fam_max >= 12
save "$data_prep\mz_sample_sibl_spacing11.dta", replace
restore

*Save HHNR
preserve 
use "$data_prep\mz_sample_sibl_spacing11.dta", clear
duplicates drop hhnr, force
keep hhnr
save "$data_prep\mz_sample_sibl_spacing_hhnr11.dta", replace
restore


*********FOCAL CHILD - final*************
preserve
use "$data_prep\mz_sample_focal.dta", clear
merge m:1 hhnr using "$data_prep\mz_sample_sibl_spacing_hhnr11.dta"
keep if _merge == 3
keep if inrange(cohort_a,2003,2007) 
drop _merge
save "$data_prep\mz_sample_focal_spacing11.dta", replace
restore



** Run regressions
use "$data_prep\mz_sample_sibl_spacing11.dta", clear


gen mage_b_mis = mage_b == 0
gen fage_b_mis = fage_b == 0

est drop _all

tab mob_a, gen(mob_a_)


**all
cap erase "$results\spacing_reg_sibl_11yrs_$date.csv"
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																								if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
	

*M2
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean

*M3
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
*M4
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	
	
*M5
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
	*Store lower confidence interval bound
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*Store upper confidence interval bound
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Store mean of dependent variable in analysis sample
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean
	
	
	esttab m* ///
		using "$results\spacing_reg_sibl_11yrs_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("Siblings at the age from $a to $b samp: `var'")
}


log close
