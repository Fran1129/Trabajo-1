# Template reporte reproducibilidad

Link al reporte (https://fran1129.github.io/Trabajo-1/)

Este repositorio contiene una plantilla para el reporte de reproducibilidad del Trabajo 1 del curso [Investigación Social Abierta](https://cienciasocialabierta.cl/2026/). La plantilla está diseñada para ser clonada y modificada por cada estudiante, siguiendo el protocolo [IPO](https://lisacoes.com/protocolos/a-ipo-rep/) (IInput-Processing-Output) y utilizando el formato Quarto.

<img src="https://lisacoes.com/protocolos/a-ipo-rep/ipo-hex.png" alt="IPO" width="220" />

## Working tree del proyecto

Este proyecto se organiza de la siguiente manera: 

<!-- WORKING_TREE_START -->
```text
Trabajo-1/
 |- .vscode/
 |  |- settings.json
 |- README.md
 |- index.html
 |- index.qmd
 |- input/
 |  |- bib/
 |  |  |- apa6.csl
 |  |  |- cita.bib
 |  |- data/
 |  |  |- original/
 |  |  |  |- Chilean_cabinets_1990_2014.csv
 |  |  |  |- Chilean_cabinets_1990_2014_v1.csv
 |  |  |- proc/
 |  |- images/
 |  |  |- tabla_3_v1.png
 |  |  |- tabla_original.png
 |  |- original-code/
 |- libs/
 |  |- ocs.scss
 |- output/
 |  |- graphs/
 |  |- tables/
 |- processing/
 |  |- CodigoOriginal.R
 |  |- README-prod.md
 |  |- ReproduccionTabla.R
 |  |- prod_analysis.Rmd
 |  |- prod_analysis.html
 |  |- prod_prep.Rmd
 |  |- prod_prep.html
 |- scripts/
 |  |- update-working-tree.sh
```
<!-- WORKING_TREE_END -->

Este working tree incorpora las carpetas y archivos principales relevantes del repo (omite algunas) y se actualiza automáticamente al hacer commit mediante una github action que se encuentra definida en el archivo `.github/workflows/update-working-tree.yml`. El propósito de esta acción es mantener un registro actualizado de la estructura del proyecto, lo que facilita la navegación y organización de los archivos para los estudiantes.


