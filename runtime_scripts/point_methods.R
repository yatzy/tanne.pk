# paivakodit
get_paivakodit = function(lat , lon  , radius ){
#   paivakodit = try(get_palvelu('paivakodit' 
#                                   , lat = lat
#                                   , lon = lon
#                                   , radius = radius ) 
#   )
  
  kunnalliset_päiväkodit = try(get_palvelu('kunnalliset_päiväkodit' 
                                  , lat = lat
                                  , lon = lon
                                  , radius = radius ) 
  )
  ostosopimuspäiväkodit = try(get_palvelu('ostosopimuspäiväkodit' 
                                  , lat = lat
                                  , lon = lon
                                  , radius = radius ) 
  )
  yksityiset_päiväkodit = try(get_palvelu('yksityiset_päiväkodit' 
                                  , lat = lat
                                  , lon = lon
                                  , radius = radius ) 
  )
  
  pk_lista = list(kunnalliset_päiväkodit , ostosopimuspäiväkodit , yksityiset_päiväkodit)
  
  error_ind = sapply( pk_lista
                     , function(x){
                       class(x) == 'try-error' || nrow(x) == 0
                       })
  paivakodit = try(do.call( 'rbind', pk_lista[!error_ind]  ))
  
  if(class(paivakodit) == 'try-error' ){
    stop('error combining päiväkodit')
  }
  
  # if called with force_one in get_palvelut
  if(radius>10){
    paivakodit = paivakodit %>% arrange(distance) %>% .[1,] 
  }
  
  if(nrow(paivakodit)==0 ){
    stop('no päiväkodit found')
  }
  
  
  paivakodit$tyyppi = 'paivakodit'
  
  return(paivakodit)
}

# vanhainkodit
get_vanhainkodit = function(lat , lon  , radius ){
  vanhusten_itsenäinen_asuminen = try(get_palvelu('vanhusten_itsenäinen_asuminen' 
                                                  , lat = lat
                                                  , lon = lon
                                                  , radius = radius ) 
  )
  vanhusten_palveluasuminen = try(get_palvelu('vanhusten_palveluasuminen' 
                                              , lat = lat
                                              , lon = lon
                                              , radius = radius ) 
  )
  vanhusten_palveluasuminen_yksityinen = try(get_palvelu('vanhusten_palveluasuminen_yksityinen' 
                                                         , lat = lat
                                                         , lon = lon
                                                         , radius = radius ) 
  )
  vanhusten_laitospalvelu = try(get_palvelu('vanhusten_laitospalvelu' 
                                            , lat = lat
                                            , lon = lon
                                            , radius = radius ) 
  )
  vanhusten_laitospalvelu_yksityinen = try(get_palvelu('vanhusten_laitospalvelu_yksityinen' 
                                                       , lat = lat
                                                       , lon = lon
                                                       , radius = radius ) 
  )
  vanhus_lista = list(vanhusten_itsenäinen_asuminen , vanhusten_palveluasuminen 
                  , vanhusten_palveluasuminen_yksityinen , vanhusten_laitospalvelu
                  , vanhusten_laitospalvelu_yksityinen )
  
  error_ind = sapply( vanhus_lista
                      , function(x){
                        class(x) == 'try-error' || nrow(x) == 0
                      })
  vanhainkodit = try(do.call( 'rbind', vanhus_lista[!error_ind]  ))
  
  if(class(vanhainkodit) == 'try-error' ){
    stop('error combining vanhainkodit')
  }
  
  # if called with force_one in get_palvelut
  if(radius>10){
    vanhainkodit = vanhainkodit %>% arrange(distance) %>% .[1,] 
  }
  
  if(nrow(vanhainkodit)==0 ){
    stop('no vanhainkodit found')
  }
  
  vanhainkodit$tyyppi = 'vanhainkodit'
  
  return(vanhainkodit)

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
  print(kirjastot)
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
  if(ncol(ruokakaupat) == 0 || nrow(ruokakaupat) == 0 ){
    stop('no data found')
  }
  
  ruokakaupat$tyyppi = 'ruokakaupat'
  name_fi_end = strsplit(ruokakaupat$osoite,',') %>% sapply('[[',1)
  ruokakaupat$name_fi = paste(ruokakaupat$nimi , name_fi_end , sep=' ')
  
  return(ruokakaupat)
}

get_point_objects = function(lat , lon , radius){
  # lisää tähän kaikki metodikutsut!
  # call ruokakaupat kutsuu metodia get_ruokakaupat(lat = lat , lon = lon , radius = radius )
  calls = c('ala_asteet' , 'yla_asteet' , 'ruokakaupat' 
            , 'kirjastot' , 'sairaalat' , 'terveysasemat'
            ,'paivakodit','vanhainkodit')
  
  return_list = lapply( calls , function(call){
    try(get_point_call_object(call, lat=lat , lon=lon , radius = radius )  ) 
  })
  
  names(return_list) = calls
  error_ind = sapply(return_list , function(x){
    class(x) == 'try-error'
  })
  return_list = return_list[!error_ind]
  if(length(return_list) == 0){
    stop('No point method was successfull')
  }
  #   ala_asteet = get_ala_asteet(lat, lon , radius)
  #   yla_asteet = get_yla_asteet(lat, lon , radius)
  #   ruokakaupat = get_ruokakaupat(lat, lon , radius)
  
  # ja palauta kaikki objektit
  return( return_list )
}

# example
lat = 60.226516;lon= 24.890556;radius =  1
asdf = get_point_objects(lat=lat , lon=lon,radius=radius)
# lat = 60.18288
# lon = 24.922
# radius = 1
# get_calls = c('ala_asteet' , 'yla_asteet' , 'ruokakaupat')
# return_list = lapply( get_calls , get_call_object )

# get_error = function(lat, lon , radius){
#   stop('virhe tapahtuu pakosti')
# }
# calls = c('ala_asteet' , 'yla_asteet','error' , 'ruokakaupat')

