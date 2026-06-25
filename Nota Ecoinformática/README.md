# Revisión sistemática de repositorios de paquetes para el lenguaje R (CRAN, GitHub, Bioconductor)
[Enlace al repositorio del proyecto](https://github.com/ajcanepa/NotaEcoinformatica_Revision_Repositorios)

## Objetivo
La **Nota Ecoinformática** presenta como objetivo dar soporte a las búsquedas sistemáticas de paquetes en el entorno de R, en concreto, en los repositorios **CRAN, Bioconductor y GitHub**. De esta forma, se busca el desarrollo de **tres funciones** que unifiquen el patrón de búsqueda y permitan filtrar el listado de paquetes según la **query introducida**. El formato de esta query debe ser aceptado tanto en la sintaxis propia del repositorio como mediante operadores booleanos, permitiendo el empleo de los distintos repositorios de **manera transparente a las peculiaridades internas** de cada uno.

El filtrado de paquetes permite llevar a cabo un análisis gráfico de los resultados, como se muestra en las siguientes figuras.

- **CRAN**
<div align="center">
	<img width="600" height="330" alt="CRAN_Publicados_Descargados" src="https://github.com/user-attachments/assets/044081ec-e893-4e2a-92e5-f66051d67921" />
  <p><em>Gráficos de barras de los paquetes creados y descargados.</em></p>
</div>

______________________________________________________

- **Bioconductor**
<div align="center">
	<img width="400" height="500" alt="Bioconductor_Dependencias" src="https://github.com/user-attachments/assets/9bb8c920-4d81-4533-acdc-e47a8ca6262d" />
  <p><em>Gráfico de dependencias entre paquetes.</em></p>
</div>

____________________________________________   

- **GitHub**
<div align="center">
	<img width="450" height="650" alt="Github_estrellas" src="https://github.com/user-attachments/assets/e8590284-4a4e-4a35-8824-768926dc0485" />
  <p><em>Gráfico de dispersión temporal del número de estrella en función de la fecha de creación</em></p>
</div>
