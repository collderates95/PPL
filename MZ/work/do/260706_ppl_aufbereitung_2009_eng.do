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
log using "$log\ppl_aufbereitung_2009_$date.log", replace



/********************************************************************************************************************/
/*** I.  This section prepares the data for 2009									  ***/
/********************************************************************************************************************/


/********************************************************************************************************************/
/*** a. Load the corresponding dataset and select variables				              			  		  ***/

/*** Select required survey years 																          ***/
foreach year of numlist 2009 { // (1)2020  ***/
	use "$datenpfad\mz`year'_5015_2024.dta" , clear  // using EF1 EF12 EF44 EF46 EF47 EF48 EF310 EF366 EF451-EF453 EF455 EF951 EF952	 
}



/********************************************************************************************************************/
/*** a. Original variables for household identification 		              			  		  								***/


******** Federal state
clonevar bula = EF1
label var bula "Bundesland"

******** Administrative district
clonevar reg_bezirk = EF2
label var reg_bezirk "Regierungsbezirk"

******** Sampling district
clonevar auswahl_bezirk = EF3S
label var auswahl_bezirk "Auswahlbezirksnummer"

******** Household ID within sampling district
clonevar auswahl_hhid = EF4S
label var auswahl_hhid "Haushalts-ID im Auswahlbezirksnummer"

******** Person number within household
clonevar hh_pnr = EF5S
label var hh_pnr "Personennummer innerhalb des Haushalts"


*** Identify households (federal state, administrative district, sampling district, household number within sampling district)				
cap drop hhid_09
egen hhid_09 = group(bula reg_bezirk auswahl_bezirk auswahl_hhid)



/********************************************************************************************************************/
/*** b. Interview information		              			  		  											***/

******** Survey quarter
gen quartal=EF12
lab var quartal "Quartal (Interview)"

******** Interview date (assumed to be in the last month of each quarter)
gen quarter_last = quartal*3
gen int_date = ym(EF11,quarter_last)
format int_date %tm

******** Wave
gen welle = 9
label var welle "Welle (Jahr)"

******** Carryover from previous year
recode EF5U2 (1=1) (else=0), gen(vorjahr)
lab var vorjahr "vorjahr"


********* Generate interview number within quarter using EF0 -> drop duplicate interviews
bysort EF1 EF2 EF3S EF4S EF5S quartal: gen EF0=_n
drop if EF0>1
drop EF0



/********************************************************************************************************************/
/*** c. Sociodemographic information		              			  		  											***/ 

******** East/West
gen west= (EF1>=1 & EF1<=10)
lab var west "west"

******** Date of birth
gen yob = EF47
lab var yob "Geb.Jahr"

gen mob = EF48
lab var mob "Geb.Mon."

gen gebdate= mdy(mob, 1, yob) 
format gebdate %tdD_m_CY
lab var gebdate "Geb.Datum (Monat, Tag, Jahr)"

gen bdate_ym = ym(yob, mob)
format bdate_ym %tm
lab var bdate_ym "Geb.Datum (Jahr, Monat)"

******** Age
gen age = EF44 
lab var age "Alter"

*Age at interview in months (assuming an interview in the last month of the quarter)
gen age_i= int((2000+welle-yob)*12 + (quartal*3-mob)) 
lab var age_i "age at interw."

recode mob (1/3=1) (4/6=2) (7/9=3) (10/12=4), gen(gebq)
gen age_q= int((2000+welle-yob)*4 + (quartal-gebq)) 
lab var age_q "age at interw. quart"

******** Sex
gen male= (EF46==1)
lab var male "male"

******** Migration
recode EF366 (8 9=1) (1=0) (else=.), gen(zuzug)
lab var zuzug "Zuzug"
gen zuzugsj=EF367 if EF367!=9999
lab var zuzugsj "Zuzugsjahr"

recode EF368 (1 2=1) (8=0), gen(gercit) 
lab var gercit "German citizen"

