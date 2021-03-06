# library(dplyr)
# dbcon = src_postgres( dbname = 'muutankotanne'
#               , port = '5454'
#               , host = simon_host
#               , user = 'muutanko'
#               , password = simon_salasana )
# units_tbl <- tbl(dbcon , "units")

simon_salasana = 'testikanta'
simon_host = 'nettiruoska.dy.fi'

library(RPostgreSQL)
db_driver <- dbDriver("PostgreSQL")
conn = RPostgreSQL::dbConnect(db_driver 
                              , user = "muutanko"
                              , password = simon_salasana
                              , dbname = "muutankotanne" 
                              , host = simon_host
                              , port = '5454')

# units = dbGetQuery(conn , "select * from units")
units_head = dbGetQuery(conn , "select * from units limit 5")
colnames(units_head)

library(ggmap)
osoite = geocode('brysselinkatu 4, helsinki')
# osoite = geocode('mannerheimintie 53, helsinki')

query_base = "
  SELECT name_fi , latitude , longitude ,  distance
    FROM (
    SELECT basetable.name_fi ,
           basetable.latitude , 
           basetable.longitude ,
           helptable.radius ,
           helptable.distance_unit
                   * DEGREES(ACOS(COS(RADIANS(helptable.latpoint))
                   * COS(RADIANS(basetable.latitude))
                   * COS(RADIANS(helptable.longpoint - basetable.longitude))
                   + SIN(RADIANS(helptable.latpoint))
                   * SIN(RADIANS(basetable.latitude)))) AS distance
    FROM units
    -- WHERE tyyppi = 'koulu' -- lisataan tulevaisuudessa
    AS basetable
    JOIN (   /* parametrit */
          SELECT  %f AS latpoint ,    
                  %f AS longpoint ,
                  %f AS radius ,
                  -- vakio
                  111.045 AS distance_unit
      ) AS helptable ON 1=1
    WHERE 
      basetable.latitude
      BETWEEN 
        helptable.latpoint  - (helptable.radius / helptable.distance_unit)
      AND 
        helptable.latpoint  + (helptable.radius / helptable.distance_unit)
      AND 
        basetable.longitude
        BETWEEN 
          helptable.longpoint - (helptable.radius / (helptable.distance_unit * COS(RADIANS(helptable.latpoint))))
          AND 
          helptable.longpoint + (helptable.radius / (helptable.distance_unit * COS(RADIANS(helptable.latpoint))))
   ) AS returntable
   WHERE distance <= radius
   ORDER BY distance
   LIMIT %d "

mun_lahella = dbGetQuery(conn ,  sprintf( query_base , osoite$lat , osoite$lon , 20 , 15 ) )

# get_nearest = function( conn , lat , lon , radius , count ){
#   query_base = "
#   SELECT name_fi , latitude , longitude ,  distance
#     FROM (
#   SELECT basetable.name_fi ,
#   basetable.latitude , 
#   basetable.longitude ,
#   helptable.radius ,
#   helptable.distance_unit
#   * DEGREES(ACOS(COS(RADIANS(helptable.latpoint))
#   * COS(RADIANS(basetable.latitude))
#   * COS(RADIANS(helptable.longpoint - basetable.longitude))
#   + SIN(RADIANS(helptable.latpoint))
#   * SIN(RADIANS(basetable.latitude)))) AS distance
#   FROM units
#   -- WHERE tyyppi = 'koulu' -- lisataan tulevaisuudessa
#   AS basetable
#   JOIN (   /* parametrit */
#   SELECT  %f AS latpoint ,    
#   %f AS longpoint ,
#   %f AS radius ,
#   -- vakio
#   111.045 AS distance_unit
#   ) AS helptable ON 1=1
#   WHERE basetable.latitude
#   BETWEEN helptable.latpoint  - (helptable.radius / helptable.distance_unit)
#   AND helptable.latpoint  + (helptable.radius / helptable.distance_unit)
#   AND basetable.longitude
#   BETWEEN helptable.longpoint - (helptable.radius / (helptable.distance_unit * COS(RADIANS(helptable.latpoint))))
#   AND helptable.longpoint + (helptable.radius / (helptable.distance_unit * COS(RADIANS(helptable.latpoint))))
#   ) AS returntable
#   WHERE distance <= radius
#   ORDER BY distance
#   LIMIT %d "
#   return( dbGetQuery(conn ,  sprintf( query_base , lat , lon , radius , count ) ) )
# }
# 
# get_nearest( conn , osoite$lat , osoite$lon , 1 ,100000 )

conn <- dbConnect(PostgreSQL()
                  , host="localhost" 
                  , user= "postgres"
                  , password=ei_mitaan
                  , dbname="karttasovellus")

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
  
  return( dbGetQuery(conn ,  sprintf( query_base , tablename , lat , lon , radius , tyyppi , count ) ) )
}

osoite = list()
osoite$lat = 60.239
osoite$lon = 24.938

get_nearest( conn , 'coord' , osoite$lat , osoite$lon , 2 , 'Ruokakaupat' , 100 )
get_nearest( conn , 'coord' , osoite$lat , osoite$lon , 15 , 'Autoliikkeet' , 100 )
get_nearest( conn , 'coord' , osoite$lat , osoite$lon , 0.5 , 'Ruokakaupat' , 100 )
