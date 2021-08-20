#update_planreview_tables_draft

#0.0 set up --------

#libraries
library(odbc)
library(tidyverse)
library(digest)

#db connections 
# greenit <- dbConnect(odbc(),
#                      Driver = "ODBC Driver 17 for SQL Server",  
#                      Server = "PWDSQLP2", 
#                      Database = "GreenIT", 
#                      uid = 'greenitvread', 
#                      pwd = 'pwd')

#db connections
planreview <- dbConnect(odbc(), 
                        Driver = "ODBC Driver 17 for SQL Server", 
                        Server = "pwdgis4", 
                        Database = "PWD_SWTracking", 
                        uid = 'swadmintesting', 
                        pwd = 'swadmin')


mars_data <- dbConnect(odbc(), "mars_data")

#1.0 query and hash -------
#1.1 query tables ------


 view_smp_designation <- dbGetQuery(planreview, "select * from View_SMP_Designation")

 crosstab <- dbGetQuery(planreview, "select * from view_smpsummary_crosstab_asbuiltall") %>% select(-Depaving)

#1.2 add hashes ----

  view_smp_designation_hash <- view_smp_designation %>% 
   rowwise() %>% 
   mutate("hash_md5" = digest(paste(`ProjectID`, `TrackingNumber`,  `SMPID`, `Designation`, `ProgramType`, `OOWProgramType`, `SMIP`, `GARP`), algo = "md5")) 

  crosstab_hash <- crosstab %>% 
    rowwise() %>% 
    mutate("hash_md5" = digest(paste(	`ProjectID`, `TrackingNumber`, `Projectname`, `SMPID`, `SMPType`, `Plan Label`, `Total Drainage Area`, `DCIA`, `Footprint`, `Loading Ratio`, `System Type`, `Location`, `Stone Storage Depth`, `Underdrain`, `Depth of Medium`, `Other - Pretreatment 1`, `Slow Release Volume`, `Static Storage`, `Water Quality Volume`, `Storage Material`, `Porous Material`, `Management Type`, `WQ Release Rate`, `Test Infiltration Rate`, `Orifice Diameter`, `Proprietary Rate Control`, `Effective Head`, `Drains To`, `Non-Regs`, `Brand Name`, `System Count`, `Rated WQ Flow Rate`, `CF Per Day`, `Tank Volume`, `Water Use`, `SW Credit`, `Total Pavement Disconnections`, `Existing Tree Credit Area`, `Number of New Trees`, `New Tree Credit Area`, `Planter Area`, `Number of Planters`, `Rooftop Area Disconnected`, `Confirmed`, `Last Modified By:`, `Date Modified:`), algo = "md5"))

  #1.3 initial WRITE ----
  
  #view_smp_designation
  dbWriteTable(mars_data, DBI::SQL("external.planreview_view_smp_designation"), view_smp_designation_hash, append= TRUE)

  #crosstab 
  dbWriteTable(mars_data, DBI::SQL("external.planreview_view_smpsummary_crosstab_asbuiltall"), crosstab_hash, append = TRUE)
  
  
  #2.0 get the data from greenit again (this is where maintenance script might start) -------
  #yes this is all the same but it makes sense linearly following the migration steps to do this
  #2.1 query tables ----
  view_smp_designation <- dbGetQuery(planreview, "select * from View_SMP_Designation")
  
  crosstab <- dbGetQuery(planreview, "select * from view_smpsummary_crosstab_asbuiltall") %>% select(-Depaving)

  #2.2 hash the plan review tables ----
  view_smp_designation_hash <- view_smp_designation %>% 
    rowwise() %>% 
    mutate("hash_md5" = digest(paste(`ProjectID`, `TrackingNumber`,  `SMPID`, `Designation`, `ProgramType`, `OOWProgramType`, `SMIP`, `GARP`), algo = "md5")) 
  
  crosstab_hash <- crosstab %>% 
    rowwise() %>% 
    mutate("hash_md5" = digest(paste(	`ProjectID`, `TrackingNumber`, `Projectname`, `SMPID`, `SMPType`, `Plan Label`, `Total Drainage Area`, `DCIA`, `Footprint`, `Loading Ratio`, `System Type`, `Location`, `Stone Storage Depth`, `Underdrain`, `Depth of Medium`, `Other - Pretreatment 1`, `Slow Release Volume`, `Static Storage`, `Water Quality Volume`, `Storage Material`, `Porous Material`, `Management Type`, `WQ Release Rate`, `Test Infiltration Rate`, `Orifice Diameter`, `Proprietary Rate Control`, `Effective Head`, `Drains To`, `Non-Regs`, `Brand Name`, `System Count`, `Rated WQ Flow Rate`, `CF Per Day`, `Tank Volume`, `Water Use`, `SW Credit`, `Total Pavement Disconnections`, `Existing Tree Credit Area`, `Number of New Trees`, `New Tree Credit Area`, `Planter Area`, `Number of Planters`, `Rooftop Area Disconnected`, `Confirmed`, `Last Modified By:`, `Date Modified:`), algo = "md5"))
  
  
  #2.3 query mars data tables -------
  view_smp_designation_md <- dbGetQuery(mars_data, "select * from external.planreview_view_smp_designation")
  
  crosstab_md <- dbGetQuery(mars_data, "select * from external.planreview_view_smpsummary_crosstab_asbuiltall")

  #2.4 compare and find new SMPs, system, and projects -----
  
  new_smps <- view_smp_designation_hash %>% anti_join(view_smp_designation_md, by = c("SMPID"))
  
  new_crosstab <- crosstab_hash %>%  anti_join(crosstab_md, by = c("SMPID")) 

  #2.5 write new records
  
  #view_smp_designation
  #dbWriteTable(mars_data, DBI::SQL("external.planreview_view_smp_designation"), new_smps, append= TRUE)
  
  #crosstab 
  #dbWriteTable(mars_data, DBI::SQL("external.planreview_view_smpsummary_crosstab_asbuiltall"), new_crosstab, append = TRUE)
  
  #2.6 query mars data tables again ----
  
  view_smp_designation_md <- dbGetQuery(mars_data, "select * from external.planreview_view_smp_designation")
  
  view_smp_designation_md_trim <- view_smp_designation_md %>% 
    dplyr::select(planreview_view_smp_designation_uid, `SMPID`)
  
  crosstab_md <- dbGetQuery(mars_data, "select * from external.planreview_view_smpsummary_crosstab_asbuiltall")
  
  crosstab_md_trim <- crosstab_md %>% 
    dplyr::select(planreview_view_smpsummary_crosstab_asbuiltall_uid, `SMPID`)
  
  #2.7 compare and find new HASHES based on smp, system, and projects -----
  
  #smp designation
  new_smp_hashes <- view_smp_designation_hash %>% 
    left_join(view_smp_designation_md_trim, by = "SMPID") %>% 
    anti_join(view_smp_designation_md, by = c("SMPID", "hash_md5"))
  
  #system
  new_crosstab_hashes <- crosstab_hash %>%
    left_join(crosstab_md_trim, by = "SMPID") %>%
    anti_join(crosstab_md, by = c("SMPID", "hash_md5")) 

  #2.8 write/update new stuff 
  #2.8.1 SMP designation -----
  #write update query
  update_smp <- dbSendQuery(mars_data, 'update external.planreview_view_smp_designation set ProjectID=?, TrackingNumber=?,  SMPID=?, Designation=?, ProgramType=?, OOWProgramType=?, SMIP=?, GARP=?, hash_md5=? WHERE planreview_view_smp_designation_uid=?')
  
  # send the updated data
  dbBind(update_smp, new_smp_hashes)
  
  #release the prepared statement
  dbClearResult(update_smp)  

  #2.8.2 crosstab-----
  #write update query
  update_crosstab <- dbSendQuery(mars_data, 'update external.planreview_view_smpsummary_crosstab_asbuiltall set "ProjectID"=?, "TrackingNumber"=?, "Projectname"=?, "SMPID"=?, "SMPType"=?, "Plan Label"=?, "Total Drainage Area"=?, "DCIA"=?, "Footprint"=?, "Loading Ratio"=?, "System Type"=?, "Location"=?, "Stone Storage Depth"=?, "Underdrain"=?, "Depth of Medium"=?, "Other - Pretreatment 1"=?, "Slow Release Volume"=?, "Static Storage"=?, "Water Quality Volume"=?, "Storage Material"=?, "Porous Material"=?, "Management Type"=?, "WQ Release Rate"=?, "Test Infiltration Rate"=?, "Orifice Diameter"=?, "Proprietary Rate Control"=?, "Effective Head"=?, "Drains To"=?, "Non-Regs"=?, "Brand Name"=?, "System Count"=?, "Rated WQ Flow Rate"=?, "CF Per Day"=?, "Tank Volume"=?, "Water Use"=?, "SW Credit"=?, "Total Pavement Disconnections"=?, "Existing Tree Credit Area"=?, "Number of New Trees"=?, "New Tree Credit Area"=?, "Planter Area"=?, "Number of Planters"=?, "Rooftop Area Disconnected"=?, "Confirmed"=?, "Last Modified By:"=?, "Date Modified:", hash_md5=? where planreview_view_smpsummary_crosstab_asbuiltall_uid=?')
  
  # send the updated data
  dbBind(update_crosstab, new_crosstab_hashes)
  
  #release the prepared statement
  dbClearResult(update_crosstab) 
  