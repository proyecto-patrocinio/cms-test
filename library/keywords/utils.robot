*** Settings ***
Documentation    Keywords utilitarias.

Library  SeleniumLibrary
Library  OperatingSystem

Resource    ../../settings.robot

*** Keywords ***
Abrir la plataforma en el navegador
    Open Browser    ${PAGE_BASE_CMS}   ${BROWSER}

Cerrar el navegador
    Close Browser


Abrir detalle de la consulta '${TAG}'
    [Documentation]    Abre el detalle de la consulta con el Tag proporcionado.
    ${TICKET_LOCATOR} =    Set Variable    xpath=//p[text()='${TAG}']
    Double Click Element    ${TICKET_LOCATOR}
    Wait Until Page Contains    Consultation Details

Cerrar Info de consulta
    [Documentation]    Cierra la ventana de detalle de consulta.
    Click Button    Close



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
