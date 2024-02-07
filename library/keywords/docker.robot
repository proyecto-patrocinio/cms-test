*** Settings ***
Documentation    Keywords para manejo de contenedores docker.

Library  OperatingSystem    WITH NAME    OS
Library    Collections
Library    SeleniumLibrary

Resource  ../../settings.robot

*** Keywords ***

# =============================================================================
# Ejecucion de Contenedores

Se inician los contenedores del CMS
    [Documentation]    Se levanta el sistema Case Management System, desde un docker compose
    ...                Ubicado en ${DOCKER_COMPOSE_PATH}
    IF    '${MODE_CMS_UP}' == 'automatic'
        Log to Console    Ejecutando Docker Compose...
        ${DOCKER_EXEC_COMMAND} =    Set Variable    docker compose -f ${DOCKER_COMPOSE_PATH} up --build -d

        Log    ${DOCKER_EXEC_COMMAND}    console=True
        Ejecutar el siguiente comando    ${DOCKER_EXEC_COMMAND}
        Wait Until Keyword Succeeds
        ...    90s
        ...    2s
        ...    Chequear los contenedores de CMS esten listos
        Sleep    2s
    ELSE
        Log    El sistema CMS se supone levantado de forma manual...
    END


Se paran los contenedores del CMS
    IF    '${MODE_CMS_UP}' == 'automatic'
        ${DOCKER_EXEC_COMMAND} =    Set Variable    docker compose -f ${DOCKER_COMPOSE_PATH} stop
        Log    ${DOCKER_EXEC_COMMAND}    console=True
        Ejecutar el siguiente comando    ${DOCKER_EXEC_COMMAND}
    END

# =============================================================================
# Utils

Ejecutar el siguiente comando
    [Documentation]    Se espera como argumento el mensaje listo para ejecutar,
    ...                se valida la correcta ejecucion del comando deseado.
    [Arguments]    ${INPUT_CMD}
    ${RC}   ${OUTPUT} =     OS.Run And Return Rc And Output     ${INPUT_CMD}
    Run Keyword If    ${RC}!=${0}
    ...    Fail    Error al ejecutar el comando ${INPUT_CMD}. RC=${RC}, Output:"${OUTPUT}"
    Sleep    2s

Chequear los contenedores de CMS esten listos
    [Documentation]    Se chequea que los contenedores backend y frontend del
    ...                sistema CMS se encuentren corriendo.
    ${STATUS_FRONT} =    Chequear si el contenedor '${FRONT_CONTAINER_NAME}' esta listo
    ${STATUS_BACK} =    Chequear si el contenedor '${BACK_CONTAINER_NAME}' esta listo
    ${ALL_STATUS}    Evaluate    $STATUS_FRONT and $STATUS_BACK
    RETURN    ${ALL_STATUS}

Chequear si el contenedor '${CONTAINER_NAME}' esta listo
    [Documentation]     Chequea que el estado del contenedor sea "healthy".
    ${RC}   ${HEALTH_STATUS} =     OS.Run And Return Rc And Output    docker inspect --format '{{.State.Running}}' ${CONTAINER_NAME}
    Run Keyword If    ${RC} == 0 and '${HEALTH_STATUS}' == 'healthy'    Log    Se levanto con exito el contenedor '${CONTAINER_NAME}'    console=True
    ${STATUS}    Evaluate    $RC == 0 and '$HEALTH_STATUS' == 'healthy'
    RETURN    ${STATUS}

Copiar el archivo '${FILENAME}' al contenedor '${CONTAINER_NAME}'
    [Documentation]    Copia un archivo en la raiz del de directorio del contenedor especificado.
    ${CMD_DOCKER_CP}    Set Variable    docker cp ${RESOURCES_PATH}/${FILENAME} ${CONTAINER_NAME}:/${FILENAME}
    Ejecutar el siguiente comando    ${CMD_DOCKER_CP}

Cargar los datos del archivo json '${FILENAME}' a la unidad
    [Documentation]    Carga a la base de datos, a traves de django, los datos contenidos en el json.
    Copiar el archivo '${FILENAME}' al contenedor '${BACK_CONTAINER_NAME}'
    ${CMD_DOCKER_LOADDATA}    Set Variable    docker exec -it ${BACK_CONTAINER_NAME} python manage.py loaddata /${FILENAME}
    Ejecutar el siguiente comando    ${CMD_DOCKER_LOADDATA}
