library(odbc)
library(tidyverse)
library(digest)
#library(logr) logs to come later

# ODBC Connection to DataConv
dataconv <- dbConnect(odbc(),
    Driver = "ODBC Driver 17 for SQL Server", 
    Server = "pwdgis4", 
    Database = "DataConv", 
    uid = 'gisread', 
    pwd = 'gisread')

mars <- dbConnect(odbc(), "mars_data")

# Queries to populate the tables
    gswibasin_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance from gisad.gswibasin'
    gswiblueroof_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance from gisad.gswiblueroof'
    gswibumpout_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance from gisad.gswibumpout'
    gswicistern_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance from gisad.gswicistern'
    gswidrainagewell_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance from gisad.gswidrainagewell'
    gswigreenroof_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance from gisad.gswigreenroof'
    gswipermeablepavement_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance, POROUS_MAINTENANCE as porous_maintenance from gisad.gswipermeablepavement'
    gswiplanter_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance from gisad.gswiplanter'
    gswiraingarden_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance from gisad.gswiraingarden'
    gswiswale_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance from gisad.gswiswale'
    gswitree_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SUBTYPE as subtype, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance from gisad.gswitree  where SUBTYPE = 1 and ASSOCIATED_SMP_ID is not null'
    gswitreetrench_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance from gisad.gswitreetrench'
    gswitrench_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance from gisad.gswitrench'
    gswiwetland_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, CONTRACTNUMBER as contract_number, FACILITYID as facility_id, SMP_ID as smp_id, SURFACE_MAINTENANCE as surface_maintenance, SUBSURFACE_MAINTENANCE as subsurface_maintenance from gisad.gswiwetland'

# Grab the tables
    gswibasin <- dbGetQuery(dataconv, gswibasin_query) 
    gswiblueroof <- dbGetQuery(dataconv, gswiblueroof_query)
    gswibumpout <- dbGetQuery(dataconv, gswibumpout_query)
    gswicistern <- dbGetQuery(dataconv, gswicistern_query)
    gswidrainagewell <- dbGetQuery(dataconv, gswidrainagewell_query)
    gswigreenroof <- dbGetQuery(dataconv, gswigreenroof_query)
    gswipermeablepavement <- dbGetQuery(dataconv, gswipermeablepavement_query)
    gswiplanter <- dbGetQuery(dataconv, gswiplanter_query)
    gswiraingarden <- dbGetQuery(dataconv, gswiraingarden_query)
    gswiswale <- dbGetQuery(dataconv, gswiswale_query)
    gswitree <- dbGetQuery(dataconv, gswitree_query)
    gswitreetrench <- dbGetQuery(dataconv, gswitreetrench_query)
    gswitrench <- dbGetQuery(dataconv, gswitrench_query)
    gswiwetland <- dbGetQuery(dataconv, gswiwetland_query)

# hash the tables
    gswibasin_hash <- gswibasin %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswiblueroof_hash <- gswiblueroof %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswibumpout_hash <- gswibumpout %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswicistern_hash <- gswicistern %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswidrainagewell_hash <- gswidrainagewell %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswigreenroof_hash <- gswigreenroof %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswipermeablepavement_hash <- gswipermeablepavement %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswiplanter_hash <- gswiplanter %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswiraingarden_hash <- gswiraingarden %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswiswale_hash <- gswiswale %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswitree_hash <- gswitree %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswitreetrench_hash <- gswitreetrench %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswitrench_hash <- gswitrench %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswiwetland_hash <- gswiwetland %>%
        rowwise() %>%
        unite("temp", colnames(.), remove = FALSE) %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

#Query the DB to pull the existing versions
    gswibasin_db <- dbGetQuery(mars, "select * from external.gswibasin")
    gswiblueroof_db <- dbGetQuery(mars, "select * from external.gswiblueroof")
    gswibumpout_db <- dbGetQuery(mars, "select * from external.gswibumpout")
    gswicistern_db <- dbGetQuery(mars, "select * from external.gswicistern")
    gswidrainagewell_db <- dbGetQuery(mars, "select * from external.gswidrainagewell")
    gswigreenroof_db <- dbGetQuery(mars, "select * from external.gswigreenroof")
    gswipermeablepavement_db <- dbGetQuery(mars, "select * from external.gswipermeablepavement")
    gswiplanter_db <- dbGetQuery(mars, "select * from external.gswiplanter")
    gswiraingarden_db <- dbGetQuery(mars, "select * from external.gswiraingarden")
    gswiswale_db <- dbGetQuery(mars, "select * from external.gswiswale")
    gswitree_db <- dbGetQuery(mars, "select * from external.gswitree")
    gswitreetrench_db <- dbGetQuery(mars, "select * from external.gswitreetrench")
    gswitrench_db <- dbGetQuery(mars, "select * from external.gswitrench")
    gswiwetland_db <- dbGetQuery(mars, "select * from external.gswiwetland")

