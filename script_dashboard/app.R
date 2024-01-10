# SET UP
#0.0: load libraries --------------
#shiny
library(shiny)
#pool for database connections
library(pool)
#odbc for database connections
library(odbc)
#tidyverse for data manipulations
library(tidyverse)
#shinythemes for colors
library(shinythemes)
#lubridate to work with dates
library(lubridate)
#shinyjs() to use easy java script functions
library(shinyjs)
#DT for datatables
library(DT)
#reactable for reactable tables
library(reactable)
#DBI FOR writing to DB
library(DBI)

#0.1: database connection and global options --------

#set default page length for datatables
options(DT.options = list(pageLength = 15))
version = '1.0.0'

#set db connection
#using a pool connection so separate connnections are unified
#gets environmental variables saved in local or pwdrstudio environment
poolConn <- dbPool(odbc(), dsn = "mars14_datav2", uid = Sys.getenv("shiny_uid"), pwd = Sys.getenv("shiny_pwd"))

#disconnect from db on stop 
onStop(function(){
 poolClose(poolConn)
})


# Define UI
ui <- navbarPage(paste("Script Dashboard", version), theme = shinytheme("cerulean"),
    
    tabPanel("Condensed View",
      DTOutput("logs"))
)

# Server logic
server <- function(input, output) {
  print("Querying DB. This should only happen once.")
  
  script_table <- dbGetQuery(poolConn, "select * from log.viw_script_dashboard") %>%
    transmute(Script = script, `Task Order` = as.numeric(task_order), `Date` = date, `Exit Code` = coalesce(status, 0), Note = note) %>%
    arrange(`Task Order`) %>%
    select(-`Task Order`)
  script_names <- pull(script_table, Script) %>% unique
  
  date_cutoff <- lubridate::today() - days(2) #Script runs older than this indicate a non-firing script
  
  output$logs <- renderDT(
    DT::datatable(
      script_table,
      rownames = FALSE,
      options = list(
        columnDefs = list(list(className = 'dt-center', targets = c(2)))
      )
    ) %>% formatStyle(
      3, #Exit Code column
      target = 'row',
      backgroundColor = styleInterval(0, c(NA, '#CC7F50'))
    )%>% formatStyle(
      2, #Date column,
      target = 'row',
      backgroundColor = styleInterval(date_cutoff, c('#770000', NA)),
      color = styleInterval(date_cutoff, c('white', 'black'))
    )
  )
}

# Complete app with UI and server components
shinyApp(ui, server)
