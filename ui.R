# 
shinyUI(
  fluidPage( 
    theme = "cerulean_fork.css"
    
    , sidebarLayout( 
      
      ### vasemman puolen paneeeli
      
      sidebarPanel(      
        
        style = "height:100vh;background-color: #ffffff;overflow-y:auto"
        , width = 4             
        # , h3("Osoitteet")
        
        # osoitteet
        
        , div(style = "display:flex"
              , div(style="flex: 1" , img(src="home.png") )
              , div(style="flex: 5" , uiOutput("koti_valikko") )
        )
        , div(style= "display: flex"
              , div(style="flex: 1" , img(src="work.png") )
              , div(style="flex: 5" , uiOutput("tyo_valikko") )
        )
        , div(style= "display: flex"
              , div(style="flex: 1" , img(src="potential.png") )
              , div(style ="flex:5;" , uiOutput("potentiaalinen_valikko") )
        )
        
        # reitit
        , plotOutput("pendeling_plot")
        
        #         # palveluboxit
        #         
        #         , uiOutput("palvelut_box")
        #         , uiOutput("palvelut_extra_box")
        #         , uiOutput("palvelut_extra_group")
        
        # statit
        
        , plotOutput("asuntojen_hinnat_plot" , height = "250px" )
        , plotOutput("talojakauma_plot" , height = "150px" )
        , plotOutput("koulutusjakauma_plot" , height = "200px" )
        , plotOutput("toimintajakauma_plot" , height = "250px" )
        , plotOutput("ikajakauma_plot" , height = "250px" )
      )
      
      # pääpaneeli
      
      , mainPanel(  style = "height:100vh;background-color: #ffffff;padding:0;margin-left:0"
                    , width = 8
                    , leafletOutput("map_in_ui" , width = "100%", height = "100%")
      )
    )
    
    # settings button
    
    , absolutePanel( 
      theme = "opacity:0.01;background:transparent;border:0px;"
      , top = 0
      , right = 70
      , bottom = "auto"
      , width = 1
      , height = 1
      # , submitButton( text="settings_button", icon = img(src="settings.png") )
      , actionButton( inputId="settings_button",'', icon = img(src="settings.png"),width=70, height=1 )
      # , submitButton("Settings", icon("cog"))
    ) , tags$style(type='text/css', "#settings_button { background:transparent;border:0px;}") # opacity:0.51;
    
    # settings panel
    
    # for testing settings_button
#     , singleton(
#       tags$head(tags$script(src = "message-handler.js"))
#     )
    
    , absolutePanel( 
       top = 50
      , right = 0
      , bottom = "auto"
      , conditionalPanel("input.settings_button%2 != 0"
                         , checkboxGroupInput(inputId = 'palvelut_extra_group'
                                              , label = NULL
                                              , choices = palvelut_nimet
                                              , selected = palvelut_nimet )
      )
    )
    
    #     , conditionalPanel("input.settings_button == true"
    #                        , checkboxGroupInput(inputId = 'palvelut_extra_group'
    #                                             , label = NULL
    #                                             , choices = palvelut_nimet
    #                                             , selected = palvelut_nimet )
    #     )
    
    
    
    #     , absolutePanel(  
    #       style = "background-color: #ffffff;"
    #       , fixed = F
    #       , draggable = F
    #       
    #       , top = 0
    #       , right = 0
    #       , bottom = "auto"
    #       , width = 100
    #       , height = "auto"
    #       , h5("DEBUG")
    #       , actionButton("alkuun_nappi", "Palaa alkuun")
    #     )
    
    
    ### oikean puolen debug-paneeeli
    , if(DEBUG){
      absolutePanel(  
        style = "background-color: #ffffff;"
        , fixed = F
        , draggable = T
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
