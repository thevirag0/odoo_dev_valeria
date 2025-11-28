
#!/bin/bash
# Restauración segura de la BD Odoo desde un dump SQL plano
# Compatible con docker compose v2 y docker-compose v1

set -euo pipefail

# Detectar comando docker compose
DC="docker compose"

PG_CONTAINER="postgres_dev_dam"
ODOO_CONTAINER="odoo_dev_dam"
DB_NAME="odoo"
PG_USER="odoo"
BACKUP_SQL="./data/backups/odoo.sql"

echo "======================================================="
echo " INICIANDO RESTAURACIÓN SEGURA"
echo "======================================================="

# 1. Comprobar que existe el backup
if [[ ! -f "${BACKUP_SQL}" ]]; then
  echo "ERROR: No se encontró el archivo ${BACKUP_SQL}"
  exit 1
fi

# 2. Parar Odoo
echo "==> Parando Odoo..."
${DC} stop "${ODOO_CONTAINER}"

# 3. Arrancar Postgres si no está activo
if ! docker ps --format '{{.Names}}' | grep -q "^${PG_CONTAINER}$"; then
  echo "==> Arrancando Postgres..."
  ${DC} up -d "${PG_CONTAINER}"
fi

# 4. Esperar a que Postgres esté listo
echo "==> Esperando a que Postgres esté disponible..."
until docker exec "${PG_CONTAINER}" pg_isready -U "${PG_USER}" >/dev/null 2>&1; do
  echo "   -> Postgres aún arrancando, reintentando en 2s..."
  sleep 2
done
echo "✅ Postgres está listo."

# 5. Eliminar BD si existe y recrear vacía
echo "==> Eliminando BD '${DB_NAME}' si existe..."
docker exec "${PG_CONTAINER}" bash -lc "dropdb -U '${PG_USER}' --if-exists '${DB_NAME}'"

echo "==> Creando BD '${DB_NAME}'..."
docker exec "${PG_CONTAINER}" bash -lc "createdb -U '${PG_USER}' '${DB_NAME}'"

# 6. Restaurar desde el SQL plano
echo "==> Restaurando datos desde ${BACKUP_SQL}..."
docker exec -i "${PG_CONTAINER}" psql -U "${PG_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=on < "${BACKUP_SQL}"

echo "✅ Restauración SQL completada en BD '${DB_NAME}'."

# 7. Intentar reiniciar Odoo
echo "==> Arrancando Odoo..."
if ! ${DC} start "${ODOO_CONTAINER}" 2>/dev/null; then
  echo "   -> start falló; recreando contenedores..."
  ${DC} up -d "${PG_CONTAINER}" "${ODOO_CONTAINER}"
fi

echo "======================================================="
echo " ✅ RESTAURACIÓN COMPLETA. Accede a: http://localhost:8069"
echo "======================================================="
