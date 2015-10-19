
get_nearest = function( conn , tablename , lat , lon , radius , tyyppi  , count ){
  
  needed_arguments = c('conn' , 'tablename' , 'lat' , 'lon' , 'radius' , 'tyyppi'  , 'count')
  given_arguments = names(as.list(match.call())[-1])
  # print(given_arguments)
  success_list = sapply(needed_arguments , function(x){
    x %in% given_arguments
  })
  if(!all(success_list)){
    return(NA)
  }
  
  
  query_base = "
  SELECT 
  nimi , 
  tyyppi , 
  osoite ,
  lat , 
  lon ,  
  distance
  FROM (
  SELECT basetable.nimi ,
  basetable.lat , 
  basetable.lon ,
  basetable.osoite ,
  basetable.tyyppi , 
  helptable.radius ,
  helptable.distance_unit
  * DEGREES(ACOS(COS(RADIANS(helptable.latpoint))
  * COS( RADIANS( basetable.lat ) )
  * COS( RADIANS( helptable.longpoint - basetable.lon ) )
  + SIN( RADIANS( helptable.latpoint ) )
  * SIN( RADIANS( basetable.lat) ) ) ) 
  AS distance
  -- tablename tahan
  FROM %s
  AS basetable
  JOIN (   
  /* parametrit */
  SELECT  %f AS latpoint ,    
  %f AS longpoint ,
  %f AS radius ,
  -- vakio
  111.045 AS distance_unit
  ) 
  AS helptable ON 1=1
  WHERE 
  basetable.lat
  BETWEEN 
  helptable.latpoint  - (helptable.radius / helptable.distance_unit)
  AND 
  helptable.latpoint  + (helptable.radius / helptable.distance_unit)
  AND 
  basetable.lon
  BETWEEN 
  helptable.longpoint - (helptable.radius / (
  helptable.distance_unit * COS(RADIANS(helptable.latpoint))))
  AND 
  helptable.longpoint + (helptable.radius / (
  helptable.distance_unit * COS(RADIANS(helptable.latpoint))))
  ) AS returntable
  WHERE 
  distance <= radius
  AND 
  tyyppi = '%s'
  ORDER BY 
  distance
  LIMIT %d "
  
  conn <- try(dbConnect(PostgreSQL()
                        , host="localhost" 
                        , user= "postgres"
                        , password=ei_mitaan
                        , dbname="karttasovellus"))
  on.exit(dbDisconnect(conn), add=TRUE)
  #   conn <- getConnection(PostgreSQL()
  #                         , host="localhost" 
  #                         , user= "postgres"
  #                         , password=ei_mitaan
  #                         , dbname="karttasovellus")
  if(class(conn)=='try-error'){
    stop('could not initialize connection')
  } 
  
  res_df = try(dbGetQuery(conn ,  sprintf( query_base , tablename , lat , lon , radius , tyyppi , count ) ) )
  if(class(res_df) == 'try-error'){
    stop( 'Could not execute the query' )  
  }
  if(nrow(res_df) == 0){
    stop('No data found')
  }
  print(res_df)
  return(res_df)
}


# 
# osoite = list()
# osoite$lat = 60.239
# osoite$lon = 24.938
# # # 
# # get_nearest( conn , 'coord' , osoite$lat , osoite$lon  , 'Ruokakaupat' , 100 )
# asdf = get_nearest( conn , 'coord' , osoite$lat , osoite$lon , 2 , 'Ruokakaupat' , 100 )
# # get_nearest( conn , 'coord' , osoite$lat , osoite$lon , 15 , 'Autoliikkeet' , 100 )
# # get_nearest( conn , 'coord' , osoite$lat , osoite$lon , 0.5 , 'Ruokakaupat' , 100 )
