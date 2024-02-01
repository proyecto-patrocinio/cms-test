*** Settings ***
Documentation     Keywords utilizadas bajo el prefijo Then.

Library  SeleniumLibrary
Library  ImapLibrary2
Library  String
Library    XML

Resource  ../settings.robot
Resource  ../constants.robot
Resource  ../library/keywords/database_handling.robot
Resource  ../library/keywords/session.robot
Resource  ../library/keywords/testing_environment.robot
Resource    keywords/utils.robot
Resource    keywords/consultation.robot


*** Keywords ***
Deberı́a recibir un correo electrónico con el enlace de confirmación
    [Documentation]    Abre el buzón de correo, espera y busca el correo electrónico de confirmación.
    ...                Extrae el enlace de confirmación desde el correo y lo almacena en la variable ${EMAIL_LINK}.
    Open Mailbox    host=${EMAIL_HOST}    user=${EMAIL_RANDOM_USER}    password=${EMAIL_RANDOM_USER_PASSWORD}
    ${LATEST} =    Wait For Email   sender=${CMS_EMAIL}   timeout=120
    Sleep    2s
    ${PARTS} =    Walk Multipart Email   ${LATEST}
    FOR    ${i}    IN RANGE    ${PARTS}
        Walk Multipart Email    ${LATEST}
        ${CONTENT-TYPE} =    Get Multipart Content Type
        Continue For Loop If    '${CONTENT-TYPE}' != 'text/html'
        ${PAYLOAD} =    Get Multipart Payload    decode=True
        Should Contain    ${PAYLOAD}    You're receiving this email because you recently registered an account on our site
        ${EMAIL_LINK} =    Extraer link desde html    ${PAYLOAD}
        Set Test Variable    ${EMAIL_LINK}
    END
    Delete Email    ${LATEST}
    Close Mailbox

Deberı́a ser redirigido a la página de inicio de sesión
     [Documentation]    Navega a la página de confirmación utilizando el enlace proporcionado en el correo.
    ...                Espera hasta que la página contenga el texto "Sign In" y captura una pantalla.
    Go To    ${EMAIL_LINK}
    Wait Until Page Contains    Sign In    timeout=10s
    Page Should Contain    Sign In
    Recolectar captura de pantalla

Deberı́a recibir un error al intentar iniciar sesión
    [Documentation]    Intenta iniciar sesión con credenciales incorrectas y verifica que se muestre un mensaje de error.
    ...                Captura una pantalla después de verificar el mensaje de error.
    Iniciar sesion con usuario '${CMS_RANDOM_USER_USERNAME}' y contraseña '${CMS_RANDOM_USER_PASSWORD}'
    ${ERROR_MSG}    Set Variable    The username or password is incorrect.
    Wait Until Page Contains    ${ERROR_MSG}    timeout=10s
    Page Should Contain    ${ERROR_MSG}
    Recolectar captura de pantalla

En la base de datos deberı́a existir el nuevo usuario registrado SIN ACTIVAR
    [Documentation]    Obtiene el nuevo usuario de la base de datos y verifica que no esté activo.
    ${USER_FROM_DB} =    Obtener el nuevo usuario de la DB
    ${IS_ACTIVE} =    Set Variable    ${USER_FROM_DB[9]}
    Should Not Be True    ${IS_ACTIVE}


El usuario "${ROL_USER}" debería poder iniciar sesión en la plataforma con éxito
    Acceder a la plataforma como usuario "${ROL_USER}"
    Wait Until Page Contains    Welcome!
    Page Should Not Contain    Sign in
    Recolectar captura de pantalla

La pestaña "${CMS_PAGE_NAME}" deberı́a estar visible
    [Documentation]    Verifica que la pestaña especificada esté visible en la interfaz del Case Management System (CMS).
    ...                Los valores posibls para ${CMS_PAGE_NAME} son: 'consultancy', 'panel de control', 'boards'
    ${CMS_PAGE_NAME} =    Convert To Lower Case    ${CMS_PAGE_NAME}
    #Espera hasta que se cargue la página HOME
    Wait Until Page Contains    Welcome!
    IF    '${CMS_PAGE_NAME}' == 'consultancy'
        ${XPATH_CONSULTANCY} =    Set Variable    xpath://span[@class='MuiTypography-root MuiTypography-body1 MuiListItemText-primary css-10hburv-MuiTypography-root' and contains(text(),'Consultancy')]
        Element Should Be Visible    ${XPATH_CONSULTANCY}

    ELSE IF    '${CMS_PAGE_NAME}' == 'panel de control'
        ${XPATH_CONTORL_PANEL} =    Set Variable    xpath://span[@class='MuiTypography-root MuiTypography-body1 MuiListItemText-primary css-10hburv-MuiTypography-root' and contains(text(),'Control Panel')]
        Element Should Be Visible    ${XPATH_CONTORL_PANEL}
        Click Element    ${XPATH_CONTORL_PANEL}
        
        ${XPATH_CONSULTATIONS} =    Set Variable    xpath://span[@class='MuiTypography-root MuiTypography-body1 MuiListItemText-primary css-10hburv-MuiTypography-root' and contains(text(),'Consultations')]
        Wait Until Element Is Visible    ${XPATH_CONSULTATIONS}
  
        ${XPATH_CLIENTS} =    Set Variable    xpath://span[@class='MuiTypography-root MuiTypography-body1 MuiListItemText-primary css-10hburv-MuiTypography-root' and contains(text(),'Clients')]
        Wait Until Element Is Visible    ${XPATH_CLIENTS}

    ELSE IF    '${CMS_PAGE_NAME}' == 'boards'
        ${XPATH_BOARDS} =    Set Variable    xpath://div[@class='MuiButtonBase-root MuiListItemButton-root MuiListItemButton-gutters MuiListItemButton-root MuiListItemButton-gutters css-16ac5r2-MuiButtonBase-root-MuiListItemButton-root' and .//span[text()='Boards']]
        Element Should Be Visible    ${XPATH_BOARDS}

    ELSE
        Fatal Error    La opción de pestaña '${CMS_PAGE_NAME}' no esta implementada.  

    END
    Recolectar captura de pantalla

