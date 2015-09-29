get_asuntojen_hinnat = function( zip ){
  conn <- dbConnect(PostgreSQL(), host="localhost", 
                    user= "postgres", password = ei_mitaan , dbname="karttasovellus")
  on.exit(dbDisconnect(conn), add=TRUE)
  query = paste("select * from asuntojen_hinnat where \"Postinumero\" = '" , zip,"'" , sep='')
  res = dbGetQuery(conn , query)
  if(ncol(res) == 0 || nrow(res) == 0){
    stop('no data found for asuntojen hinnat')
  }
  return(res)
}

get_alue_info = function(zip){
  conn <- try(dbConnect(PostgreSQL(), host="localhost", 
                    user= "postgres", password = ei_mitaan , dbname="karttasovellus"))
  if(class(conn) =='try-error'){
    stop('alue-info query failed')
  }
  on.exit(dbDisconnect(conn), add=TRUE)
  query = paste("select * from paavo where \"zip\" = '" , zip,"'" , sep='')
  res = dbGetQuery(conn , query)
  if(class(res) =='try-error'){
    stop('alue-info query failed')
  }
  nums = sapply(res , is.numeric)
  res[nums] = round(res[nums],3)
  return(res)
}

get_zip_objects = function(zip){
  calls = c('asuntojen_hinnat' , 'alue_info')
  
  return_list = lapply( calls , function(call){
    try(get_zip_call_object(call, zip )  ) 
  })
  
  names(return_list) = calls
  error_ind = sapply(return_list , function(x){
    class(x) == 'try-error'
  })
  return_list = return_list[!error_ind]
  
  if(length(return_list) == 0){
    stop('No zip method was successfull')
  }

  # ja palauta kaikki objektit
  return( return_list )
}

# get_zip_objects('00250')