******** Household income
clonevar HHinc = EF437
*replace EF437 = EF437EU if HHinc == . & welle == 11
*replace EF437 = EF437MZ if HHinc == . & welle == 11
recode HHinc (50=99)
recode 	HHinc (1 = 75) (2=225) (3=400) (4=600) (5=800) (6=1000) ///
		(7 = 1200) (8=1400) (9=1600) (10=1850) (11=2150) (12=2450) ///
		(13 = 2750) (14=3050) (15=3400) (16=3800) (17=4250) (18=4750) ///
		(19 = 5250) (20=5750) (21=6750) (22=8750) (23=14000) (24=18000) ///
		(90=0) (else=.)
gen HHinc_ln = ln(HHinc)
gen HHinc_mis = HHinc == 99
		
label var HHinc "HH-Einkommen netto"
label var HHinc_ln "HH-Einkommen netto (log.)"
label var HHinc_mis "HH-Einkommen missing"	

gsort hhid_09 -age
bys hhid_09: gen zeile = _n
gen over14 = age >= 14 & age <= .
gen oldest = zeile == 1 
gen oldest_halfweight = .
replace oldest_halfweight = 0.5 if over14 == 1 & zeile > 1

gen kid_weight = .
replace kid_weight = 0.3 if over14 == 0 & zeile > 1

egen äqui_weight_ind = rowmax(oldest oldest_halfweight kid_weight)
bys hhid_09: egen äqui_weight = total(äqui_weight_ind)

gen HHinc_äquiv = HHinc/äqui_weight
gen HHinc_äquiv_ln = ln(HHinc_äquiv)
gen HHinc_äquiv_mis = HHinc_äquiv == 99

label var HHinc_äquiv "HH-Äquivalenzeinkommen netto"
label var HHinc_äquiv_ln "HH-Äquivalenzeinkommen netto (log.)"
label var HHinc_äquiv_mis "HH-Äquivalenzeinkommen missing"		

/********************************************************************************************************************/
/*** d. Schooling and education	              			  		  											***/ 


******** School attendance
recode EF287 (1=1) (2 = 0) (8 9 = 9), gen(school_4)
label def school_4 0 "nein (wg. Ferien7Übergang in andere Schule etc.)" 1 "ja" 9 "andere Gründe/keine Angabe"
label val school_4 school_4
label var school_4 "Schule letzte 4 Wochen (0/1)"

recode EF288(1=1) (8 9 = 0), gen(school_12)
label def school_12 0 "nein" 1 "ja"
label val school_12 school_12
label var school_12 "Schule letzte 12 Monate (0/1)"

gen school_visit = inlist(school_4,1) | inlist(school_12,1)
label def school_visit 0 "nein/keine Angabe" 1 "ja"
label val school_visit sschool_visit
label var school_visit "Schulbesuch (0/1) letzte 4 Wochen/12 Monate"


******** Current type of school
clonevar schule= EF289
lab var schule "Schulart"

******** Grade
clonevar klasse= EF290
lab var klasse "Klassenstufe"


******** Highest vocational qualification
clonevar ISCED=EF540 
lab var ISCED "ISCED 97"

******** School-leaving qualification
*School qualification: [1] lower-secondary [2] intermediate-secondary [3] university of applied sciences entrance qualification [4] Abitur [5] other qualification [9] no qualification [99] no information
recode EF310 (1 6=1) (3=2) (4=3) (5=4) (2 7=5)  (else=99), gen(sbil)
replace sbil=9 if EF309==8
lab var sbil "Schulabschluss"

******** Vocational qualification
/*Vocational qualification: [0] none [1] apprenticeship [2] vocational/healthcare/technical school, master craftsman, civil-service training [3] university degree [9] other [99] no information*/
recode EF312  (3=1) (4 5 6 7 11 =2)  (8 9 10=3) (99 .=99) (else=9), gen(bbil)
replace bbil=0 if EF311==8
lab var bbil "berufl. Abschluss"

* Year of highest qualification
recode EF314 EF317  (0 9999=.)
egen yeduc=rowmax(EF314 EF317) // Year of highest qualification 
lab var yeduc "educ year"




/********************************************************************************************************************/
/*** e. Labor market		              			  		  											***/ 
recode EF77 (1=1) (8=0) (else=.), gen(work)
lab var work "Bezahlte Tätigkeit in der letzten Woche"

