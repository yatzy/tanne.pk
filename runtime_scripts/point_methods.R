# ala asteet
get_ala_asteet = function(lat , lon  , radius ){
  ala_asteet = try(get_palvelu('ala_asteet' 
                               , lat = lat
                               , lon = lon
                               , radius = radius )
  )
  return(ala_asteet)
}

# yla asteet
get_yla_asteet = function(lat , lon  , radius ){
  yla_asteet = try(get_palvelu('yla_asteet' 
                               , lat = lat
                               , lon = lon
                               , radius = radius ) 
  )
  return(yla_asteet)
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
  return(ruokakaupat)
}

get_point_objects = function(lat , lon , radius){
  # lisää tähän kaikki metodikutsut!
  ala_asteet = get_ala_asteet(lat, lon , radius)
  yla_asteet = get_yla_asteet(lat, lon , radius)
  kaupat = get_ruokakaupat(lat, lon , radius)
  
  # ja palauta kaikki objektit
  return( list( ala_asteet = ala_asteet
                , yla_asteet = yla_asteet
                , kaupat = kaupat ) )
}