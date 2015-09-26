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
### working directory tahan paikkaan

this_dir <- dirname(parent.frame(2)$ofile)
setwd(this_dir)

### omat kirjastot

source('runtime_scripts/geocode_nominatim.R')
source('runtime_scripts/get_nearest.R')
source('runtime_scripts/get_palvelut.R')
source('runtime_scripts/point_methods.R')

### iconit
icon_koti <- icons(iconUrl = 'icons/live/home.svg' , iconWidth = 60)
icon_potentiaalinen <- icons(iconUrl = 'icons/live/potential.svg' , iconWidth = 60)
icon_tyo <- icons(iconUrl = 'icons/live/work.svg' , iconWidth = 60)
icon_kaupat <- icons(iconUrl = 'icons/live/shop.svg' , iconWidth = 45)
icon_ala_asteet <- icons(iconUrl = 'icons/live/school.svg' , iconWidth = 45)
icon_yla_asteet <- icons(iconUrl = 'icons/live/high_school.svg' , iconWidth = 45)


### asetukset tahan

DEBUG = T
radius = 2
init_ready = F
marker_store = c()
ui_interaction_lag = 5 # seconds
koti_value_default = "Kotiosoite"
tyo_value_default = "Työosoite"
potentiaalinen_value_default = "Potentiaalinen osoite"