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

*Convert all may, june, jully and august data into stata file
import delimited mai, clear
sort date_heure
save "mai.dta", replace
import delimited juin, clear
sort date_heure
save "juin.dta", replace
import delimited juillet, clear
sort date_heure
save "juillet.dta", replace
import delimited aout, clear
sort date_heure
save "aout.dta", replace

*create a merged file
use mai
merge date_heure using juin
drop _merge
sort date_heure
merge date_heure using juillet
drop _merge
sort date_heure
merge date_heure using aout

save "merged.dta", replace

*sort by stop and time
sort stop date_heure

*regroup data by stop and calculate the sum of passin and passout
collapse (sum) passin passout, by(stop)

*calculation of the difference between entries and exits on the bus at each stop
gen difference = passin-passout
sort difference

save "merged_collapsed", replace

***differences between entries and exits by stop only for june
use juin
sort stop date_heure
collapse (sum) passin passout, by(stop)
gen difference = passin-passout
gen ratio_diff = difference/passin
sort ratio_diff

export delimited difference_entry_exit_stop_june


*** differences between entries and exits by line only for june
clear
use juin
sort stop date_heure
collapse (sum) passin passout, by(ligne)
gen difference = passin-passout
gen ratio_diff = difference/passin
sort ratio_diff

export delimited difference_entry_exit_line_june