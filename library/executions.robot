*** Settings ***
Documentation     Keywords utilizadas bajo el prefijo When.

Library  SeleniumLibrary
Library    XML

Resource  ../library/keywords/testing_environment.robot
Resource  ../library/keywords/session.robot
Resource  ../library/keywords/consultation.robot
Resource  ../constants.robot
Resource    keywords/database_handling.robot
Resource    keywords/http_request.robot


*** Keywords ***

Se presiona el botón SignUp
    Click Element    css:button.MuiButton-root
    Recolectar captura de pantalla    signup

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
    Recolectar captura de pantalla    signin_success

Se crea la consulta "${TAG}" con Cliente "${DNI}", oponente "${OPP}" y descripcion "${DESC}"
    Crear la consulta "${TAG}" con Cliente "${DNI}", oponente "${OPP}" y descripcion "${DESC}"

Se navega a la pestaña "Board/${COMISION_TITLE}"
    ${BOARD_ID} =    Obtener el ID del board titulado "${COMISION_TITLE}" de la DB
    Go To    ${PAGE_BOARD}/${BOARD_ID}
    Recolectar captura de pantalla    navegate_board_${COMISION_TITLE}

Se selecciona el botón de información del panel "${COMISION_NAME}"
    ${BOARD_ID}    Obtener el ID del board titulado "${COMISION_NAME}" de la DB
    Click Button    id=board-info-button-${BOARD_ID}
    Wait Until Page Contains    Board Information
    Recolectar captura de pantalla    board_info_${COMISION_NAME}

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
    Recolectar captura de pantalla    request_accepted

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
    Recolectar captura de pantalla    request_created

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
    Recolectar captura de pantalla    request_deleted

Se selecciona la opción rejected del menu del ticket "${TICKET_TAG}"
    [Documentation]    Esta keyword supone que solo existe un único
    ...                ticket en el panel de entrada al board.
    ${XPATH_TICKET}      Set Variable    xpath=//*[@id="root"]/div/div/main/div[2]/main/div/div/div/div[1]/div/div[2]
    ${XPATH_MENU}        Set Variable    ${XPATH_TICKET}/div/div/div/div/div/button
    ${XPATH_REJECTED}    Set Variable    xpath=/html/body/div[4]/div[3]/ul
    Mouse Over    ${XPATH_TICKET}
    Click Element    ${XPATH_MENU}
    Click Element    ${XPATH_REJECTED}
    Recolectar captura de pantalla    menu_ticket
    Wait Until Page Does Not Contain    ${TICKET_TAG}
    Recolectar captura de pantalla    request_rejected

Se descarga el csv de la tabla
    Click Button    Export
    Click Element    xpath=//li[text()="Download as CSV"]
    Recolectar captura de pantalla    download_csv
    Sleep   5s

Se edita el campo "${KEY}" a "${NEW_VALUE}" del ticket "${TAG}"
    [Documentation]    Edita el campo de texto especificado en un ticket cambiando su valor.
    ...                  - KEY: Nombre del campo a editar.
    ...                  - NEW_VALUE: Nuevo valor que se asignará al campo.
    ...                  - TAG: Nombre del ticket.
    # Localizar y abrir el detalle de consulta
    Abrir detalle de la consulta '${TAG}'
    ${TABLE_LOCATOR}    Set Variable    xpath=/html/body/div[4]/div[3]/div/div[2]/div/div/table/tbody
    ${ROW_LOCATOR}=    Obtener locator de la fila '${KEY}' para la tabla con locator ${TABLE_LOCATOR}

    # Click botón edit
    Recolectar captura de pantalla    before_edit_field_${KEY}
    ${EDIT_BUTTON_LOCATOR}    Set Variable    ${ROW_LOCATOR}//button[@id="field-edit-button"]
    Click Element    ${EDIT_BUTTON_LOCATOR}

    # Editar campo
    ${TEXTAREA_LOCATOR}    Set Variable    ${ROW_LOCATOR}//textarea[@id="edit-field-textarea"]
    Clear Element Text    ${TEXTAREA_LOCATOR}    
    Input Text    ${TEXTAREA_LOCATOR}    ${NEW_VALUE}
    Recolectar captura de pantalla    edit_field_${KEY}_to_${NEW_VALUE}

    # Guardar cambios
    ${SAVE_BUTTON_LOCATOR}    Set Variable    ${ROW_LOCATOR}//button[@id="field-save-button"]
    Click Element    ${SAVE_BUTTON_LOCATOR}
    Recolectar captura de pantalla    saved_data

    Se cierra el dialogo de detalle de consulta

