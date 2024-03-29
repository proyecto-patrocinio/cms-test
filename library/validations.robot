*** Settings ***
Documentation     Keywords utilizadas bajo el prefijo Then.

Library  SeleniumLibrary
Library  ImapLibrary2
Library  String
Library  CSVLibrary

Resource  ../settings.robot
Resource  ../constants.robot
Resource  keywords/database_handling.robot
Resource  keywords/session.robot
Resource  keywords/testing_environment.robot
Resource  keywords/utils.robot
Resource  keywords/consultation.robot


*** Keywords ***
Deberia recibir un correo electronico con el enlace de confirmacion
    [Documentation]    Abre el buzon de correo, espera y busca el correo electronico de confirmacion.
    ...                Extrae el enlace de confirmacion desde el correo y lo almacena en la variable ${EMAIL_LINK}.
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

Deberia ser redirigido a la pagina de inicio de sesion
     [Documentation]    Navega a la pagina de confirmacion utilizando el enlace proporcionado en el correo.
    ...                Espera hasta que la pagina contenga el texto "Sign In" y captura una pantalla.
    Go To    ${EMAIL_LINK}
    Wait Until Page Contains    Sign In    timeout=10s
    Page Should Contain    Sign In
    Recolectar captura de pantalla    email_redirect_sigin_page

Deberia recibir un error al intentar iniciar sesion
    [Documentation]    Intenta iniciar sesion con credenciales incorrectas y verifica que se muestre un mensaje de error.
    ...                Captura una pantalla despues de verificar el mensaje de error.
    Iniciar sesion con usuario '${CMS_RANDOM_USER_USERNAME}' y contraseña '${CMS_RANDOM_USER_PASSWORD}'
    ${ERROR_MSG}    Set Variable    The username or password is incorrect.
    Wait Until Page Contains    ${ERROR_MSG}    timeout=10s
    Page Should Contain    ${ERROR_MSG}
    Recolectar captura de pantalla    error_signin

En la base de datos deberia existir el nuevo usuario registrado SIN ACTIVAR
    [Documentation]    Obtiene el nuevo usuario de la base de datos y verifica que no este activo.
    ${USER_FROM_DB} =    Obtener el nuevo usuario de la DB
    ${IS_ACTIVE} =    Set Variable    ${USER_FROM_DB[9]}
    Should Not Be True    ${IS_ACTIVE}


El usuario "${ROL_USER}" deberia poder iniciar sesion en la plataforma con exito
    Acceder a la plataforma como usuario "${ROL_USER}"
    Wait Until Page Contains    Welcome!
    Page Should Not Contain    Sign in
    Recolectar captura de pantalla    signin_success

La pestaña "${CMS_PAGE_NAME}" deberia estar visible
    [Documentation]    Verifica que la pestaña especificada este visible en la interfaz del Case Management System (CMS).
    ...                Los valores posibls para ${CMS_PAGE_NAME} son: 'consultancy', 'panel de control', 'boards'
    ${CMS_PAGE_NAME} =    Convert To Lower Case    ${CMS_PAGE_NAME}
    #Espera hasta que se cargue la pagina HOME
    Wait Until Page Contains    Welcome!
    IF    '${CMS_PAGE_NAME}' == 'consultancy'
        ${XPATH_CONSULTANCY} =    Set Variable    xpath://span[contains(@class,'MuiListItemText-primary') and contains(text(),'Consultancy')]
        Element Should Be Visible    ${XPATH_CONSULTANCY}

    ELSE IF    '${CMS_PAGE_NAME}' == 'panel de control'
        ${XPATH_CONTORL_PANEL} =    Set Variable    xpath://span[contains(@class,'MuiListItemText-primary') and contains(text(),'Control Panel')]
        Element Should Be Visible    ${XPATH_CONTORL_PANEL}
        Click Element    ${XPATH_CONTORL_PANEL}

        ${XPATH_CONSULTATIONS} =    Set Variable    xpath://span[contains(@class,'MuiListItemText-primary') and contains(text(),'Consultations')]
        Wait Until Element Is Visible    ${XPATH_CONSULTATIONS}

        ${XPATH_CLIENTS} =    Set Variable    xpath://span[contains(@class,'MuiListItemText-primary') and contains(text(),'Clients')]
        Wait Until Element Is Visible    ${XPATH_CLIENTS}

    ELSE IF    '${CMS_PAGE_NAME}' == 'boards'
        ${XPATH_BOARDS} =    Set Variable    xpath://div[@class='MuiButtonBase-root MuiListItemButton-root MuiListItemButton-gutters MuiListItemButton-root MuiListItemButton-gutters css-16ac5r2-MuiButtonBase-root-MuiListItemButton-root' and .//span[text()='Boards']]
        Element Should Be Visible    ${XPATH_BOARDS}

    ELSE
        Fatal Error    La opcion de pestaña '${CMS_PAGE_NAME}' no esta implementada.

    END
    Recolectar captura de pantalla    window_${CMS_PAGE_NAME}_visible

