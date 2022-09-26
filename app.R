#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(sf)
library(tidyverse)
library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
library(terra)
library(sf)
library(dplyr)
library(reshape2)

# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("united"),

    # Application title
    titlePanel("SMI for social scientists"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("threshold",
                        "The SMI drought level threshold",
                        min = 0,
                        max = 1,
                        value = .2),
            
            
            #textInput("date_from", "Starting date (please use specified format)", 
            #          value = "2002-12-31", 
            #          width = NULL, 
            #          placeholder = NULL),
            
            dateInput("date_from", "Starting date:", value = "2002-12-31", format = "yyyy/mm/dd"),
            dateInput("date_end", "Ending date:", value = "2004-01-31", format = "yyyy/mm/dd"),
            
           
            downloadButton("downloadData", "Download")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  
  reading_data_threshold_dates <- reactive({
    fn_new<-"248981_SMI_SM_Lall_Gesamtboden_monatlich_1951-2020_inv.nc"
    threshold <- input$threshold
    nc <- raster::brick(fn_new)
    dates <- getZ(nc)
    fn2<-subset(nc, which(dates > as.Date(input$date_from) & dates<as.Date(input$date_end)))
    fn2
  })
  
  
  
  currentFib <- reactive({ 
    
    #the drought monitor data
   
    
    #polys <- raster::shapefile("nuts/EPSG_31468_shapefile.shp")
    polys <- sf::read_sf("nuts/EPSG_31468_shapefile.shp")
    
    zonal_stats <- as.data.frame(raster::extract(reading_data_threshold_dates(), polys, 
                                                 fun=function(i, ...) sum(i<input$threshold)/length(i), 
                                                 na.rm=TRUE))
    results <- zonal_stats %>% 
      as_tibble() %>% 
      mutate(subdistrict=0:400) %>% 
      tidyr::pivot_longer(!subdistrict, values_to = "smi", names_to = "date") %>% 
      mutate(date = lubridate::ymd(gsub("X", "",date))) %>% 
      mutate(date_month = lubridate::month(date),
             date_year = lubridate::year(date)) %>% 
      group_by(subdistrict) %>% 
      summarise(area_under_drought = mean(smi, na.rm = TRUE))
    
    
    polys$subdistrict=seq(0,400,1)  
    polys_1=merge(polys,results,by=c("subdistrict"))
    
    
    polys_1
    
    
    
    
    })
  
  
    output$distPlot <- renderPlot({
      
      
      
      
      ggplot(data = currentFib() %>% sf::st_as_sf(),
             aes(fill = area_under_drought
             ), color = "white")+
        geom_sf(lwd = 0, color = NA)+
        theme_minimal()+
        theme(panel.background = element_blank(),
              panel.grid = element_blank(),
              axis.text = element_blank())+
        scale_fill_gradient2(low = "white",mid = "yellow", high = "red",
                             breaks = c(0, .5, 1))
      
      
    })
    
    
    
    output$downloadData <- downloadHandler(
      filename = function() {
        paste("area_under_drought", ".csv", sep = "")
      },
      content = function(file) {
        write.csv(currentFib(), file, row.names = FALSE)
      }
    )
    
}

# Run the application 
shinyApp(ui = ui, server = server)
