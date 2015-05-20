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


geocode_table_nominatim = function(address, source_url='mapquest'){
   # Gets location data form a given address.
   #
   # Args:
   #   address: Given address.
   #
   # Returns:
   #   An object with the address data.
   
   properaddress   = gsub(' ','+',address) %>% gsub( 'ä','%C3%A4',. ) %>% gsub( 'ö','%C3%B6',. )
   if(source_url == 'mapquest'){
      urlformat = 'http://open.mapquestapi.com/nominatim/v1/search.php?format=json&q=%s&addressdetails=1&limit=3'
   } else if(source_url == 'osm'){
   urlformat = 'http://nominatim.openstreetmap.org/search?q=%s&format=json&polygon=0&addressdetails=1'
   }
   searchurl = sprintf(urlformat,properaddress)
   
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

# example
# geocode_nominatim('mannerheimintie 53 , helsinki')[c('lat','lon')]
# geocode_nominatim('mannerheimintie 55 , helsinki')[c('lat','lon')]
# geocode_nominatim('mannerheimintie 49 , helsinki')[c('lat','lon')]
# geocode_nominatim('mannerheimintie 59 , helsinki')[c('lat','lon')]
# geocode_nominatim('mannerheimintie 50 , helsinki')[c('lat','lon')]
# geocode_table_nominatim('mannerheimintie 50 , helsinki')
