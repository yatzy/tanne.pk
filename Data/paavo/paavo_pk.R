library(magrittr)
library(readr)
paavo = read.csv(  file = '/home/yatzy/Applications/tanne.pk/Data/paavo_ladattu.csv'
                 , fileEncoding = 'iso-8859-1'
                 , stringsAsFactors=)
paavo = paavo[-1,]
colnames(paavo) = gsub('\xe4' , 'ä' , colnames(paavo) ) %>% 
  gsub('\xf6' , 'ö' , . ) %>% gsub('\U3e36663c' , 'ö' , . )
  
pk_kunnat = c( 'helsinki' , 'espoo' , 'vantaa' , 'kauniainen' )

pkt = sapply(pk_kunnat , function(x){
  pkt = c(pkt ,  grep(x , tolower(paavo$Postinumeroalue) ) )
})
pkt = c(unlist(pkt))
paavo_bak = paavo
paavo = paavo[pkt ,]

paavo$zip = substr(paavo$Postinumeroalue , 1 , 5)
paavo$pa = strsplit( paavo$Postinumeroalue , ' ' ) %>% sapply('[[',2)
paavo$kaupunki = strsplit( paavo$Postinumeroalue , '(' , fixed=T) %>% 
  sapply('[[', 2 ) %>% gsub(')' , '', . , fixed=T )

# write_csv(paavo , '/home/yatzy/Applications/tanne.pk/Data/paavo/paavo_pk.csv' )
# paavo = read_csv( '/home/yatzy/Applications/tanne.pk/Data/paavo/paavo_pk.csv' )
paavo$zip = ifelse( nchar(as.character(paavo$zip)) == 3 , paste( '00',as.character(paavo$zip) , sep = '' ) , as.character(paavo$zip) )
paavo$zip = ifelse( nchar(paavo$zip) == 4 , paste( '0',paavo$zip , sep = '' ) , paavo$zip )

source( '/home/yatzy/Applications/tanne.pk/runtime_scripts/geocode_nominatim.R' )
library(dplyr)
paavo$maa = 'finland'
paavo$zippa = paavo %>% select(zip , kaupunki , maa )  %>% apply( . , 1 , paste , collapse = ' ')
geo_info = geocode_vec(paavo$zippa) 
paavo$lat = as.character(geo_info$lat)
paavo$lon = as.character(geo_info$lon)

# missing_ind = is.na(paavo$lat)
# length(which(missing_ind))
# length(which(!missing_ind))
# paavo_no_latlon = paavo[missing_ind , ]
