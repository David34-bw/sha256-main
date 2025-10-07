#!/bin/bash

# Carpeta de destino
DESTINO="./imagenes"
DB="./imagenes.db"

# Crear carpeta si no existe
mkdir -p "$DESTINO"

# Crear base de datos y tabla si no existe
sqlite3 $DB "CREATE TABLE IF NOT EXISTS imagenes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT,
    fecha TEXT,
    hora TEXT,
    hash_sha256 TEXT,
    base64 TEXT
);"

# Descargar 20 imágenes diferentes y registrar datos
for i in {1..20}; do
    NOMBRE="imagen$i.jpg"
    RUTA="$DESTINO/$NOMBRE"

    if [ -f "$RUTA" ]; then
        echo "$NOMBRE ya existe, no se descarga de nuevo."
    else
        echo "Descargando $NOMBRE..."
        wget -q "https://picsum.photos/200/300?random=$i" -O "$RUTA"

        # Obtener fecha y hora
        FECHA=$(date +"%Y-%m-%d")
        HORA=$(date +"%H:%M:%S")

        # Calcular SHA256 de (nombre + contenido)
        HASH=$( (echo -n "$NOMBRE" && cat "$RUTA") | sha256sum | awk '{print $1}' )

        # Convertir la imagen a base64
        BASE64=$(base64 -w 0 "$RUTA")

        # Insertar en la base de datos
        sqlite3 $DB "INSERT INTO imagenes (nombre, fecha, hora, hash_sha256, base64) 
                     VALUES ('$NOMBRE', '$FECHA', '$HORA', '$HASH', '$BASE64');"
    fi
done

echo "✅ Listo! 20 imágenes distintas descargadas y registradas en $DB"
