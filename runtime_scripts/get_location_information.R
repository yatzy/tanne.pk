
get_location_information = function(ui_time , click_time , ui_interaction_lag , osoite = osoite ){
  
  needed_arguments = c('ui_time' , 'click_time' , 'ui_interaction_lag' , 'osoite')
  given_arguments = names(as.list(match.call())[-1])
  # print(given_arguments)
  success_list = sapply(needed_arguments , function(x){
    x %in% given_arguments
  })
  if(!all(success_list)){
    stop('Not all parameters given')
  }
  
  ui_lag = try(as.numeric(difftime(ui_time , click_time , units='secs')))
  print(ui_lag)
  if(class(ui_lag) != 'try-error'){
    # jos klikattu 
    # tiedetään klikin koordinaatit ja haetaan osoitteet
    # jos muutettu osoitteesta, tiedetään osoite, ja haetaan koordinaatit
    if( ui_lag < ui_interaction_lag ){
      
      user_interaction_method ='click'
      
      cat('muuttui klikkaamalla')
      cat(', ero: ' , as.numeric(difftime(ui_time , click_time , units='secs')),'\n' )
      
      location_info = click_info()$adress_details
      location_info$lat = click_info()$lat
      location_info$lon = click_info()$lon
      location_info$user_interaction_method = user_interaction_method
      
    } else{
      
      user_interaction_method ='text'
      
      cat('Muuttui kirjoittamalla')
      cat(', ero: ' , as.numeric(difftime(ui_time , click_time , units='secs')),'\n' )
      
      location_info = geocode_nominatim(osoite)
      location_info$address_print = address_from_listing(location_info)
      location_info$user_interaction_method = user_interaction_method
    }
    # print(str(location_info))
    return(location_info)
  }
}