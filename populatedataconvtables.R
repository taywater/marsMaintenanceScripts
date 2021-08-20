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
    #SMP tables
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

    #Component tables
    gswicleanout_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, FACILITYID as facility_id, COMPONENTID as component_id from gisad.gswicleanout'
    gswicontrolstructure_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, FACILITYID as facility_id, COMPONENTID as component_id from gisad.gswicontrolstructure'
    gswiconveyance_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, FACILITYID as facility_id, COMPONENTID as component_id,SUBTYPE as subtype from gisad.gswiconveyance where COMPONENTID is not NULL'
    gswifitting_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, FACILITYID as facility_id, COMPONENTID as component_id from gisad.gswifitting'
    gswiinlet_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, FACILITYID as facility_id, COMPONENTID as component_id, PLUG_STATUS as plug_status from gisad.gswiinlet'
    gswimanhole_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, FACILITYID as facility_id, COMPONENTID as component_id from gisad.gswimanhole'
    gswiobservationwell_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, FACILITYID as facility_id, COMPONENTID as component_id from gisad.gswiobservationwell'
    gswistructure_query <- 'select OBJECTID as object_id, LIFECYCLESTATUS as lifecycle_status, FACILITYID as facility_id, COMPONENTID as component_id, SymbolGroup as symbol_group, StructureType as structure_type from gisad.gswistructure where COMPONENTID is not NULL'

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

    gswicleanout <- dbGetQuery(dataconv, gswicleanout_query)
    gswicontrolstructure <- dbGetQuery(dataconv, gswicontrolstructure_query)
    gswiconveyance <- dbGetQuery(dataconv, gswiconveyance_query)
    gswifitting <- dbGetQuery(dataconv, gswifitting_query)
    gswiinlet <- dbGetQuery(dataconv, gswiinlet_query)
    gswimanhole <- dbGetQuery(dataconv, gswimanhole_query)
    gswiobservationwell <- dbGetQuery(dataconv, gswiobservationwell_query)
    gswistructure <- dbGetQuery(dataconv, gswistructure_query)

# hash the tables
    gswibasin_hash <- gswibasin %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswiblueroof_hash <- gswiblueroof %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswibumpout_hash <- gswibumpout %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswicistern_hash <- gswicistern %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswidrainagewell_hash <- gswidrainagewell %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswigreenroof_hash <- gswigreenroof %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswipermeablepavement_hash <- gswipermeablepavement %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswiplanter_hash <- gswiplanter %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswiraingarden_hash <- gswiraingarden %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswiswale_hash <- gswiswale %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswitree_hash <- gswitree %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswitreetrench_hash <- gswitreetrench %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswitrench_hash <- gswitrench %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswiwetland_hash <- gswiwetland %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswicleanout_hash <- gswicleanout %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswicontrolstructure_hash <- gswicontrolstructure %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswiconveyance_hash <- gswiconveyance %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswifitting_hash <- gswifitting %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswiinlet_hash <- gswiinlet %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswimanhole_hash <- gswimanhole %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswiobservationwell_hash <- gswiobservationwell %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
        mutate(md5hash = digest(temp, algo = 'md5')) %>%
        select(-temp)

    gswistructure_hash <- gswistructure %>%
        unite("temp", remove = FALSE) %>%
        rowwise() %>%
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

    gswicleanout_db <- dbGetQuery(mars, "select * from external.gswicleanout")
    gswicontrolstructure_db <- dbGetQuery(mars, "select * from external.gswicontrolstructure")
    gswiconveyance_db <- dbGetQuery(mars, "select * from external.gswiconveyance")
    gswifitting_db <- dbGetQuery(mars, "select * from external.gswifitting")
    gswiinlet_db <- dbGetQuery(mars, "select * from external.gswiinlet")
    gswimanhole_db <- dbGetQuery(mars, "select * from external.gswimanhole")
    gswiobservationwell_db <- dbGetQuery(mars, "select * from external.gswiobservationwell")
    gswistructure_db <- dbGetQuery(mars, "select * from external.gswistructure")

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

    gswicleanout_anti <- anti_join(gswicleanout_hash, gswicleanout_db)
    gswicontrolstructure_anti <- anti_join(gswicontrolstructure_hash, gswicontrolstructure_db)
    gswiconveyance_anti <- anti_join(gswiconveyance_hash, gswiconveyance_db)
    gswifitting_anti <- anti_join(gswifitting_hash, gswifitting_db)
    gswiinlet_anti <- anti_join(gswiinlet_hash, gswiinlet_db)
    gswimanhole_anti <- anti_join(gswimanhole_hash, gswimanhole_db)
    gswiobservationwell_anti <- anti_join(gswiobservationwell_hash, gswiobservationwell_db)
    gswistructure_anti <- anti_join(gswistructure_hash, gswistructure_db)