Se edita el campo "${KEY}" seleccionando la opción "${NEW_STATE}" del ticket "${TAG}"
    [Documentation]    Edita el campo de tipo 'options' especificado en un ticket seleccionando una nueva opción.
    ...                  - KEY: Nombre del campo a editar.
    ...                  - NEW_STATE: Nueva opción que se seleccionará para el campo.
    ...                  - TAG: Nombre del ticket.
    # Localizar y abrir el detalle de consulta
    Abrir detalle de la consulta '${TAG}'
    ${TABLE_LOCATOR}    Set Variable    xpath=/html/body/div[4]/div[3]/div/div[2]/div/div/table/tbody
    ${ROW_LOCATOR}=    Obtener locator de la fila '${KEY}' para la tabla con locator ${TABLE_LOCATOR}

    # Click botón edit
    ${EDIT_BUTTON_LOCATOR}    Set Variable    ${ROW_LOCATOR}//button
    Click Element    ${EDIT_BUTTON_LOCATOR}

    # Abrir selector
    ${SELECTOR_LOCATOR}    Set Variable    xpath=//div[@aria-haspopup="listbox"]
    Click Element    ${SELECTOR_LOCATOR}

    # Seleccionar nueva opción
    ${NEW_OPTION_LOCATOR}    Set Variable    //li[@data-value="${NEW_STATE}"]
    Click Element    ${NEW_OPTION_LOCATOR} 

    # Guardar cambios
    ${SAVE_BUTTON_LOCATOR}    Set Variable    ${ROW_LOCATOR}//button[.//*[contains(@data-testid, 'SaveIcon')]]

    Click Element    ${SAVE_BUTTON_LOCATOR}

    Se cierra el dialogo de detalle de consulta

Se agrega el comentario "${COMMENT}" al ticket "${TAG}"
    [Documentation]    Abre el detalle de consultas, se mueve a la pestaña de comentarios
    ...    y agrega el nuevo comentario $COMMENT, guarda los cambios y cierra la ventana.
    Abrir detalle de la consulta '${TAG}'
    Click Button    Comments

    ${TEXTAREA_LOCATOR}    Set Variable    xpath=//textarea[@id="outlined-textarea"]
    Input Text    ${TEXTAREA_LOCATOR}    ${COMMENT}
    
    ${DIALOG_LOCATOR}    Set Variable    xpath=//div[@role="dialog"]
    Click Element    ${DIALOG_LOCATOR}//button[@id='add-icon-button']

    Se cierra el dialogo de detalle de consulta

Se elimina el comentario "${COMMENT}" al ticket "${TAG}"
    [Documentation]    Abre el dialogo del detalle de la consulta $TAG,
    ...    selecciona la opción eliminar del menu del comentario $COMMENT.
    ...    Finalmente cierra el dialogo.
    Abrir detalle de la consulta '${TAG}'
    Click Button    Comments

    # Seleccionar el menu
    ${COMMENT_LOCATOR}    Set Variable   xpath=//div[contains(@class, 'MuiCard-root') and .//*[text()='${COMMENT}']]
    Mouse Over    ${COMMENT_LOCATOR}
    ${MENU_LOCATOR}    Set Variable     ${COMMENT_LOCATOR}//button[@aria-label="menu-ticket"]
    Wait Until Element Is Visible    ${MENU_LOCATOR}
    Click Element    ${MENU_LOCATOR}

    ${DELETE_OPTION}    Set Variable    xpath=//li[text()='Delete']
    Click Element    ${DELETE_OPTION}

    Se cierra el dialogo de detalle de consulta

