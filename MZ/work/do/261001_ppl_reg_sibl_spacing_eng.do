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
log using "$log\ppl_spacing_reg_sibl_$date.log", replace



																													***/

use "$data_prep\mz_sample_sibl_spacing.dta", clear

gen mage_b_mis = mage_b == 0
gen fage_b_mis = fage_b == 0

est drop _all

tab mob_a, gen(mob_a_)

*****************************MAIN RESULTS (Table 2)****************************

**all
cap erase "$results\spacing_reg_sibl_all_$date.csv"
foreach var of varlist gym real haupt other   { 
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
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12 							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12 							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if inrange(age,$a,$b) & school_miss == 0, vce(clust bdate_se)
	
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
		using "$results\spacing_reg_sibl_all_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("Siblings at the age from $a to $b samp: `var'")
}


*****************************AGEGROUP Regressions****************************

**All results related to M1 build the basis for Fig. 1
**The figure itself was created locally after the export of these results


** all
cap erase "$results\spacing_reg_sibl_agepairs_$date.csv"

gen gruppe = 1 if inrange(age,12,13)
replace gruppe = 2 if inrange(age,14,15)
replace gruppe = 3 if inrange(age,16,17)

foreach var of varlist gym real haupt other   { 
	est drop _all
	
	foreach num of numlist 1(1)3 {
		
	global y `var'
	
*M1
	eststo m1_`var'_`num': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																								if gruppe == `num' & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m2_`var'_`num': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 												if gruppe == `num' & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m3_`var'_`num': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male												if gruppe == `num' & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m4_`var'_`num': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula											if gruppe == `num' & school_miss == 0, vce(clust bdate_se)
	
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
	eststo m5_`var'_`num': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12 							i.mob i.school_cohort i.age_q 	i.birtho spacing_m male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis											if gruppe == `num' & school_miss == 0, vce(clust bdate_se)
	
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
	

	}
	
	esttab m* ///
		using "$results\spacing_reg_sibl_agepairs_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("Affected siblings at age: `var'")
}


log close
