/********************************************************************
*******************Sample creation***********************************
********************************************************************/

use "${data}/biosib_prep.dta", clear

** Merge bula
merge 1:1 pid using "${data}/bula_res.dta", keepusing(bbula bula_age0 bula_age1 bula_age2 bula_age3 bula_age4 bula_age5 bula_first_obs)
keep if _merge == 3 
drop _merge

** Create age (in quarters)
preserve
use pid syear pid syear hid netto gebjahr using "${data_soep}/ppathl.dta", clear

bysort pid: egen first_soep_year = min(syear)
bysort pid: egen last_soep_year  = max(syear)

gen age_first_soep = first_soep_year - gebjahr
gen age_last_soep  = last_soep_year  - gebjahr
bys pid: keep if _n == 1

save "${data}/einaus.dta", replace
restore 

merge 1:1 pid using "${data}/einaus.dta", keepusing (age_first_soep age_last_soep)
keep if _merge == 3
drop _merge

gen age_first_q = age_first_soep*4
gen age_last_q = age_last_soep*4

******************************Generate variables

** Vula of residence
egen bula_res = rowfirst(bbula bula_age0 bula_age1 bula_age2 bula_age3 bula_age4 bula_age5 bula_first_obs)

** Indicator for Brandenburg and Berlin (like in Microcensus)
cap drop restr_not_berlin_brandenburg
gen restr_not_berlin_brandenburg_ = !inlist(bula_res, 11, 12) if kid_affected == 1 & bula_res != .
bys famcount: egen restr_not_berlin_brandenburg = max(restr_not_berlin_brandenburg_)
label var restr_not_berlin_brandenburg ///
    "Restriction: focal child's state of birth not Berlin/Brandenburg"
	
cap drop sibl_old_berlin_brandenburg
gen sibl_old_berlin_brandenburg_ = !inlist(bula_res, 11, 12) if sibl_old == 1 & bula_res != .
bys famcount: egen sibl_old_berlin_brandenburg = max(sibl_old_berlin_brandenburg_)

cap drop sibl_young_berlin_brandenburg
gen sibl_young_berlin_brandenburg_ = !inlist(bula_res, 11, 12) if sibl_young == 1 & bula_res != .
bys famcount: egen sibl_young_berlin_brandenburg = max(sibl_young_berlin_brandenburg_)
	
** Cutoff month for school entry analysis
gen cutm = 6
replace cutm = 7 if bula_res == 3 & yob == 2004 
replace cutm = 8 if bula_res == 3 & yob == 2005 
replace cutm = 9 if bula_res == 3 & inrange(yob,2006,2008)
replace cutm = 7 if bula_res == 5 & inrange(yob,2001,2002) 
replace cutm = 8 if bula_res == 5 & inrange(yob,2003,2004) 
replace cutm = 9 if bula_res == 5 & inrange(yob,2005,2008)
replace cutm = 8 if bula_res == 7 & yob >= 2002 
replace cutm = 7 if bula_res == 8 & yob == 1999 
replace cutm = 8 if bula_res == 8 & yob == 2000
replace cutm = 9 if bula_res == 8 & yob >= 2001 
replace cutm = 7 if bula_res == 9 & yob == 1999 
replace cutm = 8 if bula_res == 9 & yob == 2000
replace cutm = 9 if bula_res == 9 & yob == 2001 
replace cutm = 10 if bula_res == 9 & yob == 2002 
replace cutm = 11 if bula_res == 9 & yob == 2003
replace cutm = 9 if bula_res == 9 & yob >= 2004
replace cutm = 9 if bula_res == 12 & yob >= 1995 
replace cutm = 7 if bula_res == 16 & yob >= 1997 

gen school_cohort = yob + 6
replace school_cohort = school_cohort + 1 if mob > cutm & mob < .

gen school_cohort_focal = yob_focal + 6
replace school_cohort_focal = school_cohort_focal + 1 if mob_focal > cutm & mob_focal < .

** Birth order
recode pos_sib (1 = 1) (2=2) (3=3) (4/10=4), gen(birtho)
label var birtho "birth order"

*Migback
clonevar pmigback = mig_back
label var pmigback "migration background (parents)"

*Gender
recode sex (2=0) (1=1), gen(male)
label var male "male" 

** Cluster of SE
egen bdate_se = group(yob_focal mob_focal)


/********************************************************************
******Merge school entry
********************************************************************/
merge 1:1 pid using "${data}/school_entry.dta", keepusing(enrolment_year enrolment_bula enrolment_year_childl enrolment_bula_bioedu)
drop if _merge == 2
drop _merge



/********************************************************************
******1. Merge mother and father IDs and generate an final ID for them
********************************************************************/


merge 1:1 pid using "${data}/kidlong_prep.dta", keep (master match)
rename _merge merge_kidlong


