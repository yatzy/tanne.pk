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

# iconit
icon_koti <- icons(iconUrl = 'icons/live/home.svg' , iconWidth = 60)
icon_potentiaalinen <- icons(iconUrl = 'icons/live/potential.svg' , iconWidth = 60)
icon_tyo <- icons(iconUrl = 'icons/live/work.svg' , iconWidth = 60)
icon_kauppa <- icons(iconUrl = 'icons/live/shop.svg' , iconWidth = 50)
icon_ala_aste <- icons(iconUrl = 'icons/live/school.svg' , iconWidth = 50)



### asetukset tahan
# globaalit parametrit capsilla, niin erottaa

click_count = 0
DEBUG = T
