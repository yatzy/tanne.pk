shinyUI(
  fluidPage( 
    useShinyjs() , 
    
    # emphasis for next address to get updated
    shinyjs::inlineCSS(list(.emph_box_koti = "border-color:#005C94;border-style:solid;border-width: 3px;")) , 
    shinyjs::inlineCSS(list(.emph_box_tyo = "border-color:#6CDC5C;border-style:solid;border-width: 3px;")) , 
    shinyjs::inlineCSS(list(.emph_box_potentiaalinen = "border-color:#6CDCFA;border-style:solid;border-width: 3px;")) , 
    # shinyjs::inlineCSS(list(.emph_box_koti = "border-color:#005C94;border-style:none none solid none;border-width: 3px;")) , 
    
    # theme with custom css
    theme = "cerulean_fork.css" ,
    
    sidebarLayout(
      
      ### vasemman puolen paneeeli
      sidebarPanel(      
        
        style = "height:100vh;background-color: #ffffff;overflow-y:auto"
        , width = 4             
        
        # osoitteet
        , div(style = "display:flex", id = "ui_koti_emphasis"
              , div(style="flex: 1;margin-left:-20px;" , img(src="home.png") )
              , div(style = "flex: 0;" , checkboxInput(inputId='ui_koti_selected' , label=NULL , value = T ) )
              , div(style="flex: 8;" , uiOutput("koti_valikko") )
        )
        , div(style= "display: flex", id = "ui_tyo_emphasis"
              , div(style="flex: 1;margin-left:-20px;" , img(src="work.png") )
              , div(style = "flex: 0;" , checkboxInput(inputId='ui_tyo_selected' , label=NULL , value = T ) )
              , div(style="flex: 8" , uiOutput("tyo_valikko") )
        )
        , div(style= "display: flex", id = "ui_potentiaalinen_emphasis"
              , div(style="flex: 1;margin-left:-20px;" , img(src="potential.png") )
              , div(style = "flex: 0;" , checkboxInput(inputId='ui_potentiaalinen_selected' , label=NULL,value = T ) )
              , div(style ="flex:8;" , uiOutput("potentiaalinen_valikko") )
        )
        
        ### initiation notifications
        , bsAlert("initiation_notification1")
        , bsAlert("initiation_notification2")
        , bsAlert("initiation_notification3")
        , bsAlert("initiation_notification4")
        
        ### reitit
        , conditionalPanel(condition = "input.show_pendeling_plot == true"
                           , plotOutput("pendeling_plot", height = "400px") 
        )
        ## statit
        , conditionalPanel(condition = "input.show_asuntojen_hinnat_plot==true"
                           , plotOutput("asuntojen_hinnat_plot" , height = "250px" )
        )
        , conditionalPanel(condition = "input.show_talojakauma_plot==true"
                           , plotOutput("talojakauma_plot" , height = "150px" )
        )
        , conditionalPanel(condition = "input.show_asumisvaljyys_plot==true"
                           , plotOutput("asumisvaljyys_plot" , height = "150px" )
        )
        , conditionalPanel(condition = "input.show_koulutusjakauma_plot==true"
                           , plotOutput("koulutusjakauma_plot" , height = "200px" )
        )
        , conditionalPanel(condition = "input.show_ikajakauma_plot==true"
                           , plotOutput("ikajakauma_plot" , height = "250px" )
        )
        , conditionalPanel(condition = "input.show_tulojakauma_plot==true"
                           , plotOutput("tulojakauma_plot" , height = "250px" )
        )
        , conditionalPanel(condition = "input.show_keskitulot_plot==true"
                           , plotOutput("keskitulot_plot" , height = "150px" )
        )
        , conditionalPanel(condition = "input.show_toimintajakauma_plot==true"
                           , plotOutput("toimintajakauma_plot" , height = "250px" )
        )
        , conditionalPanel(condition = "input.show_yleisimmat_ammatit_table==true"
                           , h4("Yleisimmät ammattiryhmät alueella", align = "center")
                           , tableOutput("yleisimmat_ammatit_table")
        )
      )
      
      ### pääpaneeli
      , mainPanel(  style = "height:100vh;background-color: #ffffff;padding:0;margin-left:0"
                    , width = 8
                    , leafletOutput("map_in_ui" , width = "100%", height = "100%")
      )
    )
    
    ### settings panel
    , absolutePanel( style = 'height:70vh;overflow-y:auto'
                     , width = 300
                     , top = 90
                     , right = 20
                     , conditionalPanel("input.settings_button%2 != 0 "
                                        , wellPanel( 
                                          checkboxGroupInput_fork(inputId = 'palvelut_extra_group'
                                                                  , label = 'Haettavat palvelut'
                                                                  , choices = palvelut_nimet
                                                                  , selected = names(palvelut_nimet) )
                                          
                                          , sliderInput( 'radius' , 'Palvelujen hakusäde (km)' , min=0 , max=5 , value=1 )
                                          
                                          , checkboxInput(inputId = 'show_pendeling_plot','Työmatkat',T)
                                          , checkboxInput(inputId = 'show_asuntojen_hinnat_plot','Asuntojen hinnat',T)
                                          , checkboxInput(inputId = 'show_talojakauma_plot','Talotyypit',T)
                                          , checkboxInput(inputId = 'show_asumisvaljyys_plot','Asumisväljyys',T)
                                          , checkboxInput(inputId = 'show_koulutusjakauma_plot','Koulutustasot',T)
                                          , checkboxInput(inputId = 'show_ikajakauma_plot','Ikäjakauma',T)
                                          , checkboxInput(inputId = 'show_tulojakauma_plot','Tulojakauma',T)
                                          , checkboxInput(inputId = 'show_keskitulot_plot','Keskitulot',T)
                                          , checkboxInput(inputId = 'show_toimintajakauma_plot','Pääasiallinen toiminta',T)
                                          , checkboxInput(inputId = 'show_yleisimmat_ammatit_table','Yleisimmät ammattiryhmät',T)
                                        )
                     )
    )
    
    ### settings button
    , absolutePanel( 
      tags$style( "#settings_button{background:transparent;}")
      , top = 0
      , right = 70
      , bottom = "auto"
      , width = 1
      , height = 1
      , actionButton( inputId="settings_button",'', icon = img(src="settings.png"),width=70, height=1 )
    )
    
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
        , textOutput("input.selected_boxes")
        , textOutput("click_latlon")
        , textOutput("click_address")
        , textOutput("click_all_info")
        , dataTableOutput("test_table")
        , textOutput("click_count_text")
      )
    }
    
    # for testing settings_button
    #     , singleton(
    #       tags$head(tags$script(src = "message-handler.js"))
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
    
    #         # palveluboxit
    #         
    #         , uiOutput("palvelut_box")
    #         , uiOutput("palvelut_extra_box")
    #         , uiOutput("palvelut_extra_group")
    
    
  )  
)