#Filter to detect new items instead of edits
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

    gswicleanout_new <- filter(gswicleanout_anti, !(facility_id %in% gswicleanout_db$facility_id))
    gswicontrolstructure_new <- filter(gswicontrolstructure_anti, !(facility_id %in% gswicontrolstructure_db$facility_id))
    gswiconveyance_new <- filter(gswiconveyance_anti, !(facility_id %in% gswiconveyance_db$facility_id))
    gswifitting_new <- filter(gswifitting_anti, !(facility_id %in% gswifitting_db$facility_id))
    gswiinlet_new <- filter(gswiinlet_anti, !(facility_id %in% gswiinlet_db$facility_id))
    gswimanhole_new <- filter(gswimanhole_anti, !(facility_id %in% gswimanhole_db$facility_id))
    gswiobservationwell_new <- filter(gswiobservationwell_anti, !(facility_id %in% gswiobservationwell_db$facility_id))
    gswistructure_new <- filter(gswistructure_anti, !(facility_id %in% gswistructure_db$facility_id))

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

    dbWriteTable(mars, DBI::SQL("external.gswicleanout"), gswicleanout_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswicontrolstructure"), gswicontrolstructure_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswiconveyance"), gswiconveyance_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswifitting"), gswifitting_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswiinlet"), gswiinlet_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswimanhole"), gswimanhole_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswiobservationwell"), gswiobservationwell_new, append = TRUE)
    dbWriteTable(mars, DBI::SQL("external.gswistructure"), gswistructure_new, append = TRUE)

# Old facility = update the row
#Set UID to be the last column to facilitate the substitution mechanism in dbSendQuery
    gswibasin_update = anti_join(gswibasin_anti, gswibasin_new) %>%
        left_join(select(gswibasin_db, gswibasin_uid, facility_id))

    gswiblueroof_update = anti_join(gswiblueroof_anti, gswiblueroof_new) %>%
        left_join(select(gswiblueroof_db, gswiblueroof_uid, facility_id))

    gswibumpout_update = anti_join(gswibumpout_anti, gswibumpout_new) %>%
        left_join(select(gswibumpout_db, gswibumpout_uid, facility_id))

    gswicistern_update = anti_join(gswicistern_anti, gswicistern_new) %>%
        left_join(select(gswicistern_db, gswicistern_uid, facility_id))

    gswidrainagewell_update = anti_join(gswidrainagewell_anti, gswidrainagewell_new) %>%
        left_join(select(gswidrainagewell_db, gswidrainagewell_uid, facility_id))

    gswigreenroof_update = anti_join(gswigreenroof_anti, gswigreenroof_new) %>%
        left_join(select(gswigreenroof_db, gswigreenroof_uid, facility_id))

    gswipermeablepavement_update = anti_join(gswipermeablepavement_anti, gswipermeablepavement_new) %>%
        left_join(select(gswipermeablepavement_db, gswipermeablepavement_uid, facility_id))

    gswiplanter_update = anti_join(gswiplanter_anti, gswiplanter_new) %>%
        left_join(select(gswiplanter_db, gswiplanter_uid, facility_id))

    gswiraingarden_update = anti_join(gswiraingarden_anti, gswiraingarden_new) %>%
        left_join(select(gswiraingarden_db, gswiraingarden_uid, facility_id))

    gswiswale_update = anti_join(gswiswale_anti, gswiswale_new) %>%
        left_join(select(gswiswale_db, gswiswale_uid, facility_id))

    gswitree_update = anti_join(gswitree_anti, gswitree_new) %>%
        left_join(select(gswitree_db, gswitree_uid, facility_id))

    gswitreetrench_update = anti_join(gswitreetrench_anti, gswitreetrench_new) %>%
        left_join(select(gswitreetrench_db, gswitreetrench_uid, facility_id))

    gswitrench_update = anti_join(gswitrench_anti, gswitrench_new) %>%
        left_join(select(gswitrench_db, gswitrench_uid, facility_id))

    gswiwetland_update = anti_join(gswiwetland_anti, gswiwetland_new) %>%
        left_join(select(gswiwetland_db, gswiwetland_uid, facility_id))


    gswicleanout_update <- anti_join(gswicleanout_anti, gswicleanout_new) %>%
        left_join(select(gswicleanout_db, gswicleanout_uid, facility_id))

    gswicontrolstructure_update <- anti_join(gswicontrolstructure_anti, gswicontrolstructure_new) %>%
        left_join(select(gswicontrolstructure_db, gswicontrolstructure_uid, facility_id))

    gswiconveyance_update <- anti_join(gswiconveyance_anti, gswiconveyance_new) %>%
        left_join(select(gswiconveyance_db, gswiconveyance_uid, facility_id))
    
    gswifitting_update <- anti_join(gswifitting_anti, gswifitting_new) %>%
        left_join(select(gswifitting_db, gswifitting_uid, facility_id))
    
    gswiinlet_update <- anti_join(gswiinlet_anti, gswiinlet_new) %>%
        left_join(select(gswiinlet_db, gswiinlet_uid, facility_id))
    
    gswimanhole_update <- anti_join(gswimanhole_anti, gswimanhole_new) %>%
        left_join(select(gswimanhole_db, gswimanhole_uid, facility_id))
    
    gswiobservationwell_update <- anti_join(gswiobservationwell_anti, gswiobservationwell_new) %>%
        left_join(select(gswiobservationwell_db, gswiobservationwell_uid, facility_id))
    
    gswistructure_update <- anti_join(gswistructure_anti, gswistructure_new) %>%
        left_join(select(gswistructure_db, gswistructure_uid, facility_id))

