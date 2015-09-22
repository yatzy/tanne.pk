
# get_palvelunumero = function(palvelu){
#   conn <- dbConnect(PostgreSQL(), host="localhost", 
#                    user= "postgres", password=ei_mitaan, dbname="karttasovellus")
#   query = sprintf("select id from kunnalliset_palvelut where palvelu = '%s'" , palvelu )
#   res = as.numeric(dbGetQuery(conn , query) )
#   RPostgreSQL::dbDisconnect(conn)
#   return(res)
# }

palvelutaulu = read.table(textConnection('
id palvelu
27722 kunnalliset_päiväkodit
27780 ostosopimuspäiväkodit
27818 yksityiset_päiväkodit
26972 lukiot
34194 ala_asteet
34272 yla_asteet
25002 terveysasemat
25626 kirjastot') , sep =' ' , header = T)

get_palvelunumero = function(palvelu){
  return(palvelutaulu[ palvelutaulu$palvelu == palvelu , 'id'  ])
}

get_palvelulistaus = function(){
  conn <- dbConnect(PostgreSQL(), host="localhost", 
                    user= "postgres", password = ei_mitaan , dbname="karttasovellus")
  query = "select distinct(palvelu) from kunnalliset_palvelut"
  res = dbGetQuery(conn , query)
  RPostgreSQL::dbDisconnect(conn)
  return(res)
}

get_palvelu = function(palvelu , lat , lon , radius = 10){
  # radius kilometreissa
  radius = radius * 1000
  palvelunro = get_palvelunumero(palvelu)
  
  base_url = 'http://www.hel.fi/palvelukarttaws/rest/v2/unit/?service=%d&lat=%2.5f&lon=%2.5f&distance=%d'
  query_url = sprintf(base_url , palvelunro , lat , lon , radius )
  
  res = try(fromJSON(query_url) )
  
  if(class(res) == 'try-error'){return(NA)}
  # print('no errors found')
  drops = sapply( res , is.list ) 
  wanted_columns = c('name_fi' , 'street_address_fi' , 'latitude' , 'longitude' , 'address_zip' , 'www_fi','address_city_fi')
  res = res[ , wanted_columns ]
  
  mypoint = c(lon , lat)
  otherpoints = matrix( c(res$longitude , res$latitude) , ncol = 2  )
  
  res$distance = spDistsN1(otherpoints , mypoint, longlat=TRUE)
  res = res[ order(res$distance), ]
  return(res)
}

# palvelu = 'ala_asteet'
# lat = 60.18288
# lon = 24.92204
# radius = 6
# asdf = get_palvelu(palvelu , lat , lon , radius )
# colnames(asdf)
