conn <- dbConnect(PostgreSQL(), host="localhost", 
                      user= "postgres", password = 'karttasovellus' , dbname="karttasovellus")

q = 'select * from paavo'

paavo = dbGetQuery(conn , q)
colnames(paavo)

q = 'select * from paavo_full'
paavo_full = dbGetQuery(conn , q)
colnames(paavo_full)

adds = c('alimpaan.tuloluokkaan.kuuluvat.asukkaat' 
         , 'keskimmäiseen.tuloluokkaan.kuuluvat.asukkaat'
         ,'ylimpään.tuloluokkaan.kuuluvat.asukkaat'
         , 'asumisväljyys','18.vuotta.täyttäneet.yhteensä'  ,'zip')

add_cols = paavo_full[ , adds]

paavo2 = merge(paavo , add_cols , by='zip',all=T)

dbWriteTable(conn,'paavo2',as.data.frame(paavo2) , row.names=FALSE  )

paavo2$alimpaan.tuloluokkaan.kuuluvat.asukkaat = paavo2$alimpaan.tuloluokkaan.kuuluvat.asukkaat / paavo2$'18.vuotta.täyttäneet.yhteensä'
paavo2$keskimmäiseen.tuloluokkaan.kuuluvat.asukkaat = paavo2$keskimmäiseen.tuloluokkaan.kuuluvat.asukkaat / paavo2$'18.vuotta.täyttäneet.yhteensä'
paavo2$ylimpään.tuloluokkaan.kuuluvat.asukkaat = paavo2$ylimpään.tuloluokkaan.kuuluvat.asukkaat / paavo2$'18.vuotta.täyttäneet.yhteensä'

paavo2$alimpaan.tuloluokkaan.kuuluvat.asukkaat = ifelse(paavo2$alimpaan.tuloluokkaan.kuuluvat.asukkaat>1 ,paavo2$alimpaan.tuloluokkaan.kuuluvat.asukkaat/100,paavo2$alimpaan.tuloluokkaan.kuuluvat.asukkaat)
paavo2$keskimmäiseen.tuloluokkaan.kuuluvat.asukkaat = ifelse(paavo2$keskimmäiseen.tuloluokkaan.kuuluvat.asukkaat>1 ,paavo2$keskimmäiseen.tuloluokkaan.kuuluvat.asukkaat/100,paavo2$keskimmäiseen.tuloluokkaan.kuuluvat.asukkaat)
paavo2$ylimpään.tuloluokkaan.kuuluvat.asukkaat = ifelse(paavo2$ylimpään.tuloluokkaan.kuuluvat.asukkaat>1 ,paavo2$ylimpään.tuloluokkaan.kuuluvat.asukkaat/100,paavo2$ylimpään.tuloluokkaan.kuuluvat.asukkaat)

paavo2 %>% select(alimpaan.tuloluokkaan.kuuluvat.asukkaat:ylimpään.tuloluokkaan.kuuluvat.asukkaat) %>%
  rowSums()

paavo2$alimpaan.tuloluokkaan.kuuluvat.asukkaat = paavo2$alimpaan.tuloluokkaan.kuuluvat.asukkaat*100
paavo2$keskimmäiseen.tuloluokkaan.kuuluvat.asukkaat = paavo2$keskimmäiseen.tuloluokkaan.kuuluvat.asukkaat*100
paavo2$ylimpään.tuloluokkaan.kuuluvat.asukkaat = paavo2$ylimpään.tuloluokkaan.kuuluvat.asukkaat*100

dbWriteTable(conn,'paavo3',as.data.frame(paavo2) , row.names=FALSE  )

dbDisconnect(conn)