#Anti join to find what is different
    gswibasin_anti <- anti_join(gswibasin_hash, gswibasin_db)
    gswiblueroof_anti <- anti_join(gswiblueroof_hash, gswiblueroof_db)
    gswibumpout_anti <- anti_join(gswibumpout_hash, gswibumpout_db)
    gswicistern_anti <- anti_join(gswicistern_hash, gswicistern_db)
    gswidrainagewell_anti <- anti_join(gswidrainagewell_hash, gswidrainagewell_db)
    gswigreenroof_anti <- anti_join(gswigreenroof_hash, gswigreenroof_db)
    gswipermeablepavement_anti <- anti_join(gswipermeablepavement_hash, gswipermeablepavement_db)
    gswiplanter_anti <- anti_join(gswiplanter_hash, gswiplanter_db)
    gswiraingarden_anti <- anti_join(gswiraingarden_hash, gswiraingarden_db)
    gswiswale_anti <- anti_join(gswiswale_hash, gswiswale_db)
    gswitree_anti <- anti_join(gswitree_hash, gswitree_db)
    gswitreetrench_anti <- anti_join(gswitreetrench_hash, gswitreetrench_db)
    gswitrench_anti <- anti_join(gswitrench_hash, gswitrench_db)
    gswiwetland_anti <- anti_join(gswiwetland_hash, gswiwetland_db)

#Anti join #2 to detect new items instead of edits
#New assets will have new facility IDs
#New facility = append the row
    gswibasin_new <- filter(gswibasin_anti,!(facility_id %in% gswibasin_db$facility_id))
    gswiblueroof_new <- filter(gswiblueroof_anti,!(facility_id %in% gswiblueroof_db$facility_id))
    gswibumpout_new <- filter(gswibumpout_anti,!(facility_id %in% gswibumpout_db$facility_id))
    gswicistern_new <- filter(gswicistern_anti,!(facility_id %in% gswicistern_db$facility_id))
    gswidrainagewell_new <- filter(gswidrainagewell_anti,!(facility_id %in% gswidrainagewell_db$facility_id))
    gswigreenroof_new <- filter(gswigreenroof_anti,!(facility_id %in% gswigreenroof_db$facility_id))
    gswipermeablepavement_new <- filter(gswipermeablepavement_anti,!(facility_id %in% gswipermeablepavement_db$facility_id))
    gswiplanter_new <- filter(gswiplanter_anti,!(facility_id %in% gswiplanter_db$facility_id))
    gswiraingarden_new <- filter(gswiraingarden_anti,!(facility_id %in% gswiraingarden_db$facility_id))
    gswiswale_new <- filter(gswiswale_anti,!(facility_id %in% gswiswale_db$facility_id))
    gswitree_new <- filter(gswitree_anti,!(facility_id %in% gswitree_db$facility_id))
    gswitreetrench_new <- filter(gswitreetrench_anti,!(facility_id %in% gswitreetrench_db$facility_id))
    gswitrench_new <- filter(gswitrench_anti,!(facility_id %in% gswitrench_db$facility_id))
    gswiwetland_new <- filter(gswiwetland_anti,!(facility_id %in% gswiwetland_db$facility_id))

#Write new assets
    dbWriteTable(mars, DBI::SQL("external.gswibasin"), gswibasin_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswiblueroof"), gswiblueroof_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswibumpout"), gswibumpout_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswicistern"), gswicistern_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswidrainagewell"), gswidrainagewell_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswigreenroof"), gswigreenroof_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswipermeablepavement"), gswipermeablepavement_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswiplanter"), gswiplanter_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswiraingarden"), gswiraingarden_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswiswale"), gswiswale_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswitree"), gswitree_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswitreetrench"), gswitreetrench_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswitrench"), gswitrench_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswiwetland"), gswiwetland_new, append = TRUE)




