# Case Management System Test

## Prerrequisitos


Se debe contar con un entorno virtual con Python 3.8.18.


Además se debe tener instalado Docker y Docker Compose.
A continuación se nombran las verisones probadas:
* Docker version 25.0.0, build e758fe5
* Docker Compose version v2.24.1


### Crear un entorno virtual:
Por ejemplo con conda:
```bash
conda create -n cms-test python=3.8.18
conda activate cms-test
```


Instala los requisitos del proyecto:
```bash
pip install -r requirements.txt
```
### Configuración
Es muy importante revisar y configurar las variables del archivo `./settings.robot`. Se deberá revisar cada una de las variables y setear los valores correctos.
Para los emails, se deben utilizar emails reales y [contraseñas de aplicación](https://support.google.com/accounts/answer/185833?hl=es-419).


### Levanta el Docker compose de la unidad:
Si se setea la variable `MODE_CMS_UP` en "manual" del archivo `settings.robot`, deberá levantarse la unidad por cuenta propia. A continuación se describen los pasos para levantar la unidad de forma manul.

En algun directorio a convenir, clone el repo de la unidad:
```bash
git clone https://github.com/proyecto-patrocinio/proyecto-patrocinio
```
Actualice los templates ubicados en `proyecto-patrocinio/com/backend/app/templates/account/` para usar HTTP en lugar de HTTPS.

Levanta el entorno Docker Compose de la unidad:
```bash
docker-compose up --build
```

## Uso
Se debe tener el entorno virtual activado y el Docker Compose en ejecución.

Luego Ejecute las pruebas de Robot Framework:
```bash
robot tests/
```
