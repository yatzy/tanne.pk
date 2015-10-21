zippify = function(vec , method='front'){
  
  if(method == 'front'){
    vec = ifelse( nchar(as.character(vec)) == 3 , paste( '00',as.character(vec) , sep = '' ) , as.character(vec) )
    vec = ifelse( nchar(vec) == 4 , paste( '0',vec , sep = '' ) , vec )
  } else if (method =='back'){
    vec = ifelse( nchar(as.character(vec)) == 3 , paste( as.character(vec),'00' , sep = '' ) , as.character(vec) )
    vec = ifelse( nchar(vec) == 4 , paste( vec ,'0', sep = '' ) , vec )
  }
  return(vec)
}