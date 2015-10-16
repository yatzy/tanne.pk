
shinyUI(
  fluidPage(
    #     theme = shinytheme("cerulean") ,
    sidebarLayout(
      
      ### vasemman puolen paneeeli
      
      sidebarPanel(      

        style = "height:100vh;background-color: #ffffff;overflow-y: auto; }"
        , width = 4             
        , h3("Osoitteet")
        
        , uiOutput("koti_valikko")
        , uiOutput("tyo_valikko")
        , uiOutput("potentiaalinen_valikko")
        , uiOutput("palvelut_box")
        , uiOutput("palvelut_extra_box")
        , uiOutput("palvelut_extra_group")
        , plotOutput("asuntojen_hinnat_plot" , height = "250px" )
        , plotOutput("talojakauma_plot" , height = "150px"   )
        , plotOutput("koulutusjakauma_plot" , height = "200px"   )
        , plotOutput("toimintajakauma_plot" , height = "250px"   )
        , plotOutput("ikajakauma_plot" , height = "250px"   )
      )
      
      # pääpaneeli
      
      , mainPanel(  style = "height:100vh;background-color: #ffffff;"
                    , width = 8
                    , leafletOutput("map_in_ui" , width = "100%", height = "100%")
      )
    )
    
    , absolutePanel(  
      style = "background-color: #ffffff;"
      , fixed = F
      , draggable = F
      
      , top = 0
      #, left = "auto"
      , right = 0
      , bottom = "auto"
      , width = 100
      , height = "auto"
      , h5("DEBUG")
      
      , actionButton("alkuun_nappi", "Palaa alkuun")
      
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
