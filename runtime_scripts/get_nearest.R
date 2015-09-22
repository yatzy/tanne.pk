
get_nearest = function( conn , tablename , lat , lon , radius , tyyppi  , count ){
  
  query_base = "
  SELECT 
  nimi , 
  tyyppi , 
  lat , 
  lon ,  
  distance
  FROM (
  SELECT basetable.nimi ,
  basetable.lat , 
  basetable.lon ,
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
  
  conn <- dbConnect(PostgreSQL()
                    , host="localhost" 
                    , user= "postgres"
                    , password=ei_mitaan
                    , dbname="karttasovellus")
  
  res_df = try(dbGetQuery(conn ,  sprintf( query_base , tablename , lat , lon , radius , tyyppi , count ) ) )
  if(class(res_df) == 'try-error'){
    res_df = data.frame(nimi = 'liikkaa yhteyksia'
                        , tyyppi = ''
                        , lat = NA
                        , lon =NA
                        , distance = 0)
  }
  RPostgreSQL::dbDisconnect(conn)
  return(res_df)
}


# osoite = list()
# osoite$lat = 60.239
# osoite$lon = 24.938
# 
# get_nearest( conn , 'coord' , osoite$lat , osoite$lon , 2 , 'Ruokakaupat' , 100 )
# get_nearest( conn , 'coord' , osoite$lat , osoite$lon , 15 , 'Autoliikkeet' , 100 )
# get_nearest( conn , 'coord' , osoite$lat , osoite$lon , 0.5 , 'Ruokakaupat' , 100 )
