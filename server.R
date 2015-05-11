# server_dir <- dirname(sys.frame(1)$ofile)

library(leaflet)

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
      setView( lng=24.95 , lat=60.21 , zoom = 13) %>%
      # add test circles
      addMarkers(lng = runif(10 , min = 24.9 , max = 25 )
                       , lat = runif(10 , min = 60.20 , max = 60.22), 
                       layerId = paste0("marker", 1:10))
  }) 
  
  # example placeholder for texts
  output$kotiosoite <- renderText({ paste( input$kotiosoite_from_ui ) })
  output$muutto_osoite <- renderPrint({ cat(input$muutto_osoite_from_ui) })
  # example placeholder for pictures  
  output$koti_pic = renderPlot(plot(1:10))
  output$muutto_pic = renderPlot(plot(10:1))
  
  observeEvent(input$map_in_ui_marker_click, {
    leafletProxy("map_in_ui", session) %>% 
      removeMarker(input$map_in_ui_marker_click$id)
  })
  
  observeEvent(input$map_in_ui_click, {
      leafletProxy("map_in_ui") %>%
        addMarkers(lng = input$map_in_ui_click$lng, lat = input$map_in_ui_click$lat)
  })
  
})
