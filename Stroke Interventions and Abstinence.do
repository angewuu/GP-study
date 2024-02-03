*merging all of the records of interventions offered in long format
cd "P:\OX57"
use "Data\population 2\OX57_gp_clinical_events_14179", clear
destring, replace

gen dataset =1

save "Angela's coding\dataset\merged_interventions.dta", replace

use "Data\population 2\OX57_gp_clinical_events_14169", clear
destring, replace
gen dataset =2

append using "Angela's coding\dataset\merged_interventions.dta", force

save "Angela's coding\dataset\merged_interventions.dta", replace

use "Data\population 2\OX57_gp_clinical_events_14170", clear
destring, replace
gen dataset = 3

append using "Angela's coding\dataset\merged_interventions.dta", force

save "Angela's coding\dataset\merged_interventions.dta", replace

use "Data\population 2\OX57_gp_clinical_events_14171", clear
destring, replace
gen dataset = 4

append using "Angela's coding\dataset\merged_interventions.dta", force

save "Angela's coding\dataset\merged_interventions.dta", replace

use "Data\population 2\OX57_gp_clinical_events_14172", clear
destring, replace
gen dataset = 5

append using "Angela's coding\dataset\merged_interventions.dta", force

save "Angela's coding\dataset\merged_interventions.dta", replace


use "Data\population 2\OX57_gp_clinical_events_14177", clear
destring, replace
gen dataset = 6

append using "Angela's coding\dataset\merged_interventions.dta", force

save "Angela's coding\dataset\merged_interventions.dta", replace


use "Data\population 2\OX57_gp_clinical_events_14178", clear
destring, replace
gen dataset = 7

append using "Angela's coding\dataset\merged_interventions.dta", force

save "Angela's coding\dataset\merged_interventions.dta", replace

use "Data\population 2\OX57_gp_clinical_events_14180", clear
destring, replace
gen dataset = 8

append using "Angela's coding\dataset\merged_interventions.dta", force

use "Data\population 2\OX57_gp_clinical_events_14206", clear
destring, replace
gen dataset = 9

append using "Angela's coding\dataset\merged_interventions.dta", force

save "Angela's coding\dataset\merged_interventions.dta", replace

use "Data\population 2\gp_drugscripts_target_7645", clear
destring, replace
gen dataset = 10

append using "Angela's coding\dataset\merged_interventions.dta", force
save "Angela's coding\dataset\merged_interventions.dta", replace

use "Data\population 2\gp_drugscripts_target_7646", clear
destring, replace
gen dataset = 11

append using "Angela's coding\dataset\merged_interventions.dta", force
save "Angela's coding\dataset\merged_interventions.dta", replace

use "Data\population 2\gp_drugscripts_target_14194", clear
destring, replace
gen dataset = 12

append using "Angela's coding\dataset\merged_interventions.dta", force
save "Angela's coding\dataset\merged_interventions.dta", replace

*need to now change it to wide format, this is going to be ridiculously long. Is there a way that i can remove for dates that are before...

use "Angela's coding\dataset\merged_interventions.dta", clear
sort patid effectivedatetime
quietly by patid: gen timepoint = cond(_N==1,0,_n)
keep patid effectivedatetime timepoint codegroupid 

reshape wide codegroupid effectivedatetime, i(patid) j(timepoint)

merge 1:1 patid using  "Angela's coding\Stroke_final_smoking.dta"

drop if _merge ==1

save "Angela's coding\dataset\merged_interventions.dta", replace

use "Angela's coding\dataset\merged_interventions.dta", clear


replace nrt_within_1_year = 1 if NRT_within_1_year == 1
replace buproprion_within_1_year = 1 if bup_within_1_year == 1


*here i have found the number of times the patient received an intervention regardless of type, might be multiple in one day. within one year from their stroke - and one year to five stroke
cap drop num_effectivedatetime
gen num_effectivedatetime = 0
foreach var of varlist effectivedatetime* {
	replace num_effectivedatetime = num_effectivedatetime + (`var' > stroke_date & `var' < stroke_date +365) if !missing(`var') & stroke_date !=.
	}
	
rename num_effectivedatetime yearonefre

cap drop num_effectivedatetime
gen num_effectivedatetime = 0
foreach var of varlist effectivedatetime* {
	replace num_effectivedatetime = num_effectivedatetime + (`var' > stroke_date + 365 & `var' < stroke_date + 730) if !missing(`var') & stroke_date !=.
	}
	
rename num_effectivedatetime yeartwofre

cap drop num_effectivedatetime
gen num_effectivedatetime = 0
foreach var of varlist effectivedatetime* {
	replace num_effectivedatetime = num_effectivedatetime + (`var' > stroke_date + 730 & `var' < stroke_date + 1095) if !missing(`var') & stroke_date !=.
	}
	
rename num_effectivedatetime yearthreefre

cap drop num_effectivedatetime
gen num_effectivedatetime = 0
foreach var of varlist effectivedatetime* {
	replace num_effectivedatetime = num_effectivedatetime + (`var' > stroke_date + 730 & `var' < stroke_date + 1095) if !missing(`var') & stroke_date !=.
	}
	
