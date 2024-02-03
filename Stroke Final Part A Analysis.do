*To start we are going to look at the impact of intervention offered on smoking cessation at year 1 and then at year 5. What that means is that I need to I need to create a binary yes no for year 1 abstinence and year 5 abstinence. 
cd "P:\OX57"
use "Angela's coding\dataset\stroke_merged_interventions.dta", clear

label values cvd_drugs prescription
replace ethriskid = 999 if ethriskid ==.
replace town_quintile = 0 if town_quintile ==.
drop if town_quintile == 0

replace drug_within_1_year = 1 if buproprion_within_1_year == 1 
replace drug_within_1_year = 1 if nrt_within_1_year == 1 

drop nrt_within_1_year buproprion_within_1_year

cap drop time_since_entry
gen time_since_entry = onsdateofdeath - stroke_date
gen MACEtime = MACE - stroke_date

drop if time_since_entry < 0
drop if MACEtime < 0

replace MACE =. if MACE > date("2019-12-31", "YMD") 
replace MACE =  date("2019-12-31", "YMD")  if MACE ==.

replace onsdateofdeath =. if onsdateofdeath > date("2019-12-31", "YMD")
replace onsdateofdeath = date("2019-12-31", "YMD") if onsdateofdeath ==. 

replace cvd_death = 0 if onsdateofdeath == date("2019-12-31", "YMD") 
replace all_cause_mortality = 0 if onsdateofdeath == date("2019-12-31", "YMD") 

save "Angela's coding\Stroke_final_smoking.dta", replace
use "Angela's coding\Stroke_final_smoking.dta", clear
merge 1:1 patid using "Angela's coding\stroke smoking_only.dta"
drop if _merge == 2
drop _merge

keep patid stroke_date onsdeathrecord onsdateofdeath cvd_death all_cause_mortality counselling_within_1_year brief_within_1_year drug_within_1_year referral_within_1_year general_within_1_year  advice_within_1_year intervention_offered stroke_op_date chd_op_date first_stroke_after MACE first_CHD_after common_mental sex1 study_practice sha1 town_quintile ethriskid yearofbirth exitdate thiazide loop_diuretics potass_diuretics potass_diuretics_extra beta_blockers ace arb calcium oral_anti_coagulants antiplatelets hyperlipidaemia statins lipid_drugs antianginals mono_dini hypertension atrial_fib CCF asthma COPD type_1_d type_2_d terminal head_neck_cancer lung_cancer aff_psych nonaff_psych MACEfail BMI_category cvd_drugs agegroup yearonefre yeartwofre yearthreefre yearfourfre yearfivefre QOFtime firstabsti firstabstitime withinoneyear withintwoyears withinthreeyears withinfouryears withinfiveyears withinsixyears withinsevenyears abstinence var_within_1_year bup_within_1_year NRT_within_1_year drug_within_1_year newinter2 newinter3 newinter4 newinter5 oneyearsmokecat


save "Angela's coding\Stroke_Analysis.dta", replace

use "Angela's coding\Stroke_Analysis.dta", clear

*creating Table 1s and split by the different groups
table1, vars (withinoneyear cat\ abstinence cat\ intervention_offered cat\ MACEfail cat\var_within_1_year cat \ bup_within_1_year cat\ NRT_within_1_year cat\ cvd_death cat\ all_cause_mortality cat\ common_mental cat\ sex1 cat\ agegroup cat\ QOFtime cat\ sha1 cat\ town_quintile cat\ ethriskid cat\ cvd_drugs cat\ BMI_category cat\nonaff_psych cat\ aff_psych cat\ lung_cancer cat\ head_neck_cancer cat\ terminal cat\ type_2_d cat\ type_1_d cat\ COPD cat\ asthma cat\ CCF cat\ atrial_fib cat\ hypertension cat\ )format (%8.2f) onecol saving(stroke_descriptive.xlsx, sheet(overall,replace))

