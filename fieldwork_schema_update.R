#fieldwork schema migration
#Written by: Brian Cruice
#Written on: 11/1-11/2/2022

#Note: much of this code is predicated on the assumption of the primary key of a
#table is stored within the first column of that table. Any alteration to that
#assumption would render this code effectively useless. This is something to
#eventually correct, but seems unnecssary for the time being.


##### 0.1 Packages, operators #####

library(odbc)
library(tidyverse)
library(lubridate)
library(magrittr)
library(digest)

# check variables

truncate_new_tables <- FALSE
seriously <- TRUE

# Define "not in" operator
`!%in%` <- negate(`%in%`)

##### 1.0 Reading data ##### 
# read table of matching schemas between pg9 and pg14
# a local csv version of the migration table available on onedrive
# in the "migration "Migration Table Key" tab
# https://phila-my.sharepoint.com/:x:/g/personal/brian_cruice_phila_gov/EYCmRB4mOKNGnYGaQQO5CeIBJv6t1F9nQmVUvwL4hTACew?e=wwxkqk

  schema_relations <- read.csv("C:/users/brian.cruice/Desktop/schema_relations.csv")

# Limit to fieldwork pg14 schema
# This skips the 

  fieldwork_schema <- schema_relations %>% dplyr::filter(PG.14.Schema == "fieldwork")
  
  #remove one new table
  fieldwork_schema %<>% dplyr::filter(PG9.schema.table != "" &
                                      PG14.schema.table != "")

# 1.1 Read pg9/14 data
# Connect to both databases
  pg9_con <- dbConnect(odbc(), "mars_testing")
  pg14_con <- dbConnect(odbc(), "mars_data_pg14")
  
  
# Query fx's for readin' and writin'
  #query function

  #read pg9
  pg9_select_query <- function(table){
    dbGetQuery(pg9_con,paste0("SELECT * FROM ",table))
  }
  
# read pg14
  pg14_select_query <- function(table){
    dbGetQuery(pg14_con,paste0("SELECT * FROM ",table))
  }
  
  
  
# lapply functions to list the tables and read

  pg9_tables <- lapply(fieldwork_schema$PG9.schema.table, pg9_select_query)
  pg14_tables <- lapply(fieldwork_schema$PG14.schema.table, pg14_select_query)
  
##### 2.0 Data management: Adding names, grabbing metadata for later use #####  
# add names to list tables
  
  names(pg9_tables) <- fieldwork_schema$PG9.schema.table
  names(pg14_tables) <- fieldwork_schema$PG14.schema.table
  
# grab list of data types and constraints for each table. This will be used when constructing UPDATE and INSERT INTO queries

  #pg14 data grab fx
  pg14_data_type_query <- function(table){
    dbGetQuery(pg14_con, paste0("SELECT data_type FROM information_schema.columns WHERE table_name = '", table,"'"))
  }

  pg14_table_data_type <- lapply(fieldwork_schema$PG.14.Table, pg14_data_type_query)
  #names
  names(pg14_table_data_type) <- fieldwork_schema$PG14.schema.table

    
    
##### 3.0 Use hash tables and functions to check for which records new == old #####
  
  # specific check
  # here we need to round(4) some storm sizes in the srt table for pg9 so hashes are equal!
  pg9_tables$fieldwork.srt$srt_stormsize_in <- round(pg9_tables$fieldwork.srt$srt_stormsize_in, 4)
  # and then we need to check in on the NA values
  
  # create hash function
  hash_table <- function(table){
    data.frame(uid = table[,1], hash = apply(table, 1, digest))
  }  
  
  # create hash tables
  pg9_hashes  <- lapply(pg9_tables, hash_table)
  pg14_hashes <- lapply(pg14_tables, hash_table)
  
 
