library(odbc)
library(tidyverse)
library(digest)
#library(logr) logs to come later

# ODBC Connection to CIPIT
cipit <- dbConnect(odbc(),
    Driver = "ODBC Driver 17 for SQL Server", 
    Server = "PWDCIPSQLR", 
    Database = "CIPITREADER", 
    uid = 'cipreadonly', 
    pwd = 'cipread')

mars <- dbConnect(odbc(), "mars_data")

cipit_project_query <- 'select _Work_Number as work_number, _Project_Phase as project_phase, _Project_Phase_Status as project_phase_status, _Project_Title as project_title, _Targeted_Bid_FY as targeted_bid_fy, PC_NTP_Date as pc_ntp_date, CONST_Construction_Start_Date as construction_start_date, DESIGN_Design_Engineer as design_engineer, CONST_Division_Engineer as division_engineer, CONST_Contractor as contractor, ProjectAutoID as projectautoid, CONST_Substantially_Complete_Date as construction_complete_date, CONST_Contract_Close_Date as contract_closed_date from Project'
cipit_project <- dbGetQuery(cipit, cipit_project_query)

cipit_project$targeted_bid_fy <- as.numeric(cipit_project$targeted_bid_fy)

cipit_project_hash <- cipit_project %>%
    unite("temp", remove = FALSE) %>%
    rowwise() %>%
    mutate(md5hash = digest(temp, algo = 'md5')) %>%
    select(-temp)

cipit_project_db <- dbGetQuery(mars, "select * from external.cipit_project")
cipit_project_anti <- anti_join(cipit_project_hash, cipit_project_db)
cipit_project_new <- filter(cipit_project_anti,!(work_number %in% cipit_project_db$work_number))
dbWriteTable(mars, DBI::SQL("external.cipit_project"), cipit_project_new, append = TRUE)
cipit_project_update = anti_join(cipit_project_anti, cipit_project_new) %>%
    left_join(select(cipit_project_db, cipit_project_uid, work_number))

if(nrow(cipit_project_update) > 0){
    update_cipit_project <- dbSendQuery(mars, 'update external.cipit_project set work_number=?, project_phase=?, project_phase_status=?, project_title=?, targeted_bid_fy=?, pc_ntp_date=?, construction_start_date=?, design_engineer=?, division_engineer=?, contractor=?, projectautoid=?, construction_complete_date=?, contract_closed_date=?, md5hash=? where cipit_project_uid=?')
    dbBind(update_cipit_project, cipit_project_update)
    dbClearResult(update_cipit_project)
} 

