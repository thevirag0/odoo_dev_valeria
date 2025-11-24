# Preparación para entorno de desarrollo

En primer lugar clonar repositorio base de ejemplo y después:

## Cambios en los fichero de configuración

Una vez hecho el clonado **antes de restauar la base de datos** deben efectuarse cambios en los siguientes ficheros:

- `docker-compose.yml`: Cambiar todas las ocurencias de los nombre de los contenedores
  - por ejemplo, de `odoo_dev_dam` a `odoo_dev_sergio`
  - si se mantiene la raiz del nombre, solo reemplazar `dav` por `sergio`
- `data/odoo_config/odoo.conf`: 
  - En la línea 19, poner el mismo valor que en el fichero anterior en `postgres_dev_dam`
- `script/restore.sh`: actualizar el nombre del volumen (`VOLUME_NAME`)
  - En `"odoo_dev_dam_postgres_data_volume"` cambiar lo anteior a `postgres_` por el nombre de la carpeta del docker compose
  - Por ejemplo: 
    - Si carpeta `/odoo_dev_sergio/` entonces poner `"odoo_dev_sergio_postgres_data_volume"`
    - Si carpeta `/odoo/` entonces poner `"odoo_postgres_data_volume"`
- `script/backup.sh`: actualizar el nombre del volumen (`VOLUME_NAME`) como en el punto anterior


## Copia y restauración

### para restaurar copia

Una vez cambiado todo lo anterior, restaurar

```bash
sudo bash scripts/restore.sh
```


### Para hacer copia

Para guardar los cambios

```bash
sudo bash scripts/backup.sh

git add .
git commit -m "Comentario que sea"
git push
```
