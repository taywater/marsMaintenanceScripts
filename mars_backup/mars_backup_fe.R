# Script to back-up mars-testing database 
# Author: Farshad Ebrahimi, Last modified: 8/26/2022

#Dplyr stuff
  library(magrittr)
  library(tidyverse)
  library(lubridate)

#Database Stuff
  library(odbc)

#Other stuff
  library(openssl)
  options(stringsAsFactors=FALSE)
  
#which database to backup? what format?
  format_archive <- "c"
  format <- paste("--format=",format_archive, sep = "")
  database_archive <-"mars_testing"
  db <- paste("--dbname=",shQuote(database_archive), sep ="")
  
#specify other details: the pathway to find pg_dump, where to save archive, naming format, database server specs, and username credentials  
  datestring <- Sys.time() %>% format("%Y%m%dT%H%M")
  extension <- "pgdump"
  filename <- paste0(datestring, "_", "mars_testing", ".", extension)
  filepath <- paste0("C:\\Users\\Farshad.Ebrahimi\\Documents\\mars_backup\\", filename)
  filepath <- shQuote(filepath)
  pg_dump <- "C:\\Program Files\\pgAdmin 4\\v6\\runtime\\pg_dump.exe"
  pg_dump <- shQuote(pg_dump)
  host <- "PWDOOWSDBS"
  host <- shQuote(host)
  port <- "5433" 
  port <- shQuote(port)
  username <- "postgres"
  username <- shQuote(username)
  role <- "postgres"
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
  
  
