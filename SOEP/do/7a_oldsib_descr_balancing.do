use "${data}/sample_oldersib_final_restrict.dta", clear

*********************************Descriptives (Table 1 - SOEP)


preserve 
tab bula_res, gen(bula_res_)
replace mage_b = . if mage_b == 99
replace fage_b = . if fage_b == 99

label var age_first_q "Age (in quarters)"
label var mage_b "Maternal age at birth" 
label var mage_b_mis "Maternal age at birth (mis.)" 
label var fage_b "Paternal age at birth"
label var fage_b_mis "Paternal age at birth (mis.)" 
label var peduc_haupt "Parental educ.: basic" 
label var peduc_real "Parental educ.: middle" 
label var peduc_gym "Parental educ.: academic" 
label var peduc_other "Parental educ.: other" 
																									
putexcel set "${results}\SOEP_descriptives_oldersib_$date.xlsx", replace

local i = 4
foreach var of varlist mob yob age_first_q male twin birtho spacing_m bula_res_1 - bula_res_14 mage_b mage_b_mis fage_b fage_b_mis peduc_haupt peduc_real peduc_gym pmigback { // put variable labels in column A
	local colname: variable label `var' 
	putexcel A`i' = "`colname'"
	local i `++i' 
}

* label remaining columns
putexcel A1 = "All"
putexcel B2 = "Number of obs."
putexcel C2 = "Mean"
putexcel D2 = "SD"
putexcel E2 = "Min."
putexcel F2 = "Max."

tabstat mob yob age_first_q male twin birtho spacing_m bula_res_1 - bula_res_14 mage_b mage_b_mis fage_b fage_b_mis peduc_haupt peduc_real peduc_gym pmigback, stat(n mean sd min max) save 
matrix stats_all = r(StatTotal)'
putexcel B4 = matrix(stats_all), nformat(number_d2)
putexcel B4:B33, nformat(number) overwritefmt

restore

*********************************Balancing-Tests (Table 1 - SOEP; Coeff. and St.Err.)

global base i.reform_old i.after_a i.cohort_focal i.mob_focal



preserve 
tab bula_res, gen(bula_res_)
replace mage_b = . if mage_b == 99
replace fage_b = . if fage_b == 99


		foreach var of varlist mob yob age_first_q male twin birtho spacing_m  {	
			eststo did_`var': reg `var' $base  							, vce(clust bdate_se)
		
			scalar ci_ll = r(table)[5,2]
			qui estadd scalar ci_ll
			
			*obere Grenze des Konfidenzintervalls abspeichern
			scalar ci_ul = r(table)[6,2]
			qui estadd scalar ci_ul
			
			*Mittelwert der abhängigen Variable des Analysesamples abspeichern
			qui sum `var' if e(sample)
			scalar y_mean = r(mean)
			qui estadd scalar y_mean
			
		}


		foreach num of numlist 1(1)14 {
			eststo bula_res_`num': reg bula_res_`num' $base, vce(clust bdate_se)

			*untere Grenze des Konfidenzintervalls abspeichern
			scalar ci_ll = r(table)[5,2]
			qui estadd scalar ci_ll
			
			*obere Grenze des Konfidenzintervalls abspeichern
			scalar ci_ul = r(table)[6,2]
			qui estadd scalar ci_ul
			
			*Mittelwert der abhängigen Variable des Analysesamples abspeichern
			qui sum bula_res_`num' if e(sample)
			scalar y_mean = r(mean)
			qui estadd scalar y_mean
			}


		
		foreach var of varlist  mage_b fage_b mage_b mage_b_mis fage_b fage_b_mis peduc_haupt peduc_real peduc_gym pmigback {	
			eststo did_`var': reg `var' $base  							, vce(clust bdate_se)
		
			scalar ci_ll = r(table)[5,2]
			qui estadd scalar ci_ll
			
			*obere Grenze des Konfidenzintervalls abspeichern
			scalar ci_ul = r(table)[6,2]
			qui estadd scalar ci_ul
			
			*Mittelwert der abhängigen Variable des Analysesamples abspeichern
			qui sum `var' if e(sample)
			scalar y_mean = r(mean)
			qui estadd scalar y_mean
			
		}
		
	
esttab  did_mob did_yob did_age_first_q did_male did_twin did_birtho did_spacing_m bula_res_* did_mage_b did_mage_b_mis did_fage_b did_fage_b_mis did_peduc_haupt did_peduc_real did_peduc_gym did_pmigback using "${results}\SOEP_balancing_oldersib_$date", replace scsv keep(1.reform_old) cells(b(fmt(6) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Balancing Tests") stats(N y_mean, labels("Observations" "Mean of outcome") fmt(0 3))		


restore
		

		
*********************************Balancing-Tests (Table 1 - SOEP; p-values)

*Adjustment of p-values for MHT (Romano-Wolf) 

		
		
		
preserve 
tab bula_res, gen(bula_res_)
replace mage_b = . if mage_b == 99
replace fage_b = . if fage_b == 99		

label var age_first_q "Age (in quarters)"
label var mage_b "Maternal age at birth" 
label var mage_b_mis "Maternal age at birth (mis.)" 
label var fage_b "Paternal age at birth"
label var fage_b_mis "Paternal age at birth (mis.)" 
label var peduc_haupt "Parental educ.: basic" 
label var peduc_real "Parental educ.: middle" 
label var peduc_gym "Parental educ.: academic" 
label var peduc_other "Parental educ.: other" 

putexcel set "${results}\rwolf_balancing_oldersib.xlsx", replace

local i = 2
foreach var of varlist mob yob age_first_q male twin birtho spacing_m bula_res_1 - bula_res_14 mage_b mage_b_mis fage_b fage_b_mis peduc_haupt peduc_real peduc_gym pmigback { // put variable labels in column A
	local colname: variable label `var' 
	putexcel A`i' = "`colname'"
	local i `++i' 
}		


ssc install rwolf2, replace
rwolf2 ///
    (reg mob           reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) /// 
    (reg yob           reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) /// 
    (reg age_first_q           reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) /// 	
    (reg male          reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg twin          reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg birtho        reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg spacing_m     reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
	(reg bula_res_1       reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg bula_res_2       reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg bula_res_3       reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg bula_res_4       reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg bula_res_5       reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg bula_res_6       reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg bula_res_7       reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg bula_res_8       reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg bula_res_9       reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg bula_res_10      reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg bula_res_11      reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg bula_res_12      reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg bula_res_13      reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg bula_res_14      reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg mage_b        reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg mage_b_mis    reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg fage_b        reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg fage_b_mis    reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///	
    (reg peduc_haupt   reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg peduc_real    reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg peduc_gym     reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)) ///
    (reg pmigback      reform_old i.after_a i.cohort_focal i.mob_focal, vce(clust bdate_se)), ///
    indepvars( ///
        reform_old, reform_old, reform_old, reform_old, reform_old, reform_old, ///
        reform_old, reform_old, reform_old, reform_old, reform_old, reform_old, ///
        reform_old, reform_old, reform_old, reform_old, reform_old, reform_old, ///
        reform_old, reform_old, reform_old, reform_old, reform_old, reform_old, ///
        reform_old, reform_old, reform_old, reform_old, reform_old  ///
    ) ///
    reps(1000) ///
    seed(12345) ///
    usevalid

	
matrix list e(RW)

putexcel set "${results}\rwolf_balancing_oldersib.xlsx", modify
putexcel B1 = matrix(e(RW)), names		

restore
