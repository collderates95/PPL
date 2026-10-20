/********************************************************************
Prepare biosib: identify focal children and sibling roles


********************************************************************/


/********************************************************************
1. Load biosib and merge birth information
********************************************************************/

use "${data_soep}/biosib.dta", clear

merge 1:1 pid using "${data}/bdate_ppathl.dta", ///
    keepusing(mob yob gebym gebdate germanborn mig_back bbula erstbefr letztbef) keep(match master)

drop _merge

* Twin/multiple indicator, independent of focal-child status.
bysort famcount gebym: egen n_same_birthmonth = count(pid) ///
    if !missing(gebym)

gen twin = n_same_birthmonth > 1 if !missing(n_same_birthmonth)
replace twin = 0 if missing(twin)

label var twin "Twin/multiple: same birth month/year within famcount"
label var n_same_birthmonth "Number of siblings with same birth month/year"


*Identify kids-mother 
foreach var of varlist 	sibdef1 - sibdef11 {
	replace `var' = . if inlist(`var',-2,-1)
}

cap drop beziehung
egen beziehung = rowmax(sibdef1 sibdef2 sibdef3 sibdef4 sibdef5 sibdef6 sibdef7 sibdef8 sibdef9 sibdef10 sibdef11)

cap drop mother_same_ 
bys famcount: egen mother_same_ = max(beziehung)

cap drop mother_same
bys famcount: gen mother_same = inrange(mother_same_,1,6)

keep if mother_same == 1

/********************************************************************
2. Define July-June cohorts
********************************************************************/

gen cohort = .

replace cohort = 0 if yob == 2006 & inrange(mob, 7, 12)
replace cohort = 0 if yob == 2007 & inrange(mob, 1, 6)

replace cohort = 1 if yob == 2005 & inrange(mob, 7, 12)
replace cohort = 1 if yob == 2006 & inrange(mob, 1, 6)

replace cohort = 2 if yob == 2004 & inrange(mob, 7, 12)
replace cohort = 2 if yob == 2005 & inrange(mob, 1, 6)

replace cohort = 3 if yob == 2003 & inrange(mob, 7, 12)
replace cohort = 3 if yob == 2004 & inrange(mob, 1, 6)

replace cohort = 4 if yob == 2002 & inrange(mob, 7, 12)
replace cohort = 4 if yob == 2003 & inrange(mob, 1, 6)

label var cohort "July-June birth cohort of child"

gen kid_cohort = inrange(cohort, 0, 4)
label var kid_cohort "Born in relevant focal-child cohort window"


/********************************************************************
4. Identify focal child/focal children
********************************************************************/

* Youngest sibling born in the relevant cohort window
bysort famcount: egen gebdate_focal = max(cond(kid_cohort == 1, gebdate, .))
format gebdate_focal %tdD_m_CY
label var gebdate_focal "Geb.Datum - focal child"

bysort famcount: egen gebym_focal = max(cond(kid_cohort == 1, gebym, .))
format gebym_focal %tm
label var gebym_focal "Geburtsmonat - focal child"

* Family has at least one child in focal-window
gen fam_affected = !missing(gebdate_focal)
label var fam_affected "Sibship contains focal-window child"

* Mark focal child/focal children
gen kid_affected = gebdate == gebdate_focal if fam_affected == 1
replace kid_affected = 0 if missing(kid_affected)
label var kid_affected "Focal child"

* Count focal children; >1 indicates focal twins/multiples or same-month focal children
bysort famcount: egen n_focal = total(kid_affected == 1)
label var n_focal "Number of focal children in sibship"

gen twin_focal = n_focal > 1 if fam_affected == 1
replace twin_focal = 0 if missing(twin_focal)
label var twin_focal "Twin/multiple focal-child case"

drop if n_focal > 1

/********************************************************************
5. Sibling roles relative to focal child
********************************************************************/

* Non-focal siblings in affected families
gen sibling_affected = fam_affected == 1 & kid_affected == 0
label var sibling_affected "Sibling of focal child"

* Older siblings
gen sibl_old = gebdate < gebdate_focal if sibling_affected == 1
replace sibl_old = 0 if missing(sibl_old)
label var sibl_old "Older sibling of focal child"

