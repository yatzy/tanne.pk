# helper functions

makeDF <- function(List, Names) {
  m <- t(vapply(List, 
                FUN = function(X) unlist(X)[Names], 
                FUN.VALUE = numeric(length(Names))))
  as.data.frame(m)
}

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
reverse_names = c("place_id","licence","osm_type","osm_id","lat","lon","display_name","address" )

geocode_nominatim = function(address, result_count=1, source_url='mapquest' , key = mapquest_key  ){
  
  require(jsonlite) 
  require(RCurl) 
  
  properaddress   = gsub(' ','+',address) %>% gsub( 'ä','%C3%A4',. ) %>% gsub( 'ö','%C3%B6',. )
  if(source_url == 'mapquest'){
    urlformat = 'http://open.mapquestapi.com/nominatim/v1/search.php?format=json&key=%s&q=%s&addressdetails=1&limit=%d'
  } else if(source_url == 'osm'){
    urlformat = 'http://nominatim.openstreetmap.org/search?q=%s&format=json&polygon=0&addressdetails=1'
  }
  searchurl = sprintf(urlformat , key ,properaddress , result_count)
  
  #searchjson = try(getURIAsynchronous(searchurl)  , silent = TRUE )
  searchjson = try(getURL(searchurl)  , silent = TRUE )
  
  if( class(searchjson) == 'try-error' ){
    
    data = rep(NA , length(return_names))
    names(data) = return_names
  } else{
    data = jsonlite::fromJSON(searchjson,flatten=F)
    data$lat = as.numeric(data$lat)
    data$lon = as.numeric(data$lon)
    # zip = try(as.character(data$address$postcode))
#     if(class(zip) != 'try-error'){
#       data$zip = as.character(data$address$postcode)
#     }
  }
  return(data)
}


# used in geocode_vec to return full data frame with all names in any element of result list
list_to_df = function(vec_list){
  nimet = unique( unlist( sapply(vec_list , names) ) )
  rivit = length(vec_list)
  
  ret_df = data.frame( matrix( NA , nrow=rivit , ncol=length(nimet)  ) )
  colnames(ret_df) = nimet
  helper_row = ret_df[1,]
  
  for(rivi in 1:rivit){
    taysi_rivi = merge(helper_row , t(data.frame(vec_list[[rivi]])) , all=T )[1,]
    ret_df[rivi , ] = taysi_rivi
  }
  return(ret_df)
}

geocode_vec = function(address_vec ){
  library(pbapply) 
  library(dplyr)
  ret = pblapply( address_vec ,   geocode_nominatim ) %>% sapply(unlist) 
  return(list_to_df(ret))
}

# not reaylly needed anymore
geocode_nominatim_best = function(address){
  # returns the best bet for address
  addr_table = geocode_nominatim(address)
  best = try( addr_table[ which.max(addr_table$importance) , ] , silent = TRUE )
  if(class(best) == 'try-error') {
    best = rep(NA , length(return_names))
    names(best) = return_names
    return( best )
  } else{
    return(best)
  }
}

