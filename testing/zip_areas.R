library(gisfin)
pnro.sp <- get_postalcode_areas()
# pnro.sp@data$COL <- factor(generate_map_colours(sp=pnro.sp))
pnro.pks.sp <- pnro.sp[substr(pnro.sp$pnro, 1, 2) %in% c("00", "01", "02"), ]
pk_postinumerot = pnro.pks.sp
spplot(pnro.pks.sp, zcol="COL", 
       col.regions=rainbow(length(levels(pnro.pks.sp@data$COL))), 
       colorkey=FALSE)
#save(pnro.sp , file = '/home/juha/tanne.pk/Data/pnro.rda')
save(pk_postinumerot , file = '/home/juha/tanne.pk/Data/pk_postinumerot.rda')
load(file = '/home/juha/tanne.pk/Data/pk_postinumerot.rda')

format(object.size(pnro.sp) ,units = "Mb")
format(object.size(pnro.pks.sp) ,units = "Mb")

head(names(pnro.pks.sp))
str(pnro.pks.sp,3)
pnro.pks.sp@data
pnro.pks.sp@data[pnro.pks.sp@data == zip]

leaflet() %>% addTiles() %>% 
  addPolygons(data=subset(pk_postinumerot, pnro == '00100'), weight=1)
