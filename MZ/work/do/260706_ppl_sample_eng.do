clear all

/*** Specify Stata version																							  ***/
version 18   /*** Specify version                                                                                ***/

/*** Configure screen output																					  ***/
set more off
set logtype text
set linesize 255 
set seed 5698753

/*** Specify ado-file path																							  ***/
sysdir set PERSONAL "Z:\Fuerth\GWA61_5015\C_Programme\ado"

mata mata mlib index

/*** Macros for directory paths																							  ***/
global main "Z:\Fuerth\GWA61_5015"				// Project directory
global datenpfad "$main\A_Mikrodaten"		// Original data
global outputpfad "$main\work"					// Project working directory


/*** Create subdirectories in the working directory (= output path)								  ***/
cd "$outputpfad"
cap mkdir data			// For data preparation
cap mkdir results		// For descriptive statistics and regression results
cap mkdir graphs		// For figures
cap mkdir log			// For saving log files
cap mkdir do			// For storing the respective do-files


/*** Macros for paths to output subdirectories																	  ***/
global data_prep "$outputpfad\data"
global results "$outputpfad\results"
global graphs "$outputpfad\graphs"
global log "$outputpfad\log"
global do "$outputpfad\do"


/*** Macros for input and output filenames																			  ***/						
*global dateiname "mz"
*global outputname "ppl"															  

* Create a global macro for the current date
gen date_current_temp = date("`c(current_date)'","DMY")
format date_current_temp %tdYYNNDD
global date = string(date("`c(current_date)'","DMY"),"%tdYYNNDD")
drop date_current_temp
di "$date"


/*** Start logging.                                                                            ***/
cap log close
log using "$log\ppl_sample_$date.log", replace




/********************************************************************************************************************/
/***  					 Prepare the sample here												  ***/
/********************************************************************************************************************/

use "$data_prep\mz_append_temp.dta", clear



**Keep families with a focal child who has at least one older sibling
keep if family_affected == 1 
keep if sibl_old_sum >= 1


*Generate sequential household ID
egen float hhnr = group(welle bula reg_bezirk auswahl_bezirk auswahl_hhid)



*********************************Parents Info***********************************
gen mage_b = yob - myob
gen fage_b = yob - fyob
recode fsbil msbil mage fage mage_b fage_b  (.=0) // 

gen meduc_haupt =msbil==1
gen meduc_real =msbil==2
gen meduc_gym =inlist(msbil,3,4)

gen feduc_haupt =fsbil==1
gen feduc_real =fsbil==2
gen feduc_gym =inlist(fsbil,3,4)

recode fsbil msbil (99=-99) (5=-5) (9=-9)
egen psbil = rowmax(msbil fsbil)
recode psbil fsbil msbil (-99=99) (-5=5) (-9=9) (4=3)

gen peduc_haupt =psbil==1
gen peduc_real =psbil==2
gen peduc_gym =inlist(psbil,3,4)


recode *ISCED* (99 999 9998 0 = .)
recode *ISCED* (10=11) (20=21) (33=32) (34=33) (40=41) (50=51) (60 70=52) (80=60) if welle >=14
recode *ISCED* (60=52) (31 32 = 32)
egen pISCED = rowmax(mISCED fISCED)
recode *ISCED* (.=99)
label var pISCED "parental educ. ISCED" 


gen pmigback = mzuzug == 1 | fzuzug == 1
label var pmigback "parental mig.backgr."

gen m_noneligible_ = mzuzugsj - yob if kid_affected == 1 & mzuzugsj != . & mzuzugsj != -5
gen m_noneligible = m_noneligible >= -1 & m_noneligible != .

gen f_noneligible_ = fzuzugsj - yob if kid_affected == 1 & fzuzugsj != . & fzuzugsj != -5
gen f_noneligible = f_noneligible >= -1 & f_noneligible != .

egen p_noneligible = rowmax(m_noneligible f_noneligible)
egen hh_noneligible = max(p_noneligible), by(hhnr)

gen age_zuzug = zuzugsj-yob if zuzugsj != . & zuzugsj != -5 & kid == 1
label var age_zuzug "Alter bei Zuzug"

gen mage_zuzug = mzuzugsj - myob if mzuzugsj != . & mzuzugsj != -5
gen fage_zuzug = fzuzugsj - fyob if fzuzugsj != . & fzuzugsj != -5


