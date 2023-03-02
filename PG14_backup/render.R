#This script is written to run the .rmd file for backing up PG14
library(rmarkdown)
library(dplyr)
#The html report file name
datestring <- Sys.time() %>% format("%Y%m%dT%H%M")
report_name <- paste(datestring,".html", sep="")

#Pandoc render script
Sys.setenv(RSTUDIO_PANDOC = 'C:\\Program Files\\RStudio\\bin\\quarto\\bin\\pandoc')
rmarkdown::render(
  input = "C:\\Users\\Farshad.Ebrahimi\\OneDrive - City of Philadelphia\\Github Projects\\pg14backup\\PG14_Backup.Rmd",
  output_file = paste("\\\\pwdoows\\oows\\Watershed Sciences\\GSI Monitoring\\07 Databases and Tracking Spreadsheets\\18 MARS Database Back Up Files\\PG 14\\Reports\\", report_name, sep = ""),
  output_dir = "\\\\pwdoows\\oows\\Watershed Sciences\\GSI Monitoring\\07 Databases and Tracking Spreadsheets\\18 MARS Database Back Up Files\\PG 14\\Reports"
)