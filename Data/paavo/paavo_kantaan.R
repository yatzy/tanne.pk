library(mice)
library(mi)
library(readr)
library(stringr)

paavo = read_csv('/home/juha/tanne.pk/Data/paavo/paavo_coord.csv')
paavo$zip = zippify(paavo$zip)
View(paavo)
paavo
sapply(paavo , is)
replace_these =c('..2013..he.|..2012..pt.|..2013..ra.|..2012..tp.|..2012..ko.|..2012..tr.|..2013..te.|..2012..hr.|x')

colnames(paavo) = tolower(colnames(paavo)) %>% str_replace_all(replace_these,'') 
colnames(paavo)

p2 = paavo[,50:ncol(paavo)]
View(p2)
removals = c('postinumeroalue' , 'zippa' , 'alkutuotannon.työpaikat','taloudet.yhteensä','pienten.lasten.taloudet')
rem_ind = which(colnames(paavo) %in% removals )
which(colnames(paavo) == 'zip' )
which(colnames(paavo) == 'asukkaat.yhteensä' )
which(colnames(paavo) == 'eläkeläiset' )
colnames(paavo)[2]
paavo = paavo[ , -c(rem_ind,26,1)]

paavo %>% distinct(zip) -> paavo

paavomi = missing_data.frame(as.data.frame(paavo))
paavomi$postprocess
str(paavomi,2)
show(paavomi)
summary(paavomi)
image(paavomi)

# pv = mi(as.data.frame(paavo),n.chains=1)
pv = mice(paavo,m=1,defaultMethod='rf')
pvv = complete(pv)
pvvmi = missing_data.frame(pvv)
image(pvvmi)
pvv = pvv[, -which(colnames(pvv) == 'pienten.lasten.taloudet') ]
pvvv = mice(pvv,m=1,defaultMethod='rf')

pvvvv = complete(pvvv)
pvvvmi = missing_data.frame(pvvvv)
image(pvvvmi)

paavo = as_data_frame(pvvvv)
# View(paavo)

colnames(paavo)
colnames(paavo)[4:23] = paste('x.',colnames(paavo)[4:23],sep='')

paavo %>%  
  mutate( asukkaat = x.0.2.vuotiaat + x.3.6.vuotiaat + x.7.12.vuotiaat + x.13.15.vuotiaat + x.16.17.vuotiaat + x.18.19.vuotiaat + x.20.24.vuotiaat + x.25.29.vuotiaat + x.30.34.vuotiaat + x.35.39.vuotiaat + x.40.44.vuotiaat + x.45.49.vuotiaat + x.50.54.vuotiaat + x.55.59.vuotiaat + x.60.64.vuotiaat + x.65.69.vuotiaat + x.70.74.vuotiaat + x.75.79.vuotiaat + x.80.84.vuotiaat + x.85.vuotta.täyttäneet ) %>%
  mutate( min_18_vuotiaat = x.18.19.vuotiaat + x.20.24.vuotiaat + x.25.29.vuotiaat + x.30.34.vuotiaat + x.35.39.vuotiaat + x.40.44.vuotiaat + x.45.49.vuotiaat + x.50.54.vuotiaat + x.55.59.vuotiaat + x.60.64.vuotiaat + x.65.69.vuotiaat + x.70.74.vuotiaat + x.75.79.vuotiaat + x.80.84.vuotiaat + x.85.vuotta.täyttäneet ) %>%
  mutate( x.0.15.vuotiaat = (x.0.2.vuotiaat + x.3.6.vuotiaat + x.7.12.vuotiaat + x.13.15.vuotiaat)/asukkaat  ) %>%
  mutate( x.16.29.vuotiaat =  (x.16.17.vuotiaat + x.18.19.vuotiaat + x.20.24.vuotiaat + x.25.29.vuotiaat)/asukkaat ) %>%
  mutate( x.30.59.vuotiaat = (x.30.34.vuotiaat+ x.35.39.vuotiaat+ x.40.44.vuotiaat+ x.45.49.vuotiaat+x.50.54.vuotiaat+ x.55.59.vuotiaat)/asukkaat ) %>%
  mutate( x.yli.60.vuotiaat = (x.60.64.vuotiaat+ x.65.69.vuotiaat+x.70.74.vuotiaat+ x.75.79.vuotiaat+ x.80.84.vuotiaat+ x.85.vuotta.täyttäneet)/asukkaat ) %>%
  mutate( tyottomyysaste = työttömät / työvoima ) %>%
  mutate( pientaloja = pientaloasunnot / asunnot ) %>%
  mutate( kerrostaloja = kerrostaloasunnot / asunnot ) %>%
  mutate( perusasteen_koulutus = perusasteen.suorittaneet / min_18_vuotiaat) %>%
  mutate( toisen_asteen_koulutus = (ylioppilastutkinnon.suorittaneet + ammatillisen.tutkinnon.suorittaneet) / min_18_vuotiaat ) %>%
  mutate( korkeakoulutus = (alemman.korkeakoulututkinnon.suorittaneet + ylemmän.korkeakoulututkinnon.suorittaneet) / min_18_vuotiaat ) %>%
  mutate( tyolliset = työlliset / asukkaat ) %>%
  mutate( tyottomat = työttömät / asukkaat ) %>%
  mutate( lapset = lapset.0.14..vuotiaat / asukkaat ) %>%
  mutate( opiskelijat = opiskelijat / asukkaat ) %>%
  mutate( elakelaiset = eläkeläiset / asukkaat ) %>%
  mutate( muut = muut / asukkaat ) ->
  paavo2

