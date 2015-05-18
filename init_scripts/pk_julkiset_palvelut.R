# katso http://www.hel.fi/palvelukartta/

# päivähoito 27726 vai 27718
# esiopetus 33116
# luokkien 1-6 suomenkielinen opetus 34195
# luokkien 1-6 englanninkielinen opetus 34196

# kunnalliset päiväkodit 27722
# ostopalvelupäiväkodit 27780
# yksityiset päiväkodit 27818
# perhepäivähoito 27856

library(magrittr)
library(RCurl)
library(jsonlite)

# päivähoito
ph_vec = c(27722 ,27780 ,27818,27856 )
#palautettavat sarakkeet
service_columns  = c('id' , 'provider_type','name_fi' ,'latitude' ,'longitude' , 'street_address_fi','address_zip','address_city_fi','www_fi')
# service_columns = service_columns[ -which(service_columns == 'www_fi' )  ]
# palauttaa dataframe annetulle palveluid:lle
# tsekkaa http://www.hel.fi/palvelukarttaws/rest/ver2.html
get_service = function(service_number , columns='all'){
  
  require(RCurl)
  require(jsonlite)
  
  api_url = paste('http://www.hel.fi/palvelukarttaws/rest/v2/unit/?service='
                  , service_number , sep='' ) 
  df = jsonlite::fromJSON( getURL(url = api_url) %>% gsub("fi\\en" , "fi/en" , . , fixed=T )  )
  
  warning_option= options()$warn
  options(warn=-1)
  
  if(columns != 'all'){
    df = df[,columns]
  }
  
  options( warn = warning_option )
  
  return(df)
  
}

list_to_df <- function(list_for_df){
  if(!is.list(list_for_df)) stop("it should be a list")
  
  df <- list(list.element = list_for_df)
  class(df) <- c("tbl_df", "data.frame")
  attr(df, "row.names") <- .set_row_names(length(list_for_df))
  
  if (!is.null(names(list_for_df))) {
    df$name <- names(list_for_df)
  }
  
  df
}

# yleistyy usealle palveluid:lle
get_services = function( service_vec , ... ){
  list_of_dfs = lapply( service_vec , get_service , ... )
  return(do.call("rbind", list_of_dfs) )
}

paivahoito = get_services( ph_vec , columns = service_columns )

# suomenkieliset alakoulut 32540 
# suomenkieliset ylakoulut 32618 
# ruotsinkieliset alakoulut 32718
# ruotsinkieliset ylakoulut 32748

koulu_vec = c(32540,32618,32718,32748)
koulut = get_services( koulu_vec , columns = service_columns )