La pestaña "${CMS_PAGE_NAME}" NO deberia estar visible
    [Documentation]    Verifica que la pestaña especificada NO este visible en la interfaz del Case Management System (CMS).
    ...                Los valores posibls para ${CMS_PAGE_NAME} son: 'consultancy', 'panel de control', 'boards'
    ${CMS_PAGE_NAME} =    Convert To Lower Case    ${CMS_PAGE_NAME}
    ${IS_OPTION_VALID} =    Evaluate    '${CMS_PAGE_NAME}' in ['consultancy', 'panel de control', 'boards']
    IF    ${IS_OPTION_VALID} == ${True}
        Run Keyword And Expect Error    Element with locator*    La pestaña "${CMS_PAGE_NAME}" deberia estar visible

    ELSE
        Fatal Error    La opcion de pestaña '${CMS_PAGE_NAME}' no esta implementada.  

    END

Las pestañas "Consultations" y "Clients" del "Panel de Control" deberian estar visibles
    La pestaña "Panel de Control" deberia estar visible

Las pestañas "Consultations" y "Clients" del "Panel de Control" no deberian estar visibles
     Run Keyword And Expect Error    Element with locator*    La pestaña "Panel de Control" deberia estar visible

La consulta "${INPUT_TAG}" para el consultante con DNI "${INPUT_DNI}" deberia existir en base de datos
    ${CONSULT} =    Obtener consulta con TAG '${INPUT_TAG}' de la DB
    ${CLIENT_ID} =    Set Variable    ${CONSULT[-1]}
    ${CLIENT} =    Obtener consultante con id '${CLIENT_ID}' de la DB
    ${CLIENT_DNI} =    Set Variable    ${CLIENT[4]}
    Should Be Equal As Integers    ${INPUT_DNI}    ${CLIENT_DNI}

El ticket "${TAG}" deberia estar visible en el panel de entrada de la pizarra "${TITLE_BOARD}"
    [Documentation]    Valida que este visible el ticket de la consulta titulada ${TAG}.
    Wait Until Page Contains    ${TITLE_BOARD}
    ${TICKET_LOCATOR} =    Set Variable    xpath=//p[contains(text(), '${TAG}')]
    Element Should Be Visible    ${TICKET_LOCATOR}

La informacion de la consulta "${TAG}" deberia contener el consultante con DNI "${DNI}"
    [Documentation]    Valida que la ventana de informacion de una consulta titulada ${TAG},
    ...                contenga el consultante con el DNI proporcionado.
    Abrir detalle de la consulta '${TAG}'
    ${EXPAND_CLIENT_LOCATOR} =    Set Variable    //button[contains(@class, 'css-1rwt2y5-MuiButtonBase-root')]
    Wait Until Element Is Visible    ${EXPAND_CLIENT_LOCATOR}
    Recolectar captura de pantalla    content_client_${DNI}_unexpanded
    Click Element    ${EXPAND_CLIENT_LOCATOR}

    ${ROW_LOCATOR}    Set Variable    xpath=/html/body/div[4]/div[3]/div/div[2]/div/div/table/tbody/tr[2]/td[2]/div/tr[4]
    Verificar fila de la tabla    ${ROW_LOCATOR}    ID Value:    ${DNI}
    Recolectar captura de pantalla    content_client_${DNI}_expanded
    Se cierra el dialogo de detalle de consulta

La informacion de la consulta "${TAG}" deberia contener el campo "${KEY}" en "${VALUE}"
    [Documentation]    Se abre la ventana de detalle de la consulta y se busca la fila de la tabla de informacion
    ...                que contiene el campo a validar. Luego se valida que contenga el valor
    ...                correcto y se cierra la ventana.
    Abrir detalle de la consulta '${TAG}'
    ${TABLE_LOCATOR}    Set Variable    xpath=/html/body/div[4]/div[3]/div/div[2]/div/div/table/tbody
    ${ROW_LOCATOR}=    Obtener locator de la fila '${KEY}' para la tabla con locator ${TABLE_LOCATOR}
    Verificar fila de la tabla    ${ROW_LOCATOR}    ${KEY}:    ${VALUE}
    Se cierra el dialogo de detalle de consulta

