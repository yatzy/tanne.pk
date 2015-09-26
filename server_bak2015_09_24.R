
shinyServer(function(input, output, session) {
  
  ### init ui components
  
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
      value = c( lon = as.numeric(input$map_in_ui_click$lng)
                 , lat = as.numeric(input$map_in_ui_click$lat) )
      , rounded = c( lon = round(as.numeric(input$map_in_ui_click$lng) , 3) 
                     , lat = round(as.numeric(input$map_in_ui_click$lat) , 3))
      , adress_details = reverse_geocode_nominatim(lat = input$map_in_ui_click$lat
                                                   , lon = input$map_in_ui_click$lng
                                                   , get = 'listing' ) )
  })
  
  
  ### adding new markers by clicking ###
  
  observeEvent(input$map_in_ui_click, {
    clicktime <<- Sys.time()
    click_count <<- click_count + 1
    
    if(input$kotiosoite_from_ui=='Kotiosoite'){
      leafletProxy("map_in_ui", session) %>% 
        removeMarker( marker_store[ grep('koti',marker_store ) ] )
      marker_store <<- marker_store[ !grep('koti',marker_store ) ]
      
      leafletProxy("map_in_ui" , session) %>%
        addMarkers(lng = input$map_in_ui_click$lng
                   , lat = input$map_in_ui_click$lat
                   , layerId = 'koti'
                   , icon = icon_koti)
      
      kotiosoite_to_ui = address_from_listing( click_info()$adress_details )
      # print(kotiosoite_to_ui)
      
      output$koti_valikko = renderUI({
        textInput("kotiosoite_from_ui", label = p(""), value = kotiosoite_to_ui ) 
      })
      
      last_click <<- 'koti'
      last_added_marker <<- 'koti'
      
    } else if(input$tyo_osoite_from_ui=='Työpaikan osoite'){
      
      leafletProxy("map_in_ui", session) %>% 
        removeMarker( marker_store[ grep('tyo',marker_store ) ] )
      marker_store <<- marker_store[ !grep('tyo',marker_store ) ]
      
      leafletProxy("map_in_ui" , session) %>%
        addMarkers(lng = input$map_in_ui_click$lng
                   , lat = input$map_in_ui_click$lat
                   , layerId = 'tyo'
                   , icon = icon_tyo)
      tyoosoite_to_ui = address_from_listing( click_info()$adress_details )
      output$tyo_valikko = renderUI({
        textInput("tyo_osoite_from_ui", label = p(""), value = tyoosoite_to_ui ) 
      })
      
      last_click <<- 'tyo'
      last_added_marker <<- 'tyo'
      
    } else #(input$pontentiaalinen_osoite_from_ui == 'Potentiaalinen osoite')
    {
      
      leafletProxy("map_in_ui", session) %>% 
        removeMarker( marker_store[ grep('potentiaalinen',marker_store ) ] )
      marker_store <<- marker_store[ !grep('potentiaalinen',marker_store ) ]
      
      leafletProxy("map_in_ui" , session) %>%
        addMarkers(lng = input$map_in_ui_click$lng
                   , lat = input$map_in_ui_click$lat
                   , layerId = 'potentiaalinen'
                   , icon = icon_potentiaalinen)
      potentiaalinen_to_ui = address_from_listing( click_info()$adress_details )
      
      output$potentiaalinen_valikko = renderUI({
        textInput("pontentiaalinen_osoite_from_ui", label = p(""), value = potentiaalinen_to_ui ) 
      })
      
      last_click <<- 'potentiaalinen'
      last_added_marker <<- 'potentiaalinen'
      
    }
  })
  
  ### markkerien lisäys kirjoittamalla osoitekenttään ###
  
  observeEvent(input$koti_valikko , {
    
    if( last_click != 'koti' ){
      # if( last_click != 'koti' ){
      
      # print(input$kotiosoite_from_ui)
      if(input$kotiosoite_from_ui != 'Kotiosoite' ){
        kotiosoite = try(geocode_nominatim(input$kotiosoite_from_ui))
        if(class(kotiosoite) != 'try-error' ){
          if(!is.null(kotiosoite$lon))
            # print(kotiosoite$lon)
            
            leafletProxy("map_in_ui", session) %>% 
            removeMarker( marker_store[ grep('koti',marker_store ) ] )
          marker_store <<- marker_store[ !grep('koti',marker_store ) ]
          
          leafletProxy("map_in_ui" , session) %>%
            addMarkers(lng = kotiosoite$lon
                       , lat = kotiosoite$lat
                       , layerId = 'koti'
                       , icon = icon_koti)
          
        } 
#         else{
#           kotiosoite = NULL
#         }
      }
      
      if(last_added_marker == 'koti'){    
        leafletProxy("map_in_ui" , session) %>%
          addMarkers(lng = input$map_in_ui_click$lng
                     , lat = input$map_in_ui_click$lat
                     , layerId = 'koti'
                     , icon = icon_koti)
      }
    } 
#     else{
#       leafletProxy("map_in_ui", session) %>% 
#         removeMarker( marker_store[ grep('koti',marker_store ) ] )
#       marker_store <<- marker_store[ !grep('koti',marker_store ) ]
#     }
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
  ala_asteet = reactive({
    ala_asteet = get_palvelu('ala_asteet' 
                             , lat = click_info()$value[2] 
                             , lon = click_info()$value[1] 
                             , radius = 2 )
    return(ala_asteet)
  })
  
  # ruokakaupat
  ruokakaupat = reactive({
    ruokakaupat = get_nearest( conn , 'coord' 
                               , lat = click_info()$value[2] 
                               , lon = click_info()$value[1] 
                               , radius = 2 
                               , tyyppi =  'Ruokakaupat' 
                               , count =  100 )
    return(ruokakaupat)
  })
  
  ### MARKKERIEN PIIRTO 
  
  
  observeEvent(input$map_in_ui_click,{ 
    
    ### piiirra ruokakaupat ###
    ruokakaupat_layerids = paste0(last_added_marker , ruokakaupat()$lon , ruokakaupat()$lat ) 
    leafletProxy("map_in_ui" , session) %>%
      addMarkers(lng = ruokakaupat()$lon
                 , lat = ruokakaupat()$lat
                 , layerId = ruokakaupat_layerids
                 , icon = icon_kauppa) 
    marker_store <<- c(marker_store , ruokakaupat_layerids )
    ### piiirra ala-asteet ###
    
    ala_asteet_layerids = paste0(last_added_marker , ala_asteet()$lon , ala_asteet()$lat ) 
    leafletProxy("map_in_ui" , session) %>%
      addMarkers(lng = ala_asteet()$longitude
                 , lat = ala_asteet()$latitude
                 , layerId = paste0( last_added_marker , ala_asteet()$longitude , ala_asteet()$latitude ) 
                 , icon = icon_ala_aste)
    marker_store <<- c(marker_store , ala_asteet_layerids)
    
  })
  
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
