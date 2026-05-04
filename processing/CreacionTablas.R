###################################################################
# Código disponible en el repositorio original de los autores en github:
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#### Script ID ####

## Exploratory Data Analysis Ministers
## R version 4.1.0 (2021-05-18) -- "Camp Pontanezen"
## Date: November 2021

## Bastián González-Bustamante (University of Oxford, UK)
## https://bgonzalezbustamante.com
## Alejandro Olivares (Universidad Católica de Temuco, Chile)

## Data Set on Chilean Ministers
## https://github.com/bgonzalezbustamante/chilean-ministers
## https://doi.org/10.5281/zenodo.5744536

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#### Packages and Data ####

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

## Clean Environment
rm(list = ls())

## Packages
library(DataExplorer)
library(ggplot2)


## Data
data_CHL <- read.csv("C:/Users/franc/OneDrive/Escritorio/codigo_trabajo/Trabajo-1/input/data/original/Chilean_cabinets_1990_2014_v1.csv")
# Editar ruta al ejecutar según caso personal!!


## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#### EDA ####

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

## Data Set Plot 
plot_intro(data_CHL, ggtheme = theme_minimal(base_size = 12),
           theme_config = theme(legend.position = "none")) 

## Discrete Variables
selection_var1 <- drop_columns(data_CHL, c("id", "country", "name", "start_president", "end_president",
                                           "ministry", "start_minister", "end_minister", "party_leader",
                                           "exp_executive", "exp_congress", "exp_ngo", "exp_thinktanks",
                                           "exp_business", "political_kinship"))
selection_var2 <- drop_columns(data_CHL, c("id", "country", "name", "start_president", "end_president",
                                           "ministry", "start_minister", "end_minister", "sex",
                                           "president", "non_party", "president_party", "economist",
                                           "lawyer", "inner_circle"))
plot_bar(selection_var1, ggtheme = theme_minimal(base_size = 12))
plot_bar(selection_var2, ggtheme = theme_minimal(base_size = 12))

## Age
plot_histogram(data_CHL$age, ggtheme = theme_minimal(base_size = 12))

## Time Variable
data_CHL$time <- with(data_CHL, (as.Date(data_CHL$end_minister) - as.Date(data_CHL$start_minister)))
data_CHL$time <- as.numeric(data_CHL$time)
plot_histogram(data_CHL$time, ggtheme = theme_minimal(base_size = 12)) 


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