La pestaña "${CMS_PAGE_NAME}" NO deberı́a estar visible
    [Documentation]    Verifica que la pestaña especificada NO esté visible en la interfaz del Case Management System (CMS).
    ...                Los valores posibls para ${CMS_PAGE_NAME} son: 'consultancy', 'panel de control', 'boards'
    ${CMS_PAGE_NAME} =    Convert To Lower Case    ${CMS_PAGE_NAME}
    ${IS_OPTION_VALID} =    Evaluate    '${CMS_PAGE_NAME}' in ['consultancy', 'panel de control', 'boards']
    IF    ${IS_OPTION_VALID} == ${True}
        Run Keyword And Expect Error    Element with locator*    La pestaña "${CMS_PAGE_NAME}" deberı́a estar visible

    ELSE
        Fatal Error    La opción de pestaña '${CMS_PAGE_NAME}' no esta implementada.  

    END

Las pestañas "Consultations" y "Clients" del "Panel de Control" deberı́an estar visibles
    La pestaña "Panel de Control" deberı́a estar visible

Las pestañas "Consultations" y "Clients" del "Panel de Control" no deberı́an estar visibles
     Run Keyword And Expect Error    Element with locator*    La pestaña "Panel de Control" deberı́a estar visible

La consulta "${INPUT_TAG}" para el cliente con DNI "${INPUT_DNI}" deberı́a existir en base de datos
    ${CONSULT} =    Obtener consulta con TAG '${INPUT_TAG}' de la DB
    ${CLIENT_ID} =    Set Variable    ${CONSULT[-1]}
    ${CLIENT} =    Obtener cliente con id '${CLIENT_ID}' de la DB
    ${CLIENT_DNI} =    Set Variable    ${CLIENT[4]}
    Should Be Equal As Integers    ${INPUT_DNI}    ${CLIENT_DNI}

El ticket "${TAG}" deberı́a estar visible en el panel de entrada de la pizarra "${TITLE_BOARD}"
    [Documentation]    Valida que este visible el ticket de la consulta titulada ${TAG}.
    Wait Until Page Contains    ${TITLE_BOARD}
    ${TICKET_LOCATOR} =    Set Variable    xpath=//p[contains(text(), '${TAG}')]
    Element Should Be Visible    ${TICKET_LOCATOR}

La información de la consulta "${TAG}" deberı́a contener el cliente con DNI "${DNI}"
    [Documentation]    Valida que la ventana de información de una consulta titulada ${TAG},
    ...                contenga el cliente con el DNI proporcionado.
    Abrir detalle de la consulta '${TAG}'
    Recolectar captura de pantalla
    ${EXPAND_CLIENT_LOCATOR} =    Set Variable    //button[contains(@class, 'css-1rwt2y5-MuiButtonBase-root')]
    Wait Until Element Is Visible    ${EXPAND_CLIENT_LOCATOR}
    Click Element    ${EXPAND_CLIENT_LOCATOR}

    ${ROW_LOCATOR}    Set Variable    xpath=/html/body/div[4]/div[3]/div/div[2]/div/div/table/tbody/tr[2]/td[2]/div/tr[4]
    Verificar fila de la tabla    ${ROW_LOCATOR}    ID Value:    ${DNI}
    Recolectar captura de pantalla
    Cerrar Info de consulta