# Old facility = update the row
#Set UID to be the last column to facilitate the substitution mechanism in dbSendQuery
    gswibasin_update = anti_join(gswibasin_anti, gswibasin_new, on = "facility_id") %>%
        left_join(select(gswibasin_db, gswibasin_uid, facility_id)) %>%
        relocate(gswibasin_uid, after = last_col())

    gswiblueroof_update = anti_join(gswiblueroof_anti, gswiblueroof_new, on = "facility_id") %>%
        left_join(select(gswiblueroof_db, gswiblueroof_uid, facility_id)) %>%
        relocate(gswiblueroof_uid, after = last_col())

    gswibumpout_update = anti_join(gswibumpout_anti, gswibumpout_new, on = "facility_id") %>%
        left_join(select(gswibumpout_db, gswibumpout_uid, facility_id)) %>%
        relocate(gswibumpout_uid, after = last_col())

    gswicistern_update = anti_join(gswicistern_anti, gswicistern_new, on = "facility_id") %>%
        left_join(select(gswicistern_db, gswicistern_uid, facility_id)) %>%
        relocate(gswicistern_uid, after = last_col())

    gswidrainagewell_update = anti_join(gswidrainagewell_anti, gswidrainagewell_new, on = "facility_id") %>%
        left_join(select(gswidrainagewell_db, gswidrainagewell_uid, facility_id)) %>%
        relocate(gswidrainagewell_uid, after = last_col())

    gswigreenroof_update = anti_join(gswigreenroof_anti, gswigreenroof_new, on = "facility_id") %>%
        left_join(select(gswigreenroof_db, gswigreenroof_uid, facility_id)) %>%
        relocate(gswigreenroof_uid, after = last_col())

    gswipermeablepavement_update = anti_join(gswipermeablepavement_anti, gswipermeablepavement_new, on = "facility_id") %>%
        left_join(select(gswipermeablepavement_db, gswipermeablepavement_uid, facility_id)) %>%
        relocate(gswipermeablepavement_uid, after = last_col())

    gswiplanter_update = anti_join(gswiplanter_anti, gswiplanter_new, on = "facility_id") %>%
        left_join(select(gswiplanter_db, gswiplanter_uid, facility_id)) %>%
        relocate(gswiplanter_uid, after = last_col())

    gswiraingarden_update = anti_join(gswiraingarden_anti, gswiraingarden_new, on = "facility_id") %>%
        left_join(select(gswiraingarden_db, gswiraingarden_uid, facility_id)) %>%
        relocate(gswiraingarden_uid, after = last_col())

    gswiswale_update = anti_join(gswiswale_anti, gswiswale_new, on = "facility_id") %>%
        left_join(select(gswiswale_db, gswiswale_uid, facility_id)) %>%
        relocate(gswiswale_uid, after = last_col())

    gswitree_update = anti_join(gswitree_anti, gswitree_new, on = "facility_id") %>%
        left_join(select(gswitree_db, gswitree_uid, facility_id)) %>%
        relocate(gswitree_uid, after = last_col())

    gswitreetrench_update = anti_join(gswitreetrench_anti, gswitreetrench_new, on = "facility_id") %>%
        left_join(select(gswitreetrench_db, gswitreetrench_uid, facility_id)) %>%
        relocate(gswitreetrench_uid, after = last_col())

    gswitrench_update = anti_join(gswitrench_anti, gswitrench_new, on = "facility_id") %>%
        left_join(select(gswitrench_db, gswitrench_uid, facility_id)) %>%
        relocate(gswitrench_uid, after = last_col())

    gswiwetland_update = anti_join(gswiwetland_anti, gswiwetland_new, on = "facility_id") %>%
        left_join(select(gswiwetland_db, gswiwetland_uid, facility_id)) %>%
        relocate(gswiwetland_uid, after = last_col())