Se edita el comentario "${OLD_COMMENT}" a "${NEW_COMMENT}" al ticket "${TAG}"
    [Documentation]    Abre el dialogo del detalle de la consulta $TAG,
    ...    selecciona la opción de editar del menu del comentario $OLD_COMMENT.
    ...    Edita el comentario a $NEW_COMMENT. Finalmente cierra el dialogo.
    Abrir detalle de la consulta '${TAG}'
    Click Button    Comments

    # Seleccionar el menu
    ${COMMENT_LOCATOR}    Set Variable   xpath=//div[contains(@class, 'MuiCard-root') and .//*[text()='${OLD_COMMENT}']]
    Mouse Over    ${COMMENT_LOCATOR}
    ${MENU_LOCATOR}    Set Variable     ${COMMENT_LOCATOR}//button[@aria-label="menu-ticket"]
    Click Element    ${MENU_LOCATOR}

    # Seleccionar la opción editar
    ${EDITE_OPTION}    Set Variable    xpath=//li[text()='Edit']
    Click Element    ${EDITE_OPTION}
    Sleep    1s

    # Cambiar contenido
    ${TEXTAREA_LOCATOR}    Set Variable    xpath=//textarea[@id="edit-comment-area"]
    Double Click Element    ${TEXTAREA_LOCATOR}
    ${COMMENT_LENGTH}    Get Length    ${OLD_COMMENT}
    Sleep    1s
    FOR    ${LETER}    IN RANGE    ${COMMENT_LENGTH}
        Press Keys    ${TEXTAREA_LOCATOR}    ${LEFT_DELETE}
    END
    Clear Element Text    ${TEXTAREA_LOCATOR}
    Input Text    ${TEXTAREA_LOCATOR}    ${NEW_COMMENT}

    # Guardar cambios
    ${SAVE_BUTTON_LOCATOR}    Set Variable    xpath=//button[@id="comment-edit-confim-button"]
    Click Element    ${SAVE_BUTTON_LOCATOR}
    Se cierra el dialogo de detalle de consulta

Se agrega el evento para hoy al ticket "${TAG}" titulado "${TITLE}" con descripción "${DESCRIPTION}"
    [Documentation]    Abre el dialogo con el calendario de la consulta titlado $TAG, y crea un nuevo evento
    ...    para el día de la fecha, con el titulo $TITLE y la descripción $DESCRIPTION.
    ...    No cierra el dialogo.
    Abrir detalle de la consulta '${TAG}'
    Click Button    Calendar

    ${TODAY_LOCATOR}    Set Variable    xpath=//div[@class="rbc-day-bg rbc-today"]
    Click Element    ${TODAY_LOCATOR}

    Input Text    id=title    ${TITLE}
    Input Text    id=description    ${DESCRIPTION}

    Click Button    Accept

Se elimina el evento "${EVENT_TITLE}" del ticket "${TAG}"
    [Documentation]    Esta keyword supone que el dialogo del detalle de la consulta
    ...    esta visible en la pestaña Calendar.
    ${EVENT_LOCATOR}    Set Variable    xpath=//div[@title="${EVENT_TITLE}"]
    Click Element    ${EVENT_LOCATOR}

    ${TRASH_BUTTON}    Set Variable     xpath=/html/body/div[4]/div[3]/div/div[2]/div/div[2]/button
    Sleep    1s
    Click Element    ${TRASH_BUTTON}
    Sleep    2s

