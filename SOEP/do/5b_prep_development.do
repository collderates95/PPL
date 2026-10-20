


use "${data_soep}/bioagel.dta", clear


**********************NEWBORN***************************************


preserve
keep if bioage_h == 1
merge m:1 pid using "${data}/sample_focal_final_restrict.dta"
gen quest_newborn_mis = _merge == 2 
label var quest_newborn_mis "Newborn questionaire missing" 
drop if _merge == 1

* Drop variables not contained in this questionnaire version
local dropvars ""

foreach var of varlist mode_v2 - inputdataset {

    capture confirm numeric variable `var'

    if !_rc {
        quietly count if !missing(`var') & `var' != -5
    }
    else {
        quietly count if !missing(`var') & `var' != "" & `var' != "-5"
    }

    if r(N) == 0 {
        local dropvars "`dropvars' `var'"
    }
}

if "`dropvars'" != "" {
    drop `dropvars'
}

**Health
recode health (1 2 = 0) (-1 3 4 = 1), gen(healthy_child)
label var healthy_child "Gesundheit des Kindes macht keine Sorgen (0/1)"

foreach var of varlist disord1 - disord9 {
	recode `var' (-2 = 1) (1=0), gen(`var'_rec)
}

egen health_mis_newborn = rowmiss(healthy_child disord1_rec disord2_rec disord3_rec disord4_rec disord5_rec) 
egen health_index_newborn = rowmean(healthy_child disord1_rec disord2_rec disord3_rec disord4_rec disord5_rec) if health_mis_newborn == 0 
egen health_std_newborn = std(health_index_newborn)

**Temperament
foreach var of varlist temp1 { // temp4 
	recode `var' (1 = 4) (2 = 3) (3 = 2) (4 = 1) (else = .), gen(`var'_rec)
}

egen temp_mis_newborn = rowmiss(temp1_rec temp2 temp3) 
egen temp_newborn_index = rowmean(temp1_rec temp2 temp3) if temp_mis_newborn == 0
egen temp_newborn_std = std(temp_newborn_index)

keep pid health_index_newborn health_std_newborn health_mis_newborn temp_newborn_index temp_newborn_std quest_newborn_mis temp_mis_newborn


save "${data}/focal_quest_newborn.dta", replace
restore


**********************2 bis 3***************************************

preserve
keep if bioage_h == 3
merge m:1 pid using "${data}/sample_focal_final_restrict.dta"
gen quest_2bis3_mis = _merge == 2
drop if _merge == 1

* Drop variables not contained in this questionnaire version
local dropvars ""

foreach var of varlist mode_v2 - inputdataset {

    capture confirm numeric variable `var'

    if !_rc {
        quietly count if !missing(`var') & `var' != -5
    }
    else {
        quietly count if !missing(`var') & `var' != "" & `var' != "-5"
    }

    if r(N) == 0 {
        local dropvars "`dropvars' `var'"
    }
}

if "`dropvars'" != "" {
    drop `dropvars'
}



**Health
recode health (1 2 = 0) (-1 3 4 = 1), gen(healthy_child)
label var healthy_child "Gesundheit des Kindes macht keine Sorgen (0/1)"

recode hospital12m_h (-1 0 = 0) (1/99 = 1), gen(hospital_visit)

foreach var of varlist ill2 ill7 ill8 ill11 ill12 ill13 ill14 {
	recode `var' (-2 = 1) (1=0), gen(`var'_rec)
}

egen health_mis_2bis3 = rowmiss(healthy_child hospital_visit ill2_rec ill7_rec ill8_rec ill11_rec ill12_rec ill13_rec ill14_rec) 
egen health_index_2bis3 = rowmean(healthy_child hospital_visit ill2_rec ill7_rec ill8_rec ill11_rec ill12_rec ill13_rec ill14_rec)  if health_mis_2bis3 == 0
egen health_std_2bis3 = std(health_index_2bis3)


**Temperament
foreach var of varlist temp1 { // temp4 
	recode `var' (1 = 4) (2 = 3) (3 = 2) (4 = 1) (else = .), gen(`var'_rec)
}

egen temp_mis_2bis3 = rowmiss(temp1_rec temp2 temp3) 
egen temp_2bis3_index = rowmean(temp1_rec temp2 temp3) if temp_mis_2bis3 == 0
egen temp_2bis3_std = std(temp_2bis3_index)

*******Big5
foreach var of varlist char2 char4 {
	recode `var' (-1 = .) (0=10) (1=9) (2=8) (3=7) (4=6) (5=5) (6=4) (7=3) (8=2) (9=1) (10=0), gen(`var'_rec)
}

recode char1a (-1 = .), gen(extrav_2)
clonevar consc_2 = char2_rec
recode char3 (-1 = .), gen(agree_2)
clonevar open_2 = char4_rec