rename num_effectivedatetime yearfourfre

cap drop num_effectivedatetime
gen num_effectivedatetime = 0
foreach var of varlist effectivedatetime* {
	replace num_effectivedatetime = num_effectivedatetime + (`var' > stroke_date + 1095 & `var' < stroke_date + 1460) if !missing(`var') & stroke_date !=.
	}


rename num_effectivedatetime yearfivefre

sum yearonefre yeartwofre yearthreefre yearfourfre yearfivefre

tab yearonefre 
replace intervention_offered = 0 if yearonefre == 0
replace intervention_offered = 1 if yearonefre > 0

*now let's see how often people get approached in terms of their first time getting smoking cessation intervention 

gen newinter2 = 0
replace newinter2=1  if yeartwofre > 0 & yearonefre == 0

gen newinter3 = 0
replace newinter3=1  if yearthreefre > 0 & yearonefre == 0 & yeartwofre == 0

gen newinter4 = 0
replace newinter4=1  if yearfourfre > 0 & yearonefre == 0 & yeartwofre == 0 & yearthreefre == 0

gen newinter5 = 0
replace newinter5=1  if yearfivefre > 0 & yearonefre == 0 & yeartwofre == 0 & yearthreefre == 0 & yearfivefre == 0

label define new_intervention 0 "no intervention offered" 1 "first time intervention"
label values newinter2 newinter3 newinter4 newinter5 new_intervention

*here i have found the number of times the patient received an intervention regardless of type, might be multiple in one day. within one year from their stroke - and one year to five stroke

use "Angela's coding\dataset\stroke_merged_interventions.dta", clear
cap drop QOFtime
gen QOFtime =.
replace QOFtime = 1 if stroke_date > mdy(03,31,2004)
replace QOFtime = 0 if stroke_date <mdy(04,01,2004)
label define QOF 0 "Before QOF Introduced" 1 "After QOF Introduced"
label value QOFtime QOF

tab intervention_offered QOFtime


save "Angela's coding\dataset\stroke_merged_interventions.dta", replace

/* defining smoking exposure 
	*/

cd "P:\OX57"
use "Angela's coding\stroke smoking_2.dta", clear
cap drop firstabsti
cap drop firstabstitime


gen firstabsti =.
gen firstabstitime=.
format %td firstabsti


forval j=0/335 {
	local cat_var smoke_cat`j'
	local date_var smoke_date`j'
	
	qui replace firstabsti = smoke_date`j' if (`cat_var' == 0  | `cat_var'==1) & smoke_date`j' > stroke_date & (`cat_var' !=.) & (firstabsti ==.)
	}

replace firstabstitime = firstabsti - stroke_date



cap drop firstsmokingrecord
cap drop firstsmokingtime


gen firstsmokingrecord =.
gen firstsmokingtime=.
format %td firstsmokingrecord


forval j=0/335 {
	local cat_var smoke_cat`j'
	local date_var smoke_date`j'
	
	qui replace firstsmokingrecord = smoke_date`j' if (`cat_var' == 2  | `cat_var'==3  | `cat_var'== 4) & smoke_date`j' > stroke_date & (`cat_var' !=.) & (firstsmokingrecord==.)
	}

replace firstsmokingtime = firstabsti - stroke_date


cap drop abstinext1

gen abstinext1=.
forval j=0/335 {
	local cat_var smoke_cat`j'
	local date_var smoke_date`j'
	
	qui replace abstinext1 = smoke_date`j' if (smoke_date`j' > firstabsti) & (`cat_var' !=.) & (abstinext1 ==.)
	}
format %td abstinext1

gen abstinext1cat=.
forval j=0/335 {
	local cat_var smoke_cat`j'
	local date_var smoke_date`j'
	
	qui replace abstinext1cat = smoke_cat`j' if (smoke_date`j' == abstinext1) & (`cat_var' !=.) 
	}

cap drop abstinext2

gen abstinext2=.
gen abstinext2cat=.
forval j=0/335 {
	local cat_var smoke_cat`j'
	local date_var smoke_date`j'
	
	qui replace abstinext2 = smoke_date`j' if (smoke_date`j' > abstinext1) & (`cat_var' !=.) & (abstinext2 ==.)
	qui replace abstinext2cat = smoke_cat`j' if (smoke_date`j' == abstinext2) & (`cat_var' !=.) 
	}
format %td abstinext2

gen abstinext3=.
gen abstinext3cat=.
forval j=0/335 {
	local cat_var smoke_cat`j'
	local date_var smoke_date`j'
	
	qui replace abstinext3 = smoke_date`j' if (smoke_date`j' > abstinext2) & (`cat_var' !=.) & (abstinext3 ==.)
	qui replace abstinext3cat = smoke_cat`j' if (smoke_date`j' == abstinext3) & (`cat_var' !=.) 
	}
format %td abstinext3

