# 
# shinyUI(
#   fluidPage(theme = shinytheme("cerulean")       
#     # render map created in server.r
#     #, leafletOutput("map_in_ui" , width = "0", height = "0")
#     , leafletOutput("map_in_ui" , width = "100%", height = "1800")
#     
#     ### vasemman puolen paneeeli
#     
#     , absolutePanel( style = "background-color: #ffffff;"
#       , fixed = F, draggable = FALSE
#       , id = "left_side_panel"
#       , top = 70, left = 0 , right = "auto" , bottom = "auto"
#       , width = 330, height = "auto" 
#       , h3("Koti-osoite")
#       , textInput("kotiosoite_from_ui", label = p(""), value = "Kotiosoite") 
# 
#       , conditionalPanel( condition = "input.kotiosoite_from_ui != 'Kotiosoite'"
#                           , h5('Hyvin menee')
#                           #, plotOutput( "koti_pic" )
#                           , showOutput("test_data_time_series_plot" , 'nvd3' )
#       )
#     )
#     
#     ### oikean puolen debug paneeeli
#     , if(DEBUG){
#       absolutePanel(  style = "background-color: #ffffff;"
#         , fixed = F, draggable = T
#         , id = "right_side_panel"
#         , top = 60, left = "auto", right = 40, bottom = "auto"
#         , width = 500, height = "auto"
#         , h3("DEBUG")
#         , textOutput("click_latlon")
#         , textOutput("click_address")
#         , textOutput("click_all_info")
#       )}
#   )
# )



shinyUI(
  fluidPage(
#     theme = shinytheme("cerulean") ,
     sidebarLayout(
      
      ### vasemman puolen paneeeli
      
      sidebarPanel(  style = "background-color: #ffffff;"
        , width = 3               
        , h3("Osoitteet")
        , textInput("kotiosoite_from_ui", label = p(""), value = "Kotiosoite") 
        , textInput("tyo_osoite_from_ui", label = p(""), value = "Työpaikan osoite") 
        , textInput("pontentiaalinen_osoite_from_ui", label = p(""), value = "Potentiaalinen osoite") 
        
        , conditionalPanel( condition = "input.kotiosoite_from_ui != 'Kotiosoite'"
                            , h5('Hyvin menee')
                            #, plotOutput( "koti_pic" )
                            , showOutput("test_data_time_series_plot" , 'nvd3' )
        )
      )
      , mainPanel(  
        width = 9
        # render map created in server.r
        #, leafletOutput("map_in_ui" , width = "0", height = "0")
        , leafletOutput("map_in_ui" , width = "100%", height = "1800")
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