merge 1:1 pid using "${data}/biobirth_prep.dta", keep (master match)
rename _merge merge_biobirth

merge 1:1 pid using "${data}/bioparen_prep.dta", keep (master match)
rename _merge merge_bioparen


* Mother ID: 
gen mum_id = mum_id_kidlong
replace mum_id = mum_id_biobirth  if missing(mum_id) & !missing(mum_id_biobirth)
replace mum_id = mum_id_bioparen  if missing(mum_id) & !missing(mum_id_bioparen)

* Father ID: 
gen dad_id = dad_id_kidlong
replace dad_id = dad_id_biobirth  if missing(dad_id) & !missing(dad_id_biobirth)
replace dad_id = dad_id_bioparen  if missing(dad_id) & !missing(dad_id_bioparen)

label var mum_id "Mother PID, combined"
label var dad_id "Father PID, combined"


gen miss_mother = missing(mum_id)
gen miss_father = missing(dad_id)

bys famcount: egen restr_miss_mother_ = max(miss_mother) if kid_affected == 1
bys famcount: egen restr_miss_mother = max(restr_miss_mother_) 
drop restr_miss_mother_



/********************************************************************
******Impose all restrictions (like Microcensus)******************
*********************************************************************/
keep if restr_fam_has_older_sibling	== 1  
keep if restr_focal_germanborn == 1 
keep if restr_old_spacing_ge9m == 1 
keep if restr_young_spacing_ge9m == 1 
keep if restr_single_focal_child == 1         
keep if restr_no_old_spacing_gt9 == 1
keep if restr_miss_mother == 0
keep if restr_not_berlin_brandenburg == 1 // no Berlin or Brandenburg




bys famcount: gen sibl_young_new = gebdate > gebdate_focal 
bys famcount: gen sibl_old_new = gebdate < gebdate_focal
bys famcount: gen focal = gebdate == gebdate_focal

bys famcount: egen sibl_young_summe = total(sibl_young_new)
bys famcount: egen sibl_old_summe = total(sibl_old_new)

tab sibl_young_summe if focal == 1
tab sibl_old_summe if focal == 1

cap drop sibl_old_sum sibl_young_sum
bysort famcount: egen sibl_old_sum = total(sibl_old == 1)
bysort famcount: egen sibl_young_sum = total(sibl_young == 1)




/********************************************************************
Create role-specific subsamples
********************************************************************/

*------------------------------------------------------------
* Focal children
*------------------------------------------------------------
preserve

    keep if kid_affected == 1
    sort famcount pid
    save "${data}/sample_focal.dta", replace

restore


*------------------------------------------------------------
* Older siblings
*------------------------------------------------------------
preserve

    keep if sibl_old_new == 1
    sort famcount pid
    save "${data}/sample_oldersib.dta", replace

restore


*------------------------------------------------------------
* Younger siblings
*------------------------------------------------------------
preserve

    keep if sibl_young == 1
    sort famcount pid
    save "${data}/sample_youngersib.dta", replace

restore




*------------------------------------------------------------
* Mothers
*------------------------------------------------------------

** Temporary sample of mothers
use "${data}/sample_focal.dta", clear
rename pid pid_kids

rename mum_id pid
keep if pid != .
save "${data}/sample_mothers_temp.dta", replace


*** Mothers - year of birth & migback
use "${data_soep}/ppathl.dta", clear

keep pid syear germborn gebjahr
recode germborn gebjahr (-9/-1 = .)

* First valid value of germborn
gen valid_germborn = !missing(germborn)
gen year_germborn  = syear if valid_germborn == 1

bysort pid: egen first_year_germborn = min(year_germborn)
gen germborn_first_ = germborn if syear == first_year_germborn
bysort pid: egen germborn_first = max(germborn_first_)
label var germborn_first "German born (ppathl)"

* First valid value of year of birth
gen valid_gebjahr = !missing(gebjahr)
gen year_gebjahr  = syear if valid_gebjahr == 1

bysort pid: egen first_year_gebjahr = min(year_gebjahr)
gen gebjahr_first_ = gebjahr if syear == first_year_gebjahr
bysort pid: egen gebjahr_first = max(gebjahr_first_)
label var gebjahr_first "Year of birth (ppathl)"

keep pid germborn_first gebjahr_first 

duplicates drop pid, force

save "${data}/sample_mothers_ppathl.dta", replace


*** Mothers - educational degree
use "${data_soep}/pgen.dta", clear

keep pid syear pgpsbil
recode pgpsbil (-9/-1 = .)

* Highest school degree ever observed
bysort pid: egen mother_educ_highest = max(pgpsbil)
label var mother_educ_highest "Highest school degree (mother; pgen)"

