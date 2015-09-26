ah = read_csv( '/home/juha/tanne.pk/Data/asuntojen_hinnat/asuntojen_hinnat.csv' )

source('/home/juha/tanne.pk/init_scripts/zippify.R')
ah$Postinumero = zippify(ah$Postinumero)
head(ah)

ah = as.data.frame(ah)

conn <- dbConnect(PostgreSQL(), host="localhost", 
                  user= "postgres", password = ei_mitaan , dbname="karttasovellus")

dbWriteTable(conn , 'asuntojen_hinnat' , ah, row.names=FALSE,append=F )
dbDisconnect(conn)
