### kirjastot tahan

library(shinythemes)
library(jsonlite)
library(dplyr)
library(leaflet)
library(ggmap)
library(rCharts)
library(stringr)
library(reshape2)
library(RPostgreSQL)
library(ggplot2)
library(tidyr)
library(sp)

theme_set(theme_bw())

# avainmet

ei_mitaan = read_file('/home/juha/.salasana') %>% gsub('\n','',.)
mapquest_key = read_file('/home/juha/.mapquest') %>% gsub('\n','',.)

### working directory tahan paikkaan

this_dir <- dirname(parent.frame(2)$ofile)
setwd(this_dir)

### postinumeroaineisto
# latataa objektin pk_postinumerot
load(file = '/home/juha/tanne.pk/Data/pk_postinumerot.rda')

### omat kirjastot

source('runtime_scripts/utilities.R')
source('runtime_scripts/zippify.R')
source('runtime_scripts/get_location_information.R')
source('runtime_scripts/geocode_nominatim.R')
source('runtime_scripts/get_nearest.R')
source('runtime_scripts/get_palvelut.R')
source('runtime_scripts/point_methods.R')
source('runtime_scripts/zip_methods.R')
source('runtime_scripts/route_methods.R')

### iconit

icon_koti <- icons(iconUrl = 'icons/live/home.svg' , iconWidth = 70,iconAnchorX=35 , iconAnchorY=90)
icon_potentiaalinen <- icons(iconUrl = 'icons/live/potential.svg' , iconWidth = 70,iconAnchorX=35 , iconAnchorY=90)
icon_tyo <- icons(iconUrl = 'icons/live/work.svg' , iconWidth = 70,iconAnchorX=35 , iconAnchorY=90)

icon_ruokakaupat <- icons(iconUrl = 'icons/live/shop.svg' , iconWidth = 46,iconAnchorX=23 , iconAnchorY=55)
icon_ala_asteet <- icons(iconUrl = 'icons/live/school.svg' , iconWidth = 46,iconAnchorX=23 , iconAnchorY=55)
icon_yla_asteet <- icons(iconUrl = 'icons/live/high_school.svg' , iconWidth = 46,iconAnchorX=23 , iconAnchorY=55) 
icon_paivakodit <- icons(iconUrl = 'icons/live/kinderkarten3.svg' , iconWidth = 46,iconAnchorX=23 , iconAnchorY=55)
icon_kirjastot <- icons(iconUrl = 'icons/live/library.svg' , iconWidth = 46,iconAnchorX=23 , iconAnchorY=55) 
icon_terveysasemat <- icons(iconUrl = 'icons/live/health_center.svg' , iconWidth = 46,iconAnchorX=23 , iconAnchorY=55)
icon_sairaalat <- icons(iconUrl = 'icons/live/hospital.svg' , iconWidth = 46,iconAnchorX=23 , iconAnchorY=55) 

icon_settings <- icons(iconUrl = 'icons/live/settings.svg' , iconWidth = 70 , iconAnchorX=35 , iconAnchorY=35 ) 

### varit
koti_vari = rgb( 0, 92 , 148 , maxColorValue = 255 )
potentiaalinen_vari = rgb( 108 , 220 , 250 , maxColorValue = 255 )
paletti = c(koti_vari , potentiaalinen_vari)

### asetukset tahan

DEBUG = F
radius = 1
click_count = 0
ui_interaction_lag = 5 # seconds
koti_value_default = "Kotiosoite"
tyo_value_default = "Työosoite"
potentiaalinen_value_default = "Potentiaalinen osoite"

### location informations

# boundaries

city_center_location = list(lat = 60.173700, lon =  24.940179)
boundary_north_lon = 60.459124
boundary_south_lon = 60.091627
boundary_west_lat = 24.326203
boundary_east_lat = 25.524120

# durations

durations = reactiveValues()
durations$koti_to_tyo_durations = NULL
durations$koti_to_center_durations = NULL
durations$potentiaalinen_to_tyo_durations  = NULL
durations$potentiaalinen_to_center_durations  = NULL

# location information

# koti_location_information = NULL
# tyo_location_information = NULL
# potentiaalinen_location_information = NULL

# palveluiden valikko

palvelut_nimet = c('Ala-asteet' , 'Yläasteet' , 'Ruokakaupat' 
             , 'Kirjastot' , 'Sairaalat' , 'Terveysasemat','Päiväkodit')

palvelut  = c('ala_asteet' , 'yla_asteet' , 'ruokakaupat' 
  , 'kirjastot' , 'sairaalat' , 'terveysasemat','paivakodit')

palvelu_df <<- data.frame(palvelut_nimet,palvelut,T)
kotigroups <<- sapply(unique(palvelu_df[,2]),function(x){sprintf("%s_%s", 'koti',x)})
potentiaalinengroups <<- sapply(unique(palvelu_df[,2]),function(x){sprintf("%s_%s", 'potentiaalinen',x)})
