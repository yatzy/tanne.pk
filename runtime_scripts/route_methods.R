multiply_to_length = function(val , wanted_length){
  as.character(val) %>% str_replace('\\.' , '')  -> new_val
  new_val %>% nchar() -> val_length
  needed_zeros = wanted_length - val_length
  
  if(needed_zeros>0){
    wanted_zeros = paste(rep(0,needed_zeros), collapse='')
    multiplier = paste0( 1, wanted_zeros  ,sep='') %>% as.numeric() 
    ret = as.numeric(new_val)*multiplier
  } else if( needed_zeros ==0 ){
    ret = as.numeric(new_val)
  } else{
    ret = substr( as.character(new_val) , 1 , wanted_length ) %>% as.numeric()
  }
  return( ret )
}

multiply_to_length_vec = function( val_vec , wanted_length ){
  val_vec  = sapply( val_vec , multiply_to_length , wanted_length )
  return(val_vec)
}

get_route_durations = function(from_lat , from_lon , to_lat , to_lon ){
  require(jsonlite)
  
  this_monday = format(as.Date(cut(Sys.Date(), "weeks")) , format = "%Y%m%d" )
  morning =  '0800' 
  evening =  '2100' 
  
  coords = c( from_lat , from_lon , to_lat , to_lon )
  coord_names = c('from_lat' , 'from_lon','to_lat' , 'to_lon')
  
  coords = sapply( coords  , function(x){
    nums = as.numeric(x)
    return(nums)
  })
  if(!is.numeric(coords)){
    stop('cannot mutate coordinates to numeric')
  }
  
#   reittiopas_res_list = mclapply( c(morning , evening) , function(this_time){
#     print(this_time)
#     base_url = 'http://api.reittiopas.fi/hsl/prod/?request=route&user=tannepk&pass=karttasovellus&date=%s&time=%s&show=5&detail=limited&format=json&epsg_in=wgs84&epsg_out=wgs84&from=%f,%f&to=%f,%f'
#     query_url = sprintf(base_url , this_monday , this_time ,  from_lon , from_lat  , to_lon , to_lat)
#     con <- url(query_url)
#     on.exit(close(con)) # sulje kun loppuu
#     api_res = readLines(con)
#     res = try(jsonlite::fromJSON(api_res) )
#     return(res)
#   })
  reittiopas_res_list = lapply( c(morning , evening) , function(this_time){
    print(this_time)
    base_url = 'http://api.reittiopas.fi/hsl/prod/?request=route&user=tannepk&pass=karttasovellus&date=%s&time=%s&show=5&detail=limited&format=json&epsg_in=wgs84&epsg_out=wgs84&from=%f,%f&to=%f,%f'
    query_url = sprintf(base_url , this_monday , this_time ,  from_lon , from_lat  , to_lon , to_lat)
    con <- url(query_url)
    on.exit(close(con)) # sulje kun loppuu
    api_res = readLines(con)
    res = try(jsonlite::fromJSON(api_res) )
    return(res)
  })
  
  error_ind = sapply( reittiopas_res_list ,function(res){
    class(res) == 'try-error'
  })
  if(any(error_ind)){
    stop( 'error in reittiopas results' )
  }
  
  duration_list = lapply( reittiopas_res_list , function(reittiopas_res){
    # print(head(reittiopas_res))
    sapply( reittiopas_res , function(reittiopas_part){
      # print(head(reittiopas_part))
      duration = try(as.numeric( reittiopas_part$duration ) / 60 )
      if(class(duration) == 'try-error'){
        stop('cannot coerce durations to numeric')
      }
      return(duration)
      
    })
  })
  
  error_ind = sapply( duration_list , function(x){
    class(x) == 'try-error'
  })
  if(any(error_ind)){
    stop('error in creating reittiopas duration list')
  }
  
  names(duration_list) = c('morning' , 'evening')
  cat( 'duration_list\n')
  print( duration_list)
  return(duration_list )
  
}

base_floor <- function(x,base){ 
  base*floor(x/base) 
}
base_ceiling <- function(x,base){ 
  base*ceiling(x/base) 
}
duration_min_and_max = function( duration_vec ){
  min_max = list( min = min(duration_vec) , max = max(duration_vec)  )
  # min_max = list( min = base_floor(min(duration_vec) , 5) , max = base_ceiling(max(duration_vec) , 5 ) )
  return(min_max)
}

# d1 = list(lat = 60.173086, lon = 24.937271)
# d2 = list(lat = 60.205386, lon = 24.974783)
# from_lat = d1$lat ; from_lon=d1$lon ; to_lat=d2$lat ; to_lon=d2$lon
# test_times = get_route_durations(from_lat = d1$lat , from_lon=d1$lon , to_lat=d2$lat , to_lon=d2$lon)
# duration_min_and_max(test_times$morning)
# duration_min_and_max(test_times$evening)

