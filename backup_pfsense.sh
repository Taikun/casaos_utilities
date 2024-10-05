 #!/bin/sh

# Variables
BACKUP_DIR="/cf/conf/backup"
DATE=$(date +%Y-%m-%d)
BACKUP_FILE="config-$DATE.xml"
TRUENAS_USER="truenas ssh user"
TRUENAS_IP="truenas ip"
TRUENAS_PATH=""  # Si el home del usuario es el directorio de backups, puedes dejarlo vacío

# Imprimir variables para depuración
echo "Backup Directory: $BACKUP_DIR"
echo "Backup File: $BACKUP_FILE"
echo "TrueNAS Path: $TRUENAS_PATH"
echo "TrueNAS User: $TRUENAS_USER"
echo "TrueNAS IP: $TRUENAS_IP"

# Crear el directorio de backup si no existe
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Realizar el backup
cp /cf/conf/config.xml "$BACKUP_DIR/$BACKUP_FILE"

# Usar SCP para copiar el archivo de backup a TrueNAS
if [ -z "$TRUENAS_PATH" ]; then
    # Si TRUENAS_PATH está vacío, omitimos la ruta
    scp -i /root/.ssh/id_rsa "$BACKUP_DIR/$BACKUP_FILE" "$TRUENAS_USER@$TRUENAS_IP:"
else
    scp -i /root/.ssh/id_rsa "$BACKUP_DIR/$BACKUP_FILE" "$TRUENAS_USER@$TRUENAS_IP:$TRUENAS_PATH/"
fi

# Eliminar backups locales antiguos (mantener últimos 7 días)
find "$BACKUP_DIR" -type f -name "*.xml" -mtime +7 -exec rm -f {} \;

# Eliminar backups antiguos en TrueNAS (mantener últimos 30 días)
ssh -i /root/.ssh/id_rsa "$TRUENAS_USER@$TRUENAS_IP" "find $TRUENAS_PATH -type f -name '*.xml' -mtime +30 -exec rm -f {} \;"

#Optional to check if cron was executed sucessfully
curl -fsS --retry 3 https://hc-ping.com/<yout key>
