library(lubridate)
library(knitr)

###Section 1: Set execution parameters
#Date string for filenames.
current_date = now()
datestring = format(current_date, "%Y%m%dT%H%M")

###Section 2: Run the R script that will generate the updates for the database
#We'll be calling this R script from within this python script
#We'll be composing a string that will be sent to the command line via a subprocess

folder = "//pwdoows/oows/Watershed Sciences/GSI Monitoring/07 Databases and Tracking Spreadsheets/13 MARS Analysis Database/PG14/PG14 Maintenance Scripts/Scripts/Update AccessDB Tables"
r_script = "update_accessdb_tables.rmd"
output = paste0("logs/", datestring, "_update_accessdb_tables.html")

rmarkdown::render(paste0(folder, "/", r_script), output_file = paste0(folder, "/", output))