El Popper de la comision deberia contener "${CONTENT}"
    ${POPPER_LOCATOR}    Set Variable    id=transitions-popper
    ${INFO_TEXT}    Get Text    ${POPPER_LOCATOR}
    Should Contain    ${INFO_TEXT}    ${CONTENT}

Deberia existir una "request consultation" de la consulta "${CONSULT_TAG}" al board "${BOARD_NAME}" en la DB
    [Documentation]    Obtiene de la base de datos la "request consultation" correspondiente
    ...                a la consulta llamada ${CONSULT_TAG} y corrobora que sea destinada al Board
    ...                llamado  ${BOARD_NAME}.
    ${EXPECT_BOARD_ID}    Obtener el ID del board titulado "${BOARD_NAME}" de la DB
    ${CONSULT}    Obtener consulta con TAG '${CONSULT_TAG}' de la DB
    ${CONSULT_ID}    Set Variable    ${CONSULT}[0]
    ${REQUEST}    Obtener la Request Consultation para la consulta con ID "${CONSULT_ID}"
    ${BOARD_ID_FROM_REQ}    Set Variable    ${REQUEST[1]}
    Should Be Equal As Integers    ${BOARD_ID_FROM_REQ}    ${EXPECT_BOARD_ID}

Deberia haberse eliminado la "request consultation" de la consulta "${CONSULT_TAG}" de la DB
    ${CONSULT}    Obtener consulta con TAG '${CONSULT_TAG}' de la DB
    ${CONSULT_ID}    Set Variable    ${CONSULT}[0]
    ${REQUEST}    Obtener la Request Consultation para la consulta con ID "${CONSULT_ID}"
    Should Be Equal    ${REQUEST}    ${None}

El ticket "${CONSULT_TAG}" deberia estar en el primer panel "${PANEL_NAME}" de la comision
    [Documentation]    Supone que el panel esperado es el primer panel INTERNO (no de entrada)
    ...                de la pizarra. Chequea que coincida el titulo del panel con el esperado
    ...                y valida que exista una card con el titulo ${CONSULT_TAG}.
    ...                Esta keyword supone que el panel solo contiene una sola card y esta es la esperada.
    ${XPATH_PANEL_1}    Set Variable    xpath=//*[@id="root"]/div/div/main/div[2]/main/div/div/div[3]

    ${PANEL_CONTENT}    Get Text    ${XPATH_PANEL_1}
    Should Contain    ${PANEL_CONTENT}    ${PANEL_NAME}

    ${CARD_IN_PANEL_1}    Set Variable    ${XPATH_PANEL_1}/div[2]
    ${CARD_CONTENT}    Get Text    ${CARD_IN_PANEL_1}
    Should Contain    ${CARD_CONTENT}    ${CONSULT_TAG}

El ticket "${CONSULT_TAG}" deberia estar en el panel de entrada "${PANEL_NAME}" de la comision
    [Documentation]    Se valida que en el panel de entrada de la comision,
    ...                contenga una card titulada ${CONSULT_TAG}.
    ${XPATH_PANEL_1}    Set Variable    xpath=//*[@id="root"]/div/div/main/div[2]/main/div/div/div[1]

    ${PANEL_CONTENT}    Get Text    ${XPATH_PANEL_1}
    Should Contain    ${PANEL_CONTENT}    ${PANEL_NAME}

    ${CARD_IN_PANEL_1}    Set Variable    ${XPATH_PANEL_1}/div/div[2]
    ${CARD_CONTENT}    Get Text    ${CARD_IN_PANEL_1}
    Should Contain    ${CARD_CONTENT}    ${CONSULT_TAG}

El ticket "${CONSULT_TAG}" deberia estar en el primer panel "${PANEL_NAME}" del board
    [Documentation]    Se valida que en el panel de entrada del board,
    ...                contenga una card titulada ${CONSULT_TAG}.
    ...                Esta keyword supone que solo existe un ticket en el panel.
    ${XPATH_PANEL_1}    Set Variable    xpath=//*[@id="root"]/div/div/main/div[2]/main/div/div/div/div[3]/div[1]

    ${PANEL_CONTENT}    Get Text    ${XPATH_PANEL_1}
    Should Contain    ${PANEL_CONTENT}    ${PANEL_NAME}

    ${CARD_IN_PANEL_1}    Set Variable    ${XPATH_PANEL_1}/div[2]
    ${CARD_CONTENT}    Get Text    ${CARD_IN_PANEL_1}
    Should Contain    ${CARD_CONTENT}    ${CONSULT_TAG}

