capture log using "/Users/jensenxu/Desktop/stata_clone/Model.log", replace
use "/Users/jensenxu/Desktop/2011Census/nhs2011_pumf.dta"

*Clean up the data
*Use WAGES from a tab deliminated file to get rid of scientific notations
merge 1:1 _n using "/Users/jensenxu/Desktop/2011Census/wages.dta"
drop WAGES
rename WAGES_N WAGES
*Drop unavailable data
*Drop WAGES = 0 ang 1 for taking log later
drop if WAGES == 0 | WAGES == 1 | WAGES == 8888888 | WAGES == 9999999 | WAGES == .
*Take natural log
gen lnWAGES = log(WAGES)

*Generate a binary indicator for gender
gen FEMALE = (SEX == 1)
tab SEX
label list SEX
*Label the new dummy
label define femaleLAB 1 "Female" 0 "Male"
label values FEMALE femaleLAB
label variable FEMALE "Female"

*Check if the indicator has been defined correctly
tab SEX FEMALE			
*Do the similar to other variables

*COW 
*This is not a variable in the model but needs to be modified for sampling restrction
*Drop unavailable observations
drop if COW == 7 | COW == 8
*Exclude self-employed
drop if COW != 1

*AGEGRP
label list AGEGRP
*Drop observations who are under legal working age
drop if AGEGRP <= 5
*Note: WAGES == 0 | 1 overlaps the under working-age population, so we may see "0 obs droped" in this step
*Drop unavailable observations from AGEGRP
drop if AGEGRP == 22 | AGEGRP == .
*Create a numerical variable for age, taking values of the rounded median of AGEGRP
gen AGE = 16
replace AGE = 19 if AGEGRP == 7
replace AGE = 22 if AGEGRP == 8
replace AGE = 27 if AGEGRP == 9
replace AGE = 32 if AGEGRP == 10
replace AGE = 37 if AGEGRP == 11
replace AGE = 42 if AGEGRP == 12
replace AGE = 47 if AGEGRP == 13
replace AGE = 52 if AGEGRP == 14
replace AGE = 57 if AGEGRP == 15
replace AGE = 62 if AGEGRP == 16
replace AGE = 67 if AGEGRP == 17
replace AGE = 72 if AGEGRP == 18
replace AGE = 77 if AGEGRP == 19
replace AGE = 82 if AGEGRP == 20
replace AGE = 85 if AGEGRP == 21
label variable AGE "Age"

*Variables for robustness check
gen FEM_AGE = FEMALE*AGE
label variable FEM_AGE "Female*Age"
gen AGE_2 = AGE^2
label variable AGE_2 "Age^2"
gen FEM_AGE_2 = FEMALE*AGE_2
label variable FEM_AGE_2 "Female*Age^2"
************************************************
*Create a variable for potential experience

*I plan to use potential experience in my formal model, age will be used for robustness check
*potential experience = age - years of education - 6, years of education is the expected length of each degree, 6 represents the expected age in the first year of school
gen SCHOOLYRS = .
replace SCHOOLYRS = 11 if HDGREE == 1
replace SCHOOLYRS = 12 if HDGREE == 2
replace SCHOOLYRS = 16 if HDGREE == 3 | HDGREE == 4 |HDGREE == 9
replace SCHOOLYRS = 13 if HDGREE == 5
replace SCHOOLYRS = 14 if HDGREE == 6 | HDGREE == 7 | HDGREE == 8
replace SCHOOLYRS = 17 if HDGREE == 10
replace SCHOOLYRS = 21 if HDGREE == 11 | HDGREE == 13
replace SCHOOLYRS = 18 if HDGREE == 12
gen POTENEXP = AGE - SCHOOLYRS - 6
label variable POTENEXP "Potential experience"
*A negative value is most likely to mean that the individual finished the degree faster than expected
*Drop these negative potential experiences because they don't fit in the context
drop if POTENEXP <= 0 | POTENEXP == . 

*Create a quadratic term
gen POTENEXP_2 = POTENEXP^2
label variable POTENEXP_2 "Potential experience^2"
*Create interactions
gen FEM_POTENEXP = FEMALE*POTENEXP
label variable FEM_POTENEXP "Female*Potential experience"
gen FEM_POTENEXP_2 = FEMALE*POTENEXP_2
label variable FEM_POTENEXP_2 "Female*Potential experience^2"
*************************************************


****************************************
*Dummies for having children

