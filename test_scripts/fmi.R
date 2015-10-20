fmi_url = 'http://data.fmi.fi/fmi-apikey/d3f59a0b-6c4b-4a49-b603-643cb5654385/wfs?request=getCapabilities'

library(xml2)

fmi = read_html(fmi_url)
str(fmi)

fml = as_list(fmi)
str(fml,2)
