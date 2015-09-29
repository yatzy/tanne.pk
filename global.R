### kirjastot tahan

library(jsonlite)
library(dplyr)
library(leaflet)
library(ggmap)
library(rCharts)
# library(shinythemes)
library(RPostgreSQL)
library(sp)

ei_mitaan = read_file('/home/juha/.salasana') %>% gsub('\n','',.)
mapquest_key = read_file('/home/juha/.mapquest') %>% gsub('\n','',.)

### working directory tahan paikkaan

this_dir <- dirname(parent.frame(2)$ofile)
setwd(this_dir)

### omat kirjastot


source('runtime_scripts/utilities.R')
source('runtime_scripts/zippify.R')
source('runtime_scripts/get_location_information.R')
source('runtime_scripts/geocode_nominatim.R')
source('runtime_scripts/get_nearest.R')
source('runtime_scripts/get_palvelut.R')
source('runtime_scripts/point_methods.R')
source('runtime_scripts/zip_methods.R')

### iconit

icon_koti <- icons(iconUrl = 'icons/live/home.svg' , iconWidth = 60)
icon_potentiaalinen <- icons(iconUrl = 'icons/live/potential.svg' , iconWidth = 60)
icon_tyo <- icons(iconUrl = 'icons/live/work.svg' , iconWidth = 60)

icon_ruokakaupat <- icons(iconUrl = 'icons/live/shop.svg' , iconWidth = 45) # lisatty
icon_ala_asteet <- icons(iconUrl = 'icons/live/school.svg' , iconWidth = 45) # lisatty
icon_yla_asteet <- icons(iconUrl = 'icons/live/high_school.svg' , iconWidth = 45) # lisatty
icon_paivakodit <- icons(iconUrl = 'icons/live/kinderkarten3.svg' , iconWidth = 45) # lisatty
icon_kirjastot <- icons(iconUrl = 'icons/live/library.svg' , iconWidth = 45) # lisatty
icon_terveysasemat <- icons(iconUrl = 'icons/live/health_center.svg' , iconWidth = 45) # lisatty
icon_sairaalat <- icons(iconUrl = 'icons/live/hospital.svg' , iconWidth = 45) # lisatty

### asetukset tahan

DEBUG = T
radius = 1
init_ready = F
ui_interaction_lag = 5 # seconds
koti_value_default = "Kotiosoite"
tyo_value_default = "Työosoite"
potentiaalinen_value_default = "Potentiaalinen osoite"
