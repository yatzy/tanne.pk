# ui_dir <- dirname(sys.frame(1)$ofile)
# devtools::install_github("rstudio/leaflet")

shinyUI(
  navbarPage("Muutanko tänne?"
             , tabPanel("Sovellus"
                        
                        # render map created in server.r
                        , leafletOutput("map_in_ui" , width = "100%", height = "1800")
                        
                        ### vasemman puolen paneeeli
                        
                        , absolutePanel( 
                          fixed = F, draggable = FALSE
                          , id = "left_side_panel"
                          , top = 60, left = 40 , right = "auto" , bottom = "auto"
                          , width = 330, height = "auto" 
                          , h3("Koti-osoite")
                          , textInput("kotiosoite_from_ui", label = p(""), value = "Kotiosoite") 
                          , conditionalPanel( condition = "input.kotiosoite_from_ui != 'Kotiosoite'"
                                              , h5('Hyvin menee')
                                              , plotOutput( "koti_pic" )
                          )
                        )
                        
                        ### oikean puolen paneeeli
                        
                        , absolutePanel(  
                          fixed = F, draggable = FALSE
                          , id = "right_side_panel"
                          , top = 60, left = "auto", right = 40, bottom = "auto"
                          , width = 330, height = "auto"
                          , h3("Muutto-osoite")
                          , textInput("muutto_osoite_from_ui", label = p(""), value = "Muutto-osoite") 
                          , conditionalPanel(
                            condition = "input.muutto_osoite_from_ui != 'Muutto-osoite'"
                            , h5('Täällähän menee huonosti')
                            , plotOutput( "muutto_pic" )
                          )
                        )
             )           
  )
)
