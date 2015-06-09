library(readr)
library(pbapply)
# lataa zippausfunktio
source('/home/yatzy/Applications/tanne.pk/init_scripts/zippify.R')
source('/home/yatzy/Applications/tanne.pk/Data/sanapilvi/bing.R')

key = 'avain tahan'

paavo = read_csv('/home/yatzy/Applications/tanne.pk/Data/paavo/paavo_coord.csv')

pak = paavo[, c('pa','kaupunki' , 'zip')]
pak$zip = zippify(pak$zip)
pak$pak = paste( pak$pa , pak$kaupunki , sep = ', ' )

# lots_of_pant_links = bing_urls( key = key , query = 'housut' , pages = 2)
pakit = pak$pak

# res_list = pbsapply(pakit , function(pa){
#   return( bing_urls( key = key , query = pa , pages = 3 ) )
# })

res_list = list()
for( i in 1:length(pakit) ){
  ret = try( bing_urls( key = key , query = pakit[i] , pages = 3 ) )
  if(class(ret) != 'try-error'){
  res_list[[i]] = ret
  } else {
    res_list[[i]] = NA
  }
  names(res_list)[i] = pakit[i]
}
res_list
#res_bak = res_list
# hki_hki = bing_urls( key = key , query = 'Helsinki, Helsinki' , pages = 2)

sucess = sapply( (sapply(res_list , is.na ) ) , length ) > 1
sum(sucess) / length(sucess)

### koska ekalla haulla kaikki ei onnistunut

pakit2 = pakit[!sucess]

res_list2 = list()
for( i in 1:length(pakit2) ){
  ret = try( bing_urls( key = key , query = pakit2[i] , pages = 3 ) )
  if(class(ret) != 'try-error'){
    res_list2[[i]] = ret
  } else {
    res_list2[[i]] = NA
  }
  names(res_list2)[i] = pakit2[i]
}
res_list2