*********************************Outcomes**************************************

rename school_4 school_4w
rename school_12 school_12m


******** Recode type of school
recode schule (1=1) (2=4) (3=8) (4=5) (5=2) (6=3) (7 8=6) (9=7) (10 11=12) (12=10) /// /*changed coding starting 2011
			(13 14 15=12) (16=9) (17=11) (18=13) (19 20 30=14)  (21 29=17) (22 31=15) ///
			(23 24=16)  (25=18) (26=19) (27=20) (28=21)  (99=99) (else=.) if welle>=11
lab define schule  	1 "1 Grundschule" ///
					2 "2 Hauptschule" ///
					3 "3 Realschule" /// 
					4 "4 Schulartunabhängige Orientierungsstufe" ///
					5 "5 Schularten mit mehreren Bildungsgängen (z.B. Regionale Schule, Sekundarschule, Mittelschule)" ///
					6 "6 Gesamtschule, Waldorfschule" ///
					7 "7 Gymnasium" ///
					8 "8 Sonderschule, Förderschule" ///
					9 "9 Berufsvorbereitungsjahr" ///
					10 "10 Berufliche Schule, die einen mittleren Abschluss vermittelt (z.B. Berufsfachschule)" ///
					11 "11 Berufsgrundbildungsjahr" ///
					12 "12 Berufliche Schule, die zur Fachhochschul-/Hochschulreife führt (z.B. Fachoberschule, berufliches Gymnasium, Wirtschaftsg" ///
					13 "13 Berufsschule" ///
					14 "14 Berufsfachschule, die einen Abschluss in einem Beruf vermittelt, 1-jährige Schule des Gesundheitswesens (z.B. für Pflege" ///
					15 "15 Fachschule" ///
					16 "16 Fach-/Berufsakademie" ///
					17 "17 2- oder 3-jährige Schule des Gesundheitswesens" ///
					18 "18 Verwaltungsfachhochschule" ///
					19 "19 Fachhochschule" ///
					20 "20 Universität (wissenschaftliche Hochschule, auch Kunsthochschule)" ///
					21 "21 Promotionsstudium" ///
					99 "99 Ohne Angabe"
lab val schule schule		  

replace schule = 1 if klasse == 1 // Primary school (grades 1–4)
replace schule = 7 if klasse == 3 // Upper-secondary level (= Gymnasium)


*Primary
gen grund=schule==1 
label var grund "Grundschule"
*Lower secondary
gen haupt=schule==2 
replace haupt = 1 if inrange(schule,9,99) & sbil == 1
label var haupt "Hauptschule"
*Intermediate secondary
gen real=schule==3  
replace real = 1 if inrange(schule,9,99) & sbil == 2
label var real "Realschule"
*Gymnasium
gen gym=schule==7  | klasse==3  
replace gym = 1 if inrange(schule,9,99) & inrange(sbil,3,4)
label var gym "Gymnasium"
*Comprehensive
gen gesamt=schule==4 | schule==5 | schule==6
label var gesamt "Gesamtschule"
*Special needs
gen sonder=schule==8 
label var sonder "Sonderschule"
*Unknown 
gen unbekannt = (grund == 0 & haupt == 0 & real == 0 & gym == 0 & gesamt == 0 & sonder == 0)
label var unbekannt "unbekannt (wsl. berufl. Bildung)"
*Other (all school types other than Lower secondaryschule, Intermediate secondaryschule, or Gymnasium)
gen other = (haupt == 0 & real == 0 & gym == 0)
*Nonacademic (includes multi-track schools, which are generally combined Lower secondaryschule and Intermediate secondaryschule)
gen nonacademic = (haupt == 1 | real == 1 | schule == 5)

egen school_miss = rowmiss(grund haupt real gym gesamt sonder unbekannt)



******** Cohort assignment

cap drop cohort
gen cohort=0 if yob==2006 & mob>=7 & mob<=12
replace cohort=0 if yob==2007 & mob>=1 & mob<=6

replace cohort=1 if yob==2005 & mob>=7 & mob<=12
replace cohort=1 if yob==2006 & mob>=1 & mob<=6

replace cohort=2 if yob==2004 & mob>=7 & mob<=12
replace cohort=2 if yob==2005 & mob>=1 & mob<=6

