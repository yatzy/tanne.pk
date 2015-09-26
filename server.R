
shinyServer(function(input, output, session) {
  
  ### init ui components
  # print(init_ready) 
  output$koti_valikko = renderUI({
    textInput("kotiosoite_from_ui", label = p(""), value = "Kotiosoite") 
  })
  output$tyo_valikko = renderUI({
    textInput("tyo_osoite_from_ui", label = p(""), value = "Työpaikan osoite") 
  })
  output$potentiaalinen_valikko = renderUI({
    textInput("pontentiaalinen_osoite_from_ui", label = p(""), value = "Potentiaalinen osoite") 
  })
  
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
  
  click_info = eventReactive(input$map_in_ui_click , { 
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
    cat('LAT:', click_info()$lat, 'LON:' , click_info()$lat ,'\n'  )
    
    if(input$kotiosoite_from_ui=='Kotiosoite'){
      output$koti_valikko = renderUI({
        textInput("kotiosoite_from_ui", label = p(""), value = paste(click_info()$rounded[2],click_info()$rounded[1]) ) 
      })
      
    } else if(input$tyo_osoite_from_ui=='Työpaikan osoite'){
      
      output$tyo_valikko = renderUI({
        textInput("tyo_osoite_from_click", label = p(""), value = paste(click_info()$rounded[2],click_info()$rounded[1] )) 
      })
      
    } else { #(input$pontentiaalinen_osoite_from_ui == 'Potentiaalinen osoite')
      
      output$potentiaalinen_valikko = renderUI({
        textInput("pontentiaalinen_osoite_from_ui", label = p(""), value = paste(click_info()$rounded[2],click_info()$rounded[1] ) )
      })
    }
  })
  
  ### markkerien päivitys osoitekentän kautta ###
  
  observeEvent(input$kotiosoite_from_ui , {
    
    if(init_ready){
      ui_time = Sys.time()
      
      # jos klikattu 
      # tiedetään klikin koordinaatit ja haetaan osoitteet
      # jos muutettu osoitteesta, tiedetään osoite, ja haetaan koordinaatit
      if(as.numeric(difftime(ui_time , click_time , units='secs')) < 5 ){
        
        cat('muuttui klikkaamalla')
        cat(', ero: ' , as.numeric(difftime(ui_time , click_time , units='secs')),'\n' )
        
        location_info = click_info()$adress_details
        location_info$lat = click_info()$lat
        location_info$lon = click_info()$lon
        
      } else{
        
        cat('Muuttui kirjoittamalla')
        cat(', ero: ' , as.numeric(difftime(ui_time , click_time , units='secs')),'\n' )
        
        location_info = geocode_nominatim(input$kotiosoite_from_ui)
        
      }
      
      # print(location_info$address)
      print(location_info)
      #     print(str(location_info))
      
      
      ### lisää kodille markkeri ###
      if(!is.null(location_info$lon)){
        leafletProxy("map_in_ui" , session) %>%
          addMarkers(lng = location_info$lon
                     , lat = location_info$lat
                     , layerId = 'koti'
                     , icon = icon_koti)
        
        
        ### poista vanhat kotiin liityvät markkerit ###
        
        leafletProxy("map_in_ui", session) %>% 
          removeMarker( marker_store[ grep('koti',marker_store ) ] )
        marker_store <<- marker_store[ !grep('koti',marker_store ) ]
        
        cat('\nmarker_store:\n')
        print(marker_store)
        print(length(marker_store))
        print(is(marker_store))
        print('grep(koti,marker_store )')
        print(grep('koti',marker_store ))
        print('grepl(koti,marker_store )')
        print(grepl('koti',marker_store ))
        
        ### hae palvelut
        
        ruokakaupat = try(get_ruokakaupat(lat = location_info$lat , lon = location_info$lon , radius = radius ))
        ala_asteet = try(get_ala_asteet(lat = location_info$lat , lon = location_info$lon , radius = radius ))
        # print(ruokakaupat)
        
        print('######### palautetut #########' )
        a = get_objects(lat=location_info$lat , lon = location_info$lon , radius = radius )
        print(str(a))
        
        ### lisää uudet kotiin liittyvät markkerit ###         
        
        print('ruokakaupat:')
        print(dim(ruokakaupat))
        print(class(ruokakaupat))
        print(head(ruokakaupat))
        if(is.data.frame(ruokakaupat)){
          print('on dataframe')
          cat('\n dim: ' , all(dim(ruokakaupat)) , '\n')
          cat('\n all(dim(ruokakaupat)) : ' , all(dim(ruokakaupat)) , '\n')
          
          print('inda loop')
          
          ruokakaupat_layerids = paste0('koti' , ruokakaupat$lon , ruokakaupat$lat ) 
          leafletProxy("map_in_ui" , session) %>%
            addMarkers(lng = ruokakaupat$lon
                       , lat = ruokakaupat$lat
                       , layerId = ruokakaupat_layerids
                       , icon = icon_kauppa) 
          
          print(paste('latlon:',ruokakaupat$lon,ruokakaupat$lat))
          cat('ids: ', paste0(ruokakaupat_layerids))
          
          marker_store <<- append(marker_store , ruokakaupat_layerids )
        }
        ### piiirra ala-asteet ###
        
        cat('\nala_asteet: \n')
        print(dim(ala_asteet))
        print(class(ala_asteet))
        
        if( class(ala_asteet) !='try-error' & all(dim(ala_asteet)) > 0  ){
          ala_asteet_layerids = paste0('koti' , ala_asteet$lon , ala_asteet$lat ) 
          leafletProxy("map_in_ui" , session) %>%
            addMarkers(lng = ala_asteet$lon
                       , lat = ala_asteet$lat
                       , layerId = paste0( ala_asteet_layerids ) 
                       , icon = icon_ala_aste)
          
          print(paste('latlon:',ruokakaupat$lon,ruokakaupat$lat))
          cat('ids: ', paste0(ruokakaupat_layerids))
          
          
          marker_store <<- append(marker_store , ala_asteet_layerids)
        }
        
        
        #     # print(input$kotiosoite_from_ui)
        #     if(input$kotiosoite_from_ui != 'Kotiosoite' ){
        #       kotiosoite = try(geocode_nominatim(input$kotiosoite_from_ui))
        #       print(str(kotiosoite))
        #       if(class(kotiosoite) != 'try-error' ){
        #         # print(kotiosoite$lon)
        #         
        #         leafletProxy("map_in_ui" , session) %>%
        #           addMarkers(lng = click_info()$lon
        #                      , lat = click_info()$lat
        #                      , layerId = 'koti'
        #                      , icon = icon_koti)
        #         # print( paste(click_info()$lon , click_info()$lat) )
        #         
        #         leafletProxy("map_in_ui", session) %>% 
        #           removeMarker( marker_store[ grep('koti',marker_store ) ] )
        #         marker_store <<- marker_store[ !grep('koti',marker_store ) ]
        #         
        #         ruokakaupat_layerids = paste0('koti' , ruokakaupat()$lon , ruokakaupat()$lat ) 
        #         leafletProxy("map_in_ui" , session) %>%
        #           addMarkers(lng = ruokakaupat()$lon
        #                      , lat = ruokakaupat()$lat
        #                      , layerId = ruokakaupat_layerids
        #                      , icon = icon_kauppa) 
        #         marker_store <<- c(marker_store , ruokakaupat_layerids )
        #         ### piiirra ala-asteet ###
        #         
        #         ala_asteet_layerids = paste0('koti' , ala_asteet()$lon , ala_asteet()$lat ) 
        #         leafletProxy("map_in_ui" , session) %>%
        #           addMarkers(lng = ala_asteet()$longitude
        #                      , lat = ala_asteet()$latitude
        #                      , layerId = paste0( last_added_marker , ala_asteet()$longitude , ala_asteet()$latitude ) 
        #                      , icon = icon_ala_aste)
        #         marker_store <<- c(marker_store , ala_asteet_layerids)
        #         
        #         print(address_from_listing(kotiosoite))
        #         output$koti_valikko = renderUI({
        #           textInput("kotiosoite_from_ui", label = p(""), value = address_from_listing(kotiosoite)  ) 
        #         })
        #         
        #       } 
        #     }
      }
    }
    init_ready <<- T
    # print(init_ready)
  })
  
  observeEvent(input$tyo_valikko , {
    
    if(last_click != 'tyo'){
      
      # print(input$tyo_osoite_from_ui)
      if(input$tyo_osoite_from_ui != 'Työpaikan osoite' ){
        tyoosoite = try(geocode_nominatim(input$tyo_osoite_from_ui))
        if(class(tyoosoite) != 'try-error' ){
          if(!is.null(tyoosoite$lon))
            # print(kotiosoite$lon)
            
            leafletProxy("map_in_ui", session) %>% 
            removeMarker( marker_store[ grep('tyo',marker_store ) ] )
          marker_store <<- marker_store[ !grep('tyo',marker_store ) ]
          
          leafletProxy("map_in_ui" , session) %>%
            addMarkers(lng = tyoosoite$lon
                       , lat = tyoosoite$lat
                       , layerId = 'tyo'
                       , icon = icon_tyo)
          
        } else{
          tyoosoite = NULL
        }
      }
      
      last_added_marker <<- 'tyo'
    } else{
      leafletProxy("map_in_ui", session) %>% 
        removeMarker( marker_store[ grep('tyo',marker_store ) ] )
      marker_store <<- marker_store[ !grep('tyo',marker_store ) ]
    }
  })
  
  observeEvent(input$pontentiaalinen_valikko , {
    
    if(last_click != 'potentiaalinen'){
      
      # print(input$tyo_osoite_from_ui)
      if(input$pontentiaalinen_osoite_from_ui != 'Potentiaalinen osoite' ){
        potentiaalinenosoite = try(geocode_nominatim(input$pontentiaalinen_osoite_from_ui))
        if(class(potentiaalinenosoite) != 'try-error' ){
          if(!is.null(potentiaalinenosoite$lon))
            print(potentiaalinenosoite$lon)
          
          leafletProxy("map_in_ui", session) %>% 
            removeMarker( marker_store[ grep('potentiaalinen',marker_store ) ] )
          marker_store <<- marker_store[ !grep('potentiaalinen',marker_store ) ]
          
          leafletProxy("map_in_ui" , session) %>%
            addMarkers(lng = potentiaalinenosoite$lon
                       , lat = potentiaalinenosoite$lat
                       , layerId = 'potentiaalinen'
                       , icon = icon_potentiaalinen)
          
          # } else{
          # potentiaalinenosoite = NULL
        }
      }
      
      last_added_marker <<- 'potentiaalinen'
    } else{
      leafletProxy("map_in_ui", session) %>% 
        removeMarker( marker_store[ grep('potentiaalinen',marker_store ) ] )
      marker_store <<- marker_store[ !grep('potentiaalinen',marker_store ) ]
    }
  })
  
  
  ### removing existing markers by clicking
  
  observeEvent(input$map_in_ui_marker_click, {
    
    if(input$map_in_ui_marker_click$id %in% c('koti','tyo','potentiaalinen')){
      
      leafletProxy("map_in_ui", session) %>% 
        removeMarker(input$map_in_ui_marker_click$id)
      # kun markkeri poistetaan, palauta tekstikenttä oletusasetuksiin
      if(input$map_in_ui_marker_click$id == 'koti'){
        output$koti_valikko = renderUI({
          textInput("kotiosoite_from_ui", label = p(""), value = "Kotiosoite") 
        })
        # ... ja poista markkerrin liittyvät markerit
        leafletProxy("map_in_ui", session) %>% 
          removeMarker( marker_store[ grep('koti',marker_store ) ] )
        marker_store <<- marker_store[ !grep('koti',marker_store ) ]
      }
      else if(input$map_in_ui_marker_click$id == 'tyo'){
        output$tyo_valikko = renderUI({
          textInput("tyo_osoite_from_ui", label = p(""), value = "Työpaikan osoite") 
        })
        leafletProxy("map_in_ui", session) %>% 
          removeMarker( marker_store[ grep('tyo',marker_store ) ] )
        marker_store <<- marker_store[ !grep('tyo',marker_store ) ]
      }
      else if(input$map_in_ui_marker_click$id == 'potentiaalinen') 
      {
        output$potentiaalinen_valikko = renderUI({
          textInput("pontentiaalinen_osoite_from_ui", label = p(""), value = "Potentiaalinen osoite") 
        })
        leafletProxy("map_in_ui", session) %>% 
          removeMarker( marker_store[ grep('potentiaalinen',marker_store ) ] )
        marker_store <<- marker_store[ !grep('potentiaalinen',marker_store ) ]
      }
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
  output$kotiosoite <- renderText({ paste( input$kotiosoite_from_ui ) })
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
  
})
