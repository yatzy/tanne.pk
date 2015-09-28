# paivakodit
get_paivakodit = function(lat , lon  , radius ){
  paivakodit = try(get_palvelu('paivakodit' 
                                  , lat = lat
                                  , lon = lon
                                  , radius = radius ) 
  )
  if(class(paivakodit) == 'try-error' ){
    stop('could not retrieve paivakodit')
  }
  return(paivakodit)
}

# ala asteet
get_ala_asteet = function(lat , lon  , radius ){
  ala_asteet = try(get_palvelu('ala_asteet' 
                               , lat = lat
                               , lon = lon
                               , radius = radius )
  )
  if(class(ala_asteet) == 'try-error' ){
    stop('could not retrieve ala-asteet')
  }
  return(ala_asteet)
}

# yla asteet
get_yla_asteet = function(lat , lon  , radius ){
  yla_asteet = try(get_palvelu('yla_asteet' 
                               , lat = lat
                               , lon = lon
                               , radius = radius ) 
  )
  if(class(yla_asteet) == 'try-error' ){
    stop('could not retrieve yla-asteet')
  }
  return(yla_asteet)
}

# kirjastot
get_kirjastot = function(lat , lon  , radius ){
  kirjastot = try(get_palvelu('kirjastot' 
                               , lat = lat
                               , lon = lon
                               , radius = radius ) 
  )
  if(class(kirjastot) == 'try-error' ){
    stop('could not retrieve kirjastot')
  }
  return(kirjastot)
}

# sairaalat
get_sairaalat = function(lat , lon  , radius ){
  sairaalat = try(get_palvelu('sairaalat' 
                               , lat = lat
                               , lon = lon
                               , radius = radius ) 
  )
  if(class(sairaalat) == 'try-error' ){
    stop('could not retrieve sairaalat')
  }
  return(sairaalat)
}

# terveysasemat
get_terveysasemat = function(lat , lon  , radius ){
  terveysasemat = try(get_palvelu('terveysasemat' 
                               , lat = lat
                               , lon = lon
                               , radius = radius ) 
  )
  if(class(terveysasemat) == 'try-error' ){
    stop('could not retrieve terveysasemat')
  }
  return(terveysasemat)
}


# ruokakaupat
get_ruokakaupat = function(lat, lon , radius){
  ruokakaupat = try(get_nearest( conn , 'coord'
                                 , lat = lat
                                 , lon = lon 
                                 , radius = radius 
                                 , tyyppi =  'Ruokakaupat' 
                                 , count =  10000 ) 
  )
  if(class(ruokakaupat) == 'try-error' ){
    stop('could not retrieve ruokakaupat')
  }
  return(ruokakaupat)
}

get_point_objects = function(lat , lon , radius){
  # lisää tähän kaikki metodikutsut!
  # call ruokakaupat kutsuu metodia get_ruokakaupat(lat = lat , lon = lon , radius = radius )
  calls = c('ala_asteet' , 'yla_asteet' , 'ruokakaupat' 
            , 'kirjastot' , 'sairaalat' , 'terveysasemat','paivakodit')
  
  return_list = lapply( calls , function(call){
    try(get_call_object(call, lat=lat , lon=lon , radius = radius )  ) 
  })
  
  names(return_list) = calls
  error_ind = sapply(return_list , function(x){
    class(x) == 'try-error'
  })
  return_list = return_list[!error_ind]
  if(length(return_list) == 0){
    stop('No method was successfull')
  }
  #   ala_asteet = get_ala_asteet(lat, lon , radius)
  #   yla_asteet = get_yla_asteet(lat, lon , radius)
  #   ruokakaupat = get_ruokakaupat(lat, lon , radius)
  
  # ja palauta kaikki objektit
  return( return_list )
}

# example
# lat = 60.226516;lon= 24.890556;radius =  1
# lat = 60.18288
# lon = 24.922
# radius = 1
# get_calls = c('ala_asteet' , 'yla_asteet' , 'ruokakaupat')
# return_list = lapply( get_calls , get_call_object )

# get_error = function(lat, lon , radius){
#   stop('virhe tapahtuu pakosti')
# }
# calls = c('ala_asteet' , 'yla_asteet','error' , 'ruokakaupat')