##### 4.0 Make lists of records to be altered, removed, and added #####
    
  # 4.1: CHANGED RECORDS
  #record any differences between pg9 and pg14
  altered_entries <- list()
  for(i in 1:length(pg9_hashes)){
    # altered_entries[[i]] <- anti_join(old_table_hashes[[i]],new_table_hashes[[i]], by = "hash")

    # find values where pg9_hash != pg14_hash
    x <- anti_join(pg9_hashes[[i]],pg14_hashes[[i]], by = "hash")
    # remove values where pg9 entries are NEW
    x <- dplyr::filter(x, uid %in% pg14_hashes[[i]]$uid)
    
    # associate uids with pg9 values
    y <- dplyr::filter(pg9_tables[[i]], !!as.name(colnames(pg9_tables[[i]])[1]) %in% x$uid)
    colnames(y) <- colnames(pg14_tables[[i]])
    altered_entries[[i]] <- y
  }
  # add names to select order and prevent fkey constraints
  names(altered_entries) <- fieldwork_schema$PG14.schema.table
  
  #report new values
  report_altered <- vector()
  for(i in 1:length(altered_entries)){
    report_altered[i] <- paste0("There are ",nrow(altered_entries[[i]])," entries within ",names(pg9_tables)[i]," with changes to update within ",names(pg14_tables)[i],".")
    print(report_altered[i])
  }
  
  # 4.2: NEW RECORDS  
  #record any NEWLY ADDED values from pg9 to bring into pg14
  new_entries <- list()
  for(i in 1:length(pg9_hashes)){
    #find uids in pg9 and NOT in pg14
    x <- anti_join(pg9_hashes[[i]],pg14_hashes[[i]], by = "uid")
    
    # associate uids with pg9 values    
    y <- dplyr::filter(pg9_tables[[i]], !!as.name(colnames(pg9_tables[[i]])[1]) %in% x$uid)
    
    # add table to list
    new_entries[[i]] <- y
  }
  # add names to select order and prevent fkey constraints (i.e. write tbl_ow first) 
  names(new_entries) <- fieldwork_schema$PG14.schema.table
  
  # new order
  new_entries_names_ordered <- c(names(new_entries)[18],names(new_entries)[1:17],names(new_entries)[19:36])
  new_entries <- new_entries[new_entries_names_ordered]
  
  #report new values
  report_new <- vector()
  for(i in 1:length(new_entries)){
    report_new[i] <- paste0("There are ",nrow(new_entries[[i]])," NEW entries within ",names(pg9_tables)[i]," to write to ",names(pg14_tables)[i],".")
    print(report_new[i])
  }
  
  # RECORDS TO REMOVE
  remove_entries <- list()
  for(i in 1:length(pg9_hashes)){

    # find uids in pg14 and NOT in pg14
    x <- anti_join(pg14_hashes[[i]],pg9_hashes[[i]], by = "uid")
    
    # associate uids with pg14 values    
    y <- dplyr::filter(pg14_tables[[i]], !!as.name(colnames(pg14_tables[[i]])[1]) %in% x$uid)
    
    # add table to list
    remove_entries[[i]] <- y
  }
  # add names to select order and prevent fkey constraints
  names(remove_entries) <- fieldwork_schema$PG14.schema.table
  
  
  #report values to remove
  report_remove <- vector()
  for(i in 1:length(new_entries)){
    report_remove[i] <- paste0("There are ",nrow(remove_entries[[i]])," entries within ",names(pg14_tables)[i]," to remove.")
    print(report_remove[i])
  }
  

  