#Update old assets
    if(nrow(gswibasin_update) > 0){
    	update_gswibasin <- dbSendQuery(mars, 'UPDATE external.gswibasin set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswibasin_uid=?')
        dbBind(update_gswibasin, gswibasin_update)
        dbClearResult(update_gswibasin)
    }    

    if(nrow(gswiblueroof_update) > 0){
    	update_gswiblueroof <- dbSendQuery(mars, 'UPDATE external.gswiblueroof set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswiblueroof_uid=?')
        dbBind(update_gswiblueroof, gswiblueroof_update)
        dbClearResult(update_gswiblueroof)
    }   

    if(nrow(gswibumpout_update) > 0){
    	update_gswibumpout <- dbSendQuery(mars, 'UPDATE external.gswibumpout set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswibumpout_uid=?')
        dbBind(update_gswibumpout, gswibumpout_update)
        dbClearResult(update_gswibumpout)
    }   

    if(nrow(gswicistern_update) > 0){
    	update_gswicistern <- dbSendQuery(mars, 'UPDATE external.gswicistern set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswicistern_uid=?')
        dbBind(update_gswicistern, gswicistern_update)
        dbClearResult(update_gswicistern)
    }   

    if(nrow(gswidrainagewell_update) > 0){
    	update_gswidrainagewell <- dbSendQuery(mars, 'UPDATE external.gswidrainagewell set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswidrainagewell_uid=?')
        dbBind(update_gswidrainagewell, gswidrainagewell_update)
        dbClearResult(update_gswidrainagewell)
    }   

    if(nrow(gswigreenroof_update) > 0){
    	update_gswigreenroof <- dbSendQuery(mars, 'UPDATE external.gswigreenroof set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswigreenroof_uid=?')
        dbBind(update_gswigreenroof, gswigreenroof_update)
        dbClearResult(update_gswigreenroof)
    }   

    if(nrow(gswipermeablepavement_update) > 0){
    	update_gswipermeablepavement <- dbSendQuery(mars, 'UPDATE external.gswipermeablepavement set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, porous_maintenance=?, md5hash=? where gswipermeablepavement_uid=?')
        dbBind(update_gswipermeablepavement, gswipermeablepavement_update)
        dbClearResult(update_gswipermeablepavement)
    }   

    if(nrow(gswiplanter_update) > 0){
    	update_gswiplanter <- dbSendQuery(mars, 'UPDATE external.gswiplanter set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswiplanter_uid=?')
        dbBind(update_gswiplanter, gswiplanter_update)
        dbClearResult(update_gswiplanter)
    }   

    if(nrow(gswiraingarden_update) > 0){
    	update_gswiraingarden <- dbSendQuery(mars, 'UPDATE external.gswiraingarden set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswiraingarden_uid=?')
        dbBind(update_gswiraingarden, gswiraingarden_update)
        dbClearResult(update_gswiraingarden)
    }    

    if(nrow(gswiswale_update) > 0){
    	update_gswiswale <- dbSendQuery(mars, 'UPDATE external.gswiswale set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswiswale_uid=?')
        dbBind(update_gswiswale, gswiswale_update)
        dbClearResult(update_gswiswale)
    }   

    if(nrow(gswitree_update) > 0){
    	update_gswitree <- dbSendQuery(mars, 'UPDATE external.gswitree set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, subtype=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswitree_uid=?')
        dbBind(update_gswitree, gswitree_update)
        dbClearResult(update_gswitree)
    }   

    if(nrow(gswitreetrench_update) > 0){
    	update_gswitreetrench <- dbSendQuery(mars, 'UPDATE external.gswitreetrench set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswitreetrench_uid=?')
        dbBind(update_gswitreetrench, gswitreetrench_update)
        dbClearResult(update_gswitreetrench)
    }   

    if(nrow(gswitrench_update) > 0){
    	update_gswitrench <- dbSendQuery(mars, 'UPDATE external.gswitrench set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswitrench_uid=?')
        dbBind(update_gswitrench, gswitrench_update)
        dbClearResult(update_gswitrench)
    }   

    if(nrow(gswiwetland_update) > 0){
    	update_gswiwetland <- dbSendQuery(mars, 'UPDATE external.gswiwetland set object_id=?, lifecycle_status=?, contract_number=?, facility_id=?, smp_id=?, surface_maintenance=?, subsurface_maintenance=?, md5hash=? where gswiwetland_uid=?')
        dbBind(update_gswiwetland, gswiwetland_update)
        dbClearResult(update_gswiwetland)
    }


    if(nrow(gswicleanout_update) > 0){
        update_gswicleanout <- dbSendQuery(mars, 'update external.gswicleanout set object_id=?, lifecycle_status=?, facility_id=?, component_id=?, md5hash=? where gswicleanout_uid=?')
        dbBind(update_gswicleanout, gswicleanout_update)
        dbClearResult(update_gswicleanout)
    }

    if(nrow(gswicontrolstructure_update) > 0){
        update_gswicontrolstructure <- dbSendQuery(mars, 'update external.gswicontrolstructure set object_id=?, lifecycle_status=?, facility_id=?, component_id=?, md5hash=? where gswicontrolstructure_uid=?')
        dbBind(update_gswicontrolstructure, gswicontrolstructure_update)
        dbClearResult(update_gswicontrolstructure)
    }

    if(nrow(gswiconveyance_update) > 0){
        update_gswiconveyance <- dbSendQuery(mars, 'update external.gswiconveyance set object_id=?, lifecycle_status=?, facility_id=?, component_id=?, subtype=?, md5hash=? where gswiconveyance_uid=?,')
        dbBind(update_gswiconveyance, gswiconveyance_update)
        dbClearResult(update_gswiconveyance)
    }

    if(nrow(gswifitting_update) > 0){
        update_gswifitting <- dbSendQuery(mars, 'update external.gswifitting set object_id=?, lifecycle_status=?, facility_id=?, component_id=?, md5hash=? where gswifitting_uid=?')
        dbBind(update_gswifitting, gswifitting_update)
        dbClearResult(update_gswifitting)
    }

    if(nrow(gswiinlet_update) > 0){
        update_gswiinlet <- dbSendQuery(mars, 'update external.gswiinlet set object_id=?, lifecycle_status=?, facility_id=?, component_id=?, plug_status=?, md5hash=? where gswiinlet_uid=?')
        dbBind(update_gswiinlet, gswiinlet_update)
        dbClearResult(update_gswiinlet)
    }

    if(nrow(gswimanhole_update) > 0){
        update_gswimanhole <- dbSendQuery(mars, 'update external.gswimanhole set object_id=?, lifecycle_status=?, facility_id=?, component_id=?, md5hash=? where gswimanhole_uid=?')
        dbBind(update_gswimanhole, gswimanhole_update)
        dbClearResult(update_gswimanhole)
    }

    if(nrow(gswiobservationwell_update) > 0){
        update_gswiobservationwell <- dbSendQuery(mars, 'update external.gswiobservationwell set object_id=?, lifecycle_status=?, facility_id=?, component_id=?, md5hash=? where gswiobservationwell_uid=?')
        dbBind(update_gswiobservationwell, gswiobservationwell_update)
        dbClearResult(update_gswiobservationwell)
    }

    if(nrow(gswistructure_update) > 0){
        update_gswistructure <- dbSendQuery(mars, 'update external.gswistructure set object_id=?, lifecycle_status=?, facility_id=?, component_id=?, symbol_group=?, structure_type=?, md5hash=? where gswistructure_uid=?')
        dbBind(update_gswistructure, gswistructure_update)
        dbClearResult(update_gswistructure)
    }