recode EF160 (1/3=1) (8=0) (else=.), gen(Mini)
lab var Mini "Minijob als hauptsächliche Tätigkeit"

recode EF117 (1/2=1) (3/12=0) (else=.), gen(self)
lab var self "Selbsständig"

recode EF121 (1=1) (8=0) (else=.), gen(public)
lab var public "Öffentl. Dienst"

recode EF129 (2=1) (1=0) (else=.), gen(parttime)
lab var parttime "Teilzeit"

gen wh=EF131 if EF131<=98
lab var wh "Arbeitsstunden (normal)"

gen wh_a=EF134 if EF134<=98
lab var wh_a "Arbeitsstunden (tatsächlich)"

*recode EF244 (1/3=1) (8=0) (else=.), gen(alg)
gen alg=EF423!=. |  EF424!=. 
lab var alg "Arbeitslosengeld"





/********************************************************************************************************************/
/*** f. Family structure	              			  		  											***/ 

******** Unmarried children in family/household arrangement
clonevar sibl= EF770 if EF770<=9 					// All ages
lab var sibl "Zahl Kinder (Leb.form)" 	

clonevar sibl18= EF788 if EF788<=9					// < 18 years	
lab var sibl18 "Zahl Kinder <18 Jahre (Leb.form)"

******** Birth order (youngest to oldest)
clonevar birthord= EF805 if EF805>0 
lab var birthord "birth order"

******** Family type
gen singpar=(EF809==4)  					// Single parent
lab var singpar "Eltern alleinerziehend"

gen marrpar=(EF809==1)						// Married couple with children
lab var marrpar "Eltern verheiratet"				

gen nonmarrpar= EF809==2 | EF809==3						// Unmarried cohabiting couple
lab var nonmarrpar "Lebensgemeinschaft (nicht verh.)"

gen mom=EF52==1								// Mother
lab var mom "mom in HH"

gen dad=EF54==1								// Father
lab var dad "dad in HH"





/********************************************************************************************************************/
/*** g. Mothers	              			  		  											***/ 

*Generate sequential child ID and number of children
sort hhid_09 EF53 quartal yob mob
by hhid_09 EF53 quartal: gen kidnrm=_n if EF53!=.
by hhid_09 EF53 quartal: egen sumkidsm=max(kidnrm)
lab var  kidnrm "Lfd. Nr Kind m."
lab var  sumkidsm "Anzahl Kinder m."

*Flag multiple births
duplicates tag  hhid_09 EF53 quartal yob mob, generate(duplem)
replace duplem=. if kidnrm==.
bysort hhid_09 EF53 quartal yob mob: egen multim=max(duplem)
drop duplem
lab var  multim "Mehrlinge m."
recode multim (0=0) (.=.) (else=1), gen(twinm)
lab var  twinm "twin m."

*Generate birth order
bysort hhid_09 EF53 quartal yob mob: egen birthom=min(kidnrm)
lab var  birthom "birth order m."


/********************************************************************************************************************/
/*** h. Fathers	              			  		  											***/ 
*Generate sequential child ID and number of children
sort hhid_09 EF55 quartal yob mob
by hhid_09 EF55 quartal: gen kidnrf=_n if EF55!=.
by hhid_09 EF55 quartal: egen sumkidsf=max(kidnrf)
lab var  kidnrf "Lfd. Nr Kind f."
lab var  sumkidsf "Anzahl Kinder f."

*Flag multiple births
duplicates tag  hhid_09 EF55 quartal yob mob, generate(duplef)
replace duplef=. if kidnrf==.
bysort hhid_09 EF55 quartal yob mob: egen multif=max(duplef)
drop duplef
lab var  multif "Mehrlinge f."
recode multif (0=0) (.=.) (else=1), gen(twinf)
lab var  twinf "twin f."

*Generate birth order
bysort hhid_09 EF55 quartal yob mob: egen birthof=min(kidnrf)
lab var  birthof "birth order f."

