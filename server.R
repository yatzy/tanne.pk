
shinyServer(function(input, output, session) {
  
  ### init ui components
  # print(init_ready) 
  output$koti_valikko = renderUI({
    textInput("koti_osoite_from_ui", label = p(""), value = koti_value_default) 
  })
  output$tyo_valikko = renderUI({
    textInput("tyo_osoite_from_ui", label = p(""), value = tyo_value_default) 
  })
  output$potentiaalinen_valikko = renderUI({
    textInput("potentiaalinen_osoite_from_ui", label = p(""), value = potentiaalinen_value_default) 
  })
  
  # Palvelut
  output$palvelut_box = renderUI({
    checkboxInput('palvelut', 'Palvelut', TRUE)
  })
  
  output$palvelut_extra_box = renderUI({
    checkboxInput('palvelut_extra_auki', 'Lisää vaihtoehtoja', FALSE)
  })
  
  output$palvelut_extra_group = renderUI({
    conditionalPanel(condition = 'input.palvelut_extra_auki == true',
                     checkboxGroupInput('palvelut_extra_group',NULL,palvelut_nimet,selected=palvelut_nimet))
  })
  
  # inittaa postikoodille kerättävät objektit
  zip_objects = reactiveValues(asuntojen_hinnat = NULL , alue_info = NULL )
  
  ### create map to ui
  
  output$map_in_ui <- renderLeaflet({
    # init map
    leaflet() %>%
      # add map layer
      addTiles('//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png'
               , attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>' ) %>% 
      # set initial boundaries to centre of Helsinki
      setView( lng=24.95 , lat=60.21 , zoom = 11)
  }) 
  
  # click_info() - functio palauttaa viimeisimmän karttaklikin leveys- ja pituuspiirit, sekä osoitetiedot
  
  click_info <<- eventReactive(input$map_in_ui_click , { 
    click_count <<- click_count + 1
    print(click_count)
    list(
      lat = as.numeric(input$map_in_ui_click$lat)
      , lon = as.numeric(input$map_in_ui_click$lng)
      , value = c( lon = as.numeric(input$map_in_ui_click$lng)
                   , lat = as.numeric(input$map_in_ui_click$lat) )
      , rounded = c( lon = round(as.numeric(input$map_in_ui_click$lng) , 3) 
                     , lat = round(as.numeric(input$map_in_ui_click$lat) , 3))
      , adress_details = reverse_geocode_nominatim(lat = input$map_in_ui_click$lat
                                                   , lon = input$map_in_ui_click$lng
                                                   , get = 'listing' ) )
  })
  
  
  ### notify ui that map clicked ###
  
  observeEvent(input$map_in_ui_click, {
    click_time <<- Sys.time()
    cat('KLIKKI!!! LAT:', click_info()$lat, 'LON:' , click_info()$lon ,'\n'  )
    
    if( input$koti_osoite_from_ui == koti_value_default ){
      cat('klikki koski kotia')
      print(input$koti_osoite_from_ui)
      output$koti_valikko = renderUI({
        textInput("koti_osoite_from_ui", label = p("")
                  , value = address_from_listing(click_info()$adress_details ) )
      })
      
    } else if( input$tyo_osoite_from_ui == tyo_value_default ){
      cat('klikki koski tyota')
      print(input$tyo_osoite_from_ui)
      output$tyo_valikko = renderUI({
        textInput("tyo_osoite_from_ui", label = p("")
                  , value = address_from_listing(click_info()$adress_details ) ) 
      })
      
    } else { #(input$pontentiaalinen_osoite_from_ui == potentiaalinen_value_default)
      cat('klikki koski potentiaalista')
      print(input$potentiaalinen_osoite_from_ui)
      output$potentiaalinen_valikko = renderUI({
        textInput("potentiaalinen_osoite_from_ui", label = p("")
                  , value = address_from_listing(click_info()$adress_details ) )
      })
    }
  })
  
  ## palveluihin littyvät eventit
  
  click_palvelu <<- eventReactive(input$palvelut_extra_group ,
                                  {
                                  print(output$palvelut_extra_group)
                                  }
                                  )
  
  observeEvent(input$palvelut_extra_group,
                              {
                              print(input$palvelut_extra_group)
                              }
  )
  
  ### markkerien päivitys osoitekentän kautta ###
  ### kotiosoite ###
  
  observeEvent(input$koti_osoite_from_ui , {
    if(input$koti_osoite_from_ui == koti_value_default  || str_trim(input$koti_osoite_from_ui)== "") {
      
      # poista itse markkeri
      leafletProxy("map_in_ui", session) %>% 
        removeMarker('koti')
      
      # poista markkeriin liittyvät markerit
      leafletProxy("map_in_ui", session) %>% 
        clearGroup('koti')
      
      # poista markkeriin liittyvät zip-objektit
      remove_zip_objects_for('koti',zip_objects)
      
    }
    if(nchar(input$koti_osoite_from_ui)>0){
      if(is.vector(input$koti_osoite_from_ui)){
        if(input$koti_osoite_from_ui != koti_value_default  ){
          osoite = input$koti_osoite_from_ui
          print( 'muutetetaan kotia' )
          ui_time = Sys.time()
          this_input <- 'koti'
          
          # palauta paikkaa koskevat tiedot
          location_info = try(get_location_information(ui_time , click_time , ui_interaction_lag , osoite))
          print( 'kodin info haettu' )
          print( str(location_info) )
          
          ### jos koordinaatit löytyvät ###
          if(class(location_info) !='try-error' ){
            if(!is_empty(location_info$lon) ){
              if(!is.null(location_info$lon)){
                if(length(location_info$lon)>0){
                  print(head(location_info$lon))
                  print('Kotiosoite hyvä')
                  
                  ### lisää kodille markkeri ###  
                  leafletProxy("map_in_ui" , session) %>%
                    addMarkers(lng = location_info$lon
                               , lat = location_info$lat
                               , layerId = this_input
                               , icon = icon_koti)
                  
                  ### poista vanhat kotiin liityvät markkerit ###
                  leafletProxy("map_in_ui", session) %>% 
                    clearGroup(this_input)
                  
                  ### hae koordinaattitason palvelut
                  
                  services = try(get_point_objects(lat=location_info$lat , lon = location_info$lon , radius = radius ))
                  
                  ### lisää uudet kotiin liittyvät markkerit ###         
                  if(class(services) != 'try-error'){
                    if(length(services) > 0 ){
                      for( i in 1:length(services)){
                        
                        this_service = services[[i]] 
                        this_name = names(services[i]) 
                        
                        if(class(this_service) != 'try-error' ){
                          if(length(this_service$lon)>0){
                            # these_ids = paste0(this_input , this_service$lon , this_service$lat ) 
                            icon_name = paste0( 'icon_' , this_name , sep=''  ) 
                            
                            leafletProxy("map_in_ui" , session) %>%
                              addMarkers(lng = this_service$lon
                                         , lat = this_service$lat
                                         , group = this_input
                                         , icon = eval(parse(text = icon_name)) ) 
                            # marker_store <<- append(marker_store , these_ids )
                          }
                        }
                      }
                    }
                  }
                }
              }
              ### hae zip-tason info

              update_zip_objects(location_info , this_input,zip_objects,session)
              print('zip metodi päivitetty')
              #### lopuksi päivitetään osoite
              if(location_info$user_interaction_method == 'click'){
                new_address = try( address_from_listing(location_info ) )
                if( validy_check_address(new_address) ){
                  output$koti_valikko = renderUI({
                    textInput("koti_osoite_from_ui", label = p("")
                              , value = new_address )
                  })
                }
              }
            }
          }
        }
      }
    }
  }) 
  ### tyoosoite ### 
  
  observeEvent(input$tyo_osoite_from_ui , {
    if(input$potentiaalinen_osoite_from_ui == potentiaalinen_value_default || str_trim(input$potentiaalinen_osoite_from_ui)== "") {
      leafletProxy("map_in_ui", session) %>% 
        removeMarker('tyo')
    }
    if(input$tyo_osoite_from_ui != tyo_value_default ){
      if(nchar(input$tyo_osoite_from_ui)>0){
        if(is.vector(input$tyo_osoite_from_ui)){
          
          osoite = input$tyo_osoite_from_ui
          print( 'muutetetaan tyota' )
          ui_time = Sys.time()
          this_input <- 'tyo'
          
          # palauta paikkaa koskevat tiedot
          location_info = try(get_location_information(ui_time , click_time , ui_interaction_lag , osoite))
          
          ### lisää tyolle markkeri ###  
          leafletProxy("map_in_ui" , session) %>%
            addMarkers(lng = location_info$lon
                       , lat = location_info$lat
                       , layerId = this_input
                       , icon = icon_tyo)
          
          #### lopuksi päivitetään osoite
          if(location_info$user_interaction_method == 'click'){
            new_address = try( address_from_listing(location_info ) )
            if( validy_check_address(new_address) ){
              output$tyo_valikko = renderUI({
                textInput("tyo_osoite_from_ui", label = p("")
                          , value = new_address )
              })
            }
          }
        }
      }
    }
  })  
  ### potentiaalinen ###
  
  observeEvent(input$potentiaalinen_osoite_from_ui , {
    print('muutos potentiaalisessa')
    print(input$potentiaalinen_osoite_from_ui)
    if(is.vector(input$potentiaalinen_osoite_from_ui)){
      if(input$potentiaalinen_osoite_from_ui == potentiaalinen_value_default || str_trim(input$potentiaalinen_osoite_from_ui)== "") {
        
        # poista itse markkeri
        leafletProxy("map_in_ui", session) %>% 
          removeMarker('potentiaalinen')
        
        # poista markkeriin liittyvät markerit
        leafletProxy("map_in_ui", session) %>% 
          clearGroup('potentiaalinen')
        
        # poista markkeriin liittyvät zip-objektit
        remove_zip_objects_for('potentiaalinen',zip_objects)
        
      }
      if(nchar(input$potentiaalinen_osoite_from_ui)>0){
        if(input$potentiaalinen_osoite_from_ui != potentiaalinen_value_default ){
          osoite = input$potentiaalinen_osoite_from_ui
          print('muutetaan potentiaalista')
          ui_time = Sys.time()
          this_input <- 'potentiaalinen'
          
          # palauta paikkaa koskevat tiedot
          print('haetaan osoite')
          location_info = try(get_location_information(ui_time , click_time , ui_interaction_lag , osoite))
          
          ### jos koordinaatit löytyvät ###
          if(class(location_info) !='try-error' ){
            print('osoite löytyi')
            cat(str(location_info))
            if(!is_empty(location_info$lon) ){
              if(!is.null(location_info$lon)){
                if(length(location_info)>0){  
                  
                  ### lisää kodille markkeri ###  
                  leafletProxy("map_in_ui" , session) %>%
                    addMarkers(lng = location_info$lon
                               , lat = location_info$lat
                               , layerId = this_input
                               , icon = icon_potentiaalinen)
                  
                  ### poista vanhat potentiaalinenin liityvät markkerit ###
                  leafletProxy("map_in_ui", session) %>% 
                    clearGroup(this_input)
                  
                  ### hae koordinaattitason palvelut
                  
                  services = try(get_point_objects(lat=location_info$lat , lon = location_info$lon , radius = radius ))
                  
                  ### lisää uudet potentiaalinenin liittyvät markkerit ###         
                  if(class(services) != 'try-error'){
                    #print(services$tyyppi)
                    if(length(services) > 0 ){
                      for( i in 1:length(services)){
                        
                        this_service = services[[i]] 
                        this_name = names(services[i]) 
                        
                        if(class(this_service) != 'try-error' ){
                          if(length(this_service$lon)>0){
                            icon_name = paste0( 'icon_' , this_name , sep=''  ) 
                            
                            leafletProxy("map_in_ui" , session) %>%
                              addMarkers(lng = this_service$lon
                                         , lat = this_service$lat
                                         , group = this_input
                                         , icon = eval(parse(text = icon_name)) ) 
                          }
                        }
                      }
                    }
                  }
                }
              }
              # hae zip-tason info
              
              update_zip_objects(location_info , this_input , zip_objects,session)
              
              #### lopuksi päivitetään osoite
              if(location_info$user_interaction_method == 'click'){
                new_address = try( address_from_listing(location_info ) )
                if( validy_check_address(new_address) ){
                  output$potentiaalinen_valikko = renderUI({
                    textInput("potentiaalinen_osoite_from_ui", label = p("")
                              , value = new_address )
                  })
                }
              }
            }
          }
        }
      }
    }
  })
  
  ### alkuun näppäin
  
  observeEvent(input$alkuun_nappi, {
    output$koti_valikko = renderUI({
      textInput("koti_osoite_from_ui", label = p(""), value = koti_value_default) 
    })
    output$tyo_valikko = renderUI({
      textInput("tyo_osoite_from_ui", label = p(""), value = tyo_value_default) 
    })
    output$potentiaalinen_valikko = renderUI({
      textInput("potentiaalinen_osoite_from_ui", label = p(""), value = potentiaalinen_value_default) 
    })
  })
  
  ### removing existing markers by clicking
  
  observeEvent(input$map_in_ui_marker_click, {
    this_input = try(input$map_in_ui_marker_click$id)
    if(class(this_input) != 'try-error'){
      if(!is.null(this_input)){
        if(this_input %in% c('koti','tyo','potentiaalinen')){
          
          if(this_input == 'koti'){
            
            # poista itse markkeri
            leafletProxy("map_in_ui", session) %>% 
              removeMarker(this_input)
            
            # poista markkerrin liittyvät markerit
            leafletProxy("map_in_ui", session) %>% 
              clearGroup(this_input)
            
            # poista markkeriin liittyvät zip-objektit
            remove_zip_objects_for(this_input,zip_objects)
            
            # ... ja palauta tekstikenttä oletusasetuksiin  
            output$koti_valikko = renderUI({
              textInput("koti_osoite_from_ui", label = p(""), value = koti_value_default) 
            })
            
          }
          else if(this_input == 'tyo'){
            
            leafletProxy("map_in_ui", session) %>% 
              removeMarker('tyo')
            
            output$tyo_valikko = renderUI({
              textInput("tyo_osoite_from_ui", label = p(""), value = tyo_value_default) 
            })
          }
          else if(this_input == 'potentiaalinen') {
            
            leafletProxy("map_in_ui", session) %>% 
              removeMarker(this_input)
            
            leafletProxy("map_in_ui", session) %>% 
              clearGroup(this_input)
            
            remove_zip_objects_for(this_input,zip_objects)
            
            output$potentiaalinen_valikko = renderUI({
              textInput("pontentiaalinen_osoite_from_ui", label = p(""), value = potentiaalinen_value_default) 
            })
          }
        }
      }
    }
  })
  ##################### visut  #####################
  
  # asuntojen hinnat
  output$asuntojen_hinnat_plot <- renderPlot({
    if(!is.null(zip_objects$asuntojen_hinnat)){
      
      # print(zip_objects$asuntojen_hinnat)
      
      if(is.numeric(zip_objects$asuntojen_hinnat$Vuosi)){
        
        maxvuosi = max(zip_objects$asuntojen_hinnat$Vuosi)
        minvuosi = min(zip_objects$asuntojen_hinnat$Vuosi)
        meanvuosi = floor(mean(c(maxvuosi,minvuosi)))
        
        # paletti
        pal = paletti
        if(length(unique(zip_objects$asuntojen_hinnat$paikka)) == 1 ){
          if( unique(zip_objects$asuntojen_hinnat$paikka) == 'koti'  ){
            pal = paletti[1]
          } else{
            pal = paletti[2]
          }
        }
        
        ggplot(zip_objects$asuntojen_hinnat , aes(x=Vuosi , y=Keskiarvo , color=paikka)) + 
          geom_line( size = 2 ) + 
          scale_x_continuous('Vuosi' , breaks=c(minvuosi,meanvuosi,maxvuosi) ) + 
          scale_color_manual( values = pal ) + 
          ylab('Hinta (e/m^2)') + 
          theme(legend.position = "none") + 
          ggtitle('Asuntojen hinnat')
      }
    }
  })
  
  output$ikajakauma_plot <- renderPlot({
    if(!is.null(zip_objects$alue_info)){
      
      data = zip_objects$alue_info[ , c('paikka','x.0.15.vuotiaat','x.16.29.vuotiaat','x.30.59.vuotiaat','x.yli.60.vuotiaat')]
      data = melt( data ,factorsAsStrings = T)
      data$value = data$value*100
      data$variable = str_replace(data$variable,'x.','')
      data$variable = gsub('.','-',data$variable,fixed =T)
      
      # paletti
      pal = paletti
      if(length(unique(data$paikka)) == 1 ){
        if( unique(data$paikka) == 'koti'  ){
          pal = paletti[1]
        } else{
          pal = paletti[2]
        }
      }
      
      ggplot(data , aes(x=variable , y=value , fill=paikka)) + 
        geom_bar(stat="identity" , position=position_dodge() ) + 
        scale_fill_manual( values = pal ) + 
        xlab('') + 
        scale_y_continuous("") +
        coord_flip() + 
        theme(legend.position = "none") + 
        ggtitle('Ikäjakauma (% asukkaista)')
    }
  })
  
  output$talojakauma_plot <- renderPlot({
    if(!is.null(zip_objects$alue_info)){
      
      data = zip_objects$alue_info[ , c('paikka','pientaloja','kerrostaloja')]
      data = melt( data ,factorsAsStrings = T)
      data$value = data$value*100
      
      # paletti
      pal = paletti
      if(length(unique(data$paikka)) == 1 ){
        if( unique(data$paikka) == 'koti'  ){
          pal = paletti[1]
        } else{
          pal = paletti[2]
        }
      }
      
      ggplot(data , aes(x=variable , y=value , fill=paikka)) + 
        geom_bar(stat="identity" , position=position_dodge() ) + 
        scale_fill_manual( values = pal ) + 
        xlab('') + 
        scale_y_continuous("") +
        coord_flip() + 
        theme(legend.position = "none") + 
        ggtitle('Asunnot (% asukkaista)')
    }
  })
  
  output$koulutusjakauma_plot <- renderPlot({
    if(!is.null(zip_objects$alue_info)){
      
      data = zip_objects$alue_info[ , c('paikka','perusasteen_koulutus','toisen_asteen_koulutus','korkeakoulutus')]
      data = melt( data ,factorsAsStrings = T)
      data$value = data$value*100
      
      data$variable = as.character(data$variable)
      data$variable = ifelse(data$variable == 'perusasteen_koulutus' , 'perusaste' , data$variable )
      data$variable = ifelse(data$variable == 'toisen_asteen_koulutus' , 'toinen_aste' , data$variable )
      
      data$variable = as.factor(data$variable)
      data$variable <- ordered(data$variable, levels = c("perusaste", "toinen_aste", "korkeakoulutus"))
      
      # paletti
      pal = paletti
      if(length(unique(data$paikka)) == 1 ){
        if( unique(data$paikka) == 'koti'  ){
          pal = paletti[1]
        } else{
          pal = paletti[2]
        }
      }
      
      ggplot(data , aes(x=variable , y=value , fill=paikka)) + 
        geom_bar(stat="identity" , position=position_dodge() ) + 
        scale_fill_manual( values = pal ) + 
        xlab('') + 
        scale_y_continuous("") +
        coord_flip() + 
        theme(legend.position = "none") + 
        ggtitle('Korkein koulutusaste (% asukkaista)')
    }
  })
  
  output$toimintajakauma_plot <- renderPlot({
    if(!is.null(zip_objects$alue_info)){
      
      data = zip_objects$alue_info[ , c('paikka','tyolliset', 'tyottomat' , 'lapset',  'opiskelijat','muut')]
      data = melt( data ,factorsAsStrings = T)
      data$value = data$value*100
      
      # paletti
      pal = paletti
      if(length(unique(data$paikka)) == 1 ){
        if( unique(data$paikka) == 'koti'  ){
          pal = paletti[1]
        } else{
          pal = paletti[2]
        }
      }
      
      ggplot(data , aes(x=variable , y=value , fill=paikka)) + 
        geom_bar(stat="identity" , position=position_dodge() ) + 
        scale_fill_manual( values = pal ) + 
        xlab('') + 
        scale_y_continuous("") +
        coord_flip() + 
        theme(legend.position = "none") + 
        ggtitle('Pääasiallinen toiminta (% asukkaista)')
    }
  })
  
  
  ##################### HAUT   ##################### 
  
  # ala-asteet
  #   ala_asteet = reactive({
  #     ala_asteet = get_palvelu('ala_asteet' 
  #                              , lat = click_info()$value[2] 
  #                              , lon = click_info()$value[1] 
  #                              , radius = 2 )
  #     return(ala_asteet)
  #   })
  #   
  #   # ruokakaupat
  #   ruokakaupat = reactive({
  #     ruokakaupat = get_nearest( conn , 'coord' 
  #                                , lat = click_info()$value[2] 
  #                                , lon = click_info()$value[1] 
  #                                , radius = 2 
  #                                , tyyppi =  'Ruokakaupat' 
  #                                , count =  100 )
  #     return(ruokakaupat)
  #   })
  
  ### MARKKERIEN PIIRTO 
  
  
  #   observeEvent(input$map_in_ui_click,{ 
  #     
  #     ### piiirra ruokakaupat ###
  #     ruokakaupat_layerids = paste0(last_added_marker , ruokakaupat()$lon , ruokakaupat()$lat ) 
  #     leafletProxy("map_in_ui" , session) %>%
  #       addMarkers(lng = ruokakaupat()$lon
  #                  , lat = ruokakaupat()$lat
  #                  , layerId = ruokakaupat_layerids
  #                  , icon = icon_kauppa) 
  #     marker_store <<- c(marker_store , ruokakaupat_layerids )
  #     ### piiirra ala-asteet ###
  #     
  #     ala_asteet_layerids = paste0(last_added_marker , ala_asteet()$lon , ala_asteet()$lat ) 
  #     leafletProxy("map_in_ui" , session) %>%
  #       addMarkers(lng = ala_asteet()$longitude
  #                  , lat = ala_asteet()$latitude
  #                  , layerId = paste0( last_added_marker , ala_asteet()$longitude , ala_asteet()$latitude ) 
  #                  , icon = icon_ala_aste)
  #     marker_store <<- c(marker_store , ala_asteet_layerids)
  #     
  #   })
  
  ################################## DEBUGGAUS ##################################
  
  if(DEBUG){
    test_data_time_series = data.frame(  value = c(cumsum(rnorm( 16,0,1 ) ) , cumsum(rnorm( 16,0,1 ) ) )
                                         , paikka = rep( c('koti','muutto') , each=16 )
                                         , vuosi = 2000:2015)
    
    output$test_data_time_series_plot <- renderChart({
      n <- nPlot(value ~ vuosi, data=test_data_time_series, type = "lineChart" , group="paikka")
      #     n$xAxis(tickFormat ="#!function (d) {return d3.time.format('%m/%Y')(new Date(d * 86400000 ));}!#",showMaxMin=FALSE)
      #     n$yAxis(tickFormat ="#!function (d) {return d3.format('.1f')(d);}!#",showMaxMin = FALSE)
      n$chart(useInteractiveGuideline=TRUE)
      n$set(dom = 'test_data_time_series_plot', width = 330 , height=280)
      n
    })
    
    # example placeholder for texst
    output$kotiosoite <- renderText({ paste( input$koti_osoite_from_ui ) })
    output$muutto_osoite <- renderPrint({ cat(input$muutto_osoite_from_ui) })
    # example placeholder for pictures  
    output$koti_pic = renderPlot( plot(1:10) )
    output$muutto_pic = renderPlot( plot(10:1) )
    
    
    # output$click_... - textit debuggausta varten
    output$click_latlon = renderText( paste( 'click lon lat: ' , click_info()$rounded[1] , click_info()$rounded[2]  ))
    output$click_address = renderText( paste( 'address: ' 
                                              , reverse_geocode_nominatim(lat = click_info()$value[2] 
                                                                          , lon = click_info()$value[1]  )))
    # palauttaa kaiken click_info()-funktion antaman infon yhtenä pötkönä
    output$click_all_info = renderText(
      paste( reverse_geocode_nominatim(lat = click_info()$value[2] 
                                       , lon = click_info()$value[1] 
                                       , get = 'listing' ) )
    )
    
    # testitaulukko
    test_table_head = reactive({
      test_table_head =head(
        get_nearest( conn , 'coord' , click_info()$value[2] , click_info()$value[1] , 2 , 'Ruokakaupat' , 100 ) 
        , 2 )
      #print(test_table_head)
      return(test_table_head)
    })
    output$test_table <- renderDataTable({ test_table_head() })
    #   # testitaulukko2
    #   test_table_head2 = reactive({
    #     test_table_head2 =head(
    #       get_palvelu('ala_asteet' , lat = click_info()$value[2] , lon = click_info()$value[2],distance=10 )      
    #       , 2 )
    #     print(test_table_head2)
    #     return(test_table_head2)
    #   })
    # output$test_table2 <- renderDataTable({ test_table_head2() })
    
    #   output$asuntojen_hinta_time_series_plot <- renderChart({
    #     if(!is.null(home_zip_objects$asuntojen_hinnat)){
    #       if(ncol(home_zip_objects$asuntojen_hinnat)){
    #         n <- nPlot(Keskiarvo ~ Vuosi, data=home_zip_objects$asuntojen_hinnat
    #                    , type = "lineChart" , group="paikka")
    #         n$chart(useInteractiveGuideline=TRUE)
    #         n$set(dom = 'asuntojen_hinta_time_series_plot', width = 330 , height=280)
    #         n
    #       }
    #     }
    #   })
  } # debug loppuu
})