Se crea un nuevo cliente "${CLIENT_NAME}" con DNI "${CLIENT_DNI}"
    @{CLIENT_NAMES}    Split String    ${CLIENT_NAME}
    Click Button    Add record
    Escribir en la tabla de clientes    postal    1111
    Escribir en la tabla de clientes    address    dummy address
    Seleccionar la opción "SINGLE" de la columna "marital_status"
    Seleccionar la opción "HOUSE" de la columna "housing_type"
    Seleccionar la opción "COMPLETE_UNIVERSITY" de la columna "studies"
    Escribir en la tabla de clientes    email    dummy_address@email.com
    Seleccionar la opción "DOCUMENT" de la columna "id_type"
    Escribir en la tabla de clientes    id_value    12345678
    Escribir en la tabla de clientes    first_name    ${CLIENT_NAMES[0]}
    Escribir en la tabla de clientes    last_name    ${CLIENT_NAMES[1]}
    Seleccionar la opción "FEMALE" de la columna "sex"
    Escribir en la tabla de clientes    birth_date    2024-02-06
    Escribir en la tabla de clientes     nationality    Argentina
    Escribir en la tabla de clientes     province    Catamarca
    Escribir en la tabla de clientes     locality    Ancasti
    Escribir en la tabla de clientes    patrimony.employment    dummy employment
    Escribir en la tabla de clientes    patrimony.salary    1111
    Escribir en la tabla de clientes    patrimony.other_income    No
    Escribir en la tabla de clientes    patrimony.amount_other_income    0
    Escribir en la tabla de clientes    patrimony.amount_retirement    0
    Escribir en la tabla de clientes    patrimony.amount_pension    0
    Escribir en la tabla de clientes    patrimony.vehicle    N0
    Escribir en la tabla de clientes    family.partner_salary    0

    Click Element    xpath=//button[@aria-label="Save"]

Seleccionar la opción "${OPTION}" de la columna "${CURRENT_KEY}"
    [Documentation]    Selecciona la opción elegida para campo especificado.
    ...    Esta keyword funciona para columnas de tipo "selector".
    ...    En caso de no encontrar el elemento visible, esta keyword supone la
    ...    variable de test PREV_LOCATOR seteada con el elemento de tipo "text"
    ...    mas cercano del lado izquierdo al elemento deseado.
    ${ROW_LOCATOR}    Set Variable    xpath=//div[contains(@class,"MuiDataGrid-virtualScrollerRenderZone")]
    ${CURRENT_LOCATOR}    Set Variable    ${ROW_LOCATOR}//div[@data-field="${CURRENT_KEY}"]/div

    ${IS_VISIBLE}    Run Keyword And Return Status
    ...    Element Should Be Visible    ${CURRENT_LOCATOR}
    IF    ${IS_VISIBLE}
        Click Element    ${CURRENT_LOCATOR}
    ELSE
        Press Keys    ${PREV_LOCATOR}    ${TAB_KEY}
        Wait Until Element Is Visible    ${CURRENT_LOCATOR}
        Click Element    ${CURRENT_LOCATOR}
    END
    ${OPTION_LOCATOR}    Set Variable    xpath=//li[@data-value="${OPTION}"]
    Wait Until Element Is Visible    ${OPTION_LOCATOR}
    Click Element    ${OPTION_LOCATOR}

Escribir en la tabla de clientes
    [Documentation]    Ingresa un dato en un elemento de la tabla Clients,
    ...    de la página panel de control. Verifica si el elemento esta visible.
    ...    En caso de no estarlo, presiona la tecla tab del elemento anterior
    ...    y vuelve a intentar escribir.
    ...    Simula un scroll a la derecha, si el elemento no es visible.
    ...    Esta keyword, debe utilizarse en orden de izquierda a derecha
    ...    comenzando por primera vez con un elemento visible.
    [Arguments]    ${CURRENT_KEY}    ${VALUE}
    ${CURRENT_LOCATOR}    Set Variable    xpath=//div[@data-field="${CURRENT_KEY}"]//input

    ${IS_VISIBLE}    Run Keyword And Return Status
    ...    Element Should Be Visible    ${CURRENT_LOCATOR}
    IF    ${IS_VISIBLE}
        Input Text    ${CURRENT_LOCATOR}    ${VALUE}
    ELSE
        Press Keys    ${PREV_LOCATOR}    ${TAB_KEY}
        Wait Until Element Is Visible    ${CURRENT_LOCATOR}
        Input Text    ${CURRENT_LOCATOR}    ${VALUE}
    END
    # Se actualiza el ultimo elemento previo.
    ${PREV_LOCATOR} =    Set Variable    ${CURRENT_LOCATOR}
    Set Test Variable    ${PREV_LOCATOR}
