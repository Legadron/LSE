---

use "$data\matched_censusdata.dta" if largeareas==1, clear

generate treated_ = insee_dep
replace treated_ = 1 if insee_dep == 59
replace treated_ = 0 if insee_dep == 62

ta treated_

su

su if treated_==1
su if treated_==0


ttest ag0813_dis , by(treated_) unequal
* or reg ag0813_dis treated_, robust
ttest ag1318_dis , by(treated_) unequal
ttest ag0813_ser , by(treated_) unequal
ttest ag1318_ser , by(treated_) unequal

ttest agr0813dis , by(treated_) unequal
ttest agr1318dis , by(treated_) unequal
ttest agr0813ser , by(treated_) unequal
ttest agr1318ser , by(treated_) unequal

ttest dif_eff47 , by(treated_) unequal
ttest dif_eff56 , by(treated_) unequal
ttest rdif_eff47 , by(treated_) unequal
ttest rdif_eff56 , by(treated_) unequal

***

generate treated_ = 0
replace treated_ = 1 if dummy_int == 1

ta treated_

ttest _lol_ind , by(treated_) unequal
reg _lol_ind treated_, robust

ttest ind , by(treated_) unequal
reg ind treated_, robust

ttest ind , by(treated_) unequal
reg ind treated_, robust

ttest difpop1517 , by(treated_) unequal
reg difpop1517 treated_, robust

ttest rdipop1517 , by(treated_) unequal
reg rdipop1517 treated_, robust

reg rdipop1517 treated_ _lol_ind, robust