replace cohort=3 if yob==2003 & mob>=7 & mob<=12
replace cohort=3 if yob==2004 & mob>=1 & mob<=6

replace cohort=4 if yob==2002 & mob>=7 & mob<=12
replace cohort=4 if yob==2003 & mob>=1 & mob<=6

replace cohort=5 if yob==2001 & mob>=7 & mob<=12
replace cohort=5 if yob==2002 & mob>=1 & mob<=6

gen after = inrange(mob,1,6)

*******generate attended grade
* gen age
gen samp=7 if (welle == 14 & cohort == 0) | (welle == 13 & cohort == 1) | (welle == 12 & cohort == 2) | (welle == 11 & cohort == 3) | (welle == 10 & cohort == 4) | (welle == 9 & cohort == 5)
replace samp=8 if (welle == 15 & cohort == 0) | (welle == 14 & cohort == 1) | (welle == 13 & cohort == 2) | (welle == 12 & cohort == 3) | (welle == 11 & cohort == 4) | (welle == 10 & cohort == 5)
replace samp=9 if (welle == 16 & cohort == 0) | (welle == 15 & cohort == 1) | (welle == 14 & cohort == 2) | (welle == 13 & cohort == 3) | (welle == 12 & cohort == 4) | (welle == 11 & cohort == 5)
replace samp=10 if (welle == 17 & cohort == 0) | (welle == 16 & cohort == 1) | (welle == 15 & cohort == 2) | (welle == 14 & cohort == 3) | (welle == 13 & cohort == 4) | (welle == 12 & cohort == 5)
replace samp=11 if (welle == 18 & cohort == 0) | (welle == 17 & cohort == 1) | (welle == 16 & cohort == 2) | (welle == 15 & cohort == 3) | (welle == 14 & cohort == 4) | (welle == 13 & cohort == 5)
replace samp=12 if (welle == 19 & cohort == 0) | (welle == 18 & cohort == 1) | (welle == 17 & cohort == 2) | (welle == 16 & cohort == 3) | (welle == 15 & cohort == 4) | (welle == 14 & cohort == 5)
* gen interview year
gen MZ = welle + 2000
* gen grade (assumption: All individuals of a given cohort, that are being interviewed in the last quarter of the year, should have advanced to the next grade)
gen grade = samp - 6 + 1
replace grade = grade - 1 if inlist(quartal,1,2,3)




***** Birth order****

clonevar birthorder = birthord
bys hhnr kid: egen kids_total = max(birthord) if birthord <= 9998 
replace birthorder = ((birthorder - kids_total)*(-1))+1 

recode birthorder (4/9 = 4) (9998 = .), gen(birtho)

*Number of children per household ID
bys hhnr: egen kids_number = total(kid) 

*Households with twins
bys hhnr gebdate: gen twins = _n
bys hhnr: egen twin_hh_ = max(twins)
gen twin_hh = twins == 2
label var twin_hh "Household with twins"