No deberia existir el ticket "${TITLE}" en el board
    ${TICKET_LOCATOR}    Set Variable    xpath=//div[text()='${TITLE}']
    Should Not Exist    ${TICKET_LOCATOR}

La tabla deberia contener ${EXPECT_NUM_ROWS} filas
    [Documentation]    Valida que la cantidad de filas es la esperada.
    ...                Obtiene la cantidad de filas encontradas contando la
    ...                primera fila con los titulos.
    ...                y verifica que la cantidad encontrada -1 sea igual a la esperada.
    ...                Se setea la variable de test ${EXPECT_NUM_ROWS}.
    ${NUM_ROWS}    SeleniumLibrary.Get Element Count    xpath=//div[@role='row']
    Log    La cantidad de filas es: ${NUM_ROWS}
    ${NUM_ROWS}    Evaluate    ${NUM_ROWS}-1
    Should Be Equal As Integers    ${NUM_ROWS}    ${EXPECT_NUM_ROWS}
    Set Test Variable    ${EXPECT_NUM_ROWS}

La tabla deberia contener la consulta:
    [Documentation]    El primer elemento de la lista deberia
    ...    contener el TAG de la consulta.
    [Arguments]    @{DATA_LIST}
    ${CONSULT}    Obtener consulta con TAG '${DATA_LIST[0]}' de la DB
    ${CONSULT_ID}    Set Variable    ${CONSULT[0]}

    ${CONTENT_ROW}    Obtener el texto de la fila con ID '${CONSULT_ID}'
    Log    FILA: ${CONTENT_ROW}    console=${True}
    FOR    ${DATA}    IN    @{DATA_LIST}
        Should Contain    ${CONTENT_ROW}    ${DATA} 
    END

La tabla deberia contener el consultante:
    [Documentation]    El primer elemento de la lista deberia ser el DNI del consultante.
    [Arguments]    @{DATA_LIST}
    ${CLIENT}    Obtener consultante con id_value '${DATA_LIST[0]}' de la DB
    ${ID_CLIENT}    Set Variable    ${CLIENT[0]}
    ${CONTENT_ROW}    Obtener el texto de la fila con ID '${ID_CLIENT}'
    Log    FILA: ${CONTENT_ROW}    console=${True}
    FOR    ${DATA}    IN    @{DATA_LIST}
        Should Contain    ${CONTENT_ROW}    ${DATA} 
    END

Obtener el texto de la fila con ID '${CONSULT_ID}'
    [Documentation]    Obtiene de la tabla "control panel - consultations" el texto del row con el ID especificado.
    ${ROW_DATA}    Get Text    xpath=//div[@data-id='${CONSULT_ID}']
    RETURN    ${ROW_DATA}

El archivo se deberia haber descargado correctamente
    [Documentation]    Chequea la existencia del archivo descargado.
    ...                Luego chequea que el mismo no este vacio.
    ...                Finalmente mueve el archivo a la carpeta temporal de trabajo
    ...                Y setea el nombre del archivo como variable de entorno FILENAME_DOWNLOAD.
    [Arguments]    ${FILENAME_DOWNLOAD}=data_table_*.csv
    ${FILE_PATH}    Obtener el path del archivo descargado '${FILENAME_DOWNLOAD}'
    File Should Exist    ${FILE_PATH}
    File Should Not Be Empty    ${FILE_PATH}

    ${DOWNLOAD_FILE_PATH}    Set Variable    ${TEST_TEMP_FOLDER}/${FILENAME_DOWNLOAD}
    Move File    ${FILE_PATH}    ${DOWNLOAD_FILE_PATH}
    Set Test Variable    ${DOWNLOAD_FILE_PATH}