*Generate person identifiers 
gen EF5m=EF53
lab var EF5m "ID mother within HH"
egen id_m=group(hhid_09 EF5m quartal) if EF5m!=.
lab var id_m "ID mother"
gen EF5f=EF55
lab var EF5f "ID father within HH"
egen id_f=group(hhid_09 EF5f quartal) if EF5f!=.
lab var id_f "ID father"


sort quartal hhid_09 EF5S
qui compress

****Save working dataset 
save "$data_prep\mz09_temp.dta", replace
count




/********************************************************************************************************************/
/*** g. Link maternal variables	              			  		  										 ***/  
drop EF5m
rename  EF5S EF5m

keep hhid_09 EF5m quartal yob age male ISCED sbil bbil zuzug zuzugsj gercit EF372 work Mini self public parttime wh wh_a alg gebdate bdate_ym
rename  yob myob
rename  age mage
rename  male mmale
rename  ISCED mISCED
rename  sbil msbil
rename  bbil mbbil
rename  zuzug mzuzug
rename  zuzugsj mzuzugsj
rename  gercit mgercit

rename  EF372 mEF372
rename work mwork
rename Mini mMini
rename self mself
rename public mpublic
rename wh mwh
rename wh_a mwh_a
rename alg malg
rename gebdate mgebdate
rename bdate_ym mbdate_ym


*Adjust maternal variable labels
lab var  myob            "m.Geb.Jahr"
lab var  mage             "m.age"
lab var  mmale            "m.male"
lab var  mISCED           "m.ISCED 97"
lab var  msbil            "m.Schulbildung"
lab var  mbbil           "m.Berufsbildung"
lab var  mzuzug           "m.Zuzug"
lab var  mzuzugsj         "m.Zuzugsjahr"
lab var  mgercit          "m.German citizen"


sort quartal hhid_09 EF5m  
joinby  quartal hhid_09 EF5m using "$data_prep\mz09_temp.dta", _merge(merge_M) unmatched(using)

sort quartal hhid_09 EF5S 

count

****Save working dataset 
save "$data_prep\mz09_mother_merged.dta", replace

/********************************************************************************************************************/
/*** h. Link paternal variables	              			  		  											***/  

drop EF5f
rename  EF5S EF5f

keep hhid_09 EF5f quartal yob age male ISCED sbil bbil zuzug zuzugsj gercit EF372 work Mini self public parttime wh wh_a alg gebdate bdate_ym
*Rename paternal variables
rename  yob fyob
rename  age fage
rename  male fmale
rename  ISCED fISCED
rename  sbil fsbil
rename  bbil fbbil

rename  zuzug fzuzug
rename  zuzugsj fzuzugsj
rename  gercit fgercit
rename EF372 fEF372
rename work fwork
rename Mini fMini
rename self fself
rename public fpublic
rename wh fwh
rename wh_a fwh_a
rename alg falg
rename gebdate fgebdate
rename bdate_ym fbdate_ym


*Adjust paternal variable labels
lab var  fyob            "f.Geb.Jahr"
lab var  fage             "f.age"
lab var  fmale            "f.male"
lab var  fISCED           "f.ISCED 97"
lab var  fsbil            "f.Schulbildung"
lab var  fbbil           "f.Berufsbildung"
lab var  fzuzug           "f.Zuzug"
lab var  fzuzugsj         "f.Zuzugsjahr"
lab var  fgercit          "f.German citizen"


sort  quartal hhid_09 EF5f
joinby  quartal hhid_09 EF5f using "$data_prep\mz09_mother_merged.dta", _merge(merge_F) unmatched(using)

sort quartal hhid_09 EF5S 
lab drop __MERGE
recode merge_M (3=1) (2=0)
recode merge_F (3=1) (2=0)
lab var merge_M "merge mother"
lab var merge_F "merge father"

recode birthord  (.=9998)
recode birthom birthof  (.=9998)
gen twin=(twinm==1 | twinf==1)
lab var twin "twin"


****Save working dataset 
compress
save "$data_prep\mz09_father_merged.dta", replace



/********************************************************************************************************************/
/*** i. Identify focal children and siblings	              			  		  								***/ 


* Identify children
gen kid = birthord > 0 & birthord < 9998
label var kid "Kind"

******Identify the youngest child (= focal child) born between July 2001 and June 2007

