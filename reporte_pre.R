library(data.table)
library(magrittr)
library(ggplot2)

## Acá va la url de la lista de participantes
url <- "https://docs.google.com/spreadsheets/d/12hq4HeIpjfN07La4qsHDrcY9f4Q-1yBwGni8LJs_kW4/edit#gid=1804838870"

if (!googlesheets4::gs4_has_token()) {
  stop("Hay que sacar el token!")

}
lista_raw <- googlesheets4::read_sheet(url, skip = 1) %>%
  as.data.table()


columnas <- c(nombre = "Name",
                   pais = "País",
                   provincia = 'Si estás en Argentina, provincia o distrito, si no completá la opción "other". Seleccioná la provincia/distrito en la cual tenés la mayor cantidad de horas de docencia',
                   docs = "¿Cuál es tu experiencia con las siguientes herramientas? [Google Docs]",
                   zoom = "¿Cuál es tu experiencia con las siguientes herramientas? [Zoom]",
                   barrera = "¿Tenés alguna barrera tecnológica para enseñar o aprender en forma remota?",
                   discapacidad = "¿Tenés alguna discapacidad o impedimento que afecte la forma en que estudiás o trabajás? ¿Necesitás requisitos especiales en tu entorno de aprendizaje o trabajo? Seleccioná todas las que correspondan",
                   conexion = "¿Cómo es el acceso a internet desde donde te conectarías para aprender y/o enseñar?",
                   n_estudiantes = "Aproximadamente, ¿qué cantidad de estudiantes que esperás en tu próxima clase? Completá con 0, si no vas a enseñar en 2020",
                   n_años = "Aproximadamente, ¿cuántos años hace que diste tu primera clase? Elegí 0 si nunca enseñaste."

                   )

lista <- lista_raw[, ..columnas] %>%
  setnames(columnas, names(columnas)) %>%
  .[]


docs <- lista[docs == "Nunca la usé"] %>%
  .[, .(nombre, barrera = "Nunca usó google docs")]


zoom <- lista[zoom == "Nunca la usé"] %>%
  .[, .(nombre, barrera = "Nunca usó zoom")]


barrera <- lista[barrera != "No tengo ninguna barrera de este tipo"] %>%
  .[, .(nombre, barrera)]


discapacidad <- lista[discapacidad != "No tengo discapacidad o impedimento"] %>%
  .[, .(nombre, barrera = discapacidad)]


conexion <- lista[!(grepl("aceptable", conexion))] %>%
  .[, .(nombre, barrera = "Conexión limitada")]

especiales <- rbind(docs, zoom, barrera, discapacidad, conexion) %>%
  na.omit() %>%
  .[, n := .N, by = nombre] %>%
  .[order(-n)] %>%
  .[by = nombre, j = paste0("    - ", barrera, collapse = "\n")] %>%
  .[, paste0("* ", nombre, "\n", V1, "\n")] %>%
  paste0(collapse = "\n")




text_hist <- function(labels, n, sort = FALSE) {
  # h <- hist(x, ...,plot = FALSE)

  zero <- n == 0
  if (sort) {
    order <- order(-n)
    n <- n[order]
    labels <- labels[order]
  }


  lapply(n[!zero], function(x) {
    if (x > 0) {
      paste0(rep("*", x), collapse = "")
    } else {
      ""
    }
  }) %>%
    unlist() -> stars

  labels <- formatC(labels[!zero], width = max(nchar(labels)))

  paste(labels, stars, sep = "|", collapse= "\n")
}


estudiantes <- hist(lista$n_estudiantes, plot = FALSE) %>%
  with(., text_hist(paste0("(", breaks[-length(breaks)], "; ", breaks[-1], ")"),
                    counts))

años <- split(lista, unlist(lista$n_años)) %>%
  lapply(nrow) %>%
  {text_hist(names(.), unlist(.))}



paises <- split(lista, unlist(lista$pais)) %>%
  lapply(nrow) %>%
  {text_hist(names(.), unlist(.), sort = TRUE)}

provincias <- lista[pais == "Argentina"] %>%
  .[provincia == "Ciudad Autónoma de Buenos Aires", provincia := "CABA"] %>%
  split(., unlist(.$provincia)) %>%
  lapply(nrow) %>%
  {text_hist(names(.), unlist(.), sort = TRUE)}


reporte <- paste(paste0("Casos especiales:\n", especiales),
    "Datos generales:",
    paste0("Paises:\n", paises),
    paste0("Provincias:\n", provincias),
    paste0("Cantidad de estuiantes:\n", estudiantes),
    paste0("Años de docencia:\n", años),
    sep = "\n\n", collapse = "\n")


# Imprime el reporte en la consola para copiar y pedar (por ahora)
cat(reporte)

# Imprime los nombres en orden alfabético para llenar en el documento compartido
cat(sort(lista$nombre), sep = "\n")


# La idea es tener balance de género, peroque siempre sea 50% exacto
# se siente artificial, así que le mando entre 40% y 60%.
fem <- runif(1, .4, .6)
fem <- round(fem*nrow(lista))
mas <- nrow(lista) - fem

gen <- list(F = fem,
            M = mas)

nombres <- fread("datos/nombres_procesados.csv")

personas <- nombres[, sample(nombre, gen[[genero]], prob = log(cantidad), replace = FALSE), by = genero] %>%
  .[sample(.N)] # para aleatorizar el orden

lista[, persona := personas$V1]

# Nombres en orden alfabético y asigna una persona para agergar.
lista[order(nombre)] %>%
  .[, paste0(nombre, ": ", persona, "... ")] %>%
  cat(sep = "\n")