El archivo de consultas descargado deberia ser el esperado '${EXPECTED_FILENAME}'
    [Documentation]    Esta keyword, necesita de la variable de test ${EXPECT_NUM_ROWS},
    ...                previamente seteada con la cantidad de filas de la tabla.
    ${EXPECTED_FILE_PATH}    Set Variable    ${RESOURCES_PATH}/${EXPECTED_FILENAME}
    @{EXPECTED_TABLE}    read csv file to associative    ${EXPECTED_FILE_PATH}    delimiter=;

    @{DOWNLOAD_TABLE}    read csv file to associative     ${DOWNLOAD_FILE_PATH}    delimiter=;

    FOR    ${INDEX}    IN RANGE    ${EXPECT_NUM_ROWS}
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Availability State]    ${DOWNLOAD_TABLE}[${INDEX}][Availability State]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Progress State]        ${DOWNLOAD_TABLE}[${INDEX}][Progress State]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Description]           ${DOWNLOAD_TABLE}[${INDEX}][Description]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Opponent]              ${DOWNLOAD_TABLE}[${INDEX}][Opponent]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Client]                ${DOWNLOAD_TABLE}[${INDEX}][Client]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Tag]                   ${DOWNLOAD_TABLE}[${INDEX}][Tag]
    END

El archivo de consultantes descargado deberia ser el esperado '${EXPECTED_FILENAME}'
    [Documentation]    Esta keyword, necesita de la variable de test ${EXPECT_NUM_ROWS},
    ...                previamente seteada con la cantidad de filas de la tabla.
    ${EXPECTED_FILE_PATH}    Set Variable    ${RESOURCES_PATH}/${EXPECTED_FILENAME}
    @{EXPECTED_TABLE}    read csv file to associative    ${EXPECTED_FILE_PATH}    delimiter=;

    @{DOWNLOAD_TABLE}    read csv file to associative     ${DOWNLOAD_FILE_PATH}    delimiter=;

    FOR    ${INDEX}    IN RANGE  ${EXPECT_NUM_ROWS}
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Postal]    ${DOWNLOAD_TABLE}[${INDEX}][Postal]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Address]        ${DOWNLOAD_TABLE}[${INDEX}][Address]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Marital Status]           ${DOWNLOAD_TABLE}[${INDEX}][Marital Status]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Housing Type]              ${DOWNLOAD_TABLE}[${INDEX}][Housing Type]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Education Level]                ${DOWNLOAD_TABLE}[${INDEX}][Education Level]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Email]                   ${DOWNLOAD_TABLE}[${INDEX}][Email]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][ID Type]                   ${DOWNLOAD_TABLE}[${INDEX}][ID Type]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][ID Value]                   ${DOWNLOAD_TABLE}[${INDEX}][ID Value]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][First Name]                   ${DOWNLOAD_TABLE}[${INDEX}][First Name]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Last Name]                   ${DOWNLOAD_TABLE}[${INDEX}][Last Name]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Birth Date]                   ${DOWNLOAD_TABLE}[${INDEX}][Birth Date]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Sex]                   ${DOWNLOAD_TABLE}[${INDEX}][Sex]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Nationality]                   ${DOWNLOAD_TABLE}[${INDEX}][Nationality]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Province]                   ${DOWNLOAD_TABLE}[${INDEX}][Province]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Locality]                   ${DOWNLOAD_TABLE}[${INDEX}][Locality]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Phone Numbers]                   ${DOWNLOAD_TABLE}[${INDEX}][Phone Numbers]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Employment]                   ${DOWNLOAD_TABLE}[${INDEX}][Employment]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Other Incomet]                   ${DOWNLOAD_TABLE}[${INDEX}][Other Incomet]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Amount Other Incomet]                   ${DOWNLOAD_TABLE}[${INDEX}][Amount Other Incomet]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Amount Retirement]                   ${DOWNLOAD_TABLE}[${INDEX}][Amount Retirement]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Amount Pension]                   ${DOWNLOAD_TABLE}[${INDEX}][Amount Pension]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Vehicle]                   ${DOWNLOAD_TABLE}[${INDEX}][Vehicle]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Partner Salary]                   ${DOWNLOAD_TABLE}[${INDEX}][Partner Salary]
        Should Be Equal As Strings    ${EXPECTED_TABLE}[${INDEX}][Children]                   ${DOWNLOAD_TABLE}[${INDEX}][Children]
    END

Se crea el filtro "${FILTER_TYPE}" con "${FILTER_TEXT}"
    [Documentation]    Selecciona el menu de la columna correspondiente a ${FILTER_TYPE}.
    ...                Luego, selecciona la opcion FILTER, e ingresa el valor de
    ...                ${FILTER_TEXT} como filtro de busqueda.
    ${XPATH_COLUMN}    Set Variable    xpath=//div[@aria-label="${FILTER_TYPE}"]
    Mouse Over    ${XPATH_COLUMN}
    ${LOCATOR_MENU}    Set Variable    ${XPATH_COLUMN}//button[@aria-label="Menu"]
    Click Element    ${LOCATOR_MENU}

    ${XPATH_FILTER_OPTION}    Set Variable    xpath=//span[text()='Filter']
    Click Element    ${XPATH_FILTER_OPTION}

    ${XPATH_INPUT}    Set Variable    xpath=//input[@placeholder="Filter value"]
    Input Text    ${XPATH_INPUT}    ${FILTER_TEXT}
    Sleep    1s

