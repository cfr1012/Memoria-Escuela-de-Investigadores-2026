# Revisión sistemática de repositorios de paquetes para el lenguaje R (CRAN, GitHub, Bioconductor)
[Enlace al repositorio del proyecto](https://github.com/ajcanepa/NotaEcoinformatica_Revision_Repositorios)

## Objetivo
La **Nota Ecoinformática** presenta como objetivo dar soporte a las búsquedas sistemáticas de paquetes en el entorno de R, en concreto, en los repositorios **CRAN, Bioconductor y GitHub**. De esta forma, se busca el desarrollo de **tres funciones** que unifiquen el patrón de búsqueda y permitan filtrar el listado de paquetes según la **query introducida**. El formato de esta query debe ser aceptado tanto en la sintaxis propia del repositorio como mediante operadores booleanos, permitiendo el empleo de los distintos repositorios de **manera transparente a las peculiaridades internas** de cada uno.

El filtrado de paquetes permite llevar a cabo un análisis gráfico de los resultados, como se muestra en las siguientes figuras.

- **CRAN**
<div align="center">
	<img width="600" height="330" alt="CRAN_Publicados_Descargados" src="https://github.com/user-attachments/assets/a904e24a-cd4b-49c4-b4c4-6c7b4dffd9aa" />
  <p><em>Gráficos de barras de los paquetes creados y descargados.</em></p>
</div>


______________________________________________________

- **Bioconductor**
<div align="center">
	<img width="400" height="500" alt="Bioconductor_Dependencias" src="https://github.com/user-attachments/assets/150ec364-cc2c-47c2-b777-a4b703559363" />
  <p><em>Gráfico de dependencias entre paquetes.</em></p>
</div>


____________________________________________   

- **GitHub**
<div align="center">
	<img width="450" height="650" alt="Github_estrellas" src="https://github.com/user-attachments/assets/26538278-1915-4dd3-ba93-c03753491c4e" />
  <p><em>Gráfico de dispersión temporal del número de estrella en función de la fecha de creación</em></p>
</div>

