library(data.table)

# La idea es tener nombres reales con sus popularidad y género 
# para obtener una muestra aproximadamente balanceada por género y 
# que tienda a nombres populares.
# 
# Combina datos de primeros nombres desde 2015 en CABA (tiene datos de género),
# con nombres completos entre 2010 y 2014 en nación (tiene popularidad).

# Listado de los primeros nombres inscriptos en el registro civil desde 2015
# https://data.buenosaires.gob.ar/dataset/nombres/archivo/a21fd18d-4bd7-4003-8cd8-d8574f599a61
nombres <- fread("datos/nombres-usados.csv")

# Nombres de personas físicas 
# https://datos.gob.ar/dataset/otros-nombres-personas-fisicas
h <- fread("datos/nombres-2010-2014.csv") %>% 
  .[, .(cantidad = sum(cantidad)), by = .(nombre)]

nombres <- h[nombres, on = "nombre"] %>% 
  na.omit()

fwrite(nombres, "datos/nombres_procesados.csv")
