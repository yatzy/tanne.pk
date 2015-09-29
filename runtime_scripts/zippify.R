zippify = function(vec){
  vec = ifelse( nchar(as.character(vec)) == 3 , paste( '00',as.character(vec) , sep = '' ) , as.character(vec) )
  vec = ifelse( nchar(vec) == 4 , paste( '0',vec , sep = '' ) , vec )
  return(vec)
}