table1, vars (withinoneyear cat\ abstinence cat\ intervention_offered cat\ var_within_1_year cat \ bup_within_1_year cat \ NRT_within_1_year cat \ cvd_death cat \ all_cause_mortality cat \MACEfail cat\ sex1 cat \ agegroup cat\ QOFtime cat\ sha1 cat\ town_quintile cat\ ethriskid cat\ cvd_drugs cat\ BMI_category cat\nonaff_psych cat\ aff_psych cat\ lung_cancer cat\ head_neck_cancer cat\ terminal cat\ type_2_d cat\ type_1_d cat\ COPD cat\ asthma cat\ CCF cat\ atrial_fib cat\ hypertension cat\ ) by (town_quintile) format (%8.2f) onecol saving(stroke_descriptive.xlsx, sheet(town_quintile,replace))

table1, vars (withinoneyear cat\ abstinence cat\ intervention_offered cat\ var_within_1_year cat \ bup_within_1_year cat \ NRT_within_1_year cat \ cvd_death cat \ all_cause_mortality cat \MACEfail cat\ sex1 cat \ agegroup cat\ QOFtime cat\ sha1 cat\ town_quintile cat\ ethriskid cat\ cvd_drugs cat\ BMI_category cat\nonaff_psych cat\ aff_psych cat\ lung_cancer cat\ head_neck_cancer cat\ terminal cat\ type_2_d cat\ type_1_d cat\ COPD cat\ asthma cat\ CCF cat\ atrial_fib cat\ hypertension cat\ ) by (QOF) format (%8.2f) onecol saving(stroke_descriptive.xlsx, sheet(QOF,replace))

table1, vars (withinoneyear cat\ abstinence cat\ intervention_offered cat\ var_within_1_year cat \ bup_within_1_year cat \ NRT_within_1_year cat \ cvd_death cat \ all_cause_mortality cat \ MACEfail cat\sex1 cat \ agegroup cat\ QOFtime cat\ sha1 cat\ town_quintile cat\ ethriskid cat\ cvd_drugs cat\ BMI_category cat\nonaff_psych cat\ aff_psych cat\ lung_cancer cat\ head_neck_cancer cat\ terminal cat\ type_2_d cat\ type_1_d cat\ COPD cat\ asthma cat\ CCF cat\ atrial_fib cat\ hypertension cat\ ) by (cvd_death) format (%8.2f) onecol saving(stroke_descriptive.xlsx, sheet(cvd_death,replace))

table1, vars (withinoneyear cat\ abstinence cat\ intervention_offered cat\ var_within_1_year cat \ bup_within_1_year cat \ NRT_within_1_year cat \ cvd_death cat \ all_cause_mortality cat \MACEfail cat\ sex1 cat \ agegroup cat\ QOFtime cat\ sha1 cat\ town_quintile cat\ ethriskid cat\ cvd_drugs cat\ BMI_category cat\nonaff_psych cat\ aff_psych cat\ lung_cancer cat\ head_neck_cancer cat\ terminal cat\ type_2_d cat\ type_1_d cat\ COPD cat\ asthma cat\ CCF cat\ atrial_fib cat\ hypertension cat\ ) by (all_cause_mortality) format (%8.2f) onecol saving(stroke_descriptive.xlsx, sheet(all_cause_mortality,replace))

table1, vars (withinoneyear cat\ abstinence cat\ intervention_offered cat\ var_within_1_year cat \ bup_within_1_year cat\ NRT_within_1_year cat\ cvd_death cat\ all_cause_mortality cat\ MACEfail cat\common_mental cat\ sex1 cat\ agegroup cat\ QOFtime cat\ sha1 cat\ town_quintile cat\ ethriskid cat\ cvd_drugs cat\ BMI_category cat\nonaff_psych cat\ aff_psych cat\ lung_cancer cat\ head_neck_cancer cat\ terminal cat\ type_2_d cat\ type_1_d cat\ COPD cat\ asthma cat\ CCF cat\ atrial_fib cat\ hypertension cat\ )by (common_mental) format (%8.2f) onecol saving(stroke_descriptive.xlsx, sheet(mental_health,replace))