La información de la consulta "${TAG}" deberı́a contener el campo "${KEY}" en "${VALUE}"
    [Documentation]    Se abre la ventana de detalle de la consulta y se busca la fila de la tabla de información
    ...                que contiene el campo a validar. Luego se valida que contenga el valor
    ...                correcto y se cierra la ventana.
    Abrir detalle de la consulta '${TAG}'
    ${TABLE_LOCATOR}    Set Variable    xpath=/html/body/div[4]/div[3]/div/div[2]/div/div/table/tbody
    ${ROW_LOCATOR}=    Obtener locator de la fila '${KEY}' para la tabla con locator ${TABLE_LOCATOR}
    Verificar fila de la tabla    ${ROW_LOCATOR}    ${KEY}:    ${VALUE}
    Cerrar Info de consulta

El Popper de la comisión debería contener "${CONTENT}"
    ${POPPER_LOCATOR}    Set Variable    id=transitions-popper
    ${INFO_TEXT}    Get Text    ${POPPER_LOCATOR}
    Should Contain    ${INFO_TEXT}    ${CONTENT}

Debería existir una "request consultation" de la consulta "${CONSULT_TAG}" al board "${BOARD_NAME}" en la DB
    [Documentation]    Obtiene de la base de datos la "request consultation" correspondiente
    ...                a la consulta llamada ${CONSULT_TAG} y corrobora que sea destinada al Board
    ...                llamado  ${BOARD_NAME}.
    ${EXPECT_BOARD_ID}    Obtener el ID del board titulado "${BOARD_NAME}" de la DB
    ${CONSULT}    Obtener consulta con TAG '${CONSULT_TAG}' de la DB
    ${CONSULT_ID}    Set Variable    ${CONSULT}[0]
    ${REQUEST}    Obtener la Request Consultation para la consulta con ID "${CONSULT_ID}"
    ${BOARD_ID_FROM_REQ}    Set Variable    ${REQUEST[1]}
    Should Be Equal As Integers    ${BOARD_ID_FROM_REQ}    ${EXPECT_BOARD_ID}

Debería haberse eliminado la "request consultation" de la consulta "${CONSULT_TAG}" de la DB
    ${CONSULT}    Obtener consulta con TAG '${CONSULT_TAG}' de la DB
    ${CONSULT_ID}    Set Variable    ${CONSULT}[0]
    ${REQUEST}    Obtener la Request Consultation para la consulta con ID "${CONSULT_ID}"
    Should Be Equal    ${REQUEST}    ${None}

El ticket "${CONSULT_TAG}" debería estar en el primer panel "${PANEL_NAME}" de la comisión
    [Documentation]    Supone que el panel esperado es el primer panel INTERNO (no de entrada)
    ...                de la pizarra. Chequea que coincida el titulo del panel con el esperado
    ...                y valida que exista una card con el titulo ${CONSULT_TAG}.
    ...                Esta keyword supone que el panel solo contiene una sola card y ésta es la esperada.
    ${XPATH_PANEL_1}    Set Variable    xpath=//*[@id="root"]/div/div/main/div[2]/main/div/div/div[3]

    ${PANEL_CONTENT}    Get Text    ${XPATH_PANEL_1}
    Should Contain    ${PANEL_CONTENT}    ${PANEL_NAME}

    ${CARD_IN_PANEL_1}    Set Variable    ${XPATH_PANEL_1}/div[2]
    ${CARD_CONTENT}    Get Text    ${CARD_IN_PANEL_1}
    Should Contain    ${CARD_CONTENT}    ${CONSULT_TAG}

El ticket "${CONSULT_TAG}" debería estar en el panel de entrada "${PANEL_NAME}" de la comisión
    [Documentation]    Se valida que en el panel de entrada de la comisión,
    ...                contenga una card titulada ${CONSULT_TAG}.
    ${XPATH_PANEL_1}    Set Variable    xpath=//*[@id="root"]/div/div/main/div[2]/main/div/div/div[1]

    ${PANEL_CONTENT}    Get Text    ${XPATH_PANEL_1}
    Should Contain    ${PANEL_CONTENT}    ${PANEL_NAME}

    ${CARD_IN_PANEL_1}    Set Variable    ${XPATH_PANEL_1}/div/div[2]
    ${CARD_CONTENT}    Get Text    ${CARD_IN_PANEL_1}
    Should Contain    ${CARD_CONTENT}    ${CONSULT_TAG}

El ticket "${CONSULT_TAG}" debería estar en el primer panel "${PANEL_NAME}" del board
    [Documentation]    Se valida que en el panel de entrada del board,
    ...                contenga una card titulada ${CONSULT_TAG}.
    ${XPATH_PANEL_1}    Set Variable    xpath=//*[@id="root"]/div/div/main/div[2]/main/div/div/div/div[3]/div[1]

    ${PANEL_CONTENT}    Get Text    ${XPATH_PANEL_1}
    Should Contain    ${PANEL_CONTENT}    ${PANEL_NAME}

    ${CARD_IN_PANEL_1}    Set Variable    ${XPATH_PANEL_1}/div[2]
    ${CARD_CONTENT}    Get Text    ${CARD_IN_PANEL_1}
    Should Contain    ${CARD_CONTENT}    ${CONSULT_TAG}
