#install.packages('pbapply')
library(readr)
source('/home/yatzy/Applications/tanne.pk/runtime_scripts/reverse_geocode.R')
shops_pk = read_csv('/home/yatzy/Applications/tanne.pk/Data/shops_pk.csv')
if(is.null(shops_pk$osoite_paikkakunta) ){
  shops_pk$osoite_paikkakunta = paste(shops_pk$Osoite , shops_pk$Paikkakunta, sep =',')
}
if(is.null(shops_pk$lon)){
  shops_pk$lon = shops_pk$lat = NA
}

usefull_columns = c("lat","lon" ,"address.road","address.suburb","address.city_district","address.city"          
                    ,"address.county","address.state_district","address.state","address.postcode")
must_columns = c("lat","lon")
# coordinate_table = data.frame( reverse_geocode_nominatim(shops_pk$osoite_paikkakunta[1])[must_columns] )
wanted_columns = must_columns

total = length(shops_pk$osoite_paikkakunta)
pb <- txtProgressBar(min = 0, max = total, style = 3)

for(i in 1:length(shops_pk$osoite_paikkakunta) ){
  
  if( is.na(shops_pk$lat[i]) | is.na(shops_pk$lon[i]) ){
    
    # proper_dims = dim( coordinate_table[1,] )
    null_row = rep(NA , length(wanted_columns) )
    osoite = shops_pk$osoite_paikkakunta[i]
    
    geocode_info = try( reverse_geocode_nominatim(osoite) )
    
    if(class(geocode_info) == 'try-error') {
      coordinate_row = null_row
    } else {
      coordinate_row = geocode_info[wanted_columns] 
      if( length(coordinate_row) != length(wanted_columns)  ){
        coordinate_row = null_row
      }
    }
    
    shops_pk$lat[i] = coordinate_row[1]
    shops_pk$lon[i] = coordinate_row[2]
    #coordinate_table = rbind( coordinate_table , coordinate_row )
  }
  setTxtProgressBar(pb, i)
  if( i %% 500 == 0 ){
    print(shops_pk[i,])
  }
}

write_csv(shops_pk , '/home/yatzy/Applications/tanne.pk/Data/shops_pk_coord.csv' )

