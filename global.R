### kirjastot tahan

library(leaflet)
library(ggmap)
library(rCharts)
library(shinythemes)

### working directory tahan paikkaan

this_dir <- dirname(parent.frame(2)$ofile)
setwd(this_dir)

### omat kirjastot

source('runtime_scripts/geocode_nominatim.R')

### asetukset tahan
# globaalit parametrit capsilla, niin erottaa

DEBUG = T
