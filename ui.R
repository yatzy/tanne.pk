shinyUI(
  
  navbarPage(title='pkmuutto.info'
             , theme = "cerulean_fork.css" 
             , header = ""
             , windowTitle = 'pkmuutto.info'
             , tabPanel("Sovellus"  
                        , style = "margin-top:-19px" 
                        
                        , useShinyjs()  
                        # emphasis for next address to get updated
                        , shinyjs::inlineCSS(list(.emph_box_koti = "border-color:#005C94;border-style:solid;border-width: 3px;")) 
                        , shinyjs::inlineCSS(list(.emph_box_tyo = "border-color:#6CDC5C;border-style:solid;border-width: 3px;"))  
                        , shinyjs::inlineCSS(list(.emph_box_potentiaalinen = "border-color:#6CDCFA;border-style:solid;border-width: 3px;")) 
                        
                        , sidebarLayout(
                          ### vasemman puolen paneeeli
                          sidebarPanel( style = "height:100vh;background-color: #ffffff;overflow-y:auto" , width = 4
                                        
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
                            # style = "height: calc(100vh - 18px);background-color: #ffffff;padding:0;margin-left:0;"
                            style = "height:100vh;background-color: #ffffff;padding:0;margin-left:0"
                            , width = 8
                            , leafletOutput("map_in_ui" , width = "100%", height = "100%")
                          )
                        )  
             )
             , tabPanel("Asetukset"  ,
                        fluidRow(
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
                        ### initiation notifications
                        , column(3
                                 , bsAlert("initiation_notification1")
                                 , bsAlert("initiation_notification2")
                                 , bsAlert("initiation_notification3")
                        )
                        , column(9
                                 , HTML('<p><b>Infoa palvelusta</b></p>')
                                 , HTML('<p>Palvelun avulla pk-seudulle muuttoa harkitsevat saavat lisätietoja päätöksensä tueksi avoimen datan kautta. Palvelu on tarkoitettu ensisijaisesti pk-seudun sisällä muuttaville, jolloin nykyistä asuinaluettaan voi verrata potentiaaliseen muuttokohteeseen. Palvelu toimii toki muualtakin muuttaville, mutta silloin ei voi vertailla aluetta kotiosoitteeseensa. Haluamme palvelullamme avustaa muuttajaa tekemään paremman päätöksen tarjoamalla asuinalueeseen liittyvää tietoa helposti yhdestä paikasta.</p>
                                        
                                        <p>Palvelu on vielä kehitysasteella, joten kaikki ominaisuudet eivät välttämättä toimi odotetulla tavalla. Voit lähettää tietoa virheistä tai kehittämisehdotuksista osoitteeseen X TODO.</p>
                                        
                                        <p>Palvelusta saa katuosoitekohtaisena tietona seuraavat lähipalvelut: Ala-asteet, yläasteet, kirjastot, sairaalat, terveysasemat, päiväkodit ja vanhainkodit. Lisäksi osoitekohtaisena tietona annetaan reittioppaasta arvioidut matka-ajan vaihteluväli aamuisin ja iltaisin käyttäjän ilmoittamaan työpaikkaan sekä Helsingin keskustaan. Lisäksi käyttäjä voi vertailla kotialueensa ja potentiaalisen muuttoalueen asuntojen hintatietoja sekä demografista dataa kuten koulutustasot, ikäjakauman, tulojakauman, keskitulot, pääasialliset toiminnot ja yleisimmät ammattiryhmät.</p>
                                        
                                        <p>Tarkemmat kuvaukset toiminnoista alla:</p>'),
                        HTML('<p><b>Haettavat palvelut</b></p>
                             <p>Käyttäjän syöttäessä kotiosoitteen ja vastaavasti potentiaalisen osoitteen kartalla näytetään oletuksena yhden kilometrin päässä olevat ala-asteet, yläasteet, kirjastot, sairaalat, terveysasemat, päiväkodit ja vanhainkodit. Jos jotain näistä palveluista ei ole tarjolla ollenkaan yhden kilometrin päässä, näytetään kuitenkin yksi lähin palvelu.</p>
                             
                             <p>Asetukset-sivulla käyttäjä voi muuttaa näytettävien palveluiden sädettä 1-5 kilometrin välillä. Lisäksi voi valita kunkin palvelukegorian kohdalla haluaako kyseistä kategoriaa näytettäväksi kartalla. Jos esimerkiksi päiväkodit tai vanhainkodit eivät ole sinulle kiinnostavia palveluita, voit ruksista valita ettei niitä näytetä kartalla.</p>
                             
                             <p><b>Matka-ajat</b></p>
                             
                             <p>Matka-aika arviot on haettu reittioppaan rajapinnan kautta. Käyttäjälle ilmoitetaan vaihteluväli reittioppaan ilmoittamasta matkan kestosta aamulla kellonajoilla X TODO ja illalla kellonajoilla X TODO. Helsingin keskustan osoitteeksi on valittu X TODO.</p>
                             
                             <p><b>Muut näytettävät kuvaajat</b></p>
                             
                             <p>Aluekohtaiset asuntojen hintatiedot on saatu palvelusta X TODO</p>
                             
                             <p>Aluekohtaiset koulutustasot, ikäjakaumat, tulojakaumat, keskitulot, pääasialliset toiminnot ja yleisimmät ammattiryhmät on saatu palvelusta X TODO</p>
                             
                             <p><b>Kiitokset</b></p>
                             
                             <p>Duukkis TODO</p>')
                        )
                        
             )
             
  )
)
