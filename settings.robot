*** Settings ***
Documentation       Parametros de configuracion para el entorno.

*** Variables ***
# ===================================================================
# Utilidades de Testing
${ABS_ROOT_PATH}                       ${CURDIR}

${TEST_IDENTIFIER_BEGINNING}           PAT-        # Comienzo del Tag del ID del Test
${TEST_IDENTIFIER_DEVTESTING}          PAT-SYS-     # ID del Test para testing de desarrollo
@{TEST_ID_BEGINNING_TAGS}                          # Colocados en orden de prioridad
...    ${TEST_IDENTIFIER_BEGINNING}
...    ${TEST_IDENTIFIER_DEVTESTING}

${EVIDENCES_FOLDER}                    ${ABS_ROOT_PATH}/evidences
${TEST_TEMP_FOLDER}                    ${ABS_ROOT_PATH}/tmpWorkdir

# Directorio de recursos.
${RESOURCES_PATH}                      ${ABS_ROOT_PATH}/resources

# ===================================================================
# Base de datos

${DB_NAME}              patrocinio
${DATABASE_USER}        patrocinio_api
${DATABASE_PASSWORD}    patrocinio_password
${DATABASE_IP}          localhost
${DB_PORT}              5432

# ===================================================================
# Backend


# Emails
${EMAIL_HOST}            imap.gmail.com
${CMS_EMAIL}             patrociniouba1@gmail.com  # Email del sistema CMS

${EMAIL_RANDOM_USER}             randomuser@gmail.com      # Setear con email real (para user)
${EMAIL_RANDOM_USER_PASSWORD}    bsgrrzkffmgjwitf    # Setear con contraseña real de aplicación para dicho email (para user)


# Superuser
${CMS_SUPERUSER_USERNAME}        admin
${CMS_SUPERUSER_PASSWORD}        Administrator2023!
${CMS_SUPERUSER_EMAIL}           admin@proyectopatrocinio.com


# ===================================================================
# Docker compose del sistema CMS

${MODE_CMS_UP}            manual    # 'automatic' para levantar el contenedor. 'manual' para levantar el sistema CMS de forma manual.
${DOCKER_COMPOSE_PATH}   /home/juli/Documents/proyecto-patrocinio/com/docker-compose.yml  # Path del Docker compose de la unidad CMS

${FRONT_CONTAINER_NAME}    frontend
${BACK_CONTAINER_NAME}     backend-app

# ===================================================================
# Selenium

${BROWSER}    chrome

# ===================================================================
# Pages

${PAGE_BASE_CMS}      http://localhost:80
${PAGE_SIGNUP}        ${PAGE_BASE_CMS}/signup
${PAGE_ADMIN}         ${PAGE_BASE_CMS}/admin
${PAGE_ADMIN_USER}        ${PAGE_ADMIN}/auth/user
