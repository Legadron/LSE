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

*import data by lines
import delimited par_lignes

* Rename variables
rename v1 week_number
rename v2 day_of_the_week
rename v3 exact_date
rename v4 Bus_line
rename v5 passenger

*check primary statistics
browse
summarize

***to get the number of passenger per line per weekday/weekend

*separate Weekdays and Weekends
gen exact_date2 = date(exact_date, "YMD")
gen number_of_the_day = dow(exact_date2)

gen type_of_day = "Weekend" if number_of_the_day == 0 | number_of_the_day == 6
replace type_of_day = "Weekday" if number_of_the_day >= 1 & number_of_the_day <= 5

***keep only the data for which we have a full week available. We do kkep the data between the 2021-08-23 and the 2022-08-14
drop if exact_date2 <= 22514
drop if exact_date2 >= 22872
*the data for the last week of the year are complete, but labeled "53" for the last 4 days before january 2022. 
replace week_number = 1 if week_number == 53

*generate ridership data per week
egen passengers_total_week = total(passenger), by(week_number)
*generate ridership data per day for a certain week
gen passengers_day_week = passengers_total_week /7
*pass_tod correspond to the total number of passenger for the weekdays and for the weekends within a certain week
egen pass_tod = total(passenger), by(week_number type_of_day)
*generate 2 variables for the number of passenger per day of weekday and per day of weekend within a certain week
gen pass_weekday = pass_tod/5 if number_of_the_day >= 1 & number_of_the_day <= 5
gen pass_weekend = pass_tod/2 if number_of_the_day == 0 | number_of_the_day == 6

*creation of a file with only one raw for each week
collapse (mean) passengers_day_week pass_weekday pass_weekend, by(week_number)

*ajust the week_number for 1 to start on 2021-08-23 and 51 to end on 2022-08-14
gen store_week = week_number
replace week_number = week_number + 52 if week_number <= 34
replace week_number = week_number - 34
sort week_number

* Création of the graph	
twoway (line passengers_day_week week_number, ///
        title(Average ridership per day for each week) ///
        ytitle(Number of passengers) ///
        xtitle(Week number (between 2021-08-23 and 2022-08-14)) ///
        sort) ///
       (line pass_weekday week_number, ///
        color(red) ///
        sort) ///
       (line pass_weekend week_number, ///
        color(black) ///
        sort) ///
       , xline(41 45)

graph export "ridership_year.svg", replace



