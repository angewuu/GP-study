*analysis plan created with Rafael :) 

*To start we are going to look at the impact of intervention offered on smoking cessation at year 1 and then at year 5. What that means is that I need to I need to create a binary yes no for year 1 abstinence and year 5 abstinence. 
cd "P:\OX57"
use "Angela's coding\CHD_Analysis.dta", clear


global covariates " i.QOFtime i.var_within_1_year i.bup_within_1_year i.NRT_within_1_year i.common_mental i.hypertension i.atrial_fib i.CCF i.asthma i.COPD i.type_1_d i.type_2_d i.terminal i.head_neck_cancer i.lung_cancer i.aff_psych i.nonaff_psych i.BMI_category i.ethriskid i.town_quintile i.sex1 i.cvd_drugs i.agegroup i.sha1"


replace oneyearsmokecat = 1 if oneyearsmokecat ==0
gen oneyearsmokemissing = oneyearsmokecat
replace oneyearsmokecat = 2 if oneyearsmokecat ==.


*withinoneyear and withinfiveyears demonstrate abstinence 
logistic withinoneyear intervention_offered $covariates
logistic withinfiveyears intervention_offered $covariates

logistic withinoneyear advice_within_1_year $covariates
logistic withinoneyear drug_within_1_year  $covariates
logistic withinoneyear referral_within_1_year $covariates
logistic withinoneyear brief_within_1_year $covariates
logistic withinoneyear counselling_within_1_year $covariates

bysort common_mental: logistic withinoneyear intervention_offered $covariates
bysort common_mental: logistic withinfiveyears intervention_offered $covariates

bysort QOFtime: logistic withinoneyear intervention_offered $covariates
bysort QOFtime: logistic withinfiveyears intervention_offered $covariates


logistic withinoneyear i.counselling_within_1_year i.brief_within_1_year i.referral_within_1_year i.general_within_1_year i.drug_within_1_year i.advice_within_1_year $covariates

logistic withinfiveyears i.counselling_within_1_year i.brief_within_1_year i.referral_within_1_year i.general_within_1_year i.drug_within_1_year i.advice_within_1_year $covariates

corr counselling_within_1_year brief_within_1_year referral_within_1_year general_within_1_year drug_within_1_year advice_within_1_year



*Next we look at the Kaplan Meier 
cap drop time_since_entry
cap drop MACEtime

gen time_since_entry = onsdateofdeath - chd_date
gen MACEtime = MACE - chd_date

sum time_since_entry, d
sum MACEtime, d

stset time_since_entry, id(patid) failure(cvd_death)
sts graph, by (intervention_offered)
graph export cvdcvddeath.png
sts graph, by (withintwoyears)

stset time_since_entry, id(patid) failure(all_cause_mortality)
sts graph, by (intervention_offered)
graph export cvdalldeath.png

stset MACEtime, id(patid) failure(MACEfail)
sts graph, by (intervention_offered)
graph export cvdMACE.png


*Generating time year 5 because significant drop off in population after year 5
cap drop fiveyearfailure
gen fiveyearfailure = .
replace fiveyearfailure = 1 if time_since_entry > 1825
replace fiveyearfailure = 0 if fiveyearfailure == . 

gen time_since_entryfive = time_since_entry
replace time_since_entryfive = 1825 if  fiveyearfailure ==1 

gen all_cause_five = 1 if all_cause_mortality == 1 & fiveyearfailure == 0 
replace all_cause_five = 0 if all_cause_five ==. 

gen cvd_five = 1 if cvd_death ==1 & fiveyearfailure ==0 
replace cvd_five = 0 if cvd_five ==. 

cap drop fiveyearMACE
gen fiveyearMACE =.
replace fiveyearMACE = 1 if MACEtime > 1825
replace fiveyearMACE = 0 if fiveyearMACE==.

gen fiveyearMACEtime = MACEtime
replace fiveyearMACEtime = 1825 if fiveyearMACE ==1

cap drop MACE_five
gen MACE_five = 1 if MACEfail == 1 & fiveyearMACE==0
replace MACE_five = 0 if MACE_five==. 

*looking at time year 10 

cap drop tenyearfailure
gen tenyearfailure = .
replace tenyearfailure = 1 if time_since_entry > 3650
replace tenyearfailure = 0 if tenyearfailure == . 

gen time_since_entryten = time_since_entry
replace time_since_entryten = 3650 if  tenyearfailure ==1 

gen all_cause_ten = 1 if all_cause_mortality == 1 & tenyearfailure == 0 
replace all_cause_ten = 0 if all_cause_ten ==. 

