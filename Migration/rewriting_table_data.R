#querying old tables from PG9 and writing them to PG12 

#starting with pg9 fieldwork.ow_all -> pg12 fieldwork.ow

#0.0 set up -----
  
  #0.1 libraries ----
  library(odbc)
  library(tidyverse)
  
  #0.2 mars testing connection (OLD) ----
  mars_testing <- dbConnect(odbc(), "mars_testing")
  
  dbListTables(mars_testing)
  
  #0.3 mars data connnection (NEW) -----
  mars_data <- dbConnect(odbc(), "mars_data")
  
  dbListTables(mars_data)
  
#1.0 querying, modifying, and writing tables ----
  
  #1.1 fieldwork.ow
  #this needs to come first so we can add foreign constraints to other tables regarding ow_uid 
  old_fieldwork_ow <- dbGetQuery(mars_testing, "select * from fieldwork.ow_all")


  #don't forget to restart sequence at some point! 
  dbWriteTable(mars_data,  DBI::SQL("fieldwork.ow"), old_fieldwork_ow, append = TRUE)

  #check that it wrote successfully 
  new_fieldwork_ow <- dbGetQuery(mars_data, "select * from fieldwork.ow")
  