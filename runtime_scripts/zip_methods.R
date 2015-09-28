get_asuntojen_hinnat = function(zip ){
  conn <- dbConnect(PostgreSQL(), host="localhost", 
                    user= "postgres", password = ei_mitaan , dbname="karttasovellus")
  on.exit(dbDisconnect(conn), add=TRUE)
  query = paste("select * from asuntojen_hinnat where \"Postinumero\" = '" , zip,"'" , sep='')
  res = dbGetQuery(conn , query)
  return(res)
}

get_zip_objects = function(zip){
  zip = as.character(zip)
  asuntojen_hinnat = get_asuntojen_hinnat(zip)
  return( list(
    asuntojen_hinnat = asuntojen_hinnat
  ) )
}