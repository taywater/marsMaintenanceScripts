# Script to back-up mars-data in PG14 database 
# Author: Farshad Ebrahimi and TGH, Last modified: 11/09/2023
# Version 3.0

## Set Up 1.0 ----
#Dplyr stuff
  library(magrittr)
  library(tidyverse)
  library(lubridate)

#Database Stuff
  library(odbc)

#Other stuff
  library(openssl)
  options(stringsAsFactors=FALSE)
  
#DB connection
  marsDBCon <- odbc::dbConnect(odbc::odbc(), "mars_data_pg14v2")
  
###Log: Start
logMessage <- data.frame(date = as.Date(today()), 
                         milestone = 1,
                         exit_code = NA,
                         note = "DB Connection Successful")

dbWriteTable(marsDBCon, DBI::SQL("log.tbl_script_backup"), logMessage, append = TRUE, row.names=FALSE)
  
## Back up the database 2.0 ----  
#which database to backup? what format?
  format_archive <- "c"
  format <- paste("--format=",format_archive, sep = "")
  database_archive <-"mars_data"
  db <- paste("--dbname=",shQuote(database_archive), sep ="")
  
#specify other details: the pathway to find pg_dump, where to save archive, naming format, database server specs, and username credentials  
  datestring <- Sys.time() %>% format("%Y%m%dT%H%M")
  extension <- "pgdump"
  filename <- paste0(datestring, "_", "mars_data", ".", extension)
  filepath <- paste0("\\\\pwdoows\\oows\\Watershed Sciences\\GSI Monitoring\\07 Databases and Tracking Spreadsheets\\18 MARS Database Back Up Files\\PG 14\\", filename)
  filepath <- shQuote(filepath)
  pg_dump <- Sys.getenv("pg_dump_exe")
  pg_dump <- shQuote(pg_dump)
  host <- "PWDMARSDBS1"
  host <- shQuote(host)
  port <- "5434" 
  port <- shQuote(port)
  username <- "mars_admin"
  username <- shQuote(username)
  role <- "mars_admin"
  role <- shQuote(role)
  
###Log: Start
logMessage <- data.frame(date = as.Date(today()), 
                         milestone = 2,
                         exit_code = NA,
                         note = "Initiating DB Backup")

dbWriteTable(marsDBCon, DBI::SQL("log.tbl_script_backup"), logMessage, append = TRUE, row.names=FALSE)
  
#Assemble the entire pg_dump string	
  pgdumpstring <- paste(pg_dump,
                        "--file",filepath,
                        "--host",host,
                        "--port", port,
                        "--username",username,
                        "--no-password",
                        "--role",role,
                        format,
                        db)
 # run the command line using system function 
  results_dump <- system(pgdumpstring, intern = TRUE, wait = FALSE)
  
###Log: Start
logMessage <- data.frame(date = as.Date(today()), 
                         milestone = 3,
                         exit_code = NA,
                         note = "DB Backup Complete")

dbWriteTable(marsDBCon, DBI::SQL("log.tbl_script_backup"), logMessage, append = TRUE, row.names=FALSE)
  
## Create a database to host the test DB 3.0 ----  

###Log: Start
logMessage <- data.frame(date = as.Date(today()), 
                         milestone = 4,
                         exit_code = NA,
                         note = "Creating Restoration DB")

dbWriteTable(marsDBCon, DBI::SQL("log.tbl_script_backup"), logMessage, append = TRUE, row.names=FALSE)
  #create db
  #testdbname <- paste(database_archive,"_","archivetest_",datestring, sep = "") longnames don't get recognize by pg_restore
  testdbname <- paste("backup", datestring, sep = "_")
  query_str <- "CREATE DATABASE %s WITH TEMPLATE = template0 OWNER = mars_admin"
  sql_query <- paste(sprintf(query_str,testdbname),collapse="")
  test_db <- dbSendQuery(marsDBCon, sql_query)
  
## Restore the archive ---- 4.0
  
  pg_restore <- Sys.getenv("pg_restore_exe")
  pg_restore <- shQuote(pg_restore)

  #Assemble the entire pg_restore string	
  pgrestorestring <- paste(pg_restore,
                        "--host",host,
                        "--port", port,
                        "--username",username,
                        "--no-password",
                        "--role",role,
                        "--jobs=5",
                        paste("--dbname=",shQuote(testdbname), sep=""),
                        filepath)
  results_restore <- system(pgrestorestring, intern = TRUE, wait = FALSE)
  
###Log: Restore end
logMessage <- data.frame(date = as.Date(today()), 
                         milestone = 5,
                         exit_code = NA,
                         note = "Restoration DB populated")

dbWriteTable(marsDBCon, DBI::SQL("log.tbl_script_backup"), logMessage, append = TRUE, row.names=FALSE) 
  
## Pruning old back ups
###Log: Prune Start
logMessage <- data.frame(date = as.Date(today()), 
                         milestone = 6,
                         exit_code = NA,
                         note = "Pruning old backups")

  #get a list of backup files  from the backup directory
  backups <- list.files("//pwdoows/oows/Watershed Sciences/GSI Monitoring/07 Databases and Tracking Spreadsheets/18 MARS Database Back Up Files/PG 14/", pattern = "*\\.pgdump", full.names=TRUE)

  #extract the backup date from the backup name and reformat it as Date
  backup_datestrings <- str_trunc(basename(backups),8, "right", ellipsis = "")
  Dates <- as.Date(backup_datestrings, format="%Y%m%d")
  
  #add the weekdays
  backup_dates <-as.data.frame(Dates)
  backup_dates$W_Days <- weekdays(backup_dates$Dates)
  backup_dates$M_Days<- day(backup_dates$Dates)
  backup_dates$Days_Ago <- as.Date(Sys.time() %>% format("%Y-%m-%d"))-backup_dates$Dates
  
  #get index of those rows that are older than 7 days, and are not day 28 or Friday
  delete_lastmonth <- which(backup_dates$Days_Ago > 6 & backup_dates$Days_Ago < 30 & backup_dates$W_Days !="Friday" & backup_dates$M_Days !=28)

  #prune the delete index 
  prune_result <- file.remove(backups[delete_lastmonth])

  ###Log: Prune wens
  logMessage <- data.frame(date = as.Date(today()), 
                           milestone = 7,
                           exit_code = NA,
                           note = "Old backups pruned")
    
    