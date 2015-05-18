library(magrittr)
library(readr)
paavo = read.csv('/home/yatzy/Applications/tanne.pk/Data/paavo_ladattu.csv'
                 , fileEncoding = 'iso-8859-1'
                 ,stringsAsFactors=)
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

write_csv(paavo , '/home/yatzy/Applications/tanne.pk/Data/paavo_pk.csv' )
