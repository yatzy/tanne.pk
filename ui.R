
shinyUI(
  fluidPage(
    #     theme = shinytheme("cerulean") ,
    sidebarLayout(fluid = F
      
      ### vasemman puolen paneeeli
      
     , sidebarPanel(  style = "background-color: #ffffff;"
                      ,tags$style(type="text/css", ".tab-content { overflow: visible; }")
                     , width = 3               
                     
#                      ,   tags$head(
#                        # Include our custom CSS
#                        includeCSS("styles.css")
#                        #, includeScript("gomap.js")
#                      )             
                     
                     , h3("Osoitteet")
                     
                     , uiOutput("koti_valikko")
                     , uiOutput("tyo_valikko")
                     , uiOutput("potentiaalinen_valikko")
                     
                     , plotOutput("asuntojen_hinnat_plot" , height = "250px" )
                     , plotOutput("talojakauma_plot" , height = "150px"   )
                     , plotOutput("koulutusjakauma_plot" , height = "200px"   )
                     , plotOutput("toimintajakauma_plot" , height = "250px"   )
                     , plotOutput("ikajakauma_plot" , height = "250px"   )
                     #         , conditionalPanel( condition = "input.kotiosoite_from_ui != 'Kotiosoite'"
                     #                             , plotOutput("asuntojen_hinnat_plot" , height = "250px" )
                     #                             , plotOutput("talojakauma_plot" , height = "150px"   )
                     #                             , plotOutput("koulutusjakauma_plot" , height = "200px"   )
                     #                             , plotOutput("toimintajakauma_plot" , height = "250px"   )
                     #                             , plotOutput("ikajakauma_plot" , height = "250px"   )
                     #         )
      )
      
      # pääpaneeli
      
      , mainPanel(  
        # tags$style(type = "text/css", "html, body {width:100%;height:100%}")
        width = 9
        # render map created in server.r
        , leafletOutput("map_in_ui" , width = "100%", height = "1000px")
        # , leafletOutput("map_in_ui" , width = "100%", height = "100%" )
      )
    )
    
    
    ### oikean puolen debug-paneeeli
    , if(DEBUG){
      absolutePanel(  
        style = "background-color: #ffffff;"
        , fixed = F
        , draggable = T
        #           , id = "right_side_panel"
        , top = 60
        , left = "auto"
        , right = 40
        , bottom = "auto"
        , width = 500
        , height = "auto"
        , h5("DEBUG")
        , textOutput("click_latlon")
        , textOutput("click_address")
        , textOutput("click_all_info")
        , dataTableOutput("test_table")
      )
    }
  )  
)
