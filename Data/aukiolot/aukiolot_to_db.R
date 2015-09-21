library(dplyr)
library(data.table)
library(readr)
library(RPostgreSQL)

setwd("/home/juha/tanne.pk/Data")
shops = fread('shops_pk_coords.csv' , data.table=F)
colnames(shops)[8] = 'Tyyppi'
shops = shops %>% select(Tyyppi , lat , lon , osoite_paikkakunta , Nimi)
colnames(shops) = tolower(colnames(shops))
colnames(shops)[4] = 'osoite'

write_csv(shops , path = 'aukiolot/shops.csv')

con <- dbConnect(PostgreSQL(), host="localhost", 
                 user= "postgres", password=ei_mitaan, dbname="karttasovellus")
dbWriteTable(con , 'coord' , shops , row.names=F)

dbSendQuery(conn , 'ALTER TABLE coord ALTER COLUMN lon TYPE numeric(14,12) USING lon::numeric')
dbSendQuery(conn , 'ALTER TABLE coord ALTER COLUMN lat TYPE numeric(14,12) USING lat::numeric')