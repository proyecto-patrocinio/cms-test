*** Settings ***
Documentation    Keywords para el manejo de http rquest.

Library    RequestsLibrary    WITH NAME    Req

Resource  ../../settings.robot
Resource    database_handling.robot


*** Keywords ***
# ======================================================================
# Solicutudes generales
Enviar un Post a la API
    [Documentation]    Se ejecuta request para enviar un Post a la URL
    ...                y el Body proporcionado. Además se deberá proporcionar
    ...                el Token de autorización de la sesión.
    [Arguments]    ${TOKEN}    ${URL}    ${BODY}
    ${HEADERS} =    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Token ${TOKEN}
    ${STATUS} =     Run Keyword And Ignore Error
    ...     Req.POST    url=${URL}    json=${BODY}    headers=${HEADERS}
    RETURN    ${STATUS}

Enviar un Delete a la API
    [Documentation]    Se ejecuta request para enviar un Delete a la URL
    ...                proporcionada. Además se deberá proporcionar
    ...                el Token de autorización de la sesión.
    [Arguments]    ${TOKEN}    ${URL}
    ${HEADERS} =    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Token ${TOKEN}
    ${STATUS} =     Run Keyword And Ignore Error
    ...     Req.DELETE    url=${URL}    headers=${HEADERS}
    RETURN    ${STATUS}

# ======================================================================
# Solicitudes particulares
Aceptar la solicitud de asignación de consulta
    [Documentation]    Acepta la solicitud de asignación con el ID ${REQUEST_ID}
    ...                enviado al Panel con ID ${PANEL_ID} utilizando la última
    ...                sesión creada.
    [Arguments]    ${REQUEST_ID}    ${PANEL_ID}
    ${USER_TOKEN}    Obtener el token de la última sesion
    ${URL_ACCEPT}    Set Variable    ${API_REQ_CONSULT}/${REQUEST_ID}/accepted/
    ${BODY}    Create Dictionary    destiny_panel    ${PANEL_ID}
    ${STATUS} =    Enviar un Post a la API    ${USER_TOKEN}    ${URL_ACCEPT}    ${BODY}
    RETURN    ${STATUS}

Crear la solicitud de asignación de consulta
    [Documentation]    Crea la solicitud de asignación de la consulta
    ...                con ID ${CONSULT_ID} enviado al Board con
    ...                ID ${BOARD_ID} utilizando la última sesión creada.
    [Arguments]    ${CONSULT_ID}    ${BOARD_ID}
    ${USER_TOKEN}    Obtener el token de la última sesion
    ${BODY}    Create Dictionary
    ...    consultation    ${CONSULT_ID}
    ...    destiny_board    ${BOARD_ID}
    ${STATUS} =    Enviar un Post a la API    ${USER_TOKEN}    ${API_REQ_CONSULT}/    ${BODY}
    RETURN    ${STATUS}

Eliminar la solicitud de asignación con ID "${CONSULT_ID}"
    ${USER_TOKEN}    Obtener el token de la última sesion
    ${STATUS} =    Enviar un Delete a la API    ${USER_TOKEN}    ${API_REQ_CONSULT}/${CONSULT_ID}
    RETURN    ${STATUS}

La respuesta obtenida en la peticion deberia ser exitosa
    [Documentation]    Verifica que el status code obtenido sea
    ...                satisfactorio (200, 202, 201, 204).
    [Arguments]    ${SUCCESS_MSG}
    ${SUCCESS_MSG} =    Convert To String    ${SUCCESS_MSG}
    @{SUCCESSFUL_STATUSES}    Create List    200    201    202    204
    ${IS_CONTAINED} =    Set Variable    False
    FOR    ${STATUS_CODE}    IN    @{SUCCESSFUL_STATUSES}
        ${IS_CONTAINED} =    Run Keyword And Return Status
        ...    Should Contain    ${SUCCESS_MSG}    ${STATUS_CODE}
        IF    ${IS_CONTAINED} == True
            BREAK
        END
    END
    Should Be True    ${IS_CONTAINED}
