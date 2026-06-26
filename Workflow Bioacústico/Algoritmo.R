library(readr)  #para leer los ficheros csv
library(DBI) #para trabajar con bases de datos
library(RSQLite) #para trabajar con bases de datos dentro de SQLite
library(dplyr) #para la manipulación de tablas
library(readxl) #para leer archivos .xlsx y .xls
library(openxlsx) #para crear, modificar y guardar archivos .xlsx

#FUNCIÓN PARA CREAR BASE DE DATOS
crear_base_de_datos_de_registros <- function(
    archivos = NULL, #se pueden listar los diversos archivos csv
    carpeta = NULL, #se puede introducir directamente la carpeta donde están todos los ficheros
    archivo_sqlite = "BaseDatos_RegistrosBirdNET.sqlite" #nombre de la base de datos generada
) {
  
  # Obtener los archivos csv a procesar
  if (!is.null(carpeta)) {
    
    archivos_encontrados <- list.files(
      carpeta,
      pattern = "\\.csv$", #solo se van a tomar los archivos en formato csv
      full.names = TRUE
    )
    
  } else {
    
    archivos_encontrados <- archivos
    
  }
  
  if (length(archivos_encontrados) == 0) {
    stop("Esta carpeta introducida no dispone de ficheros con extensión .csv para generar la base de datos. Por favor, inserte una carpeta válida")
  }
  
  # Establecemos conexión entre el entorno R y SQLite
  conexion <- dbConnect(
    RSQLite::SQLite(),
    archivo_sqlite
  )
  
  # Vamos a crear dos tablas: Registros y Estaciones_Acusticas (primero las eliminamos en caso de existir)
  dbExecute(conexion, "DROP TABLE IF EXISTS Registros")
  dbExecute(conexion, "DROP TABLE IF EXISTS Estaciones_Acusticas")
  
  # La estructura de columnas de la base de datos se obtiene a partir de uno de los archivos introducidos
  primer_csv <- read_csv(
    archivos_encontrados[1],
    show_col_types = FALSE
  )
  
  columnas_requeridas <- c(
    "zona", 
    "latitud",
    "longitud"
  )
  
  #Se comprueba que el csv disponga de las columnas que vamos a usar
  faltan <- setdiff(
    columnas_requeridas,
    names(primer_csv) 
  )
  
  if (length(faltan) > 0) {
    
    stop(
      paste(
        "No se disponen de estas columnas:",
        paste(faltan, collapse = ", ")
      )
    )
    
  }
  
  # Creación de la tabla Estaciones
  dbExecute(conexion, "
    CREATE TABLE Estaciones_Acusticas (
      zona TEXT PRIMARY KEY,
      latitud REAL,
      longitud REAL
    )
  ")
  
  # Creación de la tabla Registros
  registros_vacio <- primer_csv[0, ]
  
  dbWriteTable(
    conexion,
    "Registros",
    registros_vacio,
    overwrite = TRUE
  )
  
  # Recorremos los distintos csv insertados
  for (archivo in archivos_encontrados) {
    
    datos <- read_csv(
      archivo,
      show_col_types = FALSE #no imprime nada mientras lee los archivos
    )
    
    estaciones <- datos %>%
      select(
        zona,
        latitud,
        longitud
      ) %>%
      distinct()
    
    estaciones_existentes <- dbReadTable(
      conexion,
      "Estaciones_Acusticas"
    )
    
    estaciones_nuevas <- anti_join(
      estaciones,
      estaciones_existentes,
      by = "zona"
    )
    
    if (nrow(estaciones_nuevas) > 0) {
      
      dbWriteTable(
        conexion,
        "Estaciones_Acusticas",
        estaciones_nuevas,
        append = TRUE
      )
      
    }
    
    # Insertar todos los registros
    dbWriteTable(
      conexion,
      "Registros",
      datos,
      append = TRUE
    )
  }
  
  dbDisconnect(conexion) #desconcetamos el entorno de R de la Base de datos
  
  return(archivo_sqlite) #devuelve la base de datos que incluye ambas tablas
}

crear_base_de_datos_de_registros(archivos = "Registros.csv") #prueba con uno de los ficheros

#FUNCIÓN PARA CREAR ARCHIVO DE SUBIDA A OBSERVATION.ORG
convertir_datos_BirdNET_plantilla <- function(base_de_datos_sqlite, archivo_plantilla) { #base_de_datos es la salida de la función crear_base_de_datos_de_registros
  
  # Correspondencias entre los campos de la plantilla de Observation.org y el csv generado por BirdNET
  correspondencias <- list(
    "scientific name" = "scientific_name",
    "lat" = "latitud",
    "lng" = "longitud"
  )
  
  #Creación del fichero resultado en formato .xlsx
  archivo_salida <- "Observaciones_BirdNET_plantilla.xlsx"
  
  # Obtener cabeceras de la plantilla
  plantilla <- read_excel(archivo_plantilla)
  cabeceras <- colnames(plantilla) #colnames es una función de R que devuelve el nombre de las columnas
  
  # Creación del workbook (se crea un archivo Excel y se añade una hoja)
  Excel <- createWorkbook()
  addWorksheet(Excel, "Hoja1")
  
  # Se escriben las cabeceras de las columnas
  writeData(
    Excel, #archivo creado
    "Hoja1", #en la única hoja creada
    as.data.frame(as.list(cabeceras)),
    startRow = 1, #empezamos la escritura en la primera fila
    colNames = FALSE
  )
  
  fila_actual <- 2 #se empiezan a escribir los registros en la fila 2 porque la 1 son las cabeceras
  
  # Procesar la base de datos de registros acústicos (tabla "Registros")
  conexion <- dbConnect(SQLite(), base_de_datos_sqlite)
  datos <- dbReadTable(conexion, "Registros")
  
  for (i in seq_len(nrow(datos))) { #recorre las filas
    
    new_row <- vector("list", length(cabeceras))
    names(new_row) <- cabeceras
    
    for (cabecera in cabeceras) { #según la cabecera hay datos que se autocompletan y otros que integran los datos propocionados por BirdNET
      
      if (cabecera == "date") {
        
        fecha_hora <- as.POSIXct(
          datos$datetime_deteccion_inicio[i],
          format = "%Y/%m/%d %H:%M:%S"
        )
        
        new_row[[cabecera]] <- format(fecha_hora, "%Y-%m-%d")
        
      } else if (cabecera == "time") {
        
        fecha_hora <- as.POSIXct(
          datos$datetime_deteccion_inicio[i],
          format = "%Y/%m/%d %H:%M:%S"
        )
        
        new_row[[cabecera]] <- format(fecha_hora, "%H:%M")
        
      } else if (cabecera == "number") {
        
        new_row[[cabecera]] <- 1L #indicamos que es de tipo integer y asumimos que cada canto procede de un individuo
        
      } else if (cabecera == "method") {
        
        new_row[[cabecera]] <- "heard" #AudioMoth hace un registro acústico
        
      } else if (cabecera == "accuracy") {
        
        new_row[[cabecera]] <- 10
        
      } else if (cabecera == "is certain") { #consideramos que un dato es certero si BirdNET lo detecta con una confianza igual o superior a 0.85
        
        if ("confianza" %in% names(datos)) {
          
          valor_conf <- suppressWarnings(
            as.numeric(datos$confianza[i])
          )
          
          new_row[[cabecera]] <- if (
            !is.na(valor_conf) && valor_conf > 0.85
          ) {
            "True"
          } else {
            "False"
          }
          
        } else {
          
          new_row[[cabecera]] <- "False"
          
        }
        
      } else if (cabecera == "activity") {
        
        new_row[[cabecera]] <- "singing" #las aves solo son detectadas mediante su actividad acústica
        
      } else if (cabecera == "counting method") {
        
        new_row[[cabecera]] <- "seen not counted"
        
      } else if (cabecera == "notes") {
        
        new_row[[cabecera]] <- 
          "Registro acústico clasificado automáticamente usando BirdNET"
        
      } else if (cabecera %in% names(correspondencias)) { #datos que se rellenan con los datos del registro según las correspondencias establecidas
        
        col_csv <- correspondencias[[cabecera]]
        
        if (col_csv %in% names(datos)) {
          
          new_row[[cabecera]] <- datos[[col_csv]][i]
          
        } else {
          
          new_row[[cabecera]] <- NA
          
        }
        
      } else {
        
        new_row[[cabecera]] <- NA
        
      }
    }
    
    fila_df <- as.data.frame(
      new_row,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    
    writeData(
      Excel,
      "Hoja1",
      fila_df,
      startRow = fila_actual,
      colNames = FALSE
    )
    
    fila_actual <- fila_actual + 1 #movemos el puntero de la fila actual para evitar sobreescribir la misma línea
  }
  
  # Cambiamos el formato de la celda de accuracy a numérico en el archivo resultado
  col_accuracy <- which(cabeceras == "accuracy")
  
  if (length(col_accuracy) > 0) {
    
    estilo_numerico <- createStyle(numFmt = "0")
    
    addStyle(
      Excel,
      "Hoja1",
      style = estilo_numerico,
      rows = 2:(fila_actual - 1),
      cols = col_accuracy,
      gridExpand = TRUE,
      stack = TRUE
    )
  }
  
  saveWorkbook(Excel, archivo_salida, overwrite = TRUE) #guardamos el documento generado y la escritura efectuada en el mismo
  
  return(archivo_salida) #devolvemos el fichero generado
}

convertir_datos_BirdNET_plantilla(base_de_datos_sqlite = "BaseDatos_RegistrosBirdNET.sqlite", archivo_plantilla = "plantilla.xlsx") #prueba de llamada con los datos obtenidos


