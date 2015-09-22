kunnalliset_palvelut = c(
  kunnalliset_päiväkodit = 27722,
  ostosopimuspäiväkodit = 27780,
  yksityiset_päiväkodit = 27818,
  # perhepäivähoito 27856,
  lukiot = 26972,
  ala_asteet = 34194, #& 34372 (perusopetus 2015-2016 - suomi ja ruotsi),
  yla_asteet = 34272, #& 34402 (perusopetus 2015-2016 - suomi ja ruotsi),
  terveysasemat = 25002,
  kirjastot = 25626)

kunnalliset_palvelut = data.frame(id = kunnalliset_palvelut
                                  , palvelu = names(kunnalliset_palvelut) )


con <- dbConnect(PostgreSQL(), host="localhost", 
                 user= "postgres", password="karttasovellus", dbname="karttasovellus")
dbWriteTable(con , 'kunnalliset_palvelut' , kunnalliset_palvelut , row.names=F)