egen behav_2bis3_mis = rowmiss(char1a char2_rec char3 char4_rec)  
egen behav_index_2bis3 = rowmean(char1a char2_rec char3 char4_rec)  if behav_2bis3_mis == 0
egen behav_std_2bis3 = std(behav_index_2bis3)

keep pid health_index_2bis3 health_std_2bis3 health_mis_2bis3 temp_2bis3_index temp_2bis3_std temp_mis_2bis3 extrav_2 consc_2 agree_2 open_2 quest_2bis3_mis behav_2bis3_mis

save "${data}/focal_quest_2bis3.dta", replace
restore

**********************5 bis 6***************************************


preserve
keep if bioage_h == 6
merge m:1 pid using "${data}/sample_focal_final_restrict.dta"
gen quest_5bis6_mis = _merge == 2
drop if _merge == 1

* Drop variables not contained in this questionnaire version
local dropvars ""

foreach var of varlist mode_v2 - inputdataset {

    capture confirm numeric variable `var'

    if !_rc {
        quietly count if !missing(`var') & `var' != -5
    }
    else {
        quietly count if !missing(`var') & `var' != "" & `var' != "-5"
    }

    if r(N) == 0 {
        local dropvars "`dropvars' `var'"
    }
}

if "`dropvars'" != "" {
    drop `dropvars'
}


**Health
recode hospital12m_h (-1 0 = 0) (1/99 = 1), gen(hospital_visit)

foreach var of varlist ill2 ill7 ill8 ill10 {
	recode `var' (-2 = 1) (1=0), gen(`var'_rec)
}

egen health_mis_5bis6 = rowmiss(hospital_visit ill2_rec ill7_rec ill8_rec ill10_rec) 
egen health_index_5bis6 = rowmean(hospital_visit ill2_rec ill7_rec ill8_rec ill10_rec)  if health_mis_5bis6 == 0
egen health_std_5bis6 = std(health_index_5bis6)


*******Big5
foreach var of varlist char1b char2 char4 char6 char10 {
	recode `var' (-1 = .) (0=10) (1=9) (2=8) (3=7) (4=6) (5=5) (6=4) (7=3) (8=2) (9=1) (10=0), gen(`var'_rec)
}

foreach var of varlist char3 char5 char7 char8 char9 {
	replace `var' = . if `var' == -1
}

egen personality_mis_5bis6 = rowmiss(char4_rec char7 char2_rec char5 char1b_rec char9 char3 char6_rec char8 char10_rec) 


egen open_5 = rowmean(char4_rec char7) if personality_mis_5bis6 == 0
egen consc_5 = rowmean(char2_rec char5) if personality_mis_5bis6 == 0
egen extrav_5 = rowmean(char1b_rec char9) if personality_mis_5bis6 == 0
egen agree_5 = rowmean(char3 char6_rec) if personality_mis_5bis6 == 0
egen neurot_5 = rowmean(char8 char10_rec) if personality_mis_5bis6 == 0

keep pid health_index_5bis6 health_std_5bis6 health_mis_5bis6 open_5 consc_5 extrav_5 agree_5 neurot_5 quest_5bis6_mis personality_mis_5bis6 

save "${data}/focal_quest_5bis6.dta", replace
restore

/*
preserve
keep if bioage_h == 8
merge m:1 pid using "${data}/sample_focal_final_restrict.dta"
gen quest_7bis8_mis = _merge == 2
drop if _merge == 1
distinct pid

* Drop variables not contained in this questionnaire version
local dropvars ""

foreach var of varlist mode_v2 - inputdataset {

    capture confirm numeric variable `var'

    if !_rc {
        quietly count if !missing(`var') & `var' != -5
    }
    else {
        quietly count if !missing(`var') & `var' != "" & `var' != "-5"
    }

    if r(N) == 0 {
        local dropvars "`dropvars' `var'"
    }
}

if "`dropvars'" != "" {
    drop `dropvars'
}

save "${data}/focal_quest_7bis8.dta", replace
restore

preserve
keep if inlist(bioage_h,101,102)
merge m:1 pid using "${data}/sample_focal_final_restrict.dta"
gen quest_9bis10_mis = _merge == 2
drop if _merge == 1
distinct pid

* Drop variables not contained in this questionnaire version
local dropvars ""

foreach var of varlist mode_v2 - inputdataset {

    capture confirm numeric variable `var'

    if !_rc {
        quietly count if !missing(`var') & `var' != -5
    }
    else {
        quietly count if !missing(`var') & `var' != "" & `var' != "-5"
    }

    if r(N) == 0 {
        local dropvars "`dropvars' `var'"
    }
}

if "`dropvars'" != "" {
    drop `dropvars'
}

save "${data}/focal_quest_9bis10.dta", replace
restore