table1, vars (withinoneyear cat\ abstinence cat\ intervention_offered cat\ var_within_1_year cat \ bup_within_1_year cat\ NRT_within_1_year cat\ cvd_death cat\ all_cause_mortality cat\ MACEfail cat\common_mental cat\ sex1 cat\ agegroup cat\ QOFtime cat\ sha1 cat\ town_quintile cat\ ethriskid cat\ cvd_drugs cat\ BMI_category cat\nonaff_psych cat\ aff_psych cat\ lung_cancer cat\ head_neck_cancer cat\ terminal cat\ type_2_d cat\ type_1_d cat\ COPD cat\ asthma cat\ CCF cat\ atrial_fib cat\ hypertension cat\ ) by (withinoneyear) format (%8.2f) onecol saving(stroke_descriptive.xlsx, sheet(withinoneyear,replace))

table1, vars (withinoneyear cat\ abstinence cat\ intervention_offered cat\ var_within_1_year cat \ bup_within_1_year cat\ NRT_within_1_year cat\ cvd_death cat\ all_cause_mortality cat\MACEfail cat\ common_mental cat\ sex1 cat\ agegroup cat\ QOFtime cat\ sha1 cat\ town_quintile cat\ ethriskid cat\ cvd_drugs cat\ BMI_category cat\nonaff_psych cat\ aff_psych cat\ lung_cancer cat\ head_neck_cancer cat\ terminal cat\ type_2_d cat\ type_1_d cat\ COPD cat\ asthma cat\ CCF cat\ atrial_fib cat\ hypertension cat\ ) by (intervention_offered) format (%8.2f) onecol saving(stroke_descriptive.xlsx, sheet(intervention_offered,replace))

table1, vars ( counselling_within_1_year cat\ brief_within_1_year cat\ referral_within_1_year cat\ general_within_1_year cat\ drug_within_1_year cat\   advice_within_1_year cat\) format (%8.2f) onecol saving(stroke_intervention_descriptive.xlsx, sheet(overall,replace))

table1, vars ( counselling_within_1_year cat\ brief_within_1_year cat\ referral_within_1_year cat\ general_within_1_year cat\ drug_within_1_year cat\   advice_within_1_year cat\) by(withinoneyear) format (%8.2f) onecol saving(stroke_intervention_descriptive.xlsx, sheet(withinoneyear,replace))

table1, vars ( counselling_within_1_year cat\ brief_within_1_year cat\ referral_within_1_year cat\ general_within_1_year cat\ drug_within_1_year cat\   advice_within_1_year cat\)by(cvd_death) format (%8.2f) onecol saving(stroke_intervention_descriptive.xlsx, sheet(cvd_death,replace))

table1, vars ( counselling_within_1_year cat\ brief_within_1_year cat\ referral_within_1_year cat\ general_within_1_year cat\ drug_within_1_year cat\   advice_within_1_year cat\)by(QOFtime) format (%8.2f) onecol saving(stroke_intervention_descriptive.xlsx, sheet(QOF,replace))

table1, vars ( counselling_within_1_year cat\ brief_within_1_year cat\ referral_within_1_year cat\ general_within_1_year cat\ drug_within_1_year cat\   advice_within_1_year cat\) by(withinoneyear) format (%8.2f) onecol saving(stroke_intervention_descriptive.xlsx, sheet(withinoneyear,replace))

table1, vars ( counselling_within_1_year cat\ brief_within_1_year cat\ referral_within_1_year cat\ general_within_1_year cat\ drug_within_1_year cat\   advice_within_1_year cat\) by(town_quintile) format (%8.2f) onecol saving(stroke_intervention_descriptive.xlsx, sheet(town_quintile,replace))

table1, vars ( counselling_within_1_year cat\ brief_within_1_year cat\ referral_within_1_year cat\ general_within_1_year cat\ drug_within_1_year cat\   advice_within_1_year cat\) by(common_mental) format (%8.2f) onecol saving(stroke_intervention_descriptive.xlsx, sheet(common_mental,replace))

