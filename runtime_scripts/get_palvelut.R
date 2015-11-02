
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
25004 sairaalat
25002 terveysasemat
25624 kirjastot
28020 vanhusten_itsenäinen_asuminen
28020 vanhusten_palveluasuminen
28028 vanhusten_palveluasuminen_yksityinen
28030 vanhusten_laitospalvelu
28034 vanhusten_laitospalvelu_yksityinen') 
                          , sep =' ' , header = T)


get_palvelunumero = function(palvelu){
  palvelunro = try(palvelutaulu[ palvelutaulu$palvelu == palvelu , 'id'  ])
  if(class(palvelunro) == 'try-error'){
    stop('could not map palvelu to palvelunumero')
  }
  if(length(palvelunro) == 0 ){
    erromsg = paste('palvelunumero for ', palvelu ,' not found')
    stop(erromsg)
  }
  return(palvelunro)
}

list_palvelut = function(){
  conn <- dbConnect(PostgreSQL(), host="localhost" ,
                    user= "postgres", password = ei_mitaan , dbname="karttasovellus")
  on.exit(dbDisconnect(conn), add=TRUE)
  query = "select distinct(palvelu) from kunnalliset_palvelut"
  res = dbGetQuery(conn , query)
  # RPostgreSQL::dbDisconnect(conn)
  return(res)
}

get_palvelu = function(palvelu , lat , lon , radius = 10, force_one=T){
  # radius kilometreissa
  original_query_worked = T
  radius = round(radius * 1000)
  palvelunro = get_palvelunumero(palvelu)
  
  base_url = 'http://www.hel.fi/palvelukarttaws/rest/v2/unit/?service=%d&lat=%2.5f&lon=%2.5f&distance=%d'
  query_url = sprintf(base_url , palvelunro , lat , lon , radius )
  
  res = try(jsonlite::fromJSON(query_url) )
  wanted_columns = c('name_fi' , 'street_address_fi' , 'latitude' , 'longitude' , 'address_zip' , 'www_fi','address_city_fi')
  
  if(!is.data.frame(res)){
    cat('No data found for: ' , palvelu , '\n')
    original_query_worked = F
    if(force_one==T ){
      cat('FORCE getting: ' , palvelu , '\n')
      query_url = sprintf(base_url , palvelunro , lat , lon , 20 * 1000 )
      res = try(jsonlite::fromJSON(query_url) )
    }
  }
  
  if(class(res) == 'try-error'){
    stop('error retrieving nearest locations')
  } 
  if( !all(wanted_columns %in% colnames(res) ) ){
    stop('not all information retrieved')
  }
  
  res = res[ , wanted_columns ]
  
  mypoint = c(lon , lat)
  otherpoints = matrix( c(res$longitude , res$latitude) , ncol = 2  )
  
  res$distance = spDistsN1(otherpoints , mypoint, longlat=TRUE)
  colnames(res)[tolower(colnames(res)) %in% c('lng','long' , 'longitude')] = 'lon'
  colnames(res)[tolower(colnames(res)) == 'latitude'] = 'lat'
  res = res[ order(res$distance), ]
  res$tyyppi = palvelu
  
  if( force_one == T && original_query_worked == F ){
    res = res[1,]
  }
  
  return(res)
}

# 
# palvelu = 'ala_asteet'
# lat = 60.18288
# lon = 24.92204
# radius = 0
# asdf = get_palvelu(palvelu , lat , lon , radius )
# # colnames(asdf)
# asdf[[1]]$latitude
# str(res[1:10])
# res[[1]]$latitude
# bind_rows(res)
