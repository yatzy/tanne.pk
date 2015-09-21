library(httr)
library(stringr)

### EXAMPLE
# key = '8SB9Z27it4UfuFAQfLEkj26yXzV8DHS4DJffkOQ81l4='
# bing = 'https://api.datamarket.azure.com/Bing/Search/Web?Query=%27kamppi%27&Market=%27fi-FI%27&$top=10&$format=json'
# resp = GET(bing , authenticate( '' , key )  , verbose() )
# data = content(resp)
# next_page = data$d$'__next'
# urls = sapply(data$d$results , function(x){x[['Url']]})

get_bing_url = function(search_url , key , verbose = F ){
  if(verbose){
    resp = GET(search_url , authenticate( '' , key )  , verbose() )
  } else {
    resp = GET(search_url , authenticate( '' , key ) )
  }
  return(content(resp))
}

### EXAMPLE
# pant_resposes_from_ping = get_bing_url('https://api.datamarket.azure.com/Bing/Search/Web?Query=%27kamppi%27&Market=%27fi-FI%27&$top=10&$format=json'
#                                         , key = key )
 
get_bing = function( key , query , market = 'fi-FI' , what=c('urls' , 'next_page') , ... ){
  require(httr)
  require(stringr)
  
  query = str_replace_all(query, "[^[:alnum:]]", " ") %>% gsub( '\\s+' , '+' , . ) %>% tolower()
  
  if(market == 'all'){
    base_url = 'https://api.datamarket.azure.com/Bing/Search/Web?Query=%%27%s%%27&$top=10&$format=json'
    search_url = sprintf(base_url , query )  
  } else {
    base_url = 'https://api.datamarket.azure.com/Bing/Search/Web?Query=%%27%s%%27&Market=%%27%s%%27&$top=10&$format=json'
    search_url = sprintf(base_url , query , market)
  }
  
  res = get_bing_url(search_url = search_url , key = key , ...)
  res_list = list()
  
  if( 'urls' %in% what ){
    urls = sapply(res$d$results , function(x){
      x[['Url']]
    })
    res_list['urls'] = list(urls)
  }
  
  if( 'next_page' %in% what ){
    next_page = res$d$"__next"
    res_list['next_page'] = next_page
  }
  
  return(res_list)
}

### EXAMPLE
# i_am_looking_for_pants = get_bing( key , 'housut' )

bing_urls = function(key , query , market = 'fi-FI' , pages = 1 , ... ){
  
  res_list = list()
  
  if(pages == 1){
    res_list = get_bing( key , query , market )$urls
    
  } else{
    
    first_res = get_bing( key , query , market )
    res_list = first_res$urls
    page_to_continue = first_res$next_page
    
    for( page in 2:pages){
      res = get_bing_url(search_url = page_to_continue , key = key )
      page_urls  = sapply(res$d$results , function(x){
        x[['Url']]
      })
      
      page_to_continue = res$d$"__next"
      res_list = list( res_list , page_urls ) 
    }
    res_list = unlist(res_list)
  }
  
  return(res_list)
}

### EXAMPLE
# lots_of_pant_links = bing_urls( key = key , query = 'housut' , pages = 2)
# lots_of_pant_links