gen cvd_ten = 1 if cvd_death ==1 & tenyearfailure ==0 
replace cvd_ten = 0 if cvd_ten ==. 

cap drop tenyearMACE
gen tenyearMACE =.
replace tenyearMACE = 1 if MACEtime > 3650
replace tenyearMACE = 0 if tenyearMACE==.

gen tenyearMACEtime = MACEtime
replace tenyearMACEtime = 3650 if tenyearMACE ==1

cap drop MACE_ten
gen MACE_ten = 1 if MACEfail == 1 & tenyearMACE==0
replace MACE_ten = 0 if MACE_ten==. 




























*Calculating the COX regression for year 5 data


stset time_since_entryfive, id(patid) failure(cvd_five)
sts graph, by (intervention_offered)
sts test intervention_offered, cox
stcox i.intervention_offered withinoneyear $covariates
estat phtest, detail
* not passed but not effective
stphplot, by (intervention_offered)
graph export lnlncvdcvddeath5.png

*repeating but for all cause mortality
stset time_since_entryfive, id(patid) failure (all_cause_five)
sts graph, by (intervention_offered)
sts test intervention_offered, cox
sts test withinoneyear, cox
stcox i.intervention_offered withinoneyear $covariates
estat phtest, detail
*still not passing the PH test and effective but opposite direction. intervention meant more likely to die. Also something else could be happening, makes sense though for an intervention to have greater impact on CVD rather than all cause
stphplot, by (intervention_offered)
graph export lnlncvdallcausedeath5.png


*MACE at 5 years
stset fiveyearMACEtime, id(patid) failure (MACE_five)
sts graph, by (intervention_offered)
sts test intervention_offered, cox
stcox i.intervention_offered withinoneyear $covariates
estat phtest, detail
*still no pass the PHTest and effective, intervention means less likely to get MACE
stphplot, by (intervention_offered)
graph export lnlncvdMACE5.png

*looking for people by mental health too  
stset time_since_entryfive, id(patid) failure (cvd_five)
bysort common_mental: stcox i.intervention_offered withinoneyear $covariates
estat phtest, detail

*now let's do logistic regression at years 1 and years 5 as a progression especially as for MACE and all_cause_mortality PH was not met
*generating one year as I've already done 5 year above
cap drop oneyearfailure
gen oneyearfailure = .
replace oneyearfailure = 1 if time_since_entry > 365
replace oneyearfailure = 0 if oneyearfailure == . 

gen time_since_entryone = time_since_entry
replace time_since_entryone = 365 if  oneyearfailure ==1 

gen all_cause_one = 1 if all_cause_mortality == 1 & oneyearfailure == 0 
replace all_cause_one = 0 if all_cause_one ==. 

gen cvd_one = 1 if cvd_death ==1 & oneyearfailure ==0 
replace cvd_one = 0 if cvd_one ==. 

cap drop oneyearMACE
gen oneyearMACE =.
replace oneyearMACE = 1 if MACEtime > 365
replace oneyearMACE = 0 if oneyearMACE==.

gen oneyearMACEtime = MACEtime
replace oneyearMACEtime = 365 if oneyearMACE ==1

cap drop MACE_one
gen MACE_one = 1 if MACEfail == 1 & oneyearMACE==0
replace MACE_one = 0 if MACE_one==. 


*logistic regression now looking at cvd outcomes for year 1 and year 5. I don't think one year really makes sense, the number of observations are so low... but maybe, i dunno
logistic cvd_one intervention_offered withinoneyear $covariates
logistic cvd_five intervention_offered withinoneyear $covariates 

* .8641273 very similar to cox regression for 5 years

*MACE one and five
logistic MACE_one intervention_offered withinoneyear $covariates 

logistic MACE_five intervention_offered withinoneyear $covariates 


*All cause mortality 

logistic all_cause_one intervention_offered withinoneyear $covariates

logistic all_cause_five intervention_offered  withinoneyear $covariates 

*Now we do IV analysis 
*creating IV 
sort study_practice chd_date
quietly by study_practice: gen visit_order = cond(_N==1,0,_n)
bysort study_practice (visit_order): gen prior_intervention =intervention_offered[_n-1]

*five year CVD test of endog 
regress prior_intervention intervention_offered
ivregress 2sls cvd_five (intervention_offered=prior_intervention) withinoneyear $covariates ,robust
estat endog
estat firststage

*oneyear CVD test of endog 
ivregress 2sls cvd_one (intervention_offered=prior_intervention) withinoneyear $covariates ,robust
estat endog
estat firststage

* one year abstinence
ivregress 2sls withinoneyear (intervention_offered=prior_intervention) $covariates ,robust
estat endog
estat firststage