* Younger siblings
gen sibl_young = gebdate > gebdate_focal if sibling_affected == 1
replace sibl_young = 0 if missing(sibl_young)
label var sibl_young "Younger sibling of focal child"

* Same-month non-focal siblings
gen sibl_same_month = gebdate == gebdate_focal if sibling_affected == 1
replace sibl_same_month = 0 if missing(sibl_same_month)
label var sibl_same_month "Same birth month as focal child"

* Counts at famcount level
bysort famcount: egen sibl_old_sum = total(sibl_old == 1)
bysort famcount: egen sibl_young_sum = total(sibl_young == 1)
bysort famcount: egen sibl_same_month_sum = total(sibl_same_month == 1)

label var sibl_old_sum "Number of older siblings of focal child"
label var sibl_young_sum "Number of younger siblings of focal child"
label var sibl_same_month_sum "Number of same-month non-focal siblings"

* Base family validity: focal child exists and has at least one older sibling
gen fam_valid_base = fam_affected == 1 & sibl_old_sum >= 1
label var fam_valid_base "Family has focal child and at least one older sibling"

/********************************************************************
6. Assign focal-child characteristics to all rows in famcount
********************************************************************/

* Unique focal PID only if exactly one focal child
gen pid_focal_ = pid if kid_affected == 1 & n_focal == 1
bysort famcount: egen pid_focal = max(pid_focal_)
drop pid_focal_
label var pid_focal "PID - unique focal child"

* Min/max focal PID for twin/multiple focal cases
gen pid_focal_min_ = pid if kid_affected == 1
bysort famcount: egen pid_focal_min = min(pid_focal_min_)
drop pid_focal_min_

gen pid_focal_max_ = pid if kid_affected == 1
bysort famcount: egen pid_focal_max = max(pid_focal_max_)
drop pid_focal_max_

* Link PID for focal-child-level merges
gen pid_focal_link = pid_focal
replace pid_focal_link = pid_focal_min if missing(pid_focal_link)
label var pid_focal_link "PID used for focal-child-level merges"

* Focal birth month/year
gen mob_focal_ = mob if kid_affected == 1
bysort famcount: egen mob_focal = max(mob_focal_)
drop mob_focal_
label var mob_focal "Birth month of focal child"

gen yob_focal_ = yob if kid_affected == 1
bysort famcount: egen yob_focal = max(yob_focal_)
drop yob_focal_
label var yob_focal "Birth year of focal child"

gen cohort_focal_ = cohort if kid_affected == 1
bysort famcount: egen cohort_focal = max(cohort_focal_)
drop cohort_focal_
label var cohort_focal "July-June cohort of focal child"

* Focal child born in Germany
gen germanborn_focal_ = germanborn if kid_affected == 1
bysort famcount: egen germanborn_focal = max(germanborn_focal_)
drop germanborn_focal_
label var germanborn_focal "Focal child born in Germany"

* Focal child migration background
gen mig_back_focal_ = mig_back if kid_affected == 1
bysort famcount: egen mig_back_focal = max(mig_back_focal_)
drop mig_back_focal_
label var mig_back_focal "Focal child has migration background"



/********************************************************************
7. Birth spacing and spacing indicators
********************************************************************/

gen spacing_m = gebym_focal - gebym
label var spacing_m "Birth spacing to focal child in months"

gen spacing_y = spacing_m / 12
label var spacing_y "Birth spacing to focal child in years"

* Older sibling more than 9 years older than focal child
gen sibl_old_spacing_gt9 = spacing_m > 108 if sibl_old == 1
replace sibl_old_spacing_gt9 = 0 if missing(sibl_old_spacing_gt9)
label var sibl_old_spacing_gt9 ///
    "Older sibling more than 9 years older than focal child"

bysort famcount: egen fam_old_spacing_gt9 = max(sibl_old_spacing_gt9 == 1)
label var fam_old_spacing_gt9 ///
    "Family has older sibling more than 9 years older than focal child"

* Minimum 9-month spacing around focal child
gen sibl_old_spacing_lt9m = spacing_m < 9 if sibl_old == 1
replace sibl_old_spacing_lt9m = 0 if missing(sibl_old_spacing_lt9m)
label var sibl_old_spacing_lt9m ///
    "Older sibling less than 9 months older than focal child"

