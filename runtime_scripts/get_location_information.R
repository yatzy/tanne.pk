
get_location_information = function(ui_time , click_time , ui_interaction_lag , osoite = osoite ){
  
  # jos klikattu 
  # tiedetään klikin koordinaatit ja haetaan osoitteet
  # jos muutettu osoitteesta, tiedetään osoite, ja haetaan koordinaatit
  if(as.numeric(difftime(ui_time , click_time , units='secs')) < ui_interaction_lag ){
    
    user_interaction_method ='click'
    
    cat('muuttui klikkaamalla')
    cat(', ero: ' , as.numeric(difftime(ui_time , click_time , units='secs')),'\n' )
    
    location_info = click_info()$adress_details
    location_info$lat = click_info()$lat
    location_info$lon = click_info()$lon
    
  } else{
    user_interaction_method ='text'
    
    cat('Muuttui kirjoittamalla')
    cat(', ero: ' , as.numeric(difftime(ui_time , click_time , units='secs')),'\n' )
    
    location_info = geocode_nominatim(osoite)
    
  }
  # print(str(location_info))
  return(location_info)
}