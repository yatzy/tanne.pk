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
  on.exit(dbDisconnect(conn), add=TRUE)
  if(class(conn) =='try-error'){
    stop('alue-info query failed')
  }
  query = paste("select * from paavo where \"zip\" = '" , zip,"'" , sep='')
  res = dbGetQuery(conn , query)
  if(class(res) =='try-error'){
    stop('alue-info query failed')
  }
  nums = sapply(res , is.numeric)
  # print(is(nums))
  if(is.logical(nums)){
    res[nums] = round(res[nums],3)
    return(res)
  } else{
    stop('problem with getting alue info')
  }
  
}

get_alue_recommendations = function(zip){
  zip = as.character(zip)
  conn <- try(dbConnect(PostgreSQL(), host="localhost", 
                        user= "postgres", password = ei_mitaan , dbname="karttasovellus"))
  on.exit(dbDisconnect(conn), add=TRUE)
  if(class(conn) =='try-error'){
    stop('alue_recommendations connection failed')
  }
  query_base = paste("select nearest1 , nearest2,nearest3 from paavo_nearest where area = '%s'")
  query = sprintf(query_base , zip)
  res = dbGetQuery(conn , query)
  if(class(res) =='try-error'){
    stop('alue_recommendations query failed')
  }
  res = as.vector(t(res))
  if( zip %in% res  ){
    res = res[ res != zip ]
  } else{
    res = res[1:2]
  }
  return(res)
}

#### lisää suosittelukerroksen kartalle

add_recommendation_layer = function(recommendation_vector , this_input , session){
  
  # label alueen paalle
  labeli = ifelse(this_input == 'koti' 
                  , 'Suositus kodin sijainnin perusteella'
                  , 'Vaihtoehto muuttosijainnille' )
  
  print(labeli)
  print(class(labeli))
  # valitse vari
  vari = ifelse(this_input == 'koti' , paletti[1] , paletti[2])
  
  for( recommendation in recommendation_vector ){
    recommendation_zip = recommendation  %>% as.character() %>% str_replace('\\.','') %>% zippify(method='back')
    cat('adding polygon for ' , recommendation_zip , '\n')
    
    leafletProxy("map_in_ui" , session) %>%
      addPolygons(data=subset(pk_postinumerot, pnro == recommendation_zip )
                  , weight=1 , fillColor = vari , group = this_input 
                  , layerId  = paste('suosittelu',this_input, runif(1),sep='' )
                  , label = labeli)
  }
  
}

get_zip_objects = function(zip){
  calls = c('asuntojen_hinnat' , 'alue_info','alue_recommendations')
  
  return_list = lapply( calls , function(call){
    try(get_zip_call_object(call, zip )  ) 
  })
  
  names(return_list) = calls
  error_ind = sapply(return_list , function(x){
    class(x) == 'try-error'
  })
  names(return_list) = names(return_list)[!error_ind]
  return_list = return_list[!error_ind]
  
  if(length(return_list) == 0){
    stop('No zip method was successfull')
  }
  
  # ja palauta kaikki objektit
  return( return_list )
}

update_zip_objects = function(location_info , this_input , zip_objects,session){
  
  if(!is.null(location_info$address$postcode)){
    
    this_zip = location_info$address$postcode %>% as.character() %>% str_replace('.','')
    
    data <- try(get_zip_objects(this_zip))
    if(class(data) != 'try-error'){
      if(length(data)>0){
        
        ### sido paikka
        data$asuntojen_hinnat$paikka = this_input
        data$alue_info$paikka = this_input
        
        ### paivita paiikaan liittyva info
        zip_objects$asuntojen_hinnat = subset(zip_objects$asuntojen_hinnat , zip_objects$asuntojen_hinnat$paikka != this_input)
        
        if(is.data.frame(data$asuntojen_hinnat)){
          if(ncol(data$asuntojen_hinnat)>0 && nrow(data$asuntojen_hinnat)>0){
            # poista vanhat paikkaan liittyvät havainnot
            zip_objects$asuntojen_hinnat = rbind(zip_objects$asuntojen_hinnat , data$asuntojen_hinnat )
            # print(dim(zip_objects$asuntojen_hinnat))
          }
        }
        
        ### paivita paiikaan liittyva info
        zip_objects$alue_info = subset(zip_objects$alue_info , zip_objects$alue_info$paikka != this_input)
        if(!is.null(data$alue_info)){
          if(is.data.frame(data$alue_info)){
            if(ncol(data$alue_info)>0 && nrow(data$alue_info)>0)
              # paivita paiikaan liittyva info
              zip_objects$alue_info = rbind(zip_objects$alue_info , data$alue_info )
          }
        }
        
        ### lisää suosittelukerros
        print(data$alue_recommendations)
        print(this_input)
        add_recommendation_layer(data$alue_recommendations , this_input , session)
        
      }
    }
  }
}

remove_zip_objects_for = function(this_input,zip_objects){
  if(!is.null(zip_objects$asuntojen_hinnat)){
    zip_objects$asuntojen_hinnat = subset(zip_objects$asuntojen_hinnat , zip_objects$asuntojen_hinnat$paikka != this_input)
  }
  if(!is.null(zip_objects$alue_info)){
    zip_objects$alue_info = subset(zip_objects$alue_info , zip_objects$alue_info$paikka != this_input)
  }
}

# get_zip_objects('00250')