reverse_geocode_nominatim = function( lat , lon , key = mapquest_key , get='listing' , limit=1 ){
  
  require(magrittr) 
  require(jsonlite) 
  require(RCurl) 
  
  base_url = 'http://open.mapquestapi.com/nominatim/v1/reverse.php?format=json&key=%s&limit=%d&lat=%f&lon=%f'
  searchurl   = sprintf(base_url , key , limit , lat , lon)
  searchjson = try( getURL(searchurl) , silent=TRUE)
  
  if( class(searchjson) == 'try-error' ){    
    data = rep(NA , length(reverse_names))
    names(data) = reverse_names
  } else{
    data = jsonlite::fromJSON(searchjson,flatten=T)
  }
  
  # jossain tapauksissa kadun numero menee väärään paikkaan
  # esim data$address$address29, pitäisi olla data$address$house_number = 29
  ### VEDETÄÄN TAKAISIN, myös koordinaateilla 60.2708953 , 24.9257921
  ### on address$address29
  #   if( length( grep('address' , names(data$address) ) ) > 0  ){
  #     osoite_taalta = min( grep('address' , names(data$address) ) )
  #     house_number_with_name = names( data$address[osoite_taalta] )
  #     house_number_index = gregexpr( "[0-9]{1,3}",  house_number_with_name )
  #     number = try ( regmatches( house_number_with_name , house_number_index) )
  #     if( class(number) != 'try-error' ){
  #       data$address$house_number = number
  #     }
  #   }
  
  # jos street_number, niin kaytetaan house_number, jos saatavilla
  if( is.null(data$address$street_number)) {
    if( !is.null(data$address$house_number)) {
      data$address$street_number = data$address$house_number
    }
  }
  
  ## joskus data$address$road on kohdassa data$address$construction tai data$address$pedestrian
  if( is.null( data$address$road )  ){
    if(!is.null(data$address$construction)){
      data$address$road = data$address$construction
    } else if( !is.null(data$address$pedestrian) ){
      data$address$road = data$address$pedestrian
    } else if( !is.null(data$address$cycleway) ){
      data$address$road = data$address$cycleway
    } else if( !is.null(data$address$footway) ){
      data$address$road = data$address$footway
    }
  }
  
  if(get == 'street'){
    if( !is.null(data$address$house_number) ){
      return_value = paste(   data$address$road , ' ' 
                              , data$address$house_number , ', '
                              , data$address$postcode , ' '
                              , data$address$city , sep='')
    } else{
      return_value = paste(   data$address$road , ', ' 
                              , data$address$postcode , ' '
                              , data$address$city , sep='')
    }
  } else if(get == 'listing'){
    return_value = data
  }
  
  return(return_value)
  
}

address_from_listing = function(listing_object){
  if( !is.null(listing_object$address$house_number) ){
    return_value = try(paste(   listing_object$address$road , ' ' 
                            , listing_object$address$house_number , ', '
                            , listing_object$address$postcode , ' '
                            , listing_object$address$city , sep='') )
  } else{
    return_value = try(paste(   listing_object$address$road , ', ' 
                            , listing_object$address$postcode , ' '
                            , listing_object$address$city , sep=''))
  }
  
  if(class(return_value) == 'try-error'){
    stop( 'error with address decoding' )
  }
  
  return(return_value)
}

validy_check_address = function(address){
  require(stringr)
  if(class(address) != 'try-error'){
    long_enough = nchar( str_replace_all(address , "[-., ]",'')) > 1
    if(long_enough){
      return(TRUE)
    }
  }
  return(FALSE)
}


# example
# geocode_nominatim('mannerheimintie 53 , helsinki')
# geocode_nominatim('mannerheimintie 53 , helsinki')[c('lat','lon')]
# geocode_nominatim('mannerheimintie 53 , helsinki' , 3)[c('lat','lon')]
# geocode_nominatim('mannerheimintie 55 , helsinki')[c('lat','lon')]
# geocode_nominatim('mannerheimintie 49 , helsinki')[c('lat','lon')]
# geocode_nominatim('mannerheimintie 59 , helsinki')[c('lat','lon')]
# geocode_nominatim('mannerheimintie 50 , helsinki')[c('lat','lon')]
# geocode_nominatim('mannerheimintie 50 , helsinki')
# reverse_geocode_nominatim(60.238 , 24.934 )
# asdf =  reverse_geocode_nominatim(60.238 , 24.934 , get = 'listing' )
# address_from_listing(asdf)
# 
# asd = geocode_nominatim('rinne 4, helsinki')
# address_from_listing(asd)
# 
# reverse_geocode_nominatim(60.1899456 , 24.916448 , get = 'listing' )
## mita tapahtuu?
# reverse_geocode_nominatim(60.1625814 , 24.9392381 , get = 'listing' ) # korjattu
## mita tapahtuu
# reverse_geocode_nominatim(60.25753195 , 24.8657243147127 , get = 'listing' ) # korjattu
## mita tapahtuu
# reverse_geocode_nominatim(60.1704434 , 24.934 , get = 'listing' ) # korjattu
## mita tapahtuu
# reverse_geocode_nominatim(60.2708953 , 24.9257921 , get = 'listing' ) # korjattu