gen sibl_young_spacing_lt9m = spacing_m > -9 if sibl_young == 1
replace sibl_young_spacing_lt9m = 0 if missing(sibl_young_spacing_lt9m)
label var sibl_young_spacing_lt9m ///
    "Younger sibling less than 9 months younger than focal child"

bysort famcount: egen fam_old_spacing_lt9m = max(sibl_old_spacing_lt9m == 1)
bysort famcount: egen fam_young_spacing_lt9m = max(sibl_young_spacing_lt9m == 1)


/********************************************************************
9. Treatment variables based on focal child
********************************************************************/

gen after_a = month(gebdate_focal) >= 1 & month(gebdate_focal) <= 6
label var after_a "Focal child born in first half-year"

gen cohort_a = .

replace cohort_a = 2007 if year(gebdate_focal) == 2007 & after_a == 1
replace cohort_a = 2007 if year(gebdate_focal) == 2006 & after_a == 0

replace cohort_a = 2006 if year(gebdate_focal) == 2006 & after_a == 1
replace cohort_a = 2006 if year(gebdate_focal) == 2005 & after_a == 0

replace cohort_a = 2005 if year(gebdate_focal) == 2005 & after_a == 1
replace cohort_a = 2005 if year(gebdate_focal) == 2004 & after_a == 0

replace cohort_a = 2004 if year(gebdate_focal) == 2004 & after_a == 1
replace cohort_a = 2004 if year(gebdate_focal) == 2003 & after_a == 0

replace cohort_a = 2003 if year(gebdate_focal) == 2003 & after_a == 1
replace cohort_a = 2003 if year(gebdate_focal) == 2002 & after_a == 0

label var cohort_a "July-June cohort of focal child"

* Reform exposure of focal child itself
gen reform_focal = after_a == 1 & year(gebdate_focal) == 2007 ///
    if cohort_a != . & kid_affected == 1
label var reform_focal "Reform exposure - focal child"

* Reform exposure assigned to older siblings
gen reform_old = after_a == 1 & year(gebdate_focal) == 2007 ///
    if cohort_a != . & sibling_affected == 1 & sibl_old == 1
label var reform_old "Reform exposure through focal child - older siblings"

* Reform exposure assigned to younger siblings
gen reform_young = after_a == 1 & year(gebdate_focal) == 2007 ///
    if cohort_a != . & sibling_affected == 1 & sibl_young == 1
label var reform_young "Reform exposure through focal child - younger siblings"

gen sibl_old_affected_focal = reform_old == 1 if sibl_old == 1
label var sibl_old_affected_focal ///
    "Older sibling of reform-affected focal child"

gen sibl_young_affected_focal = reform_young == 1 if sibl_young == 1
label var sibl_young_affected_focal ///
    "Younger sibling of reform-affected focal child"


/********************************************************************
10. Restriction variables, but do not impose them yet
********************************************************************/

* Base family requirement
gen restr_fam_has_older_sibling = fam_valid_base == 1
label var restr_fam_has_older_sibling ///
    "Restriction: focal child has at least one older sibling"

* Focal child born in Germany
gen restr_focal_germanborn = germanborn_focal == 1 if fam_affected == 1
label var restr_focal_germanborn "Restriction: focal child born in Germany"

* Older siblings must be at least 9 months older
gen restr_old_spacing_ge9m = fam_old_spacing_lt9m == 0 if fam_affected == 1
label var restr_old_spacing_ge9m ///
    "Restriction: no older sibling less than 9 months older"

* Younger siblings must be at least 9 months younger
gen restr_young_spacing_ge9m = fam_young_spacing_lt9m == 0 if fam_affected == 1
label var restr_young_spacing_ge9m ///
    "Restriction: no younger sibling less than 9 months younger"

* Exclude families with multiple focal children
gen restr_single_focal_child = n_focal == 1 if fam_affected == 1
label var restr_single_focal_child ///
    "Restriction: exactly one focal child in famcount"	

* Optional: older sibling no more than 9 years older
gen restr_no_old_spacing_gt9 = fam_old_spacing_gt9 == 0 if fam_affected == 1
label var restr_no_old_spacing_gt9 ///
    "Restriction: no older sibling more than 9 years older"

	
save "${data}/biosib_prep.dta", replace



