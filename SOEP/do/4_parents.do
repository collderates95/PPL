/*----------------------------------------------------------------------------*/
************************Identify parents + their background*********************

/*---------------------------- [Kidlong] ------------------------------*/
/*----------------------------------------------------------------------------*/

use "${data_soep}/kidlong.dta", clear
#delimit ;			
	keep 
	syear
	pid
	imonth iyear // interviewmonat interviewjahr
	k_birthy_h k_birthm // geburtsjahr geburtsmonat
	k_pmum // zeiger auf Mutter
	k_pmump // zeiger auf Partner der Mutter
	k_phead // head of family
	k_mid k_fid // Mutter vater
	k_relm 
	k_relf // Verhältnis zu Mutter und Vater
	;	
#delimit cr		

distinct pid

replace k_fid = . if k_fid < 0

* Parent identifiers from kidlong
clonevar mum_id_kidlong_ = k_pmum
egen dad_id_kidlong_ = rowfirst (k_pmump k_fid)

recode mum_id_kidlong_ dad_id_kidlong_ (-8/0 = .)

drop if missing(mum_id_kidlong_) & missing(dad_id_kidlong_)

* First observed valid mother ID
gen mum_valid = !missing(mum_id_kidlong_)
gen mum_year  = syear if mum_valid == 1

bysort pid: egen mum_minyear = min(mum_year)
gen mum_first = mum_id_kidlong_ if syear == mum_minyear
bysort pid: egen mum_id_kidlong = max(mum_first)

* First observed valid father/partner ID
gen dad_valid = !missing(dad_id_kidlong_)
gen dad_year  = syear if dad_valid == 1

bysort pid: egen dad_minyear = min(dad_year)
gen dad_first = dad_id_kidlong_ if syear == dad_minyear
bysort pid: egen dad_id_kidlong = max(dad_first)

* Keep one row per child
bysort pid: keep if _n == 1

*Long Datensatz
save "${data}/kidlong_prep.dta", replace



/*----------------------------------------------------------------------------*/
/*---------------------------- [Biobirth ] ------------------------------*/
/*----------------------------------------------------------------------------*/


use "${data_soep}/biobirth.dta", clear

* Child PIDs listed in parents' birth biographies
recode kidpnr* (-8/0 = .)

keep pid sex kidpnr* biokids sumkids

* Drop respondents without listed children
egen n_kids = rownonmiss(kidpnr*)
drop if n_kids == 0
drop n_kids

* Standardize kidpnr01-kidpnr09 to kidpnr1-kidpnr9 if needed
capture confirm variable kidpnr01
if !_rc {
    forval i = 1/9 {
        capture confirm variable kidpnr0`i'
        if !_rc {
            gen kidpnr`i' = kidpnr0`i'
            drop kidpnr0`i'
        }
    }
}

* Reshape to parent-child pairs
reshape long kidpnr, i(pid) j(childno)
drop if missing(kidpnr)

* Parent PID is pid; child PID is kidpnr
gen mum_id_biobirth_ = pid if sex == 2
gen dad_id_biobirth_ = pid if sex == 1

bysort kidpnr: egen mum_id_biobirth = max(mum_id_biobirth_)
bysort kidpnr: egen dad_id_biobirth = max(dad_id_biobirth_)

bysort kidpnr: keep if _n == 1

keep kidpnr mum_id_biobirth dad_id_biobirth
rename kidpnr pid

save "${data}/biobirth_prep.dta", replace




/*----------------------------------------------------------------------------*/
/*---------------------------- [Bioparen ] --------------------------*/
/*----------------------------------------------------------------------------*/

use "${data_soep}/bioparen.dta", clear

keep pid mnr fnr fybirth mybirth fsedu msedu morigin forigin
recode mnr fnr (-8/0 = .)

rename mnr mum_id_bioparen
rename fnr dad_id_bioparen

save "${data}/bioparen_prep.dta", replace












