use "${data}/sample_oldersib_final_restrict.dta", clear

replace peduc_gym = 99  if peduc_mis == 1 



*********************ENROLMENT & TRACKING********************************************************************************

clonevar bula = bula_res 
drop _merge

** merge institutional data from schooling laws -> allows to create indicators on school entry timing 
merge m:1 bula yob mob using "${data}\schooling_laws_run.dta"
keep if _merge == 3

gen early_enrolment = enrolment_year < entry_y if enrolment_year != . 
gen regular_enrolment = enrolment_year == entry_y if enrolment_year != . 
gen late_enrolment = enrolment_year > entry_y if enrolment_year != . 

gen mis_enrolment = early_enrolment == . & regular_enrolment == . & late_enrolment == . 
*gen school_mis = gym == . & real == . & haupt == . & other == . 

gen entry_date = ym(enrolment_year,8)
gen gebdate_old = ym(yob,mob)
gen aase = (entry_date - gebdate_old)/12 if mis_enrolment == 0

tab mob_focal, gen(mob_focal_) 	


cap erase "$results\oldersib_sectrack_$date.csv" 
foreach var of varlist early_enrolment regular_enrolment late_enrolment  { // aase mis_enrolment gym real haupt other school_mis
	

	
	est drop _all
	
*M1	
	eststo m1_`var': reg `var' reform_old i.after_a i.cohort_focal mob_focal_2 mob_focal_3 mob_focal_4 mob_focal_5 mob_focal_6 mob_focal_8 mob_focal_9 mob_focal_10 mob_focal_11 mob_focal_12																				, vce(clust bdate_se)
	
	*untere Grenze des Konfidenzintervalls abspeichern
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*obere Grenze des Konfidenzintervalls abspeichern
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Mittelwert der abhängigen Variable des Analysesamples abspeichern
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean

	
*M2	
	eststo m2_`var': reg `var' reform_old i.after_a i.cohort_focal mob_focal_2 mob_focal_3 mob_focal_4 mob_focal_5 mob_focal_6 mob_focal_8 mob_focal_9 mob_focal_10 mob_focal_11 mob_focal_12 i.mob i.school_cohort	i.age_first_q																							, vce(clust bdate_se)
	
	*untere Grenze des Konfidenzintervalls abspeichern
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*obere Grenze des Konfidenzintervalls abspeichern
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Mittelwert der abhängigen Variable des Analysesamples abspeichern
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	

*M3	
	eststo m3_`var': reg `var' reform_old i.after_a i.cohort_focal mob_focal_2 mob_focal_3 mob_focal_4 mob_focal_5 mob_focal_6 mob_focal_8 mob_focal_9 mob_focal_10 mob_focal_11 mob_focal_12 i.mob i.school_cohort i.age_first_q			i.birtho male spacing_m																				, vce(clust bdate_se)
	
	*untere Grenze des Konfidenzintervalls abspeichern
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*obere Grenze des Konfidenzintervalls abspeichern
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Mittelwert der abhängigen Variable des Analysesamples abspeichern
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	
	

*M4	
	eststo m4_`var': reg `var' reform_old i.after_a i.cohort_focal mob_focal_2 mob_focal_3 mob_focal_4 mob_focal_5 mob_focal_6 mob_focal_8 mob_focal_9 mob_focal_10 mob_focal_11 mob_focal_12 i.mob i.school_cohort i.age_first_q			i.birtho male	spacing_m	i.bula_res																				, vce(clust bdate_se)
	*untere Grenze des Konfidenzintervalls abspeichern
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*obere Grenze des Konfidenzintervalls abspeichern
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Mittelwert der abhängigen Variable des Analysesamples abspeichern
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean	

	
*M5	
	eststo m5_`var': reg `var' reform_old i.after_a i.cohort_focal mob_focal_2 mob_focal_3 mob_focal_4 mob_focal_5 mob_focal_6 mob_focal_8 mob_focal_9 mob_focal_10 mob_focal_11 mob_focal_12 i.mob i.school_cohort i.age_first_q			i.birtho male	spacing_m	i.bula_res		i.pmigback i.peduc_gym peduc_mis mage_b mage_b_mis fage_b fage_b_mis																		, vce(clust bdate_se)
	
	*untere Grenze des Konfidenzintervalls abspeichern
	scalar ci_ll = r(table)[5,1]
	qui estadd scalar ci_ll
			
	*obere Grenze des Konfidenzintervalls abspeichern
	scalar ci_ul = r(table)[6,1]
	qui estadd scalar ci_ul			
			
	*Mittelwert der abhängigen Variable des Analysesamples abspeichern
	qui sum `var' if e(sample)
	scalar y_mean = r(mean)
	qui estadd scalar y_mean		
		
	
	esttab m* ///
		using "$results\oldersib_sectrack_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
		keep(reform_old) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("Older siblings: `var'")
}




************* Create Figure 3 on school enrollment (relative to cutoff)



preserve
drop if run == 13
graph bar early_enrolment regular_enrolment late_enrolment if  mis_enrolment == 0, over(run) scheme(s1mono) stack bar(1, color(gs8)) bar(2, color(gs6)) bar(3, color(blue)) blabel(bar, position(center) format(%9.0f)) percent  legend(label (1 "early") label (2 "regular") label (3 "late") rows(1)) 

gr_edit .plotregion1.bars[2].style.editstyle shadestyle(color(gs0)) editcopy
gr_edit .plotregion1.bars[2].style.editstyle linestyle(color(gs0)) editcopy
gr_edit .plotregion1.barlabels[1].style.editstyle color(white) editcopy

graph export ///
    "${graphs}\enrolment_soep.pdf", ///
    as(pdf) replace
restore


*
