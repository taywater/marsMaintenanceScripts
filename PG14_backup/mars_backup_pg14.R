# Script to back-up mars-data in PG14 database 
# Author: Farshad Ebrahimi, Last modified: 11/14/2022

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
  con <- odbc::dbConnect(odbc::odbc(), "mars_data_pg14")
  
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
  filepath <- paste0("C:\\Users\\Farshad.Ebrahimi\\Documents\\mars_backup\\", filename)
  filepath <- shQuote(filepath)
  pg_dump <- "C:\\Program Files\\pgAdmin 4\\v6\\runtime\\pg_dump.exe"
  pg_dump <- shQuote(pg_dump)
  host <- "PWDOOWSDBS"
  host <- shQuote(host)
  port <- "5434" 
  port <- shQuote(port)
  username <- "mars_admin"
  username <- shQuote(username)
  role <- "mars_admin"
  role <- shQuote(role)
  
  
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
  
## Create a database to host the test DB 3.0 ----  

  #create db
  #testdbname <- paste(database_archive,"_","archivetest_",datestring, sep = "") longnames don't get recognize by pg_restore
  testdbname <- "pgrestore"
  query_str <- "CREATE DATABASE %s WITH TEMPLATE = template0 OWNER = mars_admin"
  sql_query <- paste(sprintf(query_str,testdbname),collapse="")
  test_db <- dbSendQuery(con, sql_query)
  
## Restore the archive ---- 4.0
  
  pg_restore <- "C:\\Program Files\\pgAdmin 4\\v6\\runtime\\pg_restore.exe"
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
  
  
## Pruning old back ups
  #get a list of backup files  from the backup directory
  backups <- list.files("C:\\Users\\Farshad.Ebrahimi\\Documents\\mars_backup")
  backup_pathway <- paste("C:\\Users\\Farshad.Ebrahimi\\Documents\\mars_backup", backups, sep = "\\")
  
  #extract the backup date from the backup name and reformat it as Date
  backup_datestrings <- str_trunc(backups,8, "right", ellipsis = "")
  Dates <- as.Date(backup_datestrings, format="%Y%m%d")
  
  #add the weekdays
  backup_dates <-as.data.frame(Dates)
  backup_dates$W_Days <- weekdays(backup_dates$Dates)
  backup_dates$M_Days<- day(backup_dates$Dates)
  backup_dates$Days_Ago <- as.Date(Sys.time() %>% format("%Y-%m-%d"))-backup_dates$Dates
  
  #get index of those rows that are older than 7 days, and are not day 28 or Friday
  delete_lastmonth <- which(backup_dates$Days_Ago > 6 & backup_dates$Days_Ago < 30 & backup_dates$W_Days !="Friday" & backup_dates$M_Days !=28)
  delete_older <- which(backup_dates$Days_Ago > 29 & backup_dates$M_Days !=28)
  
  #prune the delete index 
  prune_result <- file.remove(backup_pathway[c(delete_lastmonth,delete_older)])

    
    
    
    