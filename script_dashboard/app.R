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

#set db connection
#using a pool connection so separate connnections are unified
#gets environmental variables saved in local or pwdrstudio environment
poolConn <- dbPool(odbc(), dsn = "mars14_datav2", uid = Sys.getenv("shiny_uid"), pwd = Sys.getenv("shiny_pwd"))

#disconnect from db on stop 
onStop(function(){
 poolClose(poolConn)
})


# Define UI
ui <- fluidPage(
  
  # Application title
  titlePanel("Hello Shiny!"),
  
  sidebarLayout(
    
    # Sidebar with a slider input
    sidebarPanel(
      selectizeInput('foo', label = "Scripts", choices = NULL)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      DTOutput("logs")
    )
  )
)

# Server logic
server <- function(input, output) {
  print("Querying DB. This should only happen once.")
  
  script_table <- dbGetQuery(poolConn, "select * from log.viw_script_dashboard")
  script_names <- pull(script_table, script) %>% unique
  
  output$logs <- renderDT(
    script_table
  )
}

# Complete app with UI and server components
shinyApp(ui, server)
