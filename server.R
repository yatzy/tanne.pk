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
  
  # click count to ui
  output$click_count = reactive( ui_events$count )
  
  # helper notifications 
  
  
  # initiation notification
  createAlert(session, anchorId = "initiation_notification1", alertId = 'init_notification1' , title = "Lisää",
              content = init_content1, append = FALSE , dismiss = F)
  createAlert(session, anchorId = "initiation_notification2", alertId = 'init_notification2' , title = "Jatka",
              content = init_content2, append = FALSE, dismiss = F)
  createAlert(session, anchorId = "initiation_notification3", alertId = 'init_notification3' , title = "Poista",
              content = init_content3, append = FALSE, dismiss = F)
  createAlert(session, anchorId = "initiation_notification4", alertId = 'init_notification4' , title = "Valitse",
              content = init_content4, append = FALSE)
  
  ### toggle emphasises on ui text 
  
  observe({
    
    empty_var = try(input$map_in_ui_marker_click)
    this_ui_count = try(ui_events$count)
    
    # init
    if(class(this_ui_count) != 'try-error'){
      if(this_ui_count == 0){
        Sys.sleep(2)
        addClass("ui_koti_emphasis", "emph_box_koti")          
      }
    }
    
    if(this_ui_count>0){
      
      # koti
      # if( !koti_selected_error ){
      cat('input$ui_koti_selected: ' , input$ui_koti_selected , '\n')
      cat('input$koti_osoite_from_ui == koti_value_default || nchar(str_trim(input$koti_osoite_from_ui)) == 0' 
          , input$koti_osoite_from_ui == koti_value_default || nchar(str_trim(input$koti_osoite_from_ui)) == 0 , '\n' )
      if(input$ui_koti_selected  
         && ( input$koti_osoite_from_ui == koti_value_default || nchar(str_trim(input$koti_osoite_from_ui)) == 0 )
      ){
        
        #             ui_koti_emphasis_box_add = try(addClass("ui_koti_emphasis", "emph_box_koti"))
        #             ui_tyo_emphasis_box_remove = try(removeClass("ui_tyo_emphasis", "emph_box_tyo"))
        #             ui_potentiaalinen_emphasis_box_remove = try(removeClass("ui_potentiaalinen_emphasis", "emph_box_potentiaalinen"))
        #             
        #             if(class(ui_koti_emphasis_box_add)!='try-error') {ui_koti_emphasis_box_add}
        #             if(class(ui_tyo_emphasis_box_remove)!='try-error') {ui_tyo_emphasis_box_remove}
        #             if(class(ui_potentiaalinen_emphasis_box_remove)!='try-error') {ui_potentiaalinen_emphasis_box_remove}
        
        addClass("ui_koti_emphasis", "emph_box_koti")
        removeClass("ui_tyo_emphasis", "emph_box_tyo")
        removeClass("ui_potentiaalinen_emphasis", "emph_box_potentiaalinen")
      }
    }
    
    # tyo
    else if(input$ui_tyo_selected  
            && ( input$tyo_osoite_from_ui == tyo_value_default || nchar(str_trim(input$tyo_osoite_from_ui)) == 0 )
    ){
      
      #           ui_tyo_emphasis_box_add = try(addClass("ui_tyo_emphasis", "emph_box_tyo"))
      #           ui_koti_emphasis_box_remove = try(removeClass("ui_koti_emphasis", "emph_box_koti"))
      #           ui_potentiaalinen_emphasis_box_remove = try(removeClass("ui_tyo_emphasis", "emph_box_tyo"))
      #           
      #           if(class(ui_tyo_emphasis_box_add)!='try-error') {ui_tyo_emphasis_box_add}
      #           if(class(ui_koti_emphasis_box_remove)!='try-error') {ui_koti_emphasis_box_remove}
      #           if(class(ui_potentiaalinen_emphasis_box_remove)!='try-error') {ui_potentiaalinen_emphasis_box_remove}
      
      addClass("ui_tyo_emphasis", "emph_box_tyo")
      removeClass("ui_koti_emphasis", "emph_box_koti")
      removeClass("ui_potentiaalinen_emphasis", "emph_box_potentiaalinen")
      
    }
    
    # potentiaalinen
    else if(
      !is.null(input$potentiaalinen_osoite_from_ui) && input$ui_potentiaalinen_selected  
    ){
      
      #           ui_potentiaalinen_emphasis_box_add = try(addClass("ui_potentiaalinen_emphasis", "emph_box_potentiaalinen"))
      #           ui_koti_emphasis_box_remove = try(removeClass("ui_koti_emphasis", "emph_box_koti"))
      #           ui_tyo_emphasis_box_remove = try(removeClass("ui_tyo_emphasis", "emph_box_tyo"))
      #           
      #           if(class(ui_potentiaalinen_emphasis_box_add)!='try-error') {ui_potentiaalinen_emphasis_box_add}
      #           if(class(ui_koti_emphasis_box_remove)!='try-error') {ui_koti_emphasis_box_remove}
      #           if(class(ui_tyo_emphasis_box_remove)!='try-error') {ui_tyo_emphasis_box_remove}
      
      addClass("ui_potentiaalinen_emphasis", "emph_box_potentiaalinen")
      removeClass("ui_koti_emphasis", "emph_box_koti")
      removeClass("ui_tyo_emphasis", "emph_box_tyo")
    }
  })
  
  ### create map to ui
  
  output$map_in_ui <- renderLeaflet({
    # init map
    leaflet() %>%
      # add map layer
      #       addTiles('//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png' # ALKUPERÄINEN
      #                , attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>' ) %>% 
      addTiles('//{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png' # HAALEA
               , attribution = 'Tiles courtesy of <a href="http://openstreetmap.se/" target="_blank">OpenStreetMap Sweden</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>' ) %>% 
      #       addTiles('//{s}.tile.thunderforest.com/transport/{z}/{x}/{y}.png' # VAIKEA EROTTAA!
      #                , attribution = 'Maps by <a href="http://www.opencyclemap.org">OpenCycleMap</a>, &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>' ) %>% 
      #       addTiles('api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png' # ei toimi
      #                , attribution = 'Imagery from <a href="http://mapbox.com/about/maps/">MapBox</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>' ) %>% 
      # set initial boundaries to centre of Helsinki
      setView( lng=city_center_location$lon , lat=city_center_location$lat , zoom = 11) %>%
      setMaxBounds(lng1=boundary_west_lat, lat1=boundary_south_lon, lng2=boundary_east_lat, lat2=boundary_north_lon)
    
  }) 
  
  # click_info() - functio palauttaa viimeisimmän karttaklikin leveys- ja pituuspiirit, sekä osoitetiedot
  
  click_info <<- eventReactive(input$map_in_ui_click , { 
    # ui_events$count = ui_events$count + 1
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
    cat('KLIKKI!!! LAT: ', click_info()$lat, 'LON:' , click_info()$lon ,'\n'  )
    
    if( input$ui_koti_selected && input$koti_osoite_from_ui == koti_value_default || nchar(str_trim(input$koti_osoite_from_ui))== 0  ){
      cat('klikki koski kotia\n')
      print(input$koti_osoite_from_ui)
      output$koti_valikko = renderUI({
        textInput("koti_osoite_from_ui", label = p("")
                  , value = address_from_listing(click_info()$adress_details ) )
      })
      
    } else if( input$ui_tyo_selected && input$tyo_osoite_from_ui == tyo_value_default || nchar(str_trim(input$tyo_osoite_from_ui))== 0  ){
      cat('klikki koski tyota\n')
      print(input$tyo_osoite_from_ui)
      output$tyo_valikko = renderUI({
        textInput("tyo_osoite_from_ui", label = p("")
                  , value = address_from_listing(click_info()$adress_details ) ) 
      })
      
    } else if(input$ui_potentiaalinen_selected) { #(input$pontentiaalinen_osoite_from_ui == potentiaalinen_value_default)
      cat('klikki koski potentiaalista\n')
      print(input$potentiaalinen_osoite_from_ui)
      output$potentiaalinen_valikko = renderUI({
        textInput("potentiaalinen_osoite_from_ui", label = p("")
                  , value = address_from_listing(click_info()$adress_details ) )
      })
    }
  })
  
  ## palveluihin littyvät eventit
  
  observeEvent(input$palvelut_extra_group,{
    
    palvelut_valittu = palvelut %in% input$palvelut_extra_group
    for (i in 1:length(palvelut)) {
      if (palvelut_valittu[i]) {
        leafletProxy("map_in_ui", session) %>% showGroup(kotigroups[i])
        leafletProxy("map_in_ui", session) %>% showGroup(potentiaalinengroups[i])
      } else {
        leafletProxy("map_in_ui", session) %>% hideGroup(kotigroups[i])
        leafletProxy("map_in_ui", session) %>% hideGroup(potentiaalinengroups[i])
      }
    }
  })
  
  # kuvaajiin liittyvät elementit
  
  observe({
    cat('input$show_pendeling_plot: ' , input$show_pendeling_plot,'\n')
    cat('input$show_asuntojen_hinnat_plot: ' , input$show_asuntojen_hinnat_plot,'\n')
    cat('input$show_talojakauma_plot: ' , input$show_talojakauma_plot,'\n')
    cat('input$show_asumisvaljyys_plot: ' , input$show_asumisvaljyys_plot,'\n')
    cat('input$show_koulutusjakauma_plot: ' , input$show_koulutusjakauma_plot,'\n')
    cat('input$show_ikajakauma_plot: ' , input$show_ikajakauma_plot,'\n')
    cat('input$show_tulojakauma_plot: ' , input$show_tulojakauma_plot,'\n')
    cat('input$show_keskitulot_plot: ' , input$show_keskitulot_plot,'\n')
    cat('input$show_toimintajakauma_plot: ' , input$show_toimintajakauma_plot,'\n')
    cat('input$show_yleisimmat_ammatit_table: ' , input$show_yleisimmat_ammatit_table,'\n')
    
  })
  
  
  ### markkerien päivitys osoitekentän kautta ###
  ### kotiosoite ###
  
  observeEvent(input$koti_osoite_from_ui , {
    # jos ui on tyhjä
    
    if( input$koti_osoite_from_ui == koti_value_default  || nchar(str_trim(input$koti_osoite_from_ui))== 0 ) {
      
      # poista itse markkeri
      leafletProxy("map_in_ui", session) %>% 
        removeMarker('koti')
      
      # poista markkerrin liittyvät markerit
      leafletProxy("map_in_ui", session) %>% 
        clearGroup(kotigroups) 
      leafletProxy("map_in_ui", session) %>% 
        clearGroup('koti') 
      
      # poista markkeriin liittyvät zip-objektit
      remove_zip_objects_for('koti',zip_objects)
      
      # poista matka-ajat
      if(!is.null(durations$koti_to_tyo_durations)){ 
        durations$koti_to_tyo_durations = NULL 
      }
      if(!is.null(durations$koti_to_center_durations)){ 
        durations$koti_to_center_durations = NULL 
      }
    }
    
    # jos uissa tapahtuu
    
    if( nchar(str_trim(input$koti_osoite_from_ui))>0 ){
      if(is.vector(input$koti_osoite_from_ui)){
        if(input$koti_osoite_from_ui != koti_value_default  ){
          
          ui_events$count = ui_events$count + 1
          progress_koti_lisaa1 = shiny::Progress$new(session, min=1, max=4)
          on.exit(progress_koti_lisaa1$close())
          
          progress_koti_lisaa1$set(value = 1 , message = 'Haetaan kotiosoiteen tiedot')
          
          osoite = input$koti_osoite_from_ui
          print( 'muutetetaan kotia' )
          ui_time = Sys.time()
          this_input <- 'koti'
          
          # palauta paikkaa koskevat tiedot
          location_info = try(get_location_information(ui_time , click_time , ui_interaction_lag , osoite))
          print( 'kodin info haettu' )
          print( str(location_info) )
          
          progress_koti_lisaa1$set(value = 2 , message='Haetaan kodin palvelut' )
          
          ### jos koordinaatit löytyvät ###
          if(class(location_info) !='try-error' ){
            if(!is_empty(location_info$lon) ){
              if(!is.null(location_info$lon)){
                if(length(location_info$lon)>0){
                  
                  progress_koti_lisaa2 <<- shiny::Progress$new(session, min=1, max=6)
                  on.exit(progress_koti_lisaa2$close())
                  
                  progress_koti_lisaa2$set(value = 1 , message='Kotiosoiteen reitit keskustaan')
                  
                  print(head(location_info$lon))
                  print('Kotiosoite hyvä')
                  koti_location_information <<- location_info
                  
                  ### get route durations
                  
                  # durations to center
                  cat('\nkoti lat: ', location_info$lat, '\n')
                  cat('koti lon: ', location_info$lon, '\n')
                  cat('center lat: ', city_center_location$lat, '\n')
                  cat('center lon: ', city_center_location$lon , '\n')
                  koti_center_durations =  try(get_route_durations(from_lat = location_info$lat , from_lon=location_info$lon 
                                                                   , to_lat=city_center_location$lat , to_lon=city_center_location$lon)
                  )
                  if(class(koti_center_durations) != 'try-error'){
                    durations$koti_to_center_durations = lapply(koti_center_durations, duration_min_and_max)
                    cat('\nkoti_to_center_durations\n')
                    print(durations$koti_to_center_durations)
                  }
                  
                  if(input$ui_tyo_selected){
                    progress_koti_lisaa2$set(value = 2 ,message='Kotiosoiteen reitit töihin')
                    
                    # durations to work
                    koti_tyo_durations =  try(get_route_durations(from_lat = location_info$lat , from_lon=location_info$lon 
                                                                  , to_lat=tyo_location_information$lat , to_lon=tyo_location_information$lon)
                    )
                    if(class(koti_tyo_durations) != 'try-error'){
                      durations$koti_to_tyo_durations = lapply(koti_tyo_durations, duration_min_and_max)
                      # koti_to_tyo_durations <<- lapply(koti_tyo_durations, duration_min_and_max)
                      cat('\nkoti_to_tyo_durations\n')
                      print(durations$koti_to_tyo_durations)
                    }
                  }
                  progress_koti_lisaa2$set(value = 3 ,message='Päivitetään markkerit')
                  
                  
                  ### keskitä kotiosoitteeseen
                  if(!is.null(location_info$user_interaction_method)){
                    if(location_info$user_interaction_method == 'text'){
                      leafletProxy("map_in_ui" , session) %>%
                        setView( lng=location_info$lon , lat=location_info$lat , zoom = 13)
                    }
                  }
                  
                  
                  ### lisää kodille markkeri ###  
                  leafletProxy("map_in_ui" , session) %>%
                    addMarkers(lng = location_info$lon
                               , lat = location_info$lat
                               , layerId = this_input
                               , icon = icon_koti)
                  
                  ### poista vanhat kotiin liityvät markkerit ###
                  leafletProxy("map_in_ui", session) %>% 
                    clearGroup(kotigroups)
                  leafletProxy("map_in_ui", session) %>% 
                    clearGroup('koti')
                  
                  ### hae koordinaattitason palvelut
                  progress_koti_lisaa2$set(value = 4 , message='Haetaan kodin palvelut')
                  cat('input radius: ', input$radius , '\n')
                  
                  progress_koti_lisaa2$set(value = 5 ,message='Päivitetään palvelut')
                  
                  create_palvelu_markers(session,this_input,location_info$lat,location_info$lon,input$radius)
                  
                  progress_koti_lisaa2$set(value = 6 )
                }
              }
              
              progress_koti_lisaa1$set(value = 3 , message = 'Päivitetään alueen tiedot')
              
              ### hae zip-tason info
              update_zip_objects(location_info , this_input , zip_objects , session)
              print('zip metodi päivitetty')
              #### lopuksi päivitetään osoite
              if(location_info$user_interaction_method == 'click'){
                new_address = try( address_from_listing(location_info ) )
                if( validy_check_address( new_address) ){
                  output$koti_valikko = renderUI({
                    textInput("koti_osoite_from_ui", label = p("")
                              , value = new_address )
                  })
                }
              }
              progress_koti_lisaa1$set(value = 4)
              progress_koti_lisaa1$close()
            }
          }
        }
      }
    }
  }) 
  
  ### tyoosoite ### 
  
  observeEvent(input$tyo_osoite_from_ui , {
    if(input$tyo_osoite_from_ui == tyo_value_default || str_trim(input$tyo_osoite_from_ui)== "") {
      
      
      leafletProxy("map_in_ui", session) %>% 
        removeMarker('tyo')
      
      # poista töihin liittyvät reitit
      if(!is.null(durations$koti_to_tyo_durations)) {durations$koti_to_tyo_durations = NULL}
      if(!is.null(durations$potentiaalinen_to_tyo_durations)) {durations$potentiaalinen_to_tyo_durations = NULL}
      
    }
    
    if(input$tyo_osoite_from_ui != tyo_value_default ){
      if( nchar(str_trim(input$tyo_osoite_from_ui)) > 0 ){
        if(is.vector(input$tyo_osoite_from_ui)){
          
          ui_events$count = ui_events$count + 1
          progress_tyo_lisaa1 = shiny::Progress$new(session, min=1, max=3)
          on.exit(progress_tyo_lisaa1$close())
          progress_tyo_lisaa1$set(value = 1 , message = 'Haetaan työpaikan tiedot')
          
          osoite = input$tyo_osoite_from_ui
          print( 'muutetetaan tyota' )
          ui_time = Sys.time()
          this_input <- 'tyo'
          
          progress_tyo_lisaa1$set(value = 2 , message = 'Haetaan työpaikan tiedot')
          
          # palauta paikkaa koskevat tiedot
          location_info = try(get_location_information(ui_time , click_time , ui_interaction_lag , osoite))
          if(class(location_info) != 'try-error'){
            if(!is_empty(location_info$lon) ){
              if(!is.null(location_info$lon)){
                if(length(location_info$lon)>0){
                  
                  progress_tyo_lisaa2 = shiny::Progress$new(session, min=1, max=4)
                  on.exit(progress_tyo_lisaa2$close())
                  progress_tyo_lisaa2$set(value = 1 , message = 'Päivitetään reittitiedot 1')
                  
                  tyo_location_information <<- location_info
                  
                  # durations to koti
                  if(!is.null(koti_location_information)){
                    koti_tyo_durations =  try(get_route_durations(from_lat = location_info$lat 
                                                                  , from_lon=location_info$lon 
                                                                  , to_lat=koti_location_information$lat 
                                                                  , to_lon=koti_location_information$lon)
                    )
                    if(class(koti_tyo_durations) != 'try-error'){
                      # koti_to_tyo_durations <<- lapply(koti_tyo_durations, duration_min_and_max)
                      durations$koti_to_tyo_durations = lapply(koti_tyo_durations, duration_min_and_max)
                      cat('\nkoti_to_tyo_durations\n')
                      print(durations$koti_to_tyo_durations)
                    }
                  }
                  
                  progress_tyo_lisaa2$set(value = 2 , message = 'Päivitetään reittitiedot 2')
                  
                  # durations to potentiaalinen
                  if(!is.null(location_info)){
                    potentiaalinen_tyo_durations =  try(get_route_durations(from_lat = location_info$lat , from_lon=location_info$lon 
                                                                            , to_lat=potentiaalinen_location_information$lat , to_lon=potentiaalinen_location_information$lon)
                    )
                    if(class(potentiaalinen_tyo_durations) != 'try-error'){
                      # potentiaalinen_to_tyo_durations <<- lapply(potentiaalinen_tyo_durations, duration_min_and_max)
                      durations$potentiaalinen_to_tyo_durations = lapply(potentiaalinen_tyo_durations, duration_min_and_max)
                      cat('\npotentiaalinen_to_tyo_durations\n')
                      print(durations$potentiaalinen_to_tyo_durations)
                    }
                  }
                  
                  ### keskitä tyoosoitteeseen
                  if(!is.null(location_info$user_interaction_method)){
                    if(location_info$user_interaction_method == 'text'){
                      leafletProxy("map_in_ui" , session) %>%
                        setView( lng=location_info$lon , lat=location_info$lat , zoom = 13)
                    }
                  }
                  
                  
                  progress_tyo_lisaa2$set(value = 3 , message = 'Päivitetään työpaikan markkerit')
                  
                  ### lisää tyolle markkeri ###  
                  leafletProxy("map_in_ui" , session) %>%
                    addMarkers(lng = location_info$lon
                               , lat = location_info$lat
                               , layerId = this_input
                               , icon = icon_tyo)
                  
                  progress_tyo_lisaa2$set(value = 4 , message = 'Päivitetään työpaikan osoite')
                  
                  #### lopuksi päivitetään osoite
                  if(location_info$user_interaction_method == 'click'){
                    new_address = try( address_from_listing(location_info ) )
                    if( validy_check_address(new_address) ){
                      output$tyo_valikko = renderUI({
                        textInput("tyo_osoite_from_ui", label = p("")
                                  , value = new_address )
                      })
                    }
                    progress_tyo_lisaa2$set(value = 5 )
                    progress_tyo_lisaa2$close()
                  }
                }
              }
            }
          }
        }
        
        progress_tyo_lisaa1$set(value = 3)
        progress_tyo_lisaa1$close()
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
          clearGroup(potentiaalinengroups)
        leafletProxy("map_in_ui", session) %>% 
          clearGroup('potentiaalinen')
        
        # poista potentiaaliseen liittyvät reitit
        if(!is.null(durations$potentiaalinen_to_tyo_durations)){durations$potentiaalinen_to_tyo_durations = NULL }
        if(!is.null(durations$potentiaalinen_to_center_durations)){durations$potentiaalinen_to_center_durations = NULL }
        
        # poista markkeriin liittyvät zip-objektit
        remove_zip_objects_for('potentiaalinen',zip_objects)
      }
      
      if(nchar(str_trim(input$potentiaalinen_osoite_from_ui)) > 0){
        if(input$potentiaalinen_osoite_from_ui != potentiaalinen_value_default ){
          
          ui_events$count = ui_events$count + 1
          progress_potentiaalinen_lisaa1 = shiny::Progress$new(session, min=1, max=3)
          on.exit(progress_potentiaalinen_lisaa1$close())
          progress_potentiaalinen_lisaa1$set(value = 1 , message = 'Haetaan potentiaalisen osoite')
          
          osoite = input$potentiaalinen_osoite_from_ui
          print('muutetaan potentiaalista')
          ui_time = Sys.time()
          this_input <- 'potentiaalinen'
          
          # palauta paikkaa koskevat tiedot
          print('haetaan osoite')
          location_info = try(get_location_information(ui_time , click_time , ui_interaction_lag , osoite))
          
          
          progress_potentiaalinen_lisaa1$set(value = 2 , message = 'Lisätään potentiaalisen tiedot')
          
          ### jos koordinaatit löytyvät ###
          if(class(location_info) !='try-error' ){
            print('osoite löytyi')
            cat(str(location_info))
            if(!is_empty(location_info$lon) ){
              if(!is.null(location_info$lon)){
                if(length(location_info)>0){  
                  
                  progress_potentiaalinen_lisaa2 = shiny::Progress$new(session, min=1, max=5)
                  on.exit(progress_potentiaalinen_lisaa2$close())
                  progress_potentiaalinen_lisaa2$set(value = 1 , message = 'Haetaan potentiaalisen osoite')
                  
                  potentiaalinen_location_information <<- location_info
                  
                  ### get route durations
                  # durations to center
                  
                  progress_potentiaalinen_lisaa2$set(value = 2 , message = 'Potentiaalisen reitit keskustaan')
                  
                  cat('\npotentiaalinen lat: ', location_info$lat, '\n')
                  cat('potentiaalinen lon: ', location_info$lon, '\n')
                  cat('center lat: ', city_center_location$lat, '\n')
                  cat('center lon: ', city_center_location$lon , '\n')
                  potentiaalinen_center_durations =  try(get_route_durations(from_lat = location_info$lat , from_lon=location_info$lon 
                                                                             , to_lat=city_center_location$lat , to_lon=city_center_location$lon)
                  )
                  if(class(potentiaalinen_center_durations) != 'try-error'){
                    durations$potentiaalinen_to_center_durations = lapply(potentiaalinen_center_durations, duration_min_and_max)
                    # potentiaalinen_to_center_durations <<- lapply(potentiaalinen_center_durations, duration_min_and_max)
                    print(durations$potentiaalinen_to_center_durations)
                  }
                  
                  
                  # durations to work
                  if(input$ui_tyo_selected){
                    progress_potentiaalinen_lisaa2$set(value = 3 , message = 'Potentiaalisen reitit töihin')
                    
                    potentiaalinen_tyo_durations =  try(get_route_durations(from_lat = location_info$lat , from_lon=location_info$lon 
                                                                            , to_lat=tyo_location_information$lat , to_lon=tyo_location_information$lon)
                    )
                    if(class(potentiaalinen_tyo_durations) != 'try-error'){
                      durations$potentiaalinen_to_tyo_durations = lapply(potentiaalinen_tyo_durations, duration_min_and_max)
                      # potentiaalinen_to_tyo_durations <<- lapply(potentiaalinen_tyo_durations, duration_min_and_max)
                    }
                  }
                  
                  ### keskitä potentiaaliseen osoitteeseen
                  if(!is.null(location_info$user_interaction_method)){
                    if(location_info$user_interaction_method == 'text'){
                      leafletProxy("map_in_ui" , session) %>%
                        setView( lng=location_info$lon , lat=location_info$lat , zoom = 13)
                    }
                  }
                  
                  
                  progress_potentiaalinen_lisaa2$set(value = 4 , message = 'Lisätään potentiaalisen markkerit')
                  
                  ### lisää potentiaaliselle markkeri ###  
                  leafletProxy("map_in_ui" , session) %>%
                    addMarkers(lng = location_info$lon
                               , lat = location_info$lat
                               , layerId = this_input
                               , icon = icon_potentiaalinen)
                  
                  ### poista vanhat potentiaalinenin liityvät markkerit ###
                  leafletProxy("map_in_ui", session) %>% 
                    clearGroup(potentiaalinengroups)
                  leafletProxy("map_in_ui", session) %>% 
                    clearGroup('potentiaalinen')
                  
                  ### hae koordinaattitason palvelut
                  progress_potentiaalinen_lisaa2$set(value = 5 , message = 'Haetaan potentiaalisen palvelut')
                  
                  create_palvelu_markers(session,this_input,location_info$lat,location_info$lon,input$radius)
                  
                }
              }
              # hae zip-tason info
              
              progress_potentiaalinen_lisaa2$set(value = 6 , message = 'Haetaan potentiaalisen aluetiedot')
              
              update_zip_objects(location_info , this_input , zip_objects , session)
              print('potential zip-objects updadet')
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
              progress_potentiaalinen_lisaa2$set(value = 7)
              progress_potentiaalinen_lisaa2$close()
            }
          }
          progress_potentiaalinen_lisaa1$set(value = 3)
          progress_potentiaalinen_lisaa1$close()
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
            
            # palauta tekstikenttä oletusasetuksiin  
            output$koti_valikko = renderUI({
              textInput("koti_osoite_from_ui", label = p(""), value = koti_value_default) 
            })
          }
          else if(this_input == 'tyo'){
            
            output$tyo_valikko = renderUI({
              textInput("tyo_osoite_from_ui", label = p(""), value = tyo_value_default) 
            })
          }
          else if(this_input == 'potentiaalinen') {
            
            output$potentiaalinen_valikko = renderUI({
              textInput("potentiaalinen_osoite_from_ui", label = p(""), value = potentiaalinen_value_default) 
            })
          }
        }
      }
    }
  })
  
  ### remove polygon layers by clicking
  
  observeEvent(input$map_in_ui_shape_click , {
    leafletProxy("map_in_ui" , session) %>% 
      removeShape(input$map_in_ui_shape_click$id)
  })
  
  ##################### visut  #####################
  
  # pendeling
  
  output$pendeling_plot = renderPlot({
    
    withProgress(message = 'Päivitetään reittikuvaajaa',{
      
      dat_titles = c('Kodista töihin' , 'Kodista Helsingin keskustaan' , 'Potentiaalisesta töihin' , 'Potentiaalisesta Helsingin keskustaan')
      
      dats = list(durations$koti_to_tyo_durations
                  , durations$koti_to_center_durations
                  , durations$potentiaalinen_to_tyo_durations
                  , durations$potentiaalinen_to_center_durations)
      print('poistetaan tyhjat aikatauluista')
      
      null_ind = sapply(dats, is.null)
      if(all(null_ind)){
        return(NULL)
      }
      
      dats = dats[!null_ind]
      dat_titles = dat_titles[!null_ind]
      
      names(dats) = dat_titles
      dat_df = melt(dats) %>% spread(L3, value)
      colnames(dat_df)[1:2] = c('time' ,'travel' )
      # varit: koti=1, potentiaalinen = 2
      dat_df$vari = 2
      dat_df$vari[grep('Kodista',dat_df$travel)] = 1
      dat_df$vari = as.factor(dat_df$vari)
      dat_df$time = ifelse(dat_df$time=='evening' , 'Ilta' , 'Aamu')
      
      # paletti
      if( '2' %in% as.character(dat_df$vari) && '1' %in% as.character(dat_df$vari) ){
        pal = paletti
      } else if('1' %in% as.character(dat_df$vari)){
        pal = paletti[1]
      } else{
        pal = paletti[2]
      }
      
      pic = ggplot(dat_df , aes( x = time , ymax = max , ymin = min , color= vari) ) + 
        geom_errorbar(size=2) + 
        scale_color_manual(values = pal) + 
        facet_wrap( ~ travel , ncol=1) + 
        coord_flip() +
        ylab('') +
        xlab('') +
        # ylim(0,60) +
        expand_limits(y=0) +
        theme(legend.position = "none"
              , strip.background = element_rect(fill="#ffffff")
              , strip.text.x = element_text(size=12) ) +
        ggtitle('Joukkoliikenteen matka-aikojen vaihteluväli minuuteissa') 
      
      incProgress(1)
      pic
    })
  }) 
  
  
  # asuntojen hinnat
  output$asuntojen_hinnat_plot <- renderPlot({
    if(!is.null(zip_objects$asuntojen_hinnat)){
      withProgress(message = 'Päivitetään asuntokuvaaja',{
        
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
          
          pic = ggplot(zip_objects$asuntojen_hinnat , aes(x=Vuosi , y=Keskiarvo , color=paikka)) + 
            geom_line( size = 2 ) + 
            scale_x_continuous('Vuosi' , breaks=c(minvuosi,meanvuosi,maxvuosi) ) + 
            scale_color_manual( values = pal ) + 
            ylab('Hinta (e/m^2)') + 
            theme(legend.position = "none") + 
            ggtitle('Asuntojen hinnat')
        }
        incProgress(1)
        pic
      })
    }
  })
  
  
  output$ikajakauma_plot <- renderPlot({
    if(!is.null(zip_objects$alue_info)){
      withProgress(message = 'Päivitetään ikäkuvaajaa',{
        
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
        
        pic = ggplot(data , aes(x=variable , y=value , fill=paikka)) + 
          geom_bar(stat="identity" , position=position_dodge() ) + 
          scale_fill_manual( values = pal ) + 
          xlab('') + 
          scale_y_continuous("") +
          coord_flip() + 
          theme(legend.position = "none") + 
          ggtitle('Ikäjakauma (% asukkaista)')
        incProgress(1)
        pic
      })
    } else{NULL}
  })
  
  output$talojakauma_plot <- renderPlot({
    if(!is.null(zip_objects$alue_info)){
      withProgress(message = 'Päivitetään talokuvaajaa',{
        
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
        
        pic = ggplot(data , aes(x=variable , y=value , fill=paikka)) + 
          geom_bar(stat="identity" , position=position_dodge() ) + 
          scale_fill_manual( values = pal ) + 
          xlab('') + 
          scale_y_continuous("") +
          coord_flip() + 
          theme(legend.position = "none") + 
          ggtitle('Asunnot (% asukkaista)')
        incProgress(1)
        pic
      })
    } else{NULL}
  })
  
  
  output$koulutusjakauma_plot <- renderPlot({
    if(!is.null(zip_objects$alue_info)){
      withProgress(message = 'Päivitetään koulutuskuvaajaa',{
        
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
        
        pic = ggplot(data , aes(x=variable , y=value , fill=paikka)) + 
          geom_bar(stat="identity" , position=position_dodge() ) + 
          scale_fill_manual( values = pal ) + 
          xlab('') + 
          scale_y_continuous("") +
          coord_flip() + 
          theme(legend.position = "none") + 
          ggtitle('Korkein koulutusaste (% asukkaista)')
        incProgress(1)
        pic
      })
    }
  })
  
  output$toimintajakauma_plot <- renderPlot({
    if(!is.null(zip_objects$alue_info)){
      withProgress(message = 'Päivitetään toimintakuvaajaa',{
        
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
        
        pic = ggplot(data , aes(x=variable , y=value , fill=paikka)) + 
          geom_bar(stat="identity" , position=position_dodge() ) + 
          scale_fill_manual( values = pal ) + 
          xlab('') + 
          scale_y_continuous("") +
          coord_flip() + 
          theme(legend.position = "none") + 
          ggtitle('Pääasiallinen toiminta (% asukkaista)')
        incProgress(1)
        pic
      })
    }
  })
  
  output$tulojakauma_plot <- renderPlot({
    if(!is.null(zip_objects$alue_info)){
      withProgress(message = 'Päivitetään tulojakaumakuvaajaa',{
        
        data = zip_objects$alue_info[ , c('paikka'
                                          ,'alimpaan.tuloluokkaan.kuuluvat.asukkaat'
                                          , 'keskimmäiseen.tuloluokkaan.kuuluvat.asukkaat' 
                                          , 'ylimpään.tuloluokkaan.kuuluvat.asukkaat')]
        colnames(data)[2:4] = c('Alin tuloluokka', 'Keskimmäinen tuloluokka' , 'Ylin tuloluokka')
        data = melt( data , factorsAsStrings = T)
        
        # paletti
        pal = paletti
        if(length(unique(data$paikka)) == 1 ){
          if( unique(data$paikka) == 'koti'  ){
            pal = paletti[1]
          } else{
            pal = paletti[2]
          }
        }
        
        pic = ggplot(data , aes(x=variable , y=value , fill=paikka)) + 
          geom_bar(stat="identity" , position=position_dodge() ) + 
          scale_fill_manual( values = pal ) + 
          xlab('') + 
          scale_y_continuous("") +
          coord_flip() + 
          theme(legend.position = "none") + 
          ggtitle('Tuloluokat (% asukkaista)')
        incProgress(1)
        pic
      })
    }
  })
  
  output$keskitulot_plot <- renderPlot({
    if(!is.null(zip_objects$alue_info)){
      withProgress(message = 'Päivitetään keskitulokuvaajaa',{
        
        data = zip_objects$alue_info[ , c('paikka'
                                          , 'keskitulot')]
        data = melt( data ,factorsAsStrings = T)
        data$variable = ifelse(data$variable == 'Keskimmäinen tuloluokka' , 'Keskimmäinen\ntuloluokka', data$variable )
        
        # paletti
        pal = paletti
        if(length(unique(data$paikka)) == 1 ){
          if( unique(data$paikka) == 'koti'  ){
            pal = paletti[1]
          } else{
            pal = paletti[2]
          }
        }
        
        pic = ggplot(data , aes(x=variable , y=value , fill=paikka)) + 
          geom_bar(stat="identity" , position=position_dodge() ) + 
          scale_fill_manual( values = pal ) + 
          ylab('') + 
          xlab('') + 
          scale_x_continuous('') +
          coord_flip() + 
          theme(legend.position = "none") + 
          ggtitle('Keskitulot') +
          theme(axis.ticks = element_blank(), axis.text.y = element_blank())
        incProgress(1)
        pic
      })
    }
  })
  
  output$asumisvaljyys_plot <- renderPlot({
    if(!is.null(zip_objects$alue_info)){
      withProgress(message = 'Päivitetään asumisväljyyskuvaajaa',{
        
        data = zip_objects$alue_info[ , c('paikka'
                                          , 'asumisväljyys')]
        data = melt( data ,factorsAsStrings = T)
        
        # paletti
        pal = paletti
        if(length(unique(data$paikka)) == 1 ){
          if( unique(data$paikka) == 'koti'  ){
            pal = paletti[1]
          } else{
            pal = paletti[2]
          }
        }
        
        pic = ggplot(data , aes(x=variable , y=value , fill=paikka)) + 
          geom_bar(stat="identity" , position=position_dodge() ) + 
          scale_fill_manual( values = pal ) + 
          xlab('') + 
          scale_y_continuous("") +
          coord_flip() + 
          theme(legend.position = "none") + 
          ggtitle('Asumisväljyys')
        incProgress(1)
        pic
      })
    }
  })
  
  output$yleisimmat_ammatit_table <- renderTable({
    if(!is.null(zip_objects$alue_info)){
      withProgress(message = 'Päivitetään yleisimmät ammattiryhmät',{
        
        data = zip_objects$alue_info[ , c('paikka'
                                          , 'yleisimmat')]
        data = cbind(data$paikka, data.frame(str_split_fixed(data$yleisimmat, ",",3) ) )
        print(data)         
        
        incProgress(1)
        data
      })
    }
  }
  , include.colnames=F
  , include.rownames=F
  )
  
  output$closest_services_table = renderTable({
    
  })
  
  ################################## VANHAT ##################################
  
  # for testing settings_button
  #   observeEvent( input$settings_button , {
  #     session$sendCustomMessage(type = 'testmessage',
  #                               message = list(settings_button = input$settings_button))
  #     # cat(isolate(input$settings_button))
  #   })  
  
  
  #   # Palvelut
  #   output$palvelut_box = renderUI({
  #     checkboxInput('palvelut', 'Palvelut', TRUE)
  #   })
  #   
  #   output$palvelut_extra_box = renderUI({
  #     checkboxInput('palvelut_extra_auki', 'Lisää vaihtoehtoja', FALSE)
  #   })
  #   
  #   output$palvelut_extra_group = renderUI({
  #     conditionalPanel(condition = 'input.palvelut_extra_auki == true',
  #                      checkboxGroupInput('palvelut_extra_group',NULL,palvelut_nimet,selected=palvelut_nimet))
  #   })
  
  
  ################################## DEBUGGAUS ##################################
  
  # LIITÄ TÄMÄ UIHIN, JOS TARVETTA
  ### oikean puolen debug-paneeeli
  #   , if(DEBUG){
  #     absolutePanel(  
  #       style = "background-color: #ffffff;"
  #       , fixed = F
  #       , draggable = T
  #       , top = 60
  #       , left = "auto"
  #       , right = 40
  #       , bottom = "auto"
  #       , width = 500
  #       , height = "auto"
  #       , textOutput("input.selected_boxes")
  #       , textOutput("click_latlon")
  #       , textOutput("click_address")
  #       , textOutput("click_all_info")
  #       , dataTableOutput("test_table")
  #       , textOutput("click_count_text")
  #     )
  #   }
  
  #   if(DEBUG){
  #     test_data_time_series = data.frame(  value = c(cumsum(rnorm( 16,0,1 ) ) , cumsum(rnorm( 16,0,1 ) ) )
  #                                          , paikka = rep( c('koti','muutto') , each=16 )
  #                                          , vuosi = 2000:2015)
  #     
  #     output$test_data_time_series_plot <- renderChart({
  #       n <- nPlot(value ~ vuosi, data=test_data_time_series, type = "lineChart" , group="paikka")
  #       #     n$xAxis(tickFormat ="#!function (d) {return d3.time.format('%m/%Y')(new Date(d * 86400000 ));}!#",showMaxMin=FALSE)
  #       #     n$yAxis(tickFormat ="#!function (d) {return d3.format('.1f')(d);}!#",showMaxMin = FALSE)
  #       n$chart(useInteractiveGuideline=TRUE)
  #       n$set(dom = 'test_data_time_series_plot', width = 330 , height=280)
  #       n
  #     })
  #     
  #     # example placeholder for texst
  #     output$kotiosoite <- renderText({ paste( input$koti_osoite_from_ui ) })
  #     output$muutto_osoite <- renderPrint({ cat(input$muutto_osoite_from_ui) })
  #     # example placeholder for pictures  
  #     output$koti_pic = renderPlot( plot(1:10) )
  #     output$muutto_pic = renderPlot( plot(10:1) )
  #     
  #     
  #     # output$click_... - textit debuggausta varten
  #     output$click_latlon = renderText( paste( 'click lon lat: ' , click_info()$rounded[1] , click_info()$rounded[2]  ))
  #     output$click_address = renderText( paste( 'address: ' 
  #                                               , reverse_geocode_nominatim(lat = click_info()$value[2] 
  #                                                                           , lon = click_info()$value[1]  )))
  #     # palauttaa kaiken click_info()-funktion antaman infon yhtenä pötkönä
  #     output$click_all_info = renderText(
  #       paste( reverse_geocode_nominatim(lat = click_info()$value[2] 
  #                                        , lon = click_info()$value[1] 
  #                                        , get = 'listing' ) )
  #     )
  #     
  #     # testitaulukko
  #     test_table_head = reactive({
  #       test_table_head =head(
  #         get_nearest( conn , 'coord' , click_info()$value[2] , click_info()$value[1] , 2 , 'Ruokakaupat' , 100 ) 
  #         , 2 )
  #       #print(test_table_head)
  #       return(test_table_head)
  #     })
  #     output$test_table <- renderDataTable({ test_table_head() })
  #     output$click_count_text = renderPrint(output$click_count)
  #     
  #     output$selected_boxes = renderText({
  #       input$output_selector
  #     })
  #   } 
})
