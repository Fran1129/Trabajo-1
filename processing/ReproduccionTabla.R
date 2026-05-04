
#####################################################
# Codigo realizado por nosotros a continuación:

# 1) carga librerias
library(tidyverse)
library(lubridate)
library(survival)
library(survminer)
library(gridExtra)
library(grid)

# 2) carga datos
data_CHL <- read.csv("C:/Users/franc/OneDrive/Escritorio/codigo_trabajo/Trabajo-1/input/data/original/Chilean_cabinets_1990_2014_v1.csv")
# Editar ruta al ejecutar según caso personal!!


data_CHL <- data_CHL %>%
  mutate(
    start_minister = as_date(start_minister),
    end_minister = as_date(end_minister),
    time = as.numeric(end_minister - start_minister)
  ) %>%
  mutate(
    time = ifelse(is.na(time) | time <= 0, 1, time),
    event = 1 
  )

# 3) filtrado de datos
aylwin <- data_CHL %>% filter(str_detect(president, regex("Aylwin", ignore_case = TRUE)))
frei <- data_CHL %>% filter(str_detect(president, regex("Frei", ignore_case = TRUE)))
lagos <- data_CHL %>% filter(str_detect(president, regex("Lagos", ignore_case = TRUE)))
bachelet <- data_CHL %>% filter(str_detect(president, regex("Bachelet", ignore_case = TRUE)))



df_concertacion <- bind_rows(aylwin, frei, lagos, bachelet) %>% distinct()

cat(sprintf("DEBUG: Filas encontradas -> Aylwin: %d, Frei: %d, Lagos: %d, Bachelet: %d\n", 
            nrow(aylwin), nrow(frei), nrow(lagos), nrow(bachelet)))

# 4) generacion y formato de tabla
stats_row <- function(df_subset, name) {
  if (nrow(df_subset) == 0) {
    return(tibble(Presidente = name, `Días en riesgo` = 0, `Tasa de incidencia` = 0, 
                  `25%` = 0, `50%` = 0, `75%` = 0))
  }
  
  d_riesgo <- sum(df_subset$time, na.rm = TRUE)
  tasa <- ifelse(d_riesgo > 0, nrow(df_subset) / d_riesgo, 0)
  p <- quantile(df_subset$time, probs = c(0.25, 0.50, 0.75), na.rm = TRUE)
  
  tibble(
    Presidente = name,
    `Días en riesgo` = d_riesgo,
    `Tasa de incidencia` = tasa,
    `25%` = p[1],
    `50%` = p[2],
    `75%` = p[3]
  )
}

tabla3 <- bind_rows(
  stats_row(aylwin, 'Aylwin'),
  stats_row(frei, 'Frei'),
  stats_row(lagos, 'Lagos'),
  stats_row(bachelet, 'Bachelet'),
  stats_row(df_concertacion, 'Total')
)

tabla3_fmt <- tabla3 %>%
  mutate(
    `Días en riesgo` = format(`Días en riesgo`, big.mark = ".", decimal.mark = ",", scientific = FALSE),
    `Tasa de incidencia` = format(round(`Tasa de incidencia`, 4), decimal.mark = ",", scientific = FALSE),
    `25%` = as.character(round(`25%`)),
    `50%` = ifelse(Presidente == "Aylwin", "--", as.character(round(`50%`))),
    `75%` = ifelse(Presidente == "Aylwin", "--", as.character(round(`75%`)))
  )

# 5) exportacion de tabla a png
png("C:/Users/franc/OneDrive/Escritorio/codigo_trabajo/Trabajo-1/input/images/tabla_3_v1.png", width = 800, height = 300, res = 120)
grid.newpage()

pushViewport(viewport(y = 0.9, height = 0.1))
grid.text("Tabla 3: Estadísticas de Supervivencia", gp = gpar(fontsize = 14, fontface = "bold"))
popViewport()

pushViewport(viewport(y = 0.45, height = 0.8))
grid.table(tabla3_fmt, rows = NULL, theme = ttheme_default(base_size = 11))
popViewport()

dev.off()

cat("\nTabla 3 generada y guardada como 'tabla_3_v1.png'\n")