table1, vars ( counselling_within_1_year cat\ brief_within_1_year cat\ referral_within_1_year cat\ general_within_1_year cat\ drug_within_1_year cat\   advice_within_1_year cat\) by(nonaff_psych) format (%8.2f) onecol saving(stroke_intervention_descriptive.xlsx, sheet(nonaff_psych,replace))

table1, vars ( counselling_within_1_year cat\ brief_within_1_year cat\ referral_within_1_year cat\ general_within_1_year cat\ drug_within_1_year cat\   advice_within_1_year cat\) by(aff_psych) format (%8.2f) onecol saving(stroke_intervention_descriptive.xlsx, sheet(aff_psych,replace))

table1, vars ( counselling_within_1_year cat\ brief_within_1_year cat\ referral_within_1_year cat\ general_within_1_year cat\ drug_within_1_year cat\   advice_within_1_year cat\)by(QOFtime) format (%8.2f) onecol saving(stroke_intervention_descriptive.xlsx, sheet(QOF,replace))

*counting the frequency that interventions in general are offered
bysort abstinence: tab town_quintile

sum yeartwofre, detail
sum yearthreefre , detail
sum yearfourfre , detail
sum yearfivefre, detail
sum yearonefre , detail


*now let's see how often people get approached in terms of their first time getting smoking cessation intervention 
tab newinter2
tab newinter3
tab newinter4 
tab newinter5

*  comparing each intervention type at year one to abstinence for five years

tab withinoneyear counselling_within_1_year, chi2 row
tab withinoneyear  brief_within_1_year, chi2 row
tab withinoneyear  referral_within_1_year ,chi2 row
tab withinoneyear general_within_1_year ,chi2 row
tab withinoneyear  drug_within_1_year ,chi2 row
tab withinoneyear  advice_within_1_year,chi2 row
tab withinoneyear intervention_offered, chi2 row

tab withintwoyears counselling_within_1_year,chi2  row
tab withintwoyears  brief_within_1_year,chi2  row
tab withintwoyears  referral_within_1_year ,chi2  row
tab withintwoyears general_within_1_year ,chi2  row
tab withintwoyears  drug_within_1_year ,chi2  row
tab withintwoyears  advice_within_1_year,chi2  row
tab withintwoyears intervention_offered, chi2 row

tab withinthreeyears  counselling_within_1_year,chi2  row
tab withinthreeyears  brief_within_1_year,chi2  row
tab withinthreeyears  referral_within_1_year ,chi2  row
tab withinthreeyears  general_within_1_year ,chi2  row
tab withinthreeyears  drug_within_1_year ,chi2  row
tab withinthreeyears  advice_within_1_year,chi2  row
tab withinthreeyears intervention_offered, chi2 row

tab withinfouryears counselling_within_1_year,chi2  row
tab withinfouryears  brief_within_1_year,chi2  row
tab withinfouryears  referral_within_1_year ,chi2  row
tab withinfouryears general_within_1_year ,chi2  row
tab withinfouryears  drug_within_1_year ,chi2  row
tab withinfouryears  advice_within_1_year,chi2  row
tab withinfouryears intervention_offered, chi2 row

tab withinfiveyears counselling_within_1_year,chi2  row
tab withinfiveyears  brief_within_1_year,chi2  row
tab withinfiveyears  referral_within_1_year ,chi2  row
tab withinfiveyears general_within_1_year ,chi2  row
tab withinfiveyears  drug_within_1_year ,chi2  row
tab withinfiveyears  advice_within_1_year,chi2  row
tab withinfiveyears intervention_offered, chi2 row

tab abstinence counselling_within_1_year,chi2  row
tab abstinence  brief_within_1_year,chi2  row
tab abstinence  referral_within_1_year ,chi2  row
tab abstinence general_within_1_year ,chi2  row
tab abstinence  drug_within_1_year ,chi2  row
tab abstinence  advice_within_1_year,chi2  row
tab abstinence intervention_offered, chi2 row

tab town_quintile abstinence

