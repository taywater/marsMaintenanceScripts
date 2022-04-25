# Script to back-up mars-testing database 
# Author: Farshad Ebrahimi, Last modified: 8/25/2022

#Dplyr stuff
  library(magrittr)
  library(tidyverse)
  library(lubridate)

#Database Stuff
  library(odbc)

#Other stuff
  library(openssl)
  options(stringsAsFactors=FALSE)
  
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
 
  #Assemble the entire pg_dump	
  pgdumpstring <- paste(pg_dump,
                        "--file",filepath,
                        "--host",host,
                        "--port", port,
                        "--username",username,
                        "--no-password",
                        "--role",role,
                        "--format=c",
                        '--dbname="mars_testing"')
  results_dump <- system(pgdumpstring, intern = TRUE, wait = FALSE)
  
  