* Define cohort variable
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

gen kid_cohort = inrange(cohort,0,5) 


** Date of birth of focal child if born within the period above
bysort quartal hhid_09 kid_cohort: egen kid_affected_cohort_bdate = max(gebdate) if kid_cohort == 1
format kid_affected_cohort_bdate %tdD_m_CY

** Flag youngest child (and assign birth date to all siblings)
gen kid_affected = gebdate == kid_affected_cohort_bdate
label var kid_affected "Focal child"

bysort quartal hhid_09 kid (yob mob): egen gebdate_focal = max(kid_affected_cohort_bdate) if kid == 1
format gebdate_focal %tdD_m_CY
lab var gebdate_focal "Geb.Datum (Monat, Tag, Jahr) - focal child"

** Birth order of focal child
*gen birthord_focal_ = birthord if kid_affected == 1 
bysort quartal hhid_09: gen birthord_focal = birthord if kid_affected == 1
label var birthord_focal "Geburtsreihenfolge - focal child"

** Families without a child in the relevant cohorts
bysort quartal hhid_09: egen family_affected = max(kid_affected)
label var family_affected "Familien mit einem focal child"

** Identify siblings of the youngest eligible children
gen sibling_affected = .
replace sibling_affected = 1 if family_affected == 1 & kid_affected == 0  & kid == 1
label var sibling_affected "Geschwisterkind eines focal child"

*Identify older siblings
gen sibl_old = gebdate < gebdate_focal if sibling_affected == 1
label var sibl_old "Älteres Geschwisterkind eines focal child"

egen sibl_old_sum = total(sibl_old), by(hhid_09)
label var sibl_old_sum "Summe älterer Geschwisterkinder des focal child"

*Identify younger siblings
gen sibl_young = gebdate > gebdate_focal if sibling_affected == 1
label var sibl_young "Jüngeres Geschwisterkind eines focal child"

egen sibl_young_sum = total(sibl_young), by(hhid_09)
label var sibl_young_sum "Summe jüngerer Geschwisterkinder des focal child"

** Birth spacing relative to focal child
gen spacing_d = gebdate_focal - gebdate
gen spacing_m = int((gebdate_focal-gebdate)/30)
gen spacing_y = int((gebdate_focal-gebdate)/365)
gen spacing_q = int((spacing_m)/4)


*Treatment variables for siblings
gen after_a = month(gebdate_focal)>=1 & month(gebdate_focal)<=6

gen cohort_a = .
replace cohort_a = 2007 if year(gebdate_focal)==2007 & after_a == 1
replace cohort_a = 2007 if year(gebdate_focal)==2006 & after_a == 0

replace cohort_a = 2006 if year(gebdate_focal)==2006 & after_a == 1
replace cohort_a = 2006 if year(gebdate_focal)==2005 & after_a == 0

replace cohort_a = 2005 if year(gebdate_focal)==2005 & after_a == 1
replace cohort_a = 2005 if year(gebdate_focal)==2004 & after_a == 0

replace cohort_a = 2004 if year(gebdate_focal)==2004 & after_a == 1
replace cohort_a = 2004 if year(gebdate_focal)==2003 & after_a == 0

replace cohort_a = 2003 if year(gebdate_focal)==2003 & after_a == 1
replace cohort_a = 2003 if year(gebdate_focal)==2002 & after_a == 0

replace cohort_a = 2002 if year(gebdate_focal)==2002 & after_a == 1
replace cohort_a = 2002 if year(gebdate_focal)==2001 & after_a == 0

gen reform_a = after_a == 1 & year(gebdate_focal)==2007

label var after_a "Geburt im ersten Halbjahr - focal child"
label var cohort_a "Kohortenzugehörigkeit - focal child"
label var reform_a "Reformbetroffenheit - focal child"

drop kid_cohort kid_affected_cohort_bdate

/********************************************************************************************************************/
/*** i. Sample restrictions              			  		  													  ***/ 

* Exclude communal accommodation
drop if EF28 == 8

* Keep eligible families only
keep if family_affected == 1


keep hhid_09 -merge_M bula- reform_a

save "$data_prep\mz09_final.dta", replace