La vista de comentarios de la consulta "${TAG}" deberia contener "${COMMENT}"
    Abrir detalle de la consulta '${TAG}'
    Click Button    Comments

    Element Should Be Visible    xpath=//p[text()="${COMMENT}"]

    Se cierra el dialogo de detalle de consulta

El comentario "${COMMENT}" para la consulta "${TAG}" deberia existir en la DB
    ${COMMENT} =    Obtener el comentario "${COMMENT}" de la DB
    ${CONSULT_ID_FROM_COMMENT}    Set Variable    ${COMMENT[3]}

    ${CONSULT}    Obtener consulta con TAG '${TAG}' de la DB
    ${EXPECTED_CONSULT_ID}    Set Variable    ${CONSULT[0]}

    Should Be Equal As Integers    ${EXPECTED_CONSULT_ID}    ${CONSULT_ID_FROM_COMMENT}

La vista de comentarios de la consulta "${TAG}" NO deberia contener "${COMMENT}"
    Run Keyword And Expect Error
    ...    *
    ...    La vista de comentarios de la consulta "${TAG}" deberia contener "${COMMENT}"
    Se cierra el dialogo de detalle de consulta


El comentario "${COMMENT}" para la consulta "${TAG}" NO deberia existir en la DB
    Run Keyword And Expect Error
    ...    *
    ...    El comentario "${COMMENT}" para la consulta "${TAG}" deberia existir en la DB

La vista calendario de la consulta "${TAG}" deberia contener el evento "${EVENT_TITLE}" el dia de la fecha
    [Documentation]    Esta keyword supone que el dialogo de detalle de la consulta se encuentra presente,
    ...                con la pestaña Calendar visible.
    ${EVENT_LOCATOR}    Set Variable    xpath=//div[@title="${EVENT_TITLE}"]
    Wait Until Element Is Visible    ${EVENT_LOCATOR}

El evento "${EVENT_TITLE}" hoy para la consulta "${TAG}" y descripcion "${EXPECT_DESCRIPT}" deberia existir en la DB
    ${CONSULT}    Obtener consulta con TAG '${TAG}' de la DB
    ${CONSULT_ID}    Set Variable    ${CONSULT[0]}
    ${EVENT}    Obtener el evento "${EVENT_TITLE}" de la card con ID ${CONSULT_ID} en DB
    ${DESCRIPT_FROM_DB}    Set Variable    ${EVENT[2]}
    Should Be Equal As Strings    ${DESCRIPT_FROM_DB}    ${EXPECT_DESCRIPT}

La vista calendario de la consulta "${TAG}" NO deberia contener el evento "${EVENT_TITLE}"
    Run Keyword And Expect Error
    ...    *
    ...    La vista calendario de la consulta "${TAG}" deberia contener el evento "${EVENT_TITLE}" el dia de la fecha

El boton calendario deberia estar desactivado
    Run Keyword And Expect Error
    ...    *
    ...    Click Button    Calendar

No deberia existir el evento "${EVENT_TITLE}" para la consulta "${TAG}" en la DB
    ${CONSULT}    Obtener consulta con TAG '${TAG}' de la DB
    ${CONSULT_ID}    Set Variable    ${CONSULT[0]}
    ${EVENT}    Obtener el evento "${EVENT_TITLE}" de la card con ID ${CONSULT_ID} en DB
    Should Be Equal    ${EVENT}    ${None}

El consultante con DNI "${DNI}" deberia existir en DB
    ${CLIENT}    Obtener consultante con id_value '${DNI}' de la DB
    Should Not Be Empty    ${CLIENT}

El consultante con DNI "${DNI}" NO deberia existir la DB
    ${CLIENT}    Obtener consultante con id_value '${DNI}' de la DB
    Should Be Equal    ${CLIENT}    ${None}

El campo "${FIELD}" del consultante con DNI "${DNI}" deberia ser "${EXPECTED_VALUE}" en DB
    ${DATA_DB}    Obtener el campo "${FIELD}" del consultante con id_value '${DNI}' de la DB
    Should Be Equal As Integers    ${DATA_DB[0]}    ${EXPECTED_VALUE}
