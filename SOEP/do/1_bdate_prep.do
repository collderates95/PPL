/********************************************************************
Create bdate.dta from ppathl
********************************************************************/

use pid sex gebjahr gebmonat germborn migback birthregion erstbefr letztbef ///
    using "${data_soep}/ppathl.dta", clear

recode gebjahr gebmonat sex germborn migback birthregion erstbefr letztbef (-9/-1 = .)

recode germborn (2=0) (1=1), gen(germanborn)
label var germanborn "Geboren in Deutschland (1/0)"

recode migback (1=0) (2 3 = 1), gen(mig_back)
label var mig_back "Migrationshintergrund (1/0)"

rename birthregion bbula
label var bbula "Bundesland Geburt"

keep if sex > 0

* Prefer complete birth information
gen complete_birth = !missing(gebjahr, gebmonat)

gsort pid -complete_birth gebjahr gebmonat sex
by pid: keep if _n == 1

isid pid

rename gebjahr yob
rename gebmonat mob

gen gebym = ym(yob, mob)
format gebym %tm
label var gebym "Birth month/year"

gen gebdate = mdy(mob, 1, yob)
format gebdate %tdD_m_CY
label var gebdate "Birth date, first day of birth month"

label var yob "Year of birth"
label var mob "Month of birth"

drop complete_birth

save "${data}/bdate_ppathl.dta", replace


