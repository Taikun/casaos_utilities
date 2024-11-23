#!/bin/bash
set -e
set -x

# Directorio de datos de Siyuan
SIYUAN_DATA_DIR="/DATA/AppData/siyuan-note/workspace"

# Directorio de backup en TrueNAS
BACKUP_DIR="/mnt/truenas_backups/siyuan"

# Verificar si el recurso compartido está montado
if ! mountpoint -q /mnt/truenas_backups; then
    echo "El recurso compartido no está montado en /mnt/truenas_backups. Por favor, monta el recurso antes de continuar."
    exit 1
fi

# Comprobar si hay backups disponibles
if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR")" ]; then
    echo "No hay backups disponibles en $BACKUP_DIR."
    exit 1
fi

# Mostrar las fechas disponibles
echo "Backups disponibles:"
BACKUPS=($(ls -1 "$BACKUP_DIR" | sort))
for i in "${!BACKUPS[@]}"; do
    echo "$i) ${BACKUPS[i]}"
done

# Pedir al usuario que seleccione una fecha
echo -n "Elige una fecha de backup (número): "
read -r SELECTION

if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 0 ] || [ "$SELECTION" -ge "${#BACKUPS[@]}" ]; then
    echo "Selección inválida. Abortando."
    exit 1
fi

SELECTED_DATE="${BACKUPS[$SELECTION]}"
echo "Restaurando desde el backup de la fecha: $SELECTED_DATE"

# Verificar si existe el directorio seleccionado
BACKUP_TO_RESTORE="$BACKUP_DIR/$SELECTED_DATE"
if [ ! -d "$BACKUP_TO_RESTORE" ]; then
    echo "El backup seleccionado no existe: $BACKUP_TO_RESTORE"
    exit 1
fi

# Restaurar el backup
rsync -av --delete "$BACKUP_TO_RESTORE/" "$SIYUAN_DATA_DIR/"

echo "Restauración completada desde $BACKUP_TO_RESTORE a $SIYUAN_DATA_DIR."
