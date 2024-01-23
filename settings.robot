*** Settings ***
Documentation       Parametros de configuracion para el entorno.

*** Variables ***
# ===================================================================
# Utilidades de Testing
${ABS_ROOT_PATH}                       ${CURDIR}

${TEST_IDENTIFIER_BEGINNING}           PAT-        # Start of Tag to set as Test ID
${TEST_IDENTIFIER_DEVTESTING}          PAT-SYS-     # Test ID for dev testing
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

${EMAIL_RANDOM_USER}     user@gmail.com      # Set with real gmail (for user)
${EMAIL_PASSWORD}        bsgrrzkffmgjwitf    # Set with real aplication password (for user)
${EMAIL_HOST}            imap.gmail.com
${CMS_EMAIL}             patrociniouba1@gmail.com  # Email for CMS

${CMS_ADMIN_USERNAME}        administrator

# ===================================================================
# Selenium

${BROWSER}    chrome