gen meduc_haupt 	= mother_educ_highest == 1
gen meduc_real 		= mother_educ_highest == 2
gen meduc_gym 		= inrange(mother_educ_highest,3,4)
gen meduc_other 	= inrange(mother_educ_highest,5,8)
gen meduc_mis 	= mother_educ_highest == .

label var meduc_haupt "Basic track mother (pgen)"
label var meduc_real  "Middle track mother (pgen)"
label var meduc_gym 	 "(Fach-)Abi mother (pgen)"
label var meduc_other "Other educ mother (pgen)"
label var meduc_mis "Missing educ mother (pgen)"

* Keep one row per person
keep pid meduc_haupt meduc_real meduc_gym meduc_other meduc_mis mother_educ_highest
duplicates drop pid, force
save "${data}/sample_mothers_pgen.dta", replace



**********Merge to mothers main file
use "${data}/sample_mothers_temp.dta", clear

merge 1:1 pid using "${data}/sample_mothers_ppathl.dta", keepusing(germborn_first gebjahr_first)
gen mum_in_pathpl = _merge == 3
gen mum_non_pathpl = _merge == 1
drop if _merge == 2
drop _merge

merge 1:1 pid using "${data}/sample_mothers_pgen.dta", keepusing(meduc_haupt meduc_real meduc_gym meduc_other meduc_mis mother_educ_highest)
gen mum_in_pgen = _merge == 3
gen mum_non_pgen = _merge == 1
drop if _merge == 2
drop _merge

recode germborn_first (2=0) (1=1), gen(m_germanborn)
label var m_germanborn "Mother born in Germany (1/0)"

clonevar m_yob = gebjahr_first 
label var m_yob "Mother year of birth (ppathl)"


rename pid mum_id

sort mum_id

** Final dataset with information on mothers
save "${data}/sample_mothers_id.dta", replace



*------------------------------------------------------------
* Fathers
*------------------------------------------------------------

** Temporary sample of fathers
use "${data}/sample_focal.dta", clear
rename pid pid_kids

rename dad_id pid
keep if pid != .
save "${data}/sample_fathers_temp.dta", replace

*** Fathers - year of birth & migback
use "${data_soep}/ppathl.dta", clear

keep pid syear germborn gebjahr
recode germborn gebjahr (-9/-1 = .)

* First valid value of germborn
gen valid_germborn = !missing(germborn)
gen year_germborn  = syear if valid_germborn == 1

bysort pid: egen first_year_germborn = min(year_germborn)
gen germborn_first_ = germborn if syear == first_year_germborn
bysort pid: egen germborn_first = max(germborn_first_)
label var germborn_first "German born (ppathl)"

* First valid value of year of birth
gen valid_gebjahr = !missing(gebjahr)
gen year_gebjahr  = syear if valid_gebjahr == 1

bysort pid: egen first_year_gebjahr = min(year_gebjahr)
gen gebjahr_first_ = gebjahr if syear == first_year_gebjahr
bysort pid: egen gebjahr_first = max(gebjahr_first_)
label var gebjahr_first "Year of birth (ppathl)"

keep pid germborn_first gebjahr_first 
duplicates drop pid, force

save "${data}/sample_fathers_ppathl.dta", replace


*** Fathers - educational degree
use "${data_soep}/pgen.dta", clear

keep pid syear pgpsbil
recode pgpsbil (-9/-1 = .)


* Ever observed with university entrance qualification
gen uni_entrance_year = inlist(pgpsbil, 3, 4) if !missing(pgpsbil) // 1 = (Fach-)Abi, 0 = sonstiges
label var uni_entrance_year "University entrance qualification in year"

bysort pid: egen father_educ_gym = max(uni_entrance_year)
label var father_educ_gym "(Fach-)Abi; father)"

* Highest school degree ever observed
bysort pid: egen father_educ_highest = max(pgpsbil)
label var father_educ_highest "Highest school degree (father; pgen)"

gen feduc_haupt 	= father_educ_highest == 1
gen feduc_real 		= father_educ_highest == 2
gen feduc_gym 		= inrange(father_educ_highest,3,4)
gen feduc_other 	= inrange(father_educ_highest,5,8)
gen feduc_mis 	= father_educ_highest == .

label var feduc_haupt "Basic track father (pgen)"
label var feduc_real  "Middle track father (pgen)"
label var feduc_gym 	 "(Fach-)Abi father (pgen)"
label var feduc_other "Other educ father (pgen)"
label var feduc_mis "Missing educ father (pgen)"


* Keep one row per person
keep pid feduc_haupt feduc_real feduc_gym feduc_other feduc_mis father_educ_highest
duplicates drop pid, force
save "${data}/sample_fathers_pgen.dta", replace




**********Merge to fathers main file
use "${data}/sample_fathers_temp.dta", clear

merge 1:1 pid using "${data}/sample_fathers_ppathl.dta", keepusing(germborn_first gebjahr_first)
gen dad_in_pathpl = _merge == 3
gen dad_non_pathpl = _merge == 1
drop if _merge == 2
drop _merge

