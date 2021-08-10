#7/16/21 goal

#Updating greenit tables in PG12 database
#pulling info from greenit, add an md5 hash, then writing to PG12 db

#then
#then pull greenit info again and compare to what's in db

#then write metadata templates in database and then truncate greenit tables in db and then write again and see if the metadata tables update


#0.0 set up --------

#libraries
library(odbc)
library(tidyverse)
library(digest)

#db connections 
greenit <- dbConnect(odbc(),
                     Driver = "ODBC Driver 17 for SQL Server",  
                     Server = "PWDSQLP2", 
                     Database = "GreenIT", 
                     uid = 'greenitvread', 
                     pwd = 'pwd')

mars_data <- dbConnect(odbc(), "mars_data")

dbListTables(mars_data)

#1.0 query and hash -------
  #1.1 query tables ------
  smpbestdata <- dbGetQuery(greenit, "select ProjectID as project_id, SMP_DataPhase as smp_dataphase, WorkNumber as worknumber, Status as capit_status, StatusCategory as capit_statuscategory, SystemNumber as system_id, SMPNumber as smp_id, SMP_SMPType as smp_smptype, SMP_FootPrint as smp_footprint_ft2, SMP_SMPTrees as smp_smptrees, SMP_PerviousArea as smp_perviousarea_ft2, SMP_VegetatedArea as smp_vegetatedarea_ft2, SMP_StorageDepth as smp_storagedepth_ft, SMP_PondingDepth as smp_pondingdepth_in, SMP_StorageType as smp_storagetype, SMP_Pretreatment as smp_pretreatment, SMP_NotBuiltRetired as smp_notbuiltretired, SMP_NotBuiltRetiredReason as smp_notbuiltretiredreason from vw_GreenIT_SMPBestData")
  
  systembestdata <- dbGetQuery(greenit, "select Sys_DataPhase as sys_dataphase, WorkNumber as worknumber, Status as status, StatusCategory as statuscategory, ProjectID as project_id, SystemNumber as system_id, Sys_PrimaryProgram as sys_primaryprogram, Sys_SecondaryPrograms as sys_secondaryprograms, Sys_SewerType as sys_sewertype, Sys_OverFlowType as sys_overflowtype, Sys_SysFunction as sys_sysfunction, Sys_ModelInputCategory as sys_modelinputcategory, Sys_ImpervDA as sys_impervda_ft2, Sys_SurfaceDCIA as sys_surfacedcia_ft2, Sys_SubsurfaceDCIA as sys_subsurfacedcia_ft2, Sys_PerviousDA as sys_perviousda_ft2, Sys_TotalDA as sys_totalda_ft2, Sys_DisconnectedArea as sys_disconnectedarea_ft2, Sys_StorageVolume as sys_storagevolume_ft3, Sys_TotalSysVolume as sys_totalsysvolume_ft3, Sys_SoilStorageVolume as sys_soilstoragevolume_ft3, Sys_PondedStorageVolume as sys_pondedstoragevolume_ft3, Sys_VolumeBelowOrifice as sys_volumebeloworifice_ft3, Sys_CreditedGA as sys_creditedga, Sys_RawGA as sys_rawga, Sys_InfilDepth as sys_infildepth_ft, Sys_SlowReleaseHead as sys_slowreleasehead_ft, Sys_StorageFootPrint as sys_storagefootprint_ft2, Sys_InfilFootPrint as sys_infilfootprint_ft2, Sys_PondingSurfaceArea as sys_pondingsurfacearea_ft2, Sys_OrificeDia as sys_orificedia_in, Sys_Underdrain as sys_underdrain, Sys_PeakReleaseRate as sys_peakreleaserate_cfs, Sys_RawStormSizeManaged as sys_rawstormsizemanaged_in, Sys_ModeledStormSizeManaged as sys_modeledstormsizemanaged_in, Sys_CreditedStormSizeManaged as sys_creditedstormsizemanaged_in, Sys_LRimpervDA as sys_lrimpervda_ft2, Sys_LRtotalDA as sys_lrtotalda_ft2, Sys_LRSurfaceDCIA as sys_lrsurfacedcia_ft2, Sys_LRSubsurfaceDCIA as sys_lrsubsurfacedcia_ft2, Sys_NotBuiltRetired as sys_notbuiltretired, Sys_NotBuiltRetiredReason as sys_notbuiltretiredreason, Infil_Dsg_TestDate as infil_dsg_testdate, Infil_Dsg_TestType as infil_dsg_testtype, Infil_Dsg_BoringDepth as infil_dsg_boringdepth_ft, Infil_Dsg_DepthtoGW as infil_dsg_depthtogw_ft, Infil_Dsg_DepthtoBedrock as infil_dsg_depthtobedrock_ft, Infil_Dsg_Rate as infil_dsg_rate_inhr, Infil_Constr_TestDate as infil_constr_testdate, Infil_Constr_TestType as infil_constr_testtype, Infil_Constr_Rate as infil_constr_rate_inhr from vw_greenit_systembestdata")
  
  projectbestdata <- dbGetQuery(greenit, "select ProjectID as project_id, WorkNumber as worknumber, Proj_ProjectName as proj_projectname, Status as capit_status, StatusCategory as capit_statuscategory, Proj_PrimaryProgram as proj_primaryprogram, ProjSysSum_PrimaryProgram as projsyssum_primaryprogram, Proj_PilotFactor as proj_pilotfactor, Proj_X as proj_x, Proj_Y as proj_y, Proj_DataPhase as proj_dataphase, Proj_SewerType as proj_sewertype, ProjSysSum_SewerTypes as projsyssum_sewertypes, Proj_BestGA as proj_bestga, Proj_BestDA as proj_bestda_ft2, Proj_EstimatedGA as proj_estimatedga, Proj_EstimatedDA as proj_estimatedda_ft2, ProjSysSum_CreditedGA as projsyssum_creditedga, ProjSysSum_RawGA as projsyssum_rawga, ProjSysSum_ImpervDA as projsyssum_impervda_ft2, ProjSysSum_StorageVolume as projsyssum_storagevolume_ft3, ProjSMPSum_PerviousArea as projsmpsum_perviousarea_ft2, Proj_NonSMPTrees as proj_nonsmptrees, ProjSMPSum_SMPTrees as projsmpsum_smptrees, ProjSMPSum_Basins as projsmpsum_basins, ProjSMPSum_BlueRoofs as projsmpsum_blueroofs, ProjSMPSum_Bumpouts as projsmpsum_bumpouts, ProjSMPSum_Cisterns as projsmpsum_cisterns, ProjSMPSum_Depaving as projsmpsum_depaving, ProjSMPSum_DrainageWells as projsmpsum_drainagewells, ProjSMPSum_GreenGutters as projsmpsum_greengutters, ProjSMPSum_GreenRoofs as projsmpsum_greenroofs, ProjSMPSum_InfilTrenches as projsmpsum_infiltrenches, ProjSMPSum_PerviousPaving as projsmpsum_perviouspaving, ProjSMPSum_Planters as projsmpsum_planters, ProjSMPSum_RainGardens as projsmpsum_raingardens, ProjSMPSum_StormwaterTrees as projsmpsum_stormwatertrees, ProjSMPSum_Swales as projsmpsum_swales, ProjSMPSum_TreeTrenches as projsmpsum_treetrenches, ProjSMPSum_Wetlands as projsmpsum_wetlands from vw_greenit_projectbestdata")
  
  #1.2 add hashes ----
  smp_hash <- smpbestdata %>% 
    rowwise() %>% 
    mutate("hash_md5" = digest(paste(project_id, smp_dataphase, worknumber, capit_status, capit_statuscategory, system_id, smp_id, smp_smptype, smp_footprint_ft2, smp_smptrees, smp_perviousarea_ft2, smp_vegetatedarea_ft2, smp_storagedepth_ft, smp_pondingdepth_in, smp_storagetype, smp_pretreatment, smp_notbuiltretired, smp_notbuiltretiredreason), algo = "md5")) 
  
  system_hash <- systembestdata %>% 
    rowwise() %>% 
    mutate("hash_md5" = digest(paste(sys_dataphase, worknumber, status, statuscategory, project_id, system_id, sys_primaryprogram, sys_secondaryprograms, sys_sewertype, sys_overflowtype, sys_sysfunction, sys_modelinputcategory, sys_impervda_ft2, sys_surfacedcia_ft2, sys_subsurfacedcia_ft2, sys_perviousda_ft2, sys_totalda_ft2, sys_disconnectedarea_ft2, sys_storagevolume_ft3, sys_totalsysvolume_ft3, sys_soilstoragevolume_ft3, sys_pondedstoragevolume_ft3, sys_volumebeloworifice_ft3, sys_creditedga, sys_rawga, sys_infildepth_ft, sys_slowreleasehead_ft, sys_storagefootprint_ft2, sys_infilfootprint_ft2, sys_pondingsurfacearea_ft2, sys_orificedia_in, sys_underdrain, sys_peakreleaserate_cfs, sys_rawstormsizemanaged_in, sys_modeledstormsizemanaged_in, sys_creditedstormsizemanaged_in, sys_lrimpervda_ft2, sys_lrtotalda_ft2, sys_lrsurfacedcia_ft2, sys_lrsubsurfacedcia_ft2, sys_notbuiltretired, sys_notbuiltretiredreason, infil_dsg_testdate, infil_dsg_testtype, infil_dsg_boringdepth_ft, infil_dsg_depthtogw_ft, infil_dsg_depthtobedrock_ft, infil_dsg_rate_inhr, infil_constr_testdate, infil_constr_testtype, infil_constr_rate_inhr), algo = "md5"))
  
  project_hash <- projectbestdata %>% 
    rowwise() %>% 
    mutate("hash_md5" = digest(paste(project_id, worknumber, proj_projectname, capit_status, capit_statuscategory, proj_primaryprogram, projsyssum_primaryprogram, proj_pilotfactor, proj_x, proj_y, proj_dataphase, proj_sewertype, projsyssum_sewertypes, proj_bestga, proj_bestda_ft2, proj_estimatedga, proj_estimatedda_ft2, projsyssum_creditedga, projsyssum_rawga, projsyssum_impervda_ft2, projsyssum_storagevolume_ft3, projsmpsum_perviousarea_ft2, proj_nonsmptrees, projsmpsum_smptrees, projsmpsum_basins, projsmpsum_blueroofs, projsmpsum_bumpouts, projsmpsum_cisterns, projsmpsum_depaving, projsmpsum_drainagewells, projsmpsum_greengutters, projsmpsum_greenroofs, projsmpsum_infiltrenches, projsmpsum_perviouspaving, projsmpsum_planters, projsmpsum_raingardens, projsmpsum_stormwatertrees, projsmpsum_swales, projsmpsum_treetrenches, projsmpsum_wetlands), algo = "md5"))
  
  #1.3 initial WRITE ------
  #smp
  #dbWriteTable(mars_data, DBI::SQL("external.smpbdv"), smp_hash, append= TRUE)
  
  #system
  #dbWriteTable(mars_data, DBI::SQL("external.systembdv"), system_hash, append = TRUE)
  
  #project
  #dbWriteTable(mars_data, DBI::SQL("external.projectbdv"), project_hash, append = TRUE)


