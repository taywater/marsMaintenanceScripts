library(lubridate)
library(knitr)

###Section 1: Set execution parameters
#Date string for filenames.
current_date = now()
datestring = format(current_date, "%Y%m%dT%H%M")

###Section 2: Run the R script that will generate the updates for the database
#We'll be composing a string that will be sent to the command line via a subprocess

folder = "C:/Users/taylor.heffernan.wa/Documents/marsMaintenanceScripts/01_database_backup"
r_script = "mars_backup_pg14.R"

source(paste0(folder, "/", r_script))