**********************Info on focal child*****************************
foreach var of varlist grund haupt real gym gesamt sonder male twin age_q mob yob zuzug birtho sibl_old_sum sibl_young_sum {
	gen `var'_a_=`var' if kid_affected == 1
	egen `var'_a=max(`var'_a_), by(hhnr)
	drop `var'_a_
}



**********************School cohort variable*****************************
gen cutm = 6
replace cutm = 7 if bula == 3 & yob == 2004 
replace cutm = 8 if bula == 3 & yob == 2005 
replace cutm = 9 if bula == 3 & inrange(yob,2006,2008)
replace cutm = 7 if bula == 5 & inrange(yob,2001,2002) 
replace cutm = 8 if bula == 5 & inrange(yob,2003,2004) 
replace cutm = 9 if bula == 5 & inrange(yob,2005,2008)
replace cutm = 8 if bula == 7 & yob >= 2002 
replace cutm = 7 if bula == 8 & yob == 1999 
replace cutm = 8 if bula == 8 & yob == 2000
replace cutm = 9 if bula == 8 & yob >= 2001 
replace cutm = 7 if bula == 9 & yob == 1999 
replace cutm = 8 if bula == 9 & yob == 2000
replace cutm = 9 if bula == 9 & yob == 2001 
replace cutm = 10 if bula == 9 & yob == 2002 
replace cutm = 11 if bula == 9 & yob == 2003
replace cutm = 9 if bula == 9 & yob >= 2004
replace cutm = 9 if bula == 12 & yob >= 1995 
replace cutm = 7 if bula == 16 & yob >= 1997 

gen school_cohort = yob + 6
replace school_cohort = school_cohort + 1 if mob > cutm & mob < .

gen school_cohort_a = yob_a + 6
replace school_cohort_a = school_cohort_a + 1 if mob_a > cutm & mob_a < .





*****************************SAMPLE CLEANING************************************
drop if kid == 0		
					
* Remove households in which mothers/fathers immigrated to Germany after the focal child was born
drop if hh_noneligible == 1 				

* Remove households in which the focal child immigrated to Germany
gen zuzug_focal_ = zuzug_a if kid_affected == 1
bys hhnr: egen zuzug_focal = max(zuzug_focal_)
drop if zuzug_focal	== 1					
 
*Remove households with implausible values: unrealistic parental age at a child’s birth
gen mage_b_real_ = inrange(mage_b,15,50) | mage_b == 0	
bys hhnr: egen mage_b_real = min(mage_b_real)

gen fage_b_real_ = (fage_b >= 15 & fage_b != .)  | fage_b == 0	
bys hhnr: egen fage_b_real = min(fage_b_real)

gen parent_age_unreal = mage_b_real == 0 | fage_b_real == 0
drop if parent_age_unreal == 1

*Remove households with implausible values: sibling birth spacing within +/- 9 months of focal child
gen spacing_unreal_ = inrange(spacing_m,-8,-1) | inrange(spacing_m,1,8)
bys hhnr: egen spacing_unreal = max(spacing_unreal_)
drop if spacing_unreal == 1

*Exclude Brandenburg and Berlin because school tracking occurs later
drop if inlist(bula,11,12) 

*Generate spacing in years
bys hhnr: egen spacing_fam_max = max(spacing_y)
label var spacing_fam_max "Spacing in years"


**SE for clustering
egen bdate_se = group(yob_a mob_a)

save "$data_prep\mz_sample_prelim.dta", replace



***********************Final sample restrictions and save datasets*********************************
use "$data_prep\mz_sample_prelim.dta", clear

*********SIBLINGS without birth spacing restrition*******

*Create sample
preserve
keep if sibling_affected == 1 // Focus on siblings
keep if sibl_old == 1
keep if inrange(cohort_a,2003,2007) 
keep if inrange(age,12,17)

drop if yob_a == 2002 & mob_a < 7
drop if yob_a == 2007 & mob_a > 6

drop if school_miss > 0

save "$data_prep\mz_sample_sibl.dta", replace
restore

*Save household IDs from sibling sample for merging with focal-child sample
preserve 
use "$data_prep\mz_sample_sibl.dta", clear
duplicates drop hhnr, force
keep hhnr
save "$data_prep\mz_sample_sibl_hhnr.dta", replace
restore


******************Create samples


*********FOCAL CHILD - prelim *************
preserve
keep if kid_affected == 1 // 
merge m:1 hhnr using "$data_prep\mz_sample_sibl_hhnr.dta"
keep if _merge == 3
keep if inrange(cohort_a,2003,2007) 
drop _merge
save "$data_prep\mz_sample_focal.dta", replace
restore


*********SIBLINGS*******

*Max 9 years of spacing
preserve
use "$data_prep\mz_sample_sibl.dta", clear
drop if spacing_fam_max >= 10
save "$data_prep\mz_sample_sibl_spacing.dta", replace
restore

*Save HHNR to merge to sample with focal children
preserve 
use "$data_prep\mz_sample_sibl_spacing.dta", clear
duplicates drop hhnr, force
keep hhnr
save "$data_prep\mz_sample_sibl_spacing_hhnr.dta", replace
restore


*********FOCAL CHILD - final (only focal children with older siblings*************
preserve
use "$data_prep\mz_sample_focal.dta", clear
merge m:1 hhnr using "$data_prep\mz_sample_sibl_spacing_hhnr.dta"
keep if _merge == 3
keep if inrange(cohort_a,2003,2007) 
drop _merge
save "$data_prep\mz_sample_focal_spacing.dta", replace
restore


log close