#2.0 get the data from greenit again (this is where maintenance script might start) -------
#yes this is all the same but it makes sense linearly following the migration steps to do this
  #2.1 query tables ----
  
  smpbestdata <- dbGetQuery(greenit, "select ProjectID as project_id, SMP_DataPhase as smp_dataphase, WorkNumber as worknumber, Status as capit_status, StatusCategory as capit_statuscategory, SystemNumber as system_id, SMPNumber as smp_id, SMP_SMPType as smp_smptype, SMP_FootPrint as smp_footprint_ft2, SMP_SMPTrees as smp_smptrees, SMP_PerviousArea as smp_perviousarea_ft2, SMP_VegetatedArea as smp_vegetatedarea_ft2, SMP_StorageDepth as smp_storagedepth_ft, SMP_PondingDepth as smp_pondingdepth_in, SMP_StorageType as smp_storagetype, SMP_Pretreatment as smp_pretreatment, SMP_NotBuiltRetired as smp_notbuiltretired, SMP_NotBuiltRetiredReason as smp_notbuiltretiredreason from vw_GreenIT_SMPBestData")
  
  systembestdata <- dbGetQuery(greenit, "select Sys_DataPhase as sys_dataphase, WorkNumber as worknumber, Status as status, StatusCategory as statuscategory, ProjectID as project_id, SystemNumber as system_id, Sys_PrimaryProgram as sys_primaryprogram, Sys_SecondaryPrograms as sys_secondaryprograms, Sys_SewerType as sys_sewertype, Sys_OverFlowType as sys_overflowtype, Sys_SysFunction as sys_sysfunction, Sys_ModelInputCategory as sys_modelinputcategory, Sys_ImpervDA as sys_impervda_ft2, Sys_SurfaceDCIA as sys_surfacedcia_ft2, Sys_SubsurfaceDCIA as sys_subsurfacedcia_ft2, Sys_PerviousDA as sys_perviousda_ft2, Sys_TotalDA as sys_totalda_ft2, Sys_DisconnectedArea as sys_disconnectedarea_ft2, Sys_StorageVolume as sys_storagevolume_ft3, Sys_TotalSysVolume as sys_totalsysvolume_ft3, Sys_SoilStorageVolume as sys_soilstoragevolume_ft3, Sys_PondedStorageVolume as sys_pondedstoragevolume_ft3, Sys_VolumeBelowOrifice as sys_volumebeloworifice_ft3, Sys_CreditedGA as sys_creditedga, Sys_RawGA as sys_rawga, Sys_InfilDepth as sys_infildepth_ft, Sys_SlowReleaseHead as sys_slowreleasehead_ft, Sys_StorageFootPrint as sys_storagefootprint_ft2, Sys_InfilFootPrint as sys_infilfootprint_ft2, Sys_PondingSurfaceArea as sys_pondingsurfacearea_ft2, Sys_OrificeDia as sys_orificedia_in, Sys_Underdrain as sys_underdrain, Sys_PeakReleaseRate as sys_peakreleaserate_cfs, Sys_RawStormSizeManaged as sys_rawstormsizemanaged_in, Sys_ModeledStormSizeManaged as sys_modeledstormsizemanaged_in, Sys_CreditedStormSizeManaged as sys_creditedstormsizemanaged_in, Sys_LRimpervDA as sys_lrimpervda_ft2, Sys_LRtotalDA as sys_lrtotalda_ft2, Sys_LRSurfaceDCIA as sys_lrsurfacedcia_ft2, Sys_LRSubsurfaceDCIA as sys_lrsubsurfacedcia_ft2, Sys_NotBuiltRetired as sys_notbuiltretired, Sys_NotBuiltRetiredReason as sys_notbuiltretiredreason, Infil_Dsg_TestDate as infil_dsg_testdate, Infil_Dsg_TestType as infil_dsg_testtype, Infil_Dsg_BoringDepth as infil_dsg_boringdepth_ft, Infil_Dsg_DepthtoGW as infil_dsg_depthtogw_ft, Infil_Dsg_DepthtoBedrock as infil_dsg_depthtobedrock_ft, Infil_Dsg_Rate as infil_dsg_rate_inhr, Infil_Constr_TestDate as infil_constr_testdate, Infil_Constr_TestType as infil_constr_testtype, Infil_Constr_Rate as infil_constr_rate_inhr from vw_greenit_systembestdata")
  
  projectbestdata <- dbGetQuery(greenit, "select ProjectID as project_id, WorkNumber as worknumber, Proj_ProjectName as proj_projectname, Status as capit_status, StatusCategory as capit_statuscategory, Proj_PrimaryProgram as proj_primaryprogram, ProjSysSum_PrimaryProgram as projsyssum_primaryprogram, Proj_PilotFactor as proj_pilotfactor, Proj_X as proj_x, Proj_Y as proj_y, Proj_DataPhase as proj_dataphase, Proj_SewerType as proj_sewertype, ProjSysSum_SewerTypes as projsyssum_sewertypes, Proj_BestGA as proj_bestga, Proj_BestDA as proj_bestda_ft2, Proj_EstimatedGA as proj_estimatedga, Proj_EstimatedDA as proj_estimatedda_ft2, ProjSysSum_CreditedGA as projsyssum_creditedga, ProjSysSum_RawGA as projsyssum_rawga, ProjSysSum_ImpervDA as projsyssum_impervda_ft2, ProjSysSum_StorageVolume as projsyssum_storagevolume_ft3, ProjSMPSum_PerviousArea as projsmpsum_perviousarea_ft2, Proj_NonSMPTrees as proj_nonsmptrees, ProjSMPSum_SMPTrees as projsmpsum_smptrees, ProjSMPSum_Basins as projsmpsum_basins, ProjSMPSum_BlueRoofs as projsmpsum_blueroofs, ProjSMPSum_Bumpouts as projsmpsum_bumpouts, ProjSMPSum_Cisterns as projsmpsum_cisterns, ProjSMPSum_Depaving as projsmpsum_depaving, ProjSMPSum_DrainageWells as projsmpsum_drainagewells, ProjSMPSum_GreenGutters as projsmpsum_greengutters, ProjSMPSum_GreenRoofs as projsmpsum_greenroofs, ProjSMPSum_InfilTrenches as projsmpsum_infiltrenches, ProjSMPSum_PerviousPaving as projsmpsum_perviouspaving, ProjSMPSum_Planters as projsmpsum_planters, ProjSMPSum_RainGardens as projsmpsum_raingardens, ProjSMPSum_StormwaterTrees as projsmpsum_stormwatertrees, ProjSMPSum_Swales as projsmpsum_swales, ProjSMPSum_TreeTrenches as projsmpsum_treetrenches, ProjSMPSum_Wetlands as projsmpsum_wetlands from vw_greenit_projectbestdata")
  
  #2.2 hash the greenit tables ----
  smp_hash <- smpbestdata %>% 
    rowwise() %>% 
    mutate("project_id" = 5) %>% 
    mutate("hash_md5" = digest(paste(project_id, smp_dataphase, worknumber, capit_status, capit_statuscategory, system_id, smp_id, smp_smptype, smp_footprint_ft2, smp_smptrees, smp_perviousarea_ft2, smp_vegetatedarea_ft2, smp_storagedepth_ft, smp_pondingdepth_in, smp_storagetype, smp_pretreatment, smp_notbuiltretired, smp_notbuiltretiredreason), algo = "md5"))
    
  
  system_hash <- systembestdata %>% 
    rowwise() %>% 
    mutate("hash_md5" = digest(paste(sys_dataphase, worknumber, status, statuscategory, project_id, system_id, sys_primaryprogram, sys_secondaryprograms, sys_sewertype, sys_overflowtype, sys_sysfunction, sys_modelinputcategory, sys_impervda_ft2, sys_surfacedcia_ft2, sys_subsurfacedcia_ft2, sys_perviousda_ft2, sys_totalda_ft2, sys_disconnectedarea_ft2, sys_storagevolume_ft3, sys_totalsysvolume_ft3, sys_soilstoragevolume_ft3, sys_pondedstoragevolume_ft3, sys_volumebeloworifice_ft3, sys_creditedga, sys_rawga, sys_infildepth_ft, sys_slowreleasehead_ft, sys_storagefootprint_ft2, sys_infilfootprint_ft2, sys_pondingsurfacearea_ft2, sys_orificedia_in, sys_underdrain, sys_peakreleaserate_cfs, sys_rawstormsizemanaged_in, sys_modeledstormsizemanaged_in, sys_creditedstormsizemanaged_in, sys_lrimpervda_ft2, sys_lrtotalda_ft2, sys_lrsurfacedcia_ft2, sys_lrsubsurfacedcia_ft2, sys_notbuiltretired, sys_notbuiltretiredreason, infil_dsg_testdate, infil_dsg_testtype, infil_dsg_boringdepth_ft, infil_dsg_depthtogw_ft, infil_dsg_depthtobedrock_ft, infil_dsg_rate_inhr, infil_constr_testdate, infil_constr_testtype, infil_constr_rate_inhr), algo = "md5"))
  
  project_hash <- projectbestdata %>% 
    rowwise() %>% 
    mutate("hash_md5" = digest(paste(project_id, worknumber, proj_projectname, capit_status, capit_statuscategory, proj_primaryprogram, projsyssum_primaryprogram, proj_pilotfactor, proj_x, proj_y, proj_dataphase, proj_sewertype, projsyssum_sewertypes, proj_bestga, proj_bestda_ft2, proj_estimatedga, proj_estimatedda_ft2, projsyssum_creditedga, projsyssum_rawga, projsyssum_impervda_ft2, projsyssum_storagevolume_ft3, projsmpsum_perviousarea_ft2, proj_nonsmptrees, projsmpsum_smptrees, projsmpsum_basins, projsmpsum_blueroofs, projsmpsum_bumpouts, projsmpsum_cisterns, projsmpsum_depaving, projsmpsum_drainagewells, projsmpsum_greengutters, projsmpsum_greenroofs, projsmpsum_infiltrenches, projsmpsum_perviouspaving, projsmpsum_planters, projsmpsum_raingardens, projsmpsum_stormwatertrees, projsmpsum_swales, projsmpsum_treetrenches, projsmpsum_wetlands), algo = "md5"))
  
  #2.3 query mars data tables -------
  smp_md <- dbGetQuery(mars_data, "select * from external.smpbdv")
  
  system_md <- dbGetQuery(mars_data, "select * from external.systembdv")
  
  project_md <- dbGetQuery(mars_data, "select * from external.projectbdv")
  
  #2.4 compare and find new SMPs, system, and projects -----
  
  new_smps <- smp_hash %>% anti_join(smp_md, by = c("smp_id"))
  
  new_systems <- system_hash %>%  anti_join(system_md, by = c("system_id"))
  
  new_projects <- project_hash %>% anti_join(project_md, by = c("project_id"))
  
  
  #2.5 write/append new smps, systems, projects -----
  
  # #smp
  # dbWriteTable(mars_data, DBI::SQL("external.smpbdv"), new_smps, append= TRUE)
  # 
  # #system
  # dbWriteTable(mars_data, DBI::SQL("external.systembdv"), new_systems, append = TRUE)
  # 
  # #project
  # dbWriteTable(mars_data, DBI::SQL("external.projectbdv"), new_projects, append = TRUE)
  
  #2.6 query mars data tables again ----
  
  smp_md <- dbGetQuery(mars_data, "select * from external.smpbdv")
  
  smp_md_trim <- smp_md %>% 
    dplyr::select(smpbdv_uid, smp_id)
  
  system_md <- dbGetQuery(mars_data, "select * from external.systembdv")
  
  system_md_trim <- system_md %>% 
    dplyr::select(systembdv_uid, system_id)
  
  project_md <- dbGetQuery(mars_data, "select * from external.projectbdv")
  
  project_md_trim <- project_md %>% 
    dplyr::select(projectbdv_uid, project_id)
  
  #2.7 compare and find new HASHES based on smp, system, and projects -----
  
  #smp
  new_smp_hashes <- smp_hash %>% 
    left_join(smp_md_trim, by = "smp_id") %>% 
    anti_join(smp_md, by = c("smp_id", "hash_md5"))
  
  #system
  new_system_hashes <- system_hash %>%
    left_join(system_md_trim, by = "system_id") %>%
    anti_join(system_md, by = c("system_id", "hash_md5")) 
  
  #project
  new_project_hashes <- project_hash %>%
    left_join(project_md_trim, by = "project_id") %>% 
    anti_join(project_md, by = c("project_id", "hash_md5"))
  
  #2.8 write/update new stuff 
  #2.8.1 SMP -----
  #write update query
  update_smp <- dbSendQuery(mars_data, 'update external.smpbdv set project_id=?, smp_dataphase=?, worknumber=?, capit_status=?, capit_statuscategory=?, system_id=?, smp_id=?, smp_smptype=?, smp_footprint_ft2=?, smp_smptrees=?, smp_perviousarea_ft2=?, smp_vegetatedarea_ft2=?, smp_storagedepth_ft=?, smp_pondingdepth_in=?, smp_storagetype=?, smp_pretreatment=?, smp_notbuiltretired=?, smp_notbuiltretiredreason=?, hash_md5=? WHERE smpbdv_uid=?')
  
  # send the updated data
  dbBind(update_smp, new_smp_hashes)
  
  #release the prepared statement
  dbClearResult(update_smp)
  
  #2.8.2 system ----
  #write update query 
  update_system <- dbSendQuery(mars_data, 'update external.systembdv set sys_dataphase=?, worknumber=?, status=?, statuscategory=?, project_id=?, system_id=?, sys_primaryprogram=?, sys_secondaryprograms=?, sys_sewertype=?, sys_overflowtype=?, sys_sysfunction=?, sys_modelinputcategory=?, sys_impervda_ft2=?, sys_surfacedcia_ft2=?, sys_subsurfacedcia_ft2=?, sys_perviousda_ft2=?, sys_totalda_ft2=?, sys_disconnectedarea_ft2=?, sys_storagevolume_ft3=?, sys_totalsysvolume_ft3=?, sys_soilstoragevolume_ft3=?, sys_pondedstoragevolume_ft3=?, sys_volumebeloworifice_ft3=?, sys_creditedga=?, sys_rawga=?, sys_infildepth_ft=?, sys_slowreleasehead_ft=?, sys_storagefootprint_ft2=?, sys_infilfootprint_ft2=?, sys_pondingsurfacearea_ft2=?, sys_orificedia_in=?, sys_underdrain=?, sys_peakreleaserate_cfs=?, sys_rawstormsizemanaged_in=?, sys_modeledstormsizemanaged_in=?, sys_creditedstormsizemanaged_in=?, sys_lrimpervda_ft2=?, sys_lrtotalda_ft2=?, sys_lrsurfacedcia_ft2=?, sys_lrsubsurfacedcia_ft2=?, sys_notbuiltretired=?, sys_notbuiltretiredreason=?, infil_dsg_testdate=?, infil_dsg_testtype=?, infil_dsg_boringdepth_ft=?, infil_dsg_depthtogw_ft=?, infil_dsg_depthtobedrock_ft=?, infil_dsg_rate_inhr=?, infil_constr_testdate=?, infil_constr_testtype=?, infil_constr_rate_inhr=?, hash_md5=? WHERE systembdv_uid =?')
  
  #send the updated data 
  dbBind(update_system, new_system_hashes)
  
  #release the prepared statement
  dbClearResult(update_system)

  #2.8.3 project -------
  #write update query 
  update_project <- dbSendQuery(mars_data, 'update external.projectbdv set project_id=?, worknumber=?, proj_projectname=?, capit_status=?, capit_statuscategory=?, proj_primaryprogram=?, projsyssum_primaryprogram=?, proj_pilotfactor=?, proj_x=?, proj_y=?, proj_dataphase=?, proj_sewertype=?, projsyssum_sewertypes=?, proj_bestga=?, proj_bestda_ft2=?, proj_estimatedga=?, proj_estimatedda_ft2=?, projsyssum_creditedga=?, projsyssum_rawga=?, projsyssum_impervda_ft2=?, projsyssum_storagevolume_ft3=?, projsmpsum_perviousarea_ft2=?, proj_nonsmptrees=?, projsmpsum_smptrees=?, projsmpsum_basins=?, projsmpsum_blueroofs=?, projsmpsum_bumpouts=?, projsmpsum_cisterns=?, projsmpsum_depaving=?, projsmpsum_drainagewells=?, projsmpsum_greengutters=?, projsmpsum_greenroofs=?, projsmpsum_infiltrenches=?, projsmpsum_perviouspaving=?, projsmpsum_planters=?, projsmpsum_raingardens=?, projsmpsum_stormwatertrees=?, projsmpsum_swales=?, projsmpsum_treetrenches=?, projsmpsum_wetlands=?, hash_md5=? WHERE projectbdv_uid=?')
  
  #send the updated data
  dbBind(update_project, new_project_hashes)
  
  #release
  dbClearResult(update_project)




