get_ala_asteet = function(lat , lon  , radius ){
  ala_asteet = get_palvelu('ala_asteet' 
                           , lat = lat
                           , lon = lon
                           , radius = radius )
  return(ala_asteet)
}

get_yla_asteet = function(lat , lon  , radius ){
  yla_asteet = get_palvelu('yla_asteet' 
                           , lat = lat
                           , lon = lon
                           , radius = radius )
  return(yla_asteet)
}

# ruokakaupat
get_ruokakaupat = function(lat, lon , radius){
  ruokakaupat = get_nearest( conn , 'coord'
                             , lat = lat
                             , lon = lon 
                             , radius = radius 
                             , tyyppi =  'Ruokakaupat' 
                             , count =  10000 )
  return(ruokakaupat)
}

# get_objects = function(lat , lon , radius){
#   
# }