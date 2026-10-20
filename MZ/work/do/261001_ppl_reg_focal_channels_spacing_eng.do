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
log using "$log\ppl_spacing_focal_channels_age_$date.log", replace



																													***/

********Channels (using the focal sample to avoid multiple observations)

** Fig 7 & and 8 display the results, which are related to "m1"


use "$data_prep\mz_sample_focal_spacing.dta", clear

gen mage_b_mis = mage_b == 0
gen fage_b_mis = fage_b == 0

tab mob_a, gen(mob_a_)

est drop _all



foreach var of varlist fwork fMini fself fpublic fwh fwh_a falg mwork mMini mself mpublic mwh mwh_a malg {
gen `var'_mis =  `var' == .
}

** Code as missing if no info on father or mother
recode mwork (0 1 = 1) (. = 0) if mage_b != 0, gen(memploy)
recode fwork (0 1 = 1) (. = 0) if fage_b != 0, gen(femploy)



*****************************pooled****************************

cap erase "$results\spacing_focal_channels_pooled_$date.csv"
foreach var of varlist femploy memploy HHinc_äquiv_ln sibl_old_sum sibl_young_sum  {  
		est drop _all

		
	global y `var'

	
*M1	
	eststo m1_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12																							, vce(clust bdate_se)
	
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
	eststo m2_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12	i.age_q																							, vce(clust bdate_se)
	
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
	eststo m3_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12	i.age_q		i.birtho male																					, vce(clust bdate_se)
	
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
	eststo m4_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12	i.age_q		i.birtho male	i.bula																				, vce(clust bdate_se)
	
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
	eststo m5_`var': reg $y reform_a i.after_a i.cohort_a mob_a_2 mob_a_3 mob_a_4 mob_a_5 mob_a_6 mob_a_8 mob_a_9 mob_a_10 mob_a_11 mob_a_12	i.age_q		i.birtho male	i.bula	i.pmigback i.peduc_gym i.singpar	mage_b mage_b_mis fage_b fage_b_mis																		, vce(clust bdate_se)
	
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
		using "$results\spacing_focal_channels_pooled_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
		keep(reform_a) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("Focal child: `var'")
}



log close