colnames(paavo2)
paavo2 = paavo2[, -which(colnames(paavo2) == 'palveluiden.työpaikat') ]

start_col = which(colnames(paavo2) == 'jalostuksen.työpaikat')
end_col = which(colnames(paavo2) == '.toimiala.tuntematon')

correct_colnames = c('jalostus','maatalous','kaivostoiminta','sähkoliiketoiminta','vesihuolto','rakentaminen'
                     ,'tukku- ja vähittäiskauppa','kuljetus ja varastointi','majoitus ja ravitseminen'
                     , 'informaatio ja viestintä','rahoitus ja vakuutus','kiinteistöala','tieteellinen toiminta'
                     , 'hallinto ja tukipalvelut','julkinen hallinto','koulutus','terveys- ja sosiaalipalvelut'
                     , 'taide ja viihde','muu palvelutoiminta','kotitaloudet työnantajina'
                     , 'kansainväliset organisaatiot' ,'tuntematon toimiala')

colnames(paavo2)[start_col:end_col] = correct_colnames

paavott = paavo2[ , start_col:end_col]

paavo2$yleisin1 = apply(paavott , 1 , nth_max , 1)
paavo2$yleisin2 = apply(paavott , 1 , nth_max , 2)
paavo2$yleisin3 = apply(paavott , 1 , nth_max , 3)

paavo2$yleisimmat = paste(paavo2$yleisin1 , paavo2$yleisin2 , paavo2$yleisin3 , sep=', ')

paavo2 = complete(mice(paavo2 , m=1 , defaultMethod='rf'))
paavo2$keskitulot = paavo2$asukkaiden.keskitulot


conn <- dbConnect(PostgreSQL(), host="localhost", 
                  user= "postgres", password = ei_mitaan , dbname="karttasovellus")
dbWriteTable(conn,'paavo_full',as.data.frame(paavo2) , row.names=FALSE  )
dbDisconnect(conn)

end_cols = c('zip','x.0.15.vuotiaat' , 'x.16.29.vuotiaat','x.30.59.vuotiaat','x.yli.60.vuotiaat','tyottomyysaste','pientaloja','kerrostaloja'
             , 'perusasteen_koulutus' ,'toisen_asteen_koulutus','korkeakoulutus' ,'tyolliset' ,'tyottomat','lapset' ,'opiskelijat'
             ,'elakelaiset','muut' , 'yleisimmat','keskitulot')
paavo3 = paavo2[,end_cols]

conn <- dbConnect(PostgreSQL(), host="localhost", 
                  user= "postgres", password = ei_mitaan , dbname="karttasovellus")
dbWriteTable(conn,'paavo',as.data.frame(paavo3) , row.names=FALSE  )
dbDisconnect(conn)
