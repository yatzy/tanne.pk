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

update_zip_objects = function(location_info , this_input , zip_objects){
  if(!is.null(location_info$address$postcode)){
    
    data <- try(get_zip_objects(location_info$address$postcode))
    if(class(data) != 'try-error'){
      if(length(data)>0){
        
        #sido paikka
        data$asuntojen_hinnat$paikka = this_input
        data$alue_info$paikka = this_input
        
        # poista vanhat paikkaan liittyvät havainnot
        print(zip_objects$asuntojen_hinnat)
        print(data$asuntojen_hinnat)
        
        if(!is.null(zip_objects$asuntojen_hinnat)){
          zip_objects$asuntojen_hinnat = subset(zip_objects$asuntojen_hinnat , zip_objects$asuntojen_hinnat$paikka != this_input)
        }
        if(!is.null(zip_objects$alue_info)){
          zip_objects$alue_info = subset(zip_objects$alue_info , zip_objects$alue_info$paikka != this_input)
        }
        
        # paivita paiikaan liittyva info
        
        if(!is.null(data$asuntojen_hinnat)){
          if(is.data.frame(data$asuntojen_hinnat)){
            if(ncol(data$asuntojen_hinnat)>0 && nrow(data$asuntojen_hinnat)>0){
              print(dim(zip_objects$asuntojen_hinnat))
              zip_objects$asuntojen_hinnat = rbind(zip_objects$asuntojen_hinnat , data$asuntojen_hinnat )
              print(dim(zip_objects$asuntojen_hinnat))
            }
          }
          if(!is.null(data$alue_info)){
            if(is.data.frame(data$alue_info)){
              if(ncol(data$alue_info)>0 && nrow(data$alue_info)>0)
                zip_objects$alue_info = rbind(zip_objects$alue_info , data$alue_info )
            }
          }
        }
        print(zip_objects$asuntojen_hinnat)
        print(str(zip_objects))
        
      }
    }
  }
  
}

# get_zip_objects('00250')