#Update old assets
    update_gswibasin <- dbSendQuery(mars, 'UPDATE TABLE external.gswibasin set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswibasin_uid=?')
    dbBind(update_gswibasin, gswibasin_update)
    dbClearResult(update_gswibasin)
    
    update_gswiblueroof <- dbSendQuery(mars, 'UPDATE TABLE external.gswiblueroof set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswiblueroof_uid=?')
    dbBind(update_gswiblueroof, gswiblueroof_update)
    dbClearResult(update_gswiblueroof)
    
    update_gswibumpout <- dbSendQuery(mars, 'UPDATE TABLE external.gswibumpout set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswibumpout_uid=?')
    dbBind(update_gswibumpout, gswibumpout_update)
    dbClearResult(update_gswibumpout)
    
    update_gswicistern <- dbSendQuery(mars, 'UPDATE TABLE external.gswicistern set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswicistern_uid=?')
    dbBind(update_gswicistern, gswicistern_update)
    dbClearResult(update_gswicistern)
    
    update_gswidrainagewell <- dbSendQuery(mars, 'UPDATE TABLE external.gswidrainagewell set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswidrainagewell_uid=?')
    dbBind(update_gswidrainagewell, gswidrainagewell_update)
    dbClearResult(update_gswidrainagewell)
    
    update_gswigreenroof <- dbSendQuery(mars, 'UPDATE TABLE external.gswigreenroof set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswigreenroof_uid=?')
    dbBind(update_gswigreenroof, gswigreenroof_update)
    dbClearResult(update_gswigreenroof)
    
    update_gswipermeablepavement <- dbSendQuery(mars, 'UPDATE TABLE external.gswipermeablepavement set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, porous_maintenance=?, md5hash=? where gswipermeablepavement_uid=?')
    dbBind(update_gswipermeablepavement, gswipermeablepavement_update)
    dbClearResult(update_gswipermeablepavement)
    
    update_gswiplanter <- dbSendQuery(mars, 'UPDATE TABLE external.gswiplanter set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswiplanter_uid=?')
    dbBind(update_gswiplanter, gswiplanter_update)
    dbClearResult(update_gswiplanter)
    
    update_gswiraingarden <- dbSendQuery(mars, 'UPDATE TABLE external.gswiraingarden set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswiraingarden_uid=?')
    dbBind(update_gswiraingarden, gswiraingarden_update)
    dbClearResult(update_gswiraingarden)
    
    update_gswiswale <- dbSendQuery(mars, 'UPDATE TABLE external.gswiswale set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswiswale_uid=?')
    dbBind(update_gswiswale, gswiswale_update)
    dbClearResult(update_gswiswale)
    
    update_gswitree <- dbSendQuery(mars, 'UPDATE TABLE external.gswitree set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, subtype=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswitree_uid=?')
    dbBind(update_gswitree, gswitree_update)
    dbClearResult(update_gswitree)
    
    update_gswitreetrench <- dbSendQuery(mars, 'UPDATE TABLE external.gswitreetrench set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswitreetrench_uid=?')
    dbBind(update_gswitreetrench, gswitreetrench_update)
    dbClearResult(update_gswitreetrench)
    
    update_gswitrench <- dbSendQuery(mars, 'UPDATE TABLE external.gswitrench set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswitrench_uid=?')
    dbBind(update_gswitrench, gswitrench_update)
    dbClearResult(update_gswitrench)
    
    update_gswiwetland <- dbSendQuery(mars, 'UPDATE TABLE external.gswiwetland set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswiwetland_uid=?')
    dbBind(update_gswiwetland, gswiwetland_update)
    dbClearResult(update_gswiwetland)
    


    dbBind(update_gswibasin, gswibasin_update)
    

    dbBind(update_gswiblueroof, gswiblueroof_update)
    

    dbBind(update_gswibumpout, gswibumpout_update)
    

    dbBind(update_gswicistern, gswicistern_update)
    

    dbBind(update_gswidrainagewell, gswidrainagewell_update)
    

    dbBind(update_gswigreenroof, gswigreenroof_update)
    

    dbBind(update_gswipermeablepavement, gswipermeablepavement_update)
    

    dbBind(update_gswiplanter, gswiplanter_update)
    

    dbBind(update_gswiraingarden, gswiraingarden_update)
    

    dbBind(update_gswiswale, gswiswale_update)
    

    dbBind(update_gswitree, gswitree_update)
    

    dbBind(update_gswitreetrench, gswitreetrench_update)
    

    dbBind(update_gswitrench, gswitrench_update)
    

    dbBind(update_gswiwetland, gswiwetland_update)
    


