

*******************************************************************************
************ School entry ***********************************************
*******************************************************************************

use "${data_soep}/bioedu.dta", clear

keep pid bet2year bet2fst bet2age

recode bet2year bet2fst (-9/-1 = .)

rename bet2year enrolment_year_bioedu
rename bet2age enrolment_age_bioedu
rename bet2fst  enrolment_bula_bioedu

label var enrolment_year_bioedu "Year of school entry, bioedu"
label var enrolment_age_bioedu "Age at school entry, bioedu"
label var enrolment_bula_bioedu "Federal state of school entry, bioedu"

save "${data}/school_entry_bioedu.dta", replace


************Childl


use "${data_soep}/childl.dta", clear

keep pid clg0115_h

recode clg0115_h (-9/-1 = .)

rename clg0115_h enrolment_year_childl

label var enrolment_year_childl "Year of school entry, childl"

* childl may contain repeated person-year observations
bysort pid: egen enrolment_year_childl_first = min(enrolment_year_childl)

keep pid enrolment_year_childl_first
duplicates drop pid, force

rename enrolment_year_childl_first enrolment_year_childl
label var enrolment_year_childl "Year of school entry, childl"


save "${data}/school_entry_childl.dta", replace


/********************************************************************
3. Combine bioedu and childl
********************************************************************/

use "${data}/school_entry_bioedu.dta", clear

merge 1:1 pid using "${data}/school_entry_childl.dta"

tab _merge
drop _merge

* Main outcome: school entry year
gen enrolment_year = enrolment_year_bioedu
replace enrolment_year = enrolment_year_childl ///
    if missing(enrolment_year) & !missing(enrolment_year_childl)

label var enrolment_year "Year of school entry"

* Main state variable: only available from bioedu
gen enrolment_bula = enrolment_bula_bioedu
label var enrolment_bula "Federal state of school entry"

* Source indicator for school entry year
gen enrolment_year_source = .
replace enrolment_year_source = 1 if !missing(enrolment_year_bioedu)
replace enrolment_year_source = 2 if missing(enrolment_year_bioedu) ///
    & !missing(enrolment_year_childl)

label define enrolment_year_source ///
    1 "bioedu" ///
    2 "childl", replace

label values enrolment_year_source enrolment_year_source
label var enrolment_year_source "Source of school entry year"

* Source indicator for federal state of school entry
gen enrolment_bula_source = .
replace enrolment_bula_source = 1 if !missing(enrolment_bula_bioedu)

label define enrolment_bula_source ///
    1 "bioedu", replace

label values enrolment_bula_source enrolment_bula_source
label var enrolment_bula_source "Source of school entry state"


/********************************************************************
4. Checks
********************************************************************/

tab enrolment_year_source, missing
tab enrolment_bula_source, missing

summ enrolment_year enrolment_year_bioedu enrolment_year_childl

tab enrolment_bula, missing

* Check disagreement between bioedu and childl
gen enrolment_year_diff = enrolment_year_bioedu - enrolment_year_childl ///
    if !missing(enrolment_year_bioedu, enrolment_year_childl)

tab enrolment_year_diff, missing
label var enrolment_year_diff "Difference in school entry year: bioedu - childl"



keep pid ///
     enrolment_year enrolment_bula ///
     enrolment_year_source enrolment_bula_source ///
     enrolment_year_bioedu enrolment_bula_bioedu ///
     enrolment_year_childl enrolment_year_diff

isid pid

save "${data}/school_entry.dta", replace

















