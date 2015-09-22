
library(readr)
library(stringr)

pnt = read_delim('C:/Users/lehtkjuh/Downloads/folder/040_ashi_tau_104.csv' , delim=';',skip = 0, n_max = 10)
View(pnt)

pnn = read_delim('C:/Users/lehtkjuh/Downloads/040_ashi_tau_104.csv' , delim=';',skip = 2 )
colnames(pnn)[6:7] = c('Keskiarvo' ,'Lukumäärä')
head(pnn)
View(pnn)

val_to_missing = function(vec , mark){
  return(ifelse( as.character(vec) == mark , NA , vec ))
}

repeat_before = function(x) {   # repeats the last non NA value. Keeps leading NA
  ind = which(!is.na(x))      # get positions of nonmissing values
  if(is.na(x[1]))             # if it begins with a missing, add the 
    ind = c(1,ind)        # first position to the indices
  rep(x[ind], times = diff(   # repeat the values at these indices
    c(ind, length(x) + 1) )) # diffing the indices + length yields how often 
}                               # they need to be repeated


zippify = function(vec){
  vec = ifelse( nchar(as.character(vec)) == 3 , paste( '00',as.character(vec) , sep = '' ) , as.character(vec) )
  vec = ifelse( nchar(vec) == 4 , paste( '0',vec , sep = '' ) , vec )
  return(vec)
}


pnnt = data.frame(apply(pnn , 2 , val_to_missing , '' ) )
pnnt = data.frame(apply(pnnt , 2 , val_to_missing , '.' ) )

pnnt[,1:4] = data.frame(apply(pnnt[,1:4] , 2 , repeat_before ))
pnnt$Postinumero = str_trim(as.character(pnnt$Postinumero))
pnnt$Postinumero = zippify(pnnt$Postinumero)

View(pnnt)
sapply(pnnt , is)
pnnt[,6:7] = apply(pnnt[,6:7] , 2 , as.numeric)

write_csv(pnnt , 'C:/Users/lehtkjuh/Downloads/folder/asuntojen_hinnat.csv' )
