* Setup environment
clear all
cap program drop _all
set more off
set maxvar 8000
set matsize 10000
cap log close

*Setup directory
cd"your directory"

*Check that the directory has been changed
pwd

***we work only with june2022 data in the do-file bellow, but the same do-file is usable for any other month
use juin
browse


* keep only the hours of the day
gen hour = substr(date_heure, 12, length(date_heure) - 25)


* Calculate total passin and passout per stop per hour
egen total_passin = total(passin), by(stop hour)
egen total_passout = total(passout), by(stop hour)


* Genereate the total for entry and exit by hour by stop
collapse (sum) passin passout, by(stop hour)


* Use the reshape command to obtain a variable (column) by hour
reshape wide passin passout, i(stop) j(hour) string

*regroup in 4 intra-day period (5amto10am; 10amto3pm; 3pmto8pm ; after 8pm(until end of service))
egen passin_05_09 = rowtotal(passin05 passin06 passin07 passin08 passin09)
egen passin_10_14 = rowtotal(passin10 passin11 passin12 passin13 passin14)
egen passin_15_19 = rowtotal(passin15 passin16 passin17 passin18 passin19)
egen passin_20_23 = rowtotal(passin20 passin21 passin22 passin23)
egen passin = rowtotal (passin_05_09 passin_10_14 passin_15_19 passin_20_23)

egen passout_05_09 = rowtotal(passout05 passout06 passout07 passout08 passout09)
egen passout_10_14 = rowtotal(passout10 passout11 passout12 passout13 passout14)
egen passout_15_19 = rowtotal(passout15 passout16 passout17 passout18 passout19)
egen passout_20_23 = rowtotal(passout20 passout21 passout22 passout23)
egen passout = rowtotal (passout_05_09 passout_10_14 passout_15_19 passout_20_23)

keep stop passin_05_09 passin_10_14 passin_15_19 passin_20_23 passout_05_09 passout_10_14 passout_15_19 passout_20_23 passin passout

* Generate ratio for the 4 intra-day period (5amto10am; 10amto3pm; 3pmto8pm ; after 8pm(until end of service)) to obtain the proportion of movements during the period
gen rpassin_05_09 = passin_05_09 / passin
gen rpassin_10_14 = passin_10_14 / passin
gen rpassin_15_19 = passin_15_19 / passin
gen rpassin_20_23 = passin_20_23 / passin
gen rpassout_05_09 = passout_05_09 / passout
gen rpassout_10_14 = passout_10_14 / passout
gen rpassout_15_19 = passout_15_19 / passout
gen rpassout_20_23 = passout_20_23 / passout

* we are not interested in data from the depot, and we decided to drop the stop without passenger
drop if stop == "DEPOT AUTOBUS" 
drop if stop == "DEPOT CARIANE DUNKERQUE"

drop if passin == 0
sort stop

*save
save "entry_exit_stop", replace




***extract the data only for express lines
clear
use juin
drop if ligne != "C1" & ligne != "C2" & ligne != "C3" & ligne != "C4" & ligne != "C5"
sort stop date_heure

*regroup data by stop and calculate the sum of passin and passout only for express lines
collapse (sum) passin passout, by(stop)
gen express = 1
gen diff_express = passin-passout
gen rexpress = diff_express/passin
rename passin passin_express
rename passout passout_express


drop if stop == "DEPOT AUTOBUS" 
drop if passin_express == 0
sort stop

*save
save "express", replace


*merge the two files created
use entry_exit_stop
merge stop using express
drop _merge
sort stop
browse

save "data_for_reg", replace

***group the new data created with qgis data

* Setup environment
clear all
cap program drop _all
set more off
set maxvar 8000
set matsize 10000
cap log close

*Setup directory
cd"your directory"

*Check that the directory has been changed
pwd

*import data extracted with qgis
import delimited qgis_file_for_stata2
rename nom_arret stopnameinshapefile
rename good_names stop
sort stop
save qgis_file_for_stata2, replace


merge stop using data_for_reg
drop _merge
sort stop


*save
save data_prepared_for_regression2, replace
