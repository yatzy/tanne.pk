library(mice)
library(readr)
library(VIM)
source('runtime_scripts/zippify.R')
setwd("~/tanne.pk")
paavo = read_csv('/home/juha/tanne.pk/Data/paavo/paavo_coord.csv')
head(paavo)

num_ind = sapply(paavo , is.numeric)

# paavo numeric
pn = paavo[,num_ind]
# pn = pn[ , which(colnames(pn)=='zippa') ]
pn %>% distinct(zip) -> pn
rownames(pn) = zippify(pn$zip)


pn %>% mice(m=1,defaultMethod='rf') %>% complete() ->
  pnn
sum(complete.cases(pnn))
nrow(pnn)

pnn %>% select(-zip,-lat,-lon) -> pnn
pnnn = kNN(pnn)

sum(complete.cases(pnnn))
nrow(pnnn)

pnnns = scale(pnnn)

pn_scaled = as.matrix(dist(pnnns))
View(pn_scaled)
format( object.size(pn_scaled) ,units='MB' )

pn_scaled = as.data.frame(pn_scaled)
row_names = row.names(pn_scaled)

pn_scaled = cbind(row_names , pn_scaled)

conn <- dbConnect(PostgreSQL(), host="localhost", 
                  user= "postgres", password = ei_mitaan , dbname="karttasovellus")
dbWriteTable(conn,'paavo_dist', pn_scaled ,row.names=FALSE )
dbDisconnect(conn)

pn_scaled = pn_scaled[,-1]


pn_scaled = as.matrix(dist(pnnns))
res_df = data.frame( area = row.names(pn_scaled) , nearest1=NA ,nearest2=NA,nearest3=NA )
for( i in 1:nrow(pn_scaled)){
  res = c(colnames(pn_scaled)[head(order(pn_scaled[-i,i]) , 3 )] )
  res_df[i,2:4] = res
}

conn <- dbConnect(PostgreSQL(), host="localhost", 
                  user= "postgres", password = ei_mitaan , dbname="karttasovellus")
dbWriteTable(conn, 'paavo_nearest' , res_df ,row.names=FALSE )
dbDisconnect(conn)