*five year abstinence
ivregress 2sls withinfiveyears (intervention_offered=prior_intervention) $covariates ,robust
estat endog
estat firststage

*five year death test
ivregress 2sls all_cause_five (intervention_offered=prior_intervention) withinoneyear $covariates ,robust
estat endog
estat firststage

*oneyeardeath 
ivregress 2sls all_cause_one (intervention_offered=prior_intervention) withinoneyear $covariates ,robust
estat endog
estat firststage

*five year MACE endog 
ivregress 2sls MACE_five (intervention_offered=prior_intervention) withinoneyear $covariates ,robust
estat endog
estat firststage

*one year MACE endog
ivregress 2sls MACE_one (intervention_offered=prior_intervention) withinoneyear $covariates ,robust
estat endog
estat firststage

*NOW just need to do sensitivity analysis whereby I remove people who get an intervention in years 2-5. Need to calculate that. 

cap drop interafteryearone
gen interafteryearone = .
replace interafteryearone = 1 if (yeartwofre > 0 | yearthreefre > 0 | yearfourfre > 0 | yearfivefre > 0) & yearonefre == 0
replace interafteryearone = 0 if interafteryearone ==. 

tab interafteryearone, m

save "Angela's coding\CHD_Analysis.dta", replace

use "Angela's coding\CHD_Analysis.dta", clear
*sensitivity now for cox 5 year only running for those people who didn't get 
keep if interafteryearone == 0
stset time_since_entryfive, id(patid) failure (cvd_five)
sts test intervention_offered, cox
stcox i.intervention_offered withinoneyear $covariates
estat phtest, detail
*omg it's no longer not passing the PH test and effective 
stphplot, by (intervention_offered)
graph export lnlncvdcvd5sensitivity.png

*sensitivity for all cause mortality
stset time_since_entryfive, id(patid) failure (all_cause_five)
sts graph, by (intervention_offered)
sts test intervention_offered, cox
stcox i.intervention_offered withinoneyear $covariates
estat phtest, detail
stphplot, by (intervention_offered)
graph export lnlncvdall5sensitivity.png
*sensitivity for 5 year MACE removing those who were offered interventions in years 2 - 5
stset fiveyearMACEtime, id(patid) failure (MACE_five)
sts graph, by (intervention_offered)
sts test intervention_offered, cox
stcox i.intervention_offered withinoneyear $covariates
estat phtest, detail
stphplot, by (intervention_offered)
graph export lnlncvdMACE5sensitivity.png


* Sensitivity for after QOF time
use "Angela's coding\CHD_Analysis.dta", clear

keep if QOF == 1
*sensitivity now for cox 5 year 

stset time_since_entryfive, id(patid) failure (cvd_five)
sts test intervention_offered, cox
stcox i.intervention_offered withinoneyear $covariates
estat phtest, detail
*omg it's no longer not passing the PH test and effective 
stphplot, by (intervention_offered)
graph export lnlncvdcvd5QOF.png

*sensitivity for all cause mortality
stset time_since_entryfive, id(patid) failure (all_cause_five)
sts graph, by (intervention_offered)
sts test intervention_offered, cox
stcox i.intervention_offered withinoneyear $covariates
estat phtest, detail
stphplot, by (intervention_offered)
graph export lnlncvdall5QOF.png
*sensitivity for 5 year MACE 
stset fiveyearMACEtime, id(patid) failure (MACE_five)
sts graph, by (intervention_offered)
sts test intervention_offered, cox
stcox i.intervention_offered withinoneyear $covariates
estat phtest, detail
stphplot, by (intervention_offered)
graph export lnlncvdMACE5QOF.png

*sensitivity splitting out intervention types
use "Angela's coding\CHD_Analysis.dta", clear

stset time_since_entry, id(patid) failure(cvd_death)
sts graph, by (advice_within_1_year)
sts graph, by (drug_within_1_year)
sts graph, by (referral_within_1_year)
sts graph, by (counselling_within_1_year)
sts graph, by (brief_within_1_year)
sts test advice_within_1_year , cox
sts test drug_within_1_year, cox
sts test referral_within_1_year, cox
sts test counselling_within_1_year, cox
sts test brief_within_1_year, cox
stcox i.drug_within_1_year withinoneyear $covariates
estat phtest, detail
stcox i.advice_within_1_year withinoneyear $covariates
estat phtest, detail
stcox i.referral_within_1_year withinoneyear $covariates
estat phtest, detail

logistic cvd_five advice_within_1_year withinoneyear $covariates 
logistic cvd_five drug_within_1_year withinoneyear $covariates 
logistic cvd_five brief_within_1_year withinoneyear $covariates 