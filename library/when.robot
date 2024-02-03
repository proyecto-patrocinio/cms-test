*** Settings ***
Documentation     Keywords utilizadas bajo el prefijo When.

Library  SeleniumLibrary

Resource  ../library/keywords/testing_environment.robot
Resource  ../library/keywords/session.robot
Resource  ../library/keywords/consultation.robot
Resource  ../constants.robot
Resource    keywords/database_handling.robot
Resource    keywords/http_request.robot


*** Keywords ***

Se presiona el botón SignUp
    Click Element    css:button.MuiButton-root
    Recolectar captura de pantalla

Se edita el estado del usuario "${USERNAME}" a "${NEW_STATE}"
    [Documentation]    Edita el estado del usuario a activo o desactivo,
    ...                según ${NEW_STATE} desde la pagina de administración.
    ...                Los valores posibles para ${USERNAME} son:
    ...                - administrador: usuario administrador utiliza las claves $CMS_SUPERUSER_USERNAME/PASSWORD
    ...                - profesor: usuario administrador utiliza las claves $CMS_PROFESSOR_USER_USERNAME/PASSWORD
    ...                - tomador de caso: usuario administrador utiliza las claves $CMS_CASE_TAKER_USER_USERNAME/PASSWORD
    ...                - Cualquier otro valor es considerado como usuario random. Utiliza las claves $CMS_RANDOM_USER_USERNAME/PASSWORD
    ${USERNAME}    Convert To Lower Case    ${USERNAME}
    ${NEW_STATE}    Convert To Lower Case    ${NEW_STATE}
    IF    '${USERNAME}' == 'administrador'
        Editar el estado del usuario "admin" a "${NEW_STATE}"
    ELSE IF    '${USERNAME}' == 'profesor'
        Editar el estado del usuario "${CMS_PROFESSOR_USER_USERNAME}" a "${NEW_STATE}"
    ELSE IF    '${USERNAME}' == 'tomador de caso'  
        Editar el estado del usuario "${CMS_CASE_TAKER_USER_USERNAME}" a "${NEW_STATE}"
    ELSE 
        Editar el estado del usuario "${CMS_RANDOM_USER_USERNAME}" a "${NEW_STATE}"
    END

Se desloguea de la página de administración
    Desloguearse de la administración
    Go To    ${PAGE_BASE_CMS}
    Desloguearse de la plataforma

Se accede a la plataforma como el usuario "${ROL_USER}"
    Acceder a la plataforma como usuario "${ROL_USER}"
    Recolectar captura de pantalla

Se crea la consulta "${TAG}" con Cliente "${DNI}", oponente "${OPP}" y descripcion "${DESC}"
    Crear la consulta "${TAG}" con Cliente "${DNI}", oponente "${OPP}" y descripcion "${DESC}"

Se navega a la pestaña "Board/${COMISION_TITLE}"
    ${BOARD_ID} =    Obtener el ID del board titulado "${COMISION_TITLE}" de la DB
    Go To    ${PAGE_BOARD}/${BOARD_ID}
    Recolectar captura de pantalla

Se selecciona el botón de información del panel "${COMISION_NAME}"
    ${BOARD_ID}    Obtener el ID del board titulado "${COMISION_NAME}" de la DB
    Click Button    id=board-info-button-${BOARD_ID}
    Wait Until Page Contains    Board Information
    Recolectar captura de pantalla

Se acepta la solicitud de asignación de consulta "${CONSULT_TAG}" y se asigna al panel "${PANEL_NAME}"
    [Documentation]    Se obtienen los ID de la consulta y del Panel y se envía un Post a la API Rest
    ...                para aceptar la Request Consultatión y asignar la card en el panel proporcionado.
    ${PANEL_ID}    Obtener el ID del panel titulado "${PANEL_NAME}"
    ${CONSULT}    Obtener consulta con TAG '${CONSULT_TAG}' de la DB
    ${CONSULT_ID}    Set Variable    ${CONSULT}[0]
    # Request ID == Consultation ID.
    ${RESPONSE} =    Aceptar la solicitud de asignación de consulta
    ...    ${CONSULT_ID}    ${PANEL_ID}
    La respuesta obtenida en la peticion deberia ser exitosa    ${RESPONSE}
    # Se actualiza la página
    Reload Page
    Wait Until Page Contains    ${CONSULT_TAG}    timeout=10s
    Recolectar captura de pantalla

Se crea la solicitud de asignación de consulta "${CONSULT_TAG}" a la comisión "${BOARD_NAME}"
    [Documentation]    Se obtienen los ID de la consulta y del board y se envía un POST a la API Rest
    ...                para crear una Request Consultation, de dicha consulta para dicho board.
    ...                Luego actualiza la página.
    ${BOARD_ID}    Obtener el ID del board titulado "${BOARD_NAME}" de la DB
    ${CONSULT}    Obtener consulta con TAG '${CONSULT_TAG}' de la DB
    ${CONSULT_ID}    Set Variable    ${CONSULT}[0]
    ${RESPONSE} =    Crear la solicitud de asignación de consulta
    ...    ${CONSULT_ID}    ${BOARD_ID}
    La respuesta obtenida en la peticion deberia ser exitosa    ${RESPONSE}
    # Se actualiza la página
    Reload Page
    Wait Until Page Contains    ${BOARD_NAME}    timeout=10s
    Recolectar captura de pantalla

Se elimina la solicitud de asignación de consulta "${CONSULT_TAG}"
    [Documentation]    Se obtienen los ID de la consulta y se envía un DELETE a la API Rest
    ...                para eliminar una Request Consultation, de dicha consulta.
    ...                Luego actualiza la página.
    ${CONSULT}    Obtener consulta con TAG '${CONSULT_TAG}' de la DB
    ${CONSULT_ID}    Set Variable    ${CONSULT}[0]
    ${RESPONSE} =    eliminar la solicitud de asignación con ID "${CONSULT_ID}"
    La respuesta obtenida en la peticion deberia ser exitosa    ${RESPONSE}
    # Se actualiza la página
    Reload Page
    Wait Until Page Contains    ${CONSULT_TAG}    timeout=10s
    Recolectar captura de pantalla

Se selecciona la opción rejected del menu del ticket "${TICKET_TAG}"
    [Documentation]    Esta keyword supone que solo existe un único
    ...                ticket en el panel de entrada al board.
    ${XPATH_TICKET}      Set Variable    xpath=//*[@id="root"]/div/div/main/div[2]/main/div/div/div/div[1]/div/div[2]
    ${XPATH_MENU}        Set Variable    ${XPATH_TICKET}/div/div/div/div/div/button
    ${XPATH_REJECTED}    Set Variable    xpath=/html/body/div[4]/div[3]/ul
    Mouse Over    ${XPATH_TICKET}
    Click Element    ${XPATH_MENU}
    Click Element    ${XPATH_REJECTED}
    Recolectar captura de pantalla
    Wait Until Page Does Not Contain    ${TICKET_TAG}
    Recolectar captura de pantalla

Se descarga el csv de la tabla
    Click Button    Export
    Click Element    xpath=//li[text()="Download as CSV"]
    Recolectar captura de pantalla
    Sleep   5s
