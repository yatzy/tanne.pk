shinyUI(
  
  navbarPage(
    title= div(style="position: relative;top: 50%;transform: translateY(-50%);"
               , img(src='logo20151108.png' , height="45px" ) )
    
    #     title= div(style="  position: relative;top: 50%;transform: translateY(-50%);"
    #                , img(src="home.svg", height="50px") , 'pkmuutto.info' , img(src="potential.svg", height="50px") )
    
    , theme = "cerulean_fork.css" 
    , position = "fixed-top"
    , windowTitle = 'pkmuutto.info'
    , header= tags$script("www/piwik.js")
    , tabPanel("Sovellus"  
               
               , useShinyjs()  
               # emphasis for next address to get updated
               , shinyjs::inlineCSS(list(.emph_box_koti = "border-color:#005C94;border-style:solid;border-width: 3px;")) 
               , shinyjs::inlineCSS(list(.emph_box_tyo = "border-color:#6CDC5C;border-style:solid;border-width: 3px;"))  
               , shinyjs::inlineCSS(list(.emph_box_potentiaalinen = "border-color:#6CDCFA;border-style:solid;border-width: 3px;")) 
               
               , sidebarLayout(
                 ### vasemman puolen paneeeli
                 sidebarPanel( 
                   style = "height:95vh;background-color: #ffffff;overflow-y:auto;margin:50px 0px 20px" , width = 4
                   
                   # osoitteet
                   , div(style = "display:flex", id = "ui_koti_emphasis"
                         , div(style="flex: 1;margin-left:-20px;" , img(src="home.png") )
                         , div(style = "flex:0;" , checkboxInput(inputId='ui_koti_selected' , label=NULL , value = T ) )
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
                 , mainPanel(  
                   style = "height:95vh;background-color: #ffffff;margin: 40px 0px 40px 0px;" # TOIMIVA SINÄNSÄ
                   , width = 8
                   , leafletOutput("map_in_ui" , width = "100%", height = "100%")
                 )
               )  
    )
    , tabPanel("Asetukset"  
               , style='overflow:none;margin:70px 20px'
               , fluidRow(
                 column(3)
                 , column(3
                          , checkboxGroupInput_fork(inputId = 'palvelut_extra_group'
                                                    , label = 'Haettavat palvelut'
                                                    , choices = palvelut_nimet
                                                    , selected = names(palvelut_nimet) )
                          
                          , sliderInput( 'radius' , 'Palvelujen hakusäde (km)' 
                                         , min = service_radius_min 
                                         , max = service_radius_max 
                                         , value = service_radius_by )
                 )
                 , column(3 , HTML('<b>Näytettävät kuvaajat</b>')
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
                 , column(3)
               )
    )
    , tabPanel("Info"  
               , style = "height:100%;margin: 60px 5px;text-align: justify;text-justify: inter-word;"
               , column(1)
               , column(4
                        , style='height:95vh;overflow:auto;'
                        , bsAlert("initiation_notification1")
                        , bsAlert("initiation_notification2")
                        , bsAlert("initiation_notification3")
               )
               , column(1)
               , column(5
                        , style = 'height:95vh;overflow:auto;'
                        , h1('Infoa palvelusta')
                        , info1
                        , h2('Haettavat palvelut')
                        , info2
                        , h2('Matka-ajat')
                        , info3
                        , h2('Muut kuvaajat')
                        , info4
                        
               )
               , column(1)
    )
  )
)
