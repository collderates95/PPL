use "${data}/sample_focal_final_restrict.dta", clear


** Merge development data
merge 1:1 pid using "${data}/focal_quest_newborn.dta"
drop _merge

merge 1:1 pid using "${data}/focal_quest_2bis3.dta"
drop _merge

merge 1:1 pid using "${data}/focal_quest_5bis6.dta"
drop _merge

gen wave_all = quest_newborn_mis == 0 & quest_2bis3_mis == 0 & quest_5bis6_mis == 0
tab wave_all


** Standardize outcomes
cap drop health_std_newborn
egen health_std_newborn = std(health_index_newborn) if quest_newborn_mis == 0 & health_mis_newborn == 0 & temp_mis_newborn == 0

cap drop temp_newborn_std
egen temp_newborn_std = std(temp_newborn_index) if quest_newborn_mis == 0 & health_mis_newborn == 0 & temp_mis_newborn == 0




********Newborns (Panel A)
tab mob_focal, gen(mob_focal_) 	
cap erase "$results\focal_development_$date.csv"

replace peduc_gym = 99  if peduc_mis == 1 
foreach var of varlist health_std_newborn temp_newborn_std { // sonder tracked

	est drop _all

*M1
	eststo m1_`var': reg `var' reform_focal i.after_a i.cohort_a mob_focal_2 mob_focal_3 mob_focal_4 mob_focal_5 mob_focal_6 mob_focal_8 mob_focal_9 mob_focal_10 mob_focal_11 mob_focal_12																				, vce(clust bdate_se)
	
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
	eststo m2_`var': reg `var' reform_focal i.after_a i.cohort_a mob_focal_2 mob_focal_3 mob_focal_4 mob_focal_5 mob_focal_6 mob_focal_8 mob_focal_9 mob_focal_10 mob_focal_11 mob_focal_12	 i.school_cohort 	i.birtho male											, vce(clust bdate_se)
	
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
	eststo m3_`var': reg `var' reform_focal i.after_a i.cohort_a mob_focal_2 mob_focal_3 mob_focal_4 mob_focal_5 mob_focal_6 mob_focal_8 mob_focal_9 mob_focal_10 mob_focal_11 mob_focal_12	 i.school_cohort 	i.birtho male		i.bula_res									, vce(clust bdate_se)
	
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
	eststo m4_`var': reg `var' reform_focal i.after_a i.cohort_a mob_focal_2 mob_focal_3 mob_focal_4 mob_focal_5 mob_focal_6 mob_focal_8 mob_focal_9 mob_focal_10 mob_focal_11 mob_focal_12	 i.school_cohort 	i.birtho male		i.bula_res		i.pmigback i.peduc_gym peduc_mis mage_b mage_b_mis fage_b fage_b_mis							, vce(clust bdate_se)
	
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
		using "$results\focal_development_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) ///
		keep(reform_focal) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("NEWBORN Focal child: `var'")
}


********2 to 3 yo children (Panel B)

cap drop health_std_2bis3
egen health_std_2bis3 = std(health_index_2bis3) if quest_2bis3_mis ==  0 & health_mis_2bis3 == 0 & temp_mis_2bis3 == 0

cap drop temp_2bis3_std
egen temp_2bis3_std = std(temp_2bis3_index) if quest_2bis3_mis ==  0 & health_mis_2bis3 == 0 & temp_mis_2bis3 == 0

foreach var of varlist extrav_2 consc_2 agree_2 open_2 {
	egen `var'_std = std(`var') if quest_2bis3_mis == 0
}

 
foreach var of varlist health_std_2bis3 temp_2bis3_std { // extrav_2_std consc_2_std agree_2_std open_2_std

	est drop _all

*M1
	eststo m1_`var': reg `var' reform_focal i.after_a i.cohort_a mob_focal_2 mob_focal_3 mob_focal_4 mob_focal_5 mob_focal_6 mob_focal_8 mob_focal_9 mob_focal_10 mob_focal_11 mob_focal_12																							, vce(clust bdate_se)
	
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
	eststo m2_`var': reg `var' reform_focal i.after_a i.cohort_a mob_focal_2 mob_focal_3 mob_focal_4 mob_focal_5 mob_focal_6 mob_focal_8 mob_focal_9 mob_focal_10 mob_focal_11 mob_focal_12	 i.school_cohort 	i.birtho male											, vce(clust bdate_se)
	
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
	eststo m3_`var': reg `var' reform_focal i.after_a i.cohort_a mob_focal_2 mob_focal_3 mob_focal_4 mob_focal_5 mob_focal_6 mob_focal_8 mob_focal_9 mob_focal_10 mob_focal_11 mob_focal_12	 i.school_cohort 	i.birtho male		i.bula_res									, vce(clust bdate_se)
	
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
	eststo m4_`var': reg `var' reform_focal i.after_a i.cohort_a mob_focal_2 mob_focal_3 mob_focal_4 mob_focal_5 mob_focal_6 mob_focal_8 mob_focal_9 mob_focal_10 mob_focal_11 mob_focal_12	 i.school_cohort 	i.birtho male		i.bula_res		i.pmigback i.peduc_gym peduc_mis mage_b mage_b_mis fage_b fage_b_mis							, vce(clust bdate_se)
	
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
		using "$results\focal_development_$date"  ///
		, append scsv ///
		cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) ///
		keep(reform_focal) ///
		stats(N y_mean ci_ll ci_ul , labels("Observations" "Mean of outcome" "95%-KI LB" "95%-KI UB" ) fmt(0 3 6 6 )) ///
		mtitle title("2 bis 3 Focal child: `var'")
}