merge 1:1 pid using "${data}/sample_fathers_pgen.dta", keepusing(feduc_haupt feduc_real feduc_gym feduc_other feduc_mis father_educ_highest)
gen dad_in_pgen = _merge == 3
gen dad_non_pgen = _merge == 1
drop if _merge == 2
drop _merge


recode germborn_first (2=0) (1=1), gen(f_germanborn)
label var f_germanborn "Born in Germany father (1/0)"

clonevar f_yob = gebjahr_first
label var f_yob "Year of birth father (ppathl)"

rename pid dad_id

sort dad_id

** Final dataset with information on fathers
save "${data}/sample_fathers_id.dta", replace





*------------------------------------------------------------
* Merge parental information to role-specific samples
*------------------------------------------------------------


********Focal child
use "${data}/sample_focal.dta", clear
merge 1:1 mum_id using "${data}/sample_mothers_id.dta", keepusing(m_germanborn m_yob meduc_haupt meduc_real meduc_gym meduc_other meduc_mis mother_educ_highest mum_in_pathpl mum_in_pgen)
drop _merge

merge m:1 dad_id using "${data}/sample_fathers_id.dta",  keepusing(f_germanborn f_yob feduc_haupt feduc_real feduc_gym feduc_other feduc_mis father_educ_highest dad_in_pathpl dad_in_pgen)
drop _merge

gen mage_b = yob_focal - m_yob
replace mage_b = 99 if mage_b < 15 | mage_b > 50
gen mage_b_mis = mage_b == 99 


gen fage_b = yob_focal - f_yob
replace fage_b = 99 if fage_b < 15 | fage_b == .
gen fage_b_mis = fage_b == 99 

recode father_educ_highest (5 6 7 8 = 1) (1 = 2) (2=3) (3 4 = 4) (else = .), gen(feduc_high)
recode mother_educ_highest (5 6 7 8 = 1) (1 = 2) (2=3) (3 4 = 4) (else = .), gen(meduc_high)

egen peduc_high = rowmax(feduc_high meduc_high)
gen peduc_gym = peduc_high == 4
gen peduc_real = peduc_high == 3
gen peduc_haupt = peduc_high == 2
gen peduc_other = peduc_high == 1
gen peduc_mis = peduc_high == .

foreach var of varlist peduc_gym peduc_real peduc_haupt peduc_other {
	replace `var' = . if peduc_mis == 1
}

save "${data}/sample_focal_final.dta", replace

preserve 
keep if mum_in_pathpl == 1
save "${data}/sample_focal_final_restrict.dta", replace
restore


********Older sibling

use "${data}/sample_oldersib.dta", clear

merge m:1 famcount using "${data}/sample_focal_final.dta", keepusing(m_germanborn m_yob meduc_haupt meduc_real meduc_gym meduc_other meduc_mis meduc_high mum_in_pathpl mum_in_pgen f_germanborn f_yob feduc_gym feduc_high dad_in_pathpl dad_in_pgen peduc_high peduc_gym peduc_real peduc_haupt peduc_other peduc_mis)
keep if _merge == 3
drop if inlist(bula_res,11,12)

gen mage_b = yob - m_yob
replace mage_b = 99 if mage_b < 15 | mage_b > 50
gen mage_b_mis = mage_b == 99 


gen fage_b = yob - f_yob
replace fage_b = 99 if fage_b < 15 | fage_b == .
gen fage_b_mis = fage_b == 99 

save "${data}/sample_oldersib_final.dta", replace

preserve 
keep if mum_in_pathpl == 1
save "${data}/sample_oldersib_final_restrict.dta", replace
restore


********Younger sibling


use "${data}/sample_youngersib.dta", clear

merge m:1 famcount using "${data}/sample_focal_final.dta", keepusing(m_germanborn m_yob meduc_haupt meduc_real meduc_gym meduc_other meduc_mis meduc_high mum_in_pathpl mum_in_pgen f_germanborn f_yob feduc_haupt feduc_real feduc_gym feduc_other feduc_mis dad_in_pathpl feduc_high dad_in_pgen peduc_high peduc_gym peduc_real peduc_haupt peduc_other peduc_mis)
keep if _merge == 3
drop if inlist(bula_res,11,12)

gen mage_b = yob - m_yob
replace mage_b = 99 if mage_b < 15 | mage_b > 50
gen mage_b_mis = mage_b == 99 


gen fage_b = yob - f_yob
replace fage_b = 99 if fage_b < 15 | fage_b == .
gen fage_b_mis = fage_b == 99 

save "${data}/sample_youngersib_final.dta", replace

preserve 
keep if mum_in_pathpl == 1
save "${data}/sample_youngersib_final_restrict.dta", replace
restore