##### 5.0 Queries to ALTER, ADD, AND REMOVE ROWS #####
  
  # 5.1: REMOVE
  
  
  for(i in 1:length(remove_entries)){
    if(nrow(remove_entries[[i]]) > 0){
      uid_name <- colnames(pg14_tables[[i]])[1]
      uid_del_list <- paste(remove_entries[[i]][,1], collapse = ", ")
      del_query <- paste0("DELETE FROM ",names(pg14_tables)[i]," WHERE ", uid_name, " IN (", uid_del_list,")")
      
      if(seriously == TRUE){dbGetQuery(pg14_con, del_query); print(paste("Deleted rows from table ",names(pg14_tables)[i]))} else
        print(paste0("Query, \"",del_query,"\", was not used."))
    } else {
      print(paste0("No entries to be removed from ",remove_entries[i],"."))
    }
  }

  
  # 5.2: CHANGE RECORDS  
  
  #function to assist writing UPDATE query
  update_query_fx <- function(names,values,data_type){
    x = ""
    for(k in 1:length(values)){
      if(data_type[k] == "timestamp without time zone"){
        #specific paste for datetime/ date values
        x <- paste0(x,names[k]," = '", paste(as.character(values[k][[1]])),"'")
      } else if(data_type[k] == "boolean"){
        #specific paste for Boolean values
        x <- paste0(x,names[k]," = '", paste(values[k] == TRUE),"'")
      }else{
        x <- paste0(x,names[k]," = '", gsub(pattern = "'", replacement = "''", x = values[k]),"'")
      }
      if(k < length(values)){ x <- paste0(x,", ")}
    }
    x <- gsub("'NA'","NULL",x)
    x <- gsub("\\'(\\d+)\\'","\\1",x)
    return(x)
  }
  
  for(i in 1:length(altered_entries)){
    if(nrow(altered_entries[[i]]) > 0){
      
      # pg14 table column names
      col_names <- colnames(altered_entries[[i]])
      # pg14 table uid
      uid_name <- col_names[1]
      # list of uid's to be updated
      uid_upd_list <- altered_entries[[i]][,1]
      
        # write individual query for each updated row
        for(j in 1:length(uid_upd_list)){
          
        # writing
        x <- update_query_fx(col_names,altered_entries[[i]][j,],pg14_table_data_type[[i]][[1]])
        update_query <- paste0("UPDATE ",names(pg14_tables)[i]," SET ",x, " WHERE ",uid_name," = ",uid_upd_list[j],";")
        
        # send query to pg14 or print query
        if(seriously == TRUE){dbGetQuery(pg14_con, update_query); print(paste("Altered table ",names(pg14_tables)[i]))}
        else{print(paste0("Query, \"",update_query,"\", was not used."))}
        }
    } else print(paste0("No entries to be altered in ",altered_entries[i],"."))
  }

  
  # 5.3:  INSERT RECORDS
  
  #function to assist writing INSERT INTO query
  insert_query_fx <- function(data_type,values){
    x = ""
    for(k in 1:length(values)){
      
      if(data_type[k] == "timestamp without time zone"){
        #check to paste time-stamp correctly
        x <- paste(x,"'", paste(as.character(values[k][[1]])),"'", sep = "")
      }else if(data_type[k] == "boolean"){
        #specific paste for Boolean values
        x <- paste(x,"'", paste(values[k] == TRUE),"'", sep = "")
      } else {
      #paste value
      x <- paste(x,"'", gsub(pattern = "'", replacement = "''", x = values[k]),"'", sep = "")
      }
      if(k < length(values)){ x <- paste0(x,", ")}
    }
    #change NA's to NULL's
    x <- gsub("'NA'","NULL",x)
    #remove quotes for integers and decimals
    x <- gsub("\\'(\\d+)\\'","\\1",x)
    return(x)
  }
  
  
  #reorder data types to match new entries
  pg14_table_data_type <- pg14_table_data_type[new_entries_names_ordered]
  
  
  for(i in 1:length(new_entries)){
    if(nrow(new_entries[[i]]) > 0){
      
      # pg14 table column names
      col_names <- colnames(new_entries[[i]])
      # pg14 table uid
      uid_name <- col_names[i]
      # list of new uid's
      uid_new_list <- new_entries[[i]][,1]
      
      # write individual query for each new row
      for(j in 1:length(uid_new_list)){
        
        # writing
        insert_vals <- insert_query_fx(pg14_table_data_type[[i]][[1]],new_entries[[i]][j,])
        insert_query <- paste0("INSERT INTO ",names(new_entries)[[i]]," (",paste(col_names, collapse = ", "),") VALUES (",insert_vals,");")
        
        # send 
        if(seriously == TRUE){dbGetQuery(pg14_con, insert_query); print(paste("Added rwos to table ",names(pg14_tables)[i]))}
        else{print(paste0("Query, \"",insert_query,"\", was not used."))}
        
      }
      
      
    }
  }
  
  
##### 6.0 Close connection ####
  dbDisconnect(pg9_con)
  dbDisconnect(pg14_con)
  