gen abstinext4=.
gen abstinext4cat=.
forval j=0/335 {
	local cat_var smoke_cat`j'
	local date_var smoke_date`j'
	
	qui replace abstinext4 = smoke_date`j' if (smoke_date`j' > abstinext3) & (`cat_var' !=.) & (abstinext4 ==.)
	qui replace abstinext4cat = smoke_cat`j' if (smoke_date`j' == abstinext4) & (`cat_var' !=.) 
	}
format %td abstinext4


gen abstinext5=.
gen abstinext5cat=.
forval j=0/335 {
	local cat_var smoke_cat`j'
	local date_var smoke_date`j'
	
	qui replace abstinext5 = smoke_date`j' if (smoke_date`j' > abstinext4) & (`cat_var' !=.) & (abstinext5 ==.)
	qui replace abstinext5cat = smoke_cat`j' if (smoke_date`j' == abstinext5) & (`cat_var' !=.) 
	}
format %td abstinext5



cap drop abstinence 

gen abstinence = . 
replace abstinence = 1 if (abstinext1cat == 0 | abstinext1cat ==1) & (abstinext2cat == 0 | abstinext2cat ==1) & (abstinext3cat == 0 | abstinext3cat ==1) 
replace abstinence = 1 if (abstinext1cat == 0 | abstinext1cat ==1) & (abstinext2cat == 0 | abstinext2cat ==1) & (abstinext3cat == .)
replace abstinence = 1 if (abstinext1cat == 0 | abstinext1cat ==1) & (abstinext2cat == . )
replace abstinence = 1 if abstinext1cat ==. & firstabsti !=. 

cap drop withinoneyear
gen withinoneyear=.
replace withinoneyear = 1 if firstabstitime < 365 & abstinence == 1

cap drop withintwoyears
gen withintwoyears = .
replace withintwoyears = 1 if firstabstitime >= 365 & firstabstitime < 730 & abstinence == 1
replace withintwoyears = 1 if withinoneyear == 1

cap drop withinthreeyears
gen withinthreeyears = . 
replace withinthreeyears = 1 if firstabstitime >= 730 & firstabstitime < 1095 & abstinence == 1
replace withinthreeyears = 1 if withintwoyears == 1

cap drop withinfouryears
gen withinfouryears = . 
replace withinfouryears = 1 if firstabstitime >= 1095 & firstabstitime < 1460 & abstinence == 1
replace withinfouryears = 1 if withinthreeyears == 1

cap drop withinfiveyears
gen withinfiveyears = . 
replace withinfiveyears = 1 if firstabstitime >= 1460 & firstabstitime < 1825 & abstinence == 1
replace withinfiveyears = 1 if withinfouryears == 1

cap drop withinsixyears
gen withinsixyears = . 
replace withinsixyears = 1 if firstabstitime >= 1825 & firstabstitime < 2190 & abstinence == 1
replace withinsixyears = 1 if withinfiveyears == 1

cap drop withinsevenyears
gen withinsevenyears = . 
replace withinsevenyears = 1 if firstabstitime >= 2190 & firstabstitime < 2555 & abstinence == 1
replace withinsevenyears = 1 if withinsixyears == 1

replace withinoneyear = 0 if withinoneyear ==.
replace withintwoyears = 0 if withintwoyears ==. 
replace withinthreeyears = 0 if withinthreeyears ==.
replace withinfouryears = 0 if withinfouryears ==.
replace withinfiveyears = 0 if withinfiveyears ==.
replace withinsixyears = 0 if withinsixyears ==. 
replace withinsevenyears=0 if withinsevenyears ==.

label define abstinence 0 "continued smoking" 1 "achieved abstinence"
label values withinoneyear withintwoyears withinthreeyears withinfouryears withinfiveyears withinsixyears withinsevenyears abstinence

label values abstinence abstinence

replace abstinence = 0 if firstabsti==.

replace firstabsti = mdy(12,31,2019) if firstabsti ==.
replace firstabstitime = firstabsti - stroke_date if firstabstitime ==.

replace abstinence = 1 if abstinence ==. 

gen smokingbaselinefinal = baseline_smoking
replace smokingbaselinefinal = 2 if withinoneyear == 0 

keep patid stroke_date firstabsti firstabstitime abstinence withinoneyear withintwoyears withinthreeyears withinfouryears withinfiveyears withinsixyears withinsevenyears 

drop _merge

save "Angela's coding\stroke smoking_only.dta", replace

use "Angela's coding\Stroke_final_smoking.dta", clear
merge 1:1 patid using "Angela's coding\stroke smoking_only.dta"
drop if _merge == 2
drop _merge

global covariates " i.QOFtime i.var_within_1_year i.bup_within_1_year i.NRT_within_1_year i.common_mental i.hypertension i.atrial_fib i.CCF i.asthma i.COPD i.type_1_d i.type_2_d i.terminal i.head_neck_cancer i.lung_cancer i.aff_psych i.nonaff_psych i.BMI_category i.ethriskid i.town_quintile i.sex1 i.cvd_drugs i.agegroup i.sha1"

