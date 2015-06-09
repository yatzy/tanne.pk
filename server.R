
shinyServer(function(input, output, session) {
  
  reactive_values <- reactiveValues(msg = "")
  markerOptions(draggable = TRUE)
  # create variable to ui
  output$map_in_ui <- renderLeaflet({
    # init map
    leaflet() %>%
      # add map layer
      addTiles('//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png'
               , attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>' ) %>% 
      # set initial boundaries to centre of Helsinki
      setView( lng=24.95 , lat=60.21 , zoom = 13)
  }) 
  
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
  
  # adding new markers
  observeEvent(input$map_in_ui_click, {
    leafletProxy("map_in_ui" , session) %>%
      addMarkers(lng = input$map_in_ui_click$lng
                 , lat = input$map_in_ui_click$lat
                 , layerId = paste0( 'marker', runif(1,11,100000)) )
    
  })
  
  # lonlat() - functio palauttaa viimeisimmän karttaklikin leveys- ja pituuspiirit
  lonlat = eventReactive(input$map_in_ui_click , { 
    list(
      value = c( lon = as.numeric(input$map_in_ui_click$lng)  
                 , lat = as.numeric(input$map_in_ui_click$lat) )
      , rounded = c( lon = round(as.numeric(input$map_in_ui_click$lng) , 3) 
                     , lat = round(as.numeric(input$map_in_ui_click$lat) , 3))
    )
    
  })
  
  # output$click_... - textit debuggausta varten
  output$click_latlon = renderText( paste( 'click lon lat: ' , lonlat()$rounded[1] , lonlat()$rounded[2]  ))
  output$click_address = renderText( paste( 'address: ' 
                                            , reverse_geocode_nominatim(lat = lonlat()$value[2] 
                                                                        , lon = lonlat()$value[1]  )))
# palauttaa kaiken lonlat()-funktion antaman infon yhtenä pötkönä
  output$click_all_info = renderText(
    paste( reverse_geocode_nominatim(lat = lonlat()$value[2] 
                                     , lon = lonlat()$value[1] 
                                     , get = 'listing' ) )
    )
  
  # removing existing markers
  observeEvent(input$map_in_ui_marker_click, {
    leafletProxy("map_in_ui", session) %>% 
      removeMarker(input$map_in_ui_marker_click$id)
  })
  
})
