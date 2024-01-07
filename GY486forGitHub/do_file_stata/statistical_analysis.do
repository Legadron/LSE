*statistical analysis
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

*use the file with both the census and ridership data
use data_prepared_for_regression2


*preparation of the dataset 
replace express = 0 if express == .

sort passin

*delete the 3 hubs of the network
drop if inlist(stop, "LEFFRINCKOUCKE FORT DES DUNES", "DUNKERQUE GARE", "GRANDE SYNTHE PUYTHOUCK")
gen lol = ind_snv_su/ind_sum
*lol stands for Level of Life (aka Standards of living) (in euros per individual per year)

*group the population by age in 4 class
egen minor = rowtotal(ind_0_3_su ind_4_5_su ind_6_10_s ind_11_17_)
egen youth = rowtotal(ind_18_24_ ind_25_39_)
egen senior = rowtotal(ind_40_54_ ind_55_64_)
egen old = rowtotal(ind_65_79_ ind_80p_su)

gen rminor = minor/ind_sum
gen ryouth = youth/ind_sum
gen rsenior = senior/ind_sum
gen rold = old/ind_sum

*save
save data_prepared_for_regression3, replace

* summarize the independant variable
asdoc summarize ind_sum men_sum lol log_soc_su rminor ryouth rsenior rold express disttogare alti, replace

* summarize the dependant variable
asdoc summarize passin passout passin_05_09 passin_10_14 passin_15_19 passin_20_23 passout_05_09 passout_10_14 passout_15_19 passout_20_23 passin_express passout_express rexpress 

*run regressions of independant variables on dependant variables according to our hypothesis
asdoc regress passin ind_sum, robust nest replace setstars(*@.05, **@.01, ***@.001)
asdoc regress passin_05_09 ind_sum, robust nest append
asdoc regress passin express, robust nest append
asdoc regress passin_05_09 express, robust nest append
asdoc regress passin ind_sum express, robust nest append
asdoc regress passin_05_09 ind_sum express, robust nest append


asdoc regress passin_10_14 ind_sum express, robust nest replace
asdoc regress passin_15_19 ind_sum express, robust nest append
asdoc regress passin_20_23 ind_sum express, robust nest append
asdoc regress passout_05_09 ind_sum express, robust nest append
asdoc regress passout_10_14 ind_sum express, robust nest append
asdoc regress passout_15_19 ind_sum express, robust nest append
asdoc regress passout_20_23 ind_sum express, robust nest append


asdoc regress passin_05_09 ind_sum express rminor, robust nest replace
asdoc regress passin_05_09 ind_sum express ryouth, robust nest append
asdoc regress passin_05_09 ind_sum express rsenior, robust nest append
asdoc regress passin_05_09 ind_sum express rold, robust nest append
asdoc regress passin_05_09 ind_sum express ryouth rold, robust nest append
asdoc regress passin_05_09 ind_sum express lol disttogare, robust nest append
asdoc regress passin_05_09 ind_sum express log_soc_su lol disttogare, robust nest append

*trial to see if altitude has an effect on diff in boardings/alightings. If not, it may not be shown in the final dissertation.
asdoc regress rexpress alti1, robust nest

*calculate the residuals for map representation
regress passin_05_09 ind_sum express, robust
predict residuals, residuals
sort residuals

*export before inclusion in QGIS
export delimited "return_for_qgis2"


