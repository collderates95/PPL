/********************************************************************
Create Bundesland at birth or until age 5 or bula at first interview

********************************************************************/


/********************************************************************
1. Prepare Bundesland of household from hbrutto
********************************************************************/

use "${data_soep}/hbrutto.dta", clear

keep hid syear bula_h
recode bula_h (-9/-1 = .)

rename bula_h lbula
label var lbula "Bundesland des Haushalts im Interviewjahr"

isid hid syear

save "${data}/hbrutto_prep.dta", replace


/********************************************************************
2. Merge Bundesland to ppathl
********************************************************************/

use "${data_soep}/ppathl.dta", clear

keep pid hid syear gebjahr birthregion
recode gebjahr birthregion (-9/-1 = .)

rename birthregion bbula
label var bbula "Bundesland Geburt"

merge m:1 hid syear using "${data}/hbrutto_prep.dta", keep(master match)

tab _merge
drop _merge


/********************************************************************
3. Create age
********************************************************************/

gen age = syear - gebjahr if !missing(syear, gebjahr)
label var age "Age in survey year"


/********************************************************************
4. Bundesland by age 0 to 5
********************************************************************/

forvalues a = 0/5 {
    gen bula_age`a'_tmp = lbula if age == `a'
    bysort pid: egen bula_age`a' = max(bula_age`a'_tmp)
    drop bula_age`a'_tmp

    label var bula_age`a' "Bundesland at age `a'"
}


/********************************************************************
5. Bundesland at first observed interview
********************************************************************/

gen bula_first_year_tmp = syear if !missing(lbula)
bysort pid: egen bula_first_year = min(bula_first_year_tmp)

gen bula_first_obs_tmp = lbula if syear == bula_first_year
bysort pid: egen bula_first_obs = max(bula_first_obs_tmp)

label var bula_first_year "First interview year with non-missing Bundesland"
label var bula_first_obs  "Bundesland at first observed interview"

drop bula_first_year_tmp bula_first_obs_tmp


/********************************************************************
6. Identify Bundesland:
********************************************************************/

egen bula_res = rowfirst(bbula bula_age0 bula_age1 bula_age2 bula_age3 bula_age4 bula_age5 bula_first_obs)

label var bula_res ///
    "Bundesland at birth, fallback to later ages until 5 and first interview"



/********************************************************************
7. Reduce to person level
********************************************************************/

keep pid bula_res  ///
     bula_age0 bula_age1 bula_age2 bula_age3 bula_age4 ///
     bula_age5 ///
     bula_first_year bbula bula_first_obs

duplicates drop pid, force


/********************************************************************
9. Save data set
********************************************************************/
save "${data}/bula_res.dta", replace