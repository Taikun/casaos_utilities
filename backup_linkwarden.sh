#!/bin/bash
set -e
set -x

# Directorio de datos de Linkwarden (reemplaza con la ruta real)
LINKWARDEN_DATA_DIR="/DATA/AppData/big-bear-linkwarden/data"

# Directorio de backup en TrueNAS
BACKUP_DIR="/mnt/truenas_backups/linkwarden"

# Fecha actual
DATE=$(date +%Y-%m-%d)

# Verificar si el recurso compartido está montado
if ! mountpoint -q /mnt/truenas_backups; then
    echo "El recurso compartido no está montado en /mnt/truenas_backups. Por favor, monta el recurso antes de continuar."
    exit 1
fi

# Crear el directorio de backup si no existe
mkdir -p "$BACKUP_DIR/$DATE"

# Realizar el backup usando rsync sin preservar las fechas de modificación
rsync -av --no-t --delete "$LINKWARDEN_DATA_DIR/" "$BACKUP_DIR/$DATE/"

# Eliminar backups antiguos (mantener últimos 7 días)
find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;
