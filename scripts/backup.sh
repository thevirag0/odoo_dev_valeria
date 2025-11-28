#!/bin/bash
# Script para crear un paquete de backup de datos desde Named Volume, subirlo a GitHub y reiniciar el entorno local.

echo "======================================================="
echo "    PASO 1: INICIANDO COPIA DE SEGURIDAD LOCAL"
echo "======================================================="
set -euo pipefail

# Nombres según tu último docker-compose.yml
PG_CONTAINER="postgres_dev_dam"
ODOO_CONTAINER="odoo_dev_dam"
DB_NAME="odoo"
PG_USER="odoo"
BACKUP_SQL="data/backups/odoo.sql"

echo "==> Parando Odoo para garantizar consistencia..."
docker-compose stop "$ODOO_CONTAINER"

# Comprobar que el contenedor de Postgres está up
if ! docker ps --format '{{.Names}}' | grep -q "^${PG_CONTAINER}$"; then
  echo "==> Arrancando Postgres..."
  docker-compose up -d "$PG_CONTAINER"
fi


echo "==> Creando backup lógico (SQL plano) de la BD '${DB_NAME}'..."
# El dump se genera dentro del contenedor y se escribe en el bind mount /backups => ./data/backups del host
docker exec "$PG_CONTAINER" bash -lc "pg_dump -U '$PG_USER' -d '$DB_NAME' > /backups/odoo.sql"

# Opcional: sincronizar permisos en el host (por si el archivo queda con UID/GID del contenedor)
chmod 600 "$BACKUP_SQL" || true

echo "Backup completado: $BACKUP_SQL"

echo "==> Arrancando Odoo de nuevo..."
docker-compose start "$ODOO_CONTAINER"

exit

# 7. Añadir archivos al staging
echo "-> Añadiendo el nuevo paquete de datos y código a Git..."
sudo git add .

# 8. Realizar el commit
FECHA_BACKUP=$(date +"%Y-%m-%d %H:%M:%S")
echo "-> Creando commit..."
git commit -m "BACKUP AUTOMÁTICO - Datos (Volumen Nombrado) y código actualizados al $FECHA_BACKUP"

# 9. Subir a GitHub
echo "-> Subiendo a GitHub (rama main)..."

git push 

if [ $? -eq 0 ]; then
    echo "======================================================="
    echo " ¡ÉXITO! COPIA DE SEGURIDAD Y SUBIDA COMPLETADAS."
    echo "======================================================="
else
    echo "======================================================="
    echo " ERROR: FALLÓ LA SUBIDA A GITHUB."
    echo "======================================================="
fi