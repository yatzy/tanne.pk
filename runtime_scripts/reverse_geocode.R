library(RCurl)
library(jsonlite)
library(magrittr)
# returned names by reverse_geocode_table_nominatim
return_names = c("place_id", "licence", "osm_type", "osm_id", "boundingbox", 
                 "lat", "lon", "display_name", "class", "type", "importance", 
                 "icon", "address.pub", "address.house_number", "address.road", 
                 "address.suburb", "address.city", "address.county", "address.state_district", 
                 "address.state", "address.postcode", "address.country", "address.country_code"
)


geocode_table_nominatim = function(address, result_count=1, source_url='mapquest'  ){
   # Gets location data form a given address.
   #
   # Args:
   #   address: Given address.
   #
   # Returns:
   #   An object with the address data.
  require(magrittr) 
  
   properaddress   = gsub(' ','+',address) %>% gsub( 'ä','%C3%A4',. ) %>% gsub( 'ö','%C3%B6',. )
   if(source_url == 'mapquest'){
      urlformat = 'http://open.mapquestapi.com/nominatim/v1/search.php?format=json&q=%s&addressdetails=1&limit=%d'
   } else if(source_url == 'osm'){
   urlformat = 'http://nominatim.openstreetmap.org/search?q=%s&format=json&polygon=0&addressdetails=1'
   }
   searchurl = sprintf(urlformat,properaddress , result_count)
   
   #searchjson = try(getURIAsynchronous(searchurl)  , silent = TRUE )
   searchjson = try(getURL(searchurl)  , silent = TRUE )
   
   if( class(searchjson) == 'try-error' ){
      
      data = rep(NA , length(return_names))
      names(data) = return_names
      return(data)
   } else{
      data = jsonlite::fromJSON(searchjson,flatten=TRUE)
      return(data)
   }
}


geocode_nominatim = function(address){
   # returns the best bet for address
   addr_table = geocode_table_nominatim(address)
   best = try( addr_table[ which.max(addr_table$importance) , ] , silent = TRUE )
   if(class(best) == 'try-error') {
      best = rep(NA , length(return_names))
      names(best) = return_names
      return( best )
   } else{
      return(best)
   }
}

reverse_geocode_nominatim = function( lat , lon ){
  
  base_url = 'http://open.mapquestapi.com/nominatim/v1/reverse.php?format=json&limi=1&lat=%f&lon=%f'
  searchurl   = sprintf(base_url , lat , lon)
  searchjson = getURL(searchurl)
  data = jsonlite::fromJSON(searchjson,flatten=TRUE)
  return(data)
  
}


# example
# geocode_table_nominatim('mannerheimintie 53 , helsinki')[c('lat','lon')]
# geocode_table_nominatim('mannerheimintie 53 , helsinki' , 3)[c('lat','lon')]
# geocode_nominatim('mannerheimintie 55 , helsinki')[c('lat','lon')]
# geocode_nominatim('mannerheimintie 49 , helsinki')[c('lat','lon')]
# geocode_nominatim('mannerheimintie 59 , helsinki')[c('lat','lon')]
# geocode_nominatim('mannerheimintie 50 , helsinki')[c('lat','lon')]
# geocode_table_nominatim('mannerheimintie 50 , helsinki')
