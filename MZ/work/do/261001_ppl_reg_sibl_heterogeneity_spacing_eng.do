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
log using "$log\ppl_spacing_sibl_heterogeneity_$date.log", replace



*************************Heterogeneity************************************


*********** This files produces the results of Table 3
** All results reported relate to "m1"

use "$data_prep\mz_sample_sibl_spacing.dta", clear

gen mage_b_mis = mage_b == 0
gen fage_b_mis = fage_b == 0

tab mob_a, gen(mob_a_)

***************************** Birth spacing ****************************

** Median split- lower half
preserve
qui sum spacing_m, d
keep if spacing_m < `r(p50)'
cap erase "$results\spacing_sibl_birthspacing_$date.csv"
eststo clear
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																							if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
		using "$results\spacing_sibl_birthspacing_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///	
		mtitle title("Birth spacing: below median")
}

restore

** Median split- upper half
preserve
qui sum spacing_m, d
keep if spacing_m >= `r(p50)'
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																							if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
		using "$results\spacing_sibl_birthspacing_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///	
		mtitle title("Birth spacing: above median")
}

restore







*****************************Panel B: Maternal educ. ****************************

** If no info on mother, then coded as missing  

** Highly educated
preserve
recode meduc_haupt meduc_real meduc_gym (0 = .) if mage_b == 0
keep if meduc_gym == 1
cap erase "$results\spacing_sibl_meduc_$date.csv"
eststo clear
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																							if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
		using "$results\spacing_sibl_meduc_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///		
		mtitle title("Bildung Mutter: mind. (Fach-)Abi")
}

restore


** low educated
preserve
recode meduc_haupt meduc_real meduc_gym (0 = .) if mage_b == 0
keep if meduc_gym == 0
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																							if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
		using "$results\spacing_sibl_meduc_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///	
		mtitle title("Bildung Mutter: max. Realschule (unbekannt als Missing gesetzt)")
}

restore



*****************************Panel C****************************

** Focal child - male
preserve
keep if male_a == 1
cap erase "$results\spacing_sibl_gender_$date.csv"
eststo clear
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																							if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
		using "$results\spacing_sibl_gender_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///	
		mtitle title("Focal child: male")
}

restore

** Focal child - female
preserve
keep if male_a == 0
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																							if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
		using "$results\spacing_sibl_gender_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///	
		mtitle title("Focal child: female")
}

restore




*****************************Panel D: ****************************
** Older sibling - female
preserve
keep if male == 0
cap erase "$results\spacing_sibl_gender_older_$date.csv"
eststo clear
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																							if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
		using "$results\spacing_sibl_gender_older_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///	
		mtitle title("Geschlecht älteres Geschwisterkind: weiblich")
}

restore

** Older sibling - male
preserve
keep if male == 1
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																							if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
		using "$results\spacing_sibl_gender_older_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///	
		mtitle title("Geschlecht älteres Geschwisterkind: männlich")
}

restore





***************************** Migration background ****************************
** no
preserve
keep if pmigback == 0
cap erase "$results\spacing_sibl_migback_$date.csv"
eststo clear
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																							if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
		using "$results\spacing_sibl_migback_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///	
		mtitle title("Migrationshintergrund Eltern: nein")
}

restore

** yes
preserve
keep if pmigback == 1
foreach var of varlist gym real haupt other  { 
	est drop _all
	global y `var'
	global a 12
	global b 17

*M1
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																							if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12						i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
		using "$results\spacing_sibl_migback_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///	
		mtitle title("Migrationshintergrund Eltern: ja")
}

restore


log close
