library(rvest)
library(magrittr)
library(httr)
library(readr)
library(dplyr)

#cities = c('helsinki','espoo','vantaa','kauniainen')
cities = c('vantaa','kauniainen')
pages = 1:100

restaurant_list = list()

base_url = 'http://eat.fi/fi/%s/restaurants?page=%d'

hairiot = c('Osta Diili' , 'Lue lisää ja osta')

for(city in cities){
  print( paste("Kaupunki: " , city , sep=''))
  
  for(page in pages){
    
    page_df = NULL
    this_url = sprintf(base_url , city , page)
    uid = paste( city , page , sep='' )
    
    handle_reset(this_url)
    
    ravintolat = this_url %>% html() %>% html_nodes(" .disabled a , .open a , .unknown a , .closed a , .brunch a , .lunch a") %>% html_text()
    osoitteet = this_url %>% html() %>% html_nodes(".restaurant-contact-entry:nth-child(1) .restaurant-contact-entry-value") %>% html_text()
    hinta_laadut = this_url %>% html() %>% html_nodes(".ratingPrice+ .ratingTitle strong") %>% html_text()
    
    hairioravintolat = unlist(sapply( hairiot , function(hairio){
      grep( hairio , ravintolat  )
    }))
    if(length(hairioravintolat) > 0  ){
      ravintolat = ravintolat[-hairioravintolat]
    }
    
    page_df = data.frame(ravintolat = as.character(ravintolat) 
                         , osoitteet = as.character(osoitteet)
                         , hinta_laadut = as.character(hinta_laadut) )
    page_df$kaupunki = as.character( city ) 
    page_df$sivu =  as.character( page )
    
    if( page > 1 && 
          as.character(restaurant_list[[ length(restaurant_list) ]]$ravintolat[1]) == as.character(page_df$ravintolat[1] )
    ){
      #       city = cities[ which(cities == city) + 1 ]
      #       page = 1
      break
    } else {
      restaurant_list[[ uid ]] = page_df
    }
    cat( page ,  ' ' )
  }
}

restaurant_df <- do.call(rbind, unlist(restaurant_list, recursive = FALSE))
restaurant_df = restaurant_df[,!(names(restaurant_df) %in% c('kaupunki' , 'sivu') )]
restaurant_df[ , c( 'ravintolat','osoitteet' )] = apply(restaurant_df[ , c( 'ravintolat','osoitteet' )] , 2 , as.character)
restaurant_df[ , 'hinta_laadut'] = as.numeric( as.character(restaurant_df[ , 'hinta_laadut']  ) )
write_csv(restaurant_df , '/home/yatzy/Applications/tanne.pk/Data/ravintolat/ravintolat.csv' )

# 
# test_url %>% html() %>% html_nodes(" .disabled a , .open a , .unknown a , .closed a , .brunch a") %>% html_text()
# test_url %>% html() %>% html_nodes(".restaurant-contact-entry:nth-child(1) .restaurant-contact-entry-value") %>% html_text()
# test_url %>% html() %>% html_nodes(".ratingPrice+ .ratingTitle strong") %>% html_text() %>% as.numeric()
# 


# base_url = 'http://eat.fi/fi/%s/restaurants?page=%d'
# 
# test_url = 'http://eat.fi/fi/helsinki/restaurants?page=1'
# test_url = 'http://eat.fi/fi/helsinki/restaurants?page=4'
# 
# page = test_url %>% html()
# page %>% html_nodes(xpath = '//h3') %>% 
#   html_nodes(xpath = '//span') 
# 
# %>% html_nodes("restaurant-contact-entry-value")
#  
# test_url %>% html() %>% html_nodes(".restaurant-entries") %>% html_nodes("a")  %>% html_nodes("href")
# %>% html_text()
# #test_url %>% html() %>% html_nodes(".restaurant-contact-entry-value") %>% html_text()
# 
# test_url %>% html() %>% html_nodes(".restaurant-entries") %>% html_nodes(xpath="//a")
# test_url %>% html() %>% html_nodes(".restaurant-contact-entry") %>% html_text()
