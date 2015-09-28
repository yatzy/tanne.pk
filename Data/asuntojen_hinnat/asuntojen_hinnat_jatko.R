setwd('/home/yatzy/Downloads')

library( readr )
library( dplyr )
source('/home/yatzy/Applications/tanne.pk/init_scripts/zippify.R')

ah = read_csv('asuntojen_hinnat.csv')

head(ah)

ah$Postinumero = zippify(ah$Postinumero)
View(ah)

ah = ah[ah$Neljännes == 'Koko vuosi' , ]
ah = ah[ah$Rakennusvuosi == 'Rakennusvuodet yhteensä' , ]
ah = ah[ah$Talotyyppi == 'Talotyypit yhteensä' , ]

ah = ah %>% select( -Neljännes , -Talotyyppi , -Rakennusvuosi )

write_csv(ah , path='/home/yatzy/Applications/tanne.pk/Data/asuntojen_hinnat/asuntojen_hinnat.csv')