*Drop unavailable data from PKID's
label list PKID6_14
drop if PKID6_14 == 3 | PKID6_14 == . | PKID6_14 == 4
label list PKID2_5
drop if PKID2_5 == 3 | PKID2_5 == . | PKID2_5 == 4
label list PKID0_1
drop if PKID0_1 == 3 | PKID0_1 == . | PKID0_1 == 4
label list PKID15_24
drop if PKID15_24 == 3 | PKID15_24 == . | PKID15_24 == 4
*Create a dummy for each type of children one has
gen INFANT = 0
replace INFANT = 1 if PKID0_1 == 2
gen PRESCHOOLER = 0
replace PRESCHOOLER = 1 if PKID2_5 == 2
gen SCHOOLAGE = 0
replace SCHOOLAGE = 1 if PKID6_14 == 2
gen YOUTH = 0
replace YOUTH = 1 if PKID15_24 == 2
*Create labels
label define childlab 0 "None" 1 "One or more"
label values INFANT childlab
label values PRESCHOOLER childlab
label values SCHOOLAGE childlab
label values YOUTH childlab
label variable INFANT "Infant"
label variable PRESCHOOLER "preschooler"
label variable SCHOOLAGE "school-age children"
label variable YOUTH "Youth-age children" 
*Interact with gender
gen FEM_INFANT = FEMALE*INFANT
label variable FEM_INFANT "Female*Infant"
gen FEM_PRESCHOOLER = FEMALE*PRESCHOOLER
label variable FEM_PRESCHOOLER "Female*Preschooler"
gen FEM_SCHOOLAGE = FEMALE*SCHOOLAGE
label variable FEM_SCHOOLAGE "Female*Schoolage"
gen FEM_YOUTH = FEMALE*YOUTH
label variable FEM_YOUTH "Female*Youth"
*******************************************

*drop unavailable data
label list HDGREE
drop if HDGREE == 14 | HDGREE == 15 | HDGREE == .

*NAICS
*drop unavailable observations
label list NAICS
drop if NAICS == 19 | NAICS == 21 | NAICS == .

*PR
drop if PR == .

*WKSWRK
*Drop those who have never worked in 2010 and are under legal working age.
drop if WKSWRK == 8 | WKSWRK == . | WKSWRK == 1
*Take the rounded median of each category to make a numercial variable for length of work
gen WEEKWRK = 5
replace WEEKWRK = 15 if WKSWRK == 3
replace WEEKWRK = 25 if WKSWRK == 4
replace WEEKWRK = 35 if WKSWRK == 5
replace WEEKWRK = 44 if WKSWRK == 6
replace WEEKWRK = 51 if WKSWRK == 7
label variable WEEKWRK "weeks worked in 2010"

*MARSTH
*Create a dummy for marital status
drop if MARSTH == .
gen MARRIED = 0
replace MARRIED = 1 if MARSTH == 2 | MARSTH == 4
label variable MARRIED "Married"
label define MARRIEDlab 0 "not married" 1 "married"
label values MARRIED MARRIEDlab
*Interact with gender
gen FEM_MAR = FEMALE*MARRIED
label variable FEM_MAR "Female*Married"

*Visible minority
*get rid off unavailable data
drop if VISMIN == 88 | VISMIN == .
*create a dummy for visible minority
gen MINORITY = 1
replace MINORITY = 0 if VISMIN == 13
label define minlab 1 "Visible minority" 0 "Not a visible minority"
label values MINORITY minlab
label variable MINORITY "Visible minority"
*Interacts with gender
gen FEM_MIN = FEMALE*MINORITY
label variable FEM_MIN "Female*Minority"

*Descriptive statistics
summ lnWAGES FEMALE FEM_POTENEXP FEM_POTENEXP_2 FEM_MAR FEM_INFANT FEM_PRESCHOOLER FEM_SCHOOLAGE FEM_YOUTH FEM_MIN INFANT PRESCHOOLER SCHOOLAGE YOUTH MARRIED POTENEXP POTENEXP_2 i.NAIC i.HDGREE i.PR WEEKWRK MINORITY

*Fit a regression model
reg lnWAGES FEMALE FEM_POTENEXP FEM_POTENEXP_2 FEM_MAR FEM_INFANT FEM_PRESCHOOLER FEM_SCHOOLAGE FEM_YOUTH FEM_MIN INFANT PRESCHOOLER SCHOOLAGE YOUTH MARRIED POTENEXP POTENEXP_2 MINORITY i.NAIC i.HDGREE i.PR WEEKWRK
estimates store model_int

outreg2 using "myoutreg.xls", replace ctitle(Model1) label dec(3)

*Robustness check
summ lnWAGES FEMALE FEM_AGE FEM_AGE_2 FEM_MAR FEM_INFANT FEM_PRESCHOOLER FEM_SCHOOLAGE FEM_YOUTH FEM_MIN INFANT PRESCHOOLER SCHOOLAGE YOUTH MARRIED AGE AGE_2 i.NAIC i.HDGREE i.PR WEEKWRK MINORITY

reg lnWAGES FEMALE FEM_AGE FEM_AGE_2 FEM_MAR FEM_INFANT FEM_PRESCHOOLER FEM_SCHOOLAGE FEM_YOUTH FEM_MIN INFANT PRESCHOOLER SCHOOLAGE YOUTH MARRIED AGE AGE_2 MINORITY i.NAIC i.HDGREE i.PR WEEKWRK

outreg2 using "myoutreg.xls", append ctitle(Model2) label dec(3)

log close

