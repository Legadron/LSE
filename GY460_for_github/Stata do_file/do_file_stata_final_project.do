clear

* First we will study several difference in differences regarding selected variables. Every time, we study the difference of the evolution of the variable between the CUD (Communauté Urbaine de Dunkerque) and the CAB (Comunauté d'agglomération du Boulonnais). 

* The variables used below are already processed as evolutions of a variable between two time period.


* Replace XXX by your directory
import delimited "XXX\GY460_for_github\data_final\EPCI_boulogne_dunkerque_for_stata.csv"

* We generate a dummy variable to help differentiate the treated (1) and the control (0) group
generate treated_ = insee_dep
replace treated_ = 1 if insee_dep == 59
replace treated_ = 0 if insee_dep == 62


* We just check that everything looks okay and that there is no issue with the data
ta treated_
su
su if treated_==1
su if treated_==0

* We are now able to process the difference in differences : because all our variables are already a difference between two time period, we just have to check the difference between the two groups : the CUD which is the treated group (treated = 1), and the CAB which is the control group (treated = 0) 

* With the first four ttest we want to confirm the parallel trend assumption we made between the CAB and the CUD intercommunalities by analysing the 2008-2013 period, before implementation of the FFPT policy.
ttest ag0813_dis , by(treated_) unequal 
ttest ag0813_ser , by(treated_) unequal
ttest agr0813dis , by(treated_) unequal
ttest agr0813ser , by(treated_) unequal

* We conduct our analysis, running four ttest for the 2013-2018 period on job in the distribution (ag1318_dis & agr1318dis) and local services (ag1318_ser & agr1318ser) sector 
ttest ag1318_dis , by(treated_) unequal
ttest ag1318_ser , by(treated_) unequal
ttest agr1318dis , by(treated_) unequal
ttest agr1318ser , by(treated_) unequal

* We reproduce the same thing but for the 2017-2019 period with the retail (dif_eff47 & rdif_eff47) and catering (dif_eff56 & dif_eff56) sector
ttest dif_eff47 , by(treated_) unequal
ttest dif_eff56 , by(treated_) unequal
ttest rdif_eff47 , by(treated_) unequal
ttest rdif_eff56 , by(treated_) unequal

***

* For the second part of the study, we will only be interested by the CUD. Each observation is a square of 200m by 200m with at least 11 people (minimal statistical information available). We will study the population change between squares within a 500m radius from the bus stop (treated group) and squares that are not within this 500m radius, in the rest of the CUD. 

* Replace XXX by your directory
import delimited"XXX\GY460_for_github\data_final\200m_squares_for_stata.csv", clear 

* We generate a dummy variable to help differenciate the treated (1) and the control (0) group
generate treated_ = 0
replace treated_ = 1 if dummy_int == 1

* We check how many variables will be treated or untreated
ta treated_

* We check if the living standards by individuals in 2017 is a variable we have to control for or not
ttest _lol_ind , by(treated_) unequal
* or reg _lol_ind treated_, robust

* We compare the population between the treated and the control group
ttest ind , by(treated_) unequal
* or reg ind treated_, robust

* We compare the evolution of this population both in absolute value and ratio
ttest difpop1517 , by(treated_) unequal
* or reg difpop1517 treated_, robust
ttest rdipop1517 , by(treated_) unequal
* or reg rdipop1517 treated_, robust

* We run the same analysis adding the living standards as a control variable 
reg rdipop1517 treated_ _lol_ind, robust