*** Settings ***
Documentation    Keywords utilitarias.

Library  SeleniumLibrary
Library  OperatingSystem    WITH NAME    OS
Library  Collections
Library    python_tools.py/file_handling.py

Resource    ../../settings.robot

*** Keywords ***
Abrir la plataforma en el navegador
    Set Selenium Speed    ${SPEED_SELENIUM}
    Open Browser    ${PAGE_BASE_CMS}   ${BROWSER}
    Maximize Browser Window

Cerrar el navegador
    Close Browser

Obtener locator de la fila '${KEY}' para la tabla con locator ${TABLE_LOCATOR}
    [Documentation]    Dado el locator de la tabla recorre las filas hasta obtener
    ...                la fila que contenga el campo buscado igual a ${KEY}.
    ...                Retorna el Locator de la fila encontrada. Si no la encuentra
    ...                lanza una excepción.
    ${ROW_LIST} =    Get WebElements    ${TABLE_LOCATOR}//tr
    ${NUM_ROWS}    Get Length    ${ROW_LIST}
    FOR    ${INDEX}    IN RANGE    ${NUM_ROWS}
        ${ROW_LOCATOR}    Set Variable    ${TABLE_LOCATOR}/tr[${INDEX+1}]
        ${CONTENT_ROW} =    Get Text    ${ROW_LOCATOR}
        ${IS_CONTAINS}    Run Keyword And Return Status    Should Contain    ${CONTENT_ROW}    ${KEY}
        IF    ${IS_CONTAINS}
            Log    Se encontró la fila con "${KEY}:"
            RETURN    ${ROW_LOCATOR}
        END
    END
    Fatal Error    No se encontró ninguna fila con "${KEY}:"

Verificar fila de la tabla
    [Documentation]    Valida que la fila con locator ${ROW_LOCATOR} de la tabla,
    ...                contenga la key del campo y valor esperado. 
    [Arguments]    ${ROW_LOCATOR}    ${EXPECTED_KEY}    ${EXPECTED_VALUE}
    ${KEY} =    Get Text    ${ROW_LOCATOR}/td[1]
    ${valor} =    Get Text    ${ROW_LOCATOR}/td[2]
    Should Be Equal As Strings    ${KEY}    ${EXPECTED_KEY}
    Should Be Equal As Strings    ${valor}    ${EXPECTED_VALUE}

Obtener el path del archivo descargado '${FILENAME}'
    ${DOWNLOAD_DIRECTORY}    Obtener Directorio de Descarga
    ${FILE_PATH}    Get Latest Matching File    ${DOWNLOAD_DIRECTORY}    ${FILENAME}
    RETURN    ${FILE_PATH}

Obtener Directorio de Descarga
    ${HOME_PATH} =    Get Environment Variable  HOME

    # Verificar si existe un archivo llamado "Descargas" en el directorio HOME
    ${DESCARGAS_EXISTS} =  Run Keyword And Return Status
    ...    File Should Exist  ${HOME_PATH}/Descargas

    IF  ${DESCARGAS_EXISTS}
        ${DOWNLOAD_DIR}    Set Variable  ${HOME_PATH}/Descargas
    ELSE
    # Si no existe "Descargas", se usa supone la carpeta llamada "Downloads"
        ${DOWNLOAD_DIR}    Set Variable  ${HOME_PATH}/Downloads
    END

    RETURN  ${DOWNLOAD_DIR}
