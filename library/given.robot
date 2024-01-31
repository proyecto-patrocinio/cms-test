*** Settings ***
Documentation     Keywords utilizadas bajo el prefijo Given.

Library  SeleniumLibrary
Library  ImapLibrary2
Library  String
Library  DatabaseLibrary
Library  OperatingSystem
Library  JSONLibrary
Library  Collections

Resource  ../settings.robot
Resource  ../constants.robot
Resource  ../library/keywords/database_handling.robot
Resource  ../library/keywords/docker.robot
Resource  ../library/keywords/testing_environment.robot

*** Keywords ***
Se accedió a la página "SignUp"
    [Documentation]    Navega a la página de registro "SignUp".
    ...                Supone browser abierto.
    Go To    ${PAGE_SIGNUP}

Se completó el formulario con los datos del usuario
    [Documentation]    Completa el formulario de registro con los datos del usuario.
    ...                Utiliza los valores de las variables ${CMS_RANDOM_USER_USERNAME},
    ...                ${EMAIL_RANDOM_USER}, y ${CMS_RANDOM_USER_PASSWORD}.
    Input Text    name:username    ${CMS_RANDOM_USER_USERNAME}
    Input Text    name:email    ${EMAIL_RANDOM_USER}
    Input Text    name:password    ${CMS_RANDOM_USER_PASSWORD}
    Input Text    name:password2    ${CMS_RANDOM_USER_PASSWORD}

Se aceptaron los términos y condiciones
    [Documentation]    Hace clic en el elemento que representa la aceptación de los términos y condiciones.
    Click Element   css:input.PrivateSwitchBase-input

Existe un superusuario administrador
    Cargar los datos del archivo json 'dump-admin.json' a la unidad

Existe un usuario registrado sin activar
    Cargar los datos del archivo json 'dump-inactive-randomuser.json' a la unidad

Existe un usuario registrado activo con permisos "common" y "${GROUP_USER}" en la DB
    ${GROUP_USER} =    Convert To Lower Case    ${GROUP_USER}
    IF    '${GROUP_USER}' == 'case_taker'
        Cargar los datos del archivo json 'dump-case-taker.json' a la unidad
    ELSE IF    '${GROUP_USER}' == 'professor'
        Cargar los datos del archivo json 'dump-professor.json' a la unidad
    ELSE
        Fatal Error    La opción de grupo '${GROUP_USER}' no esta implementada.
    END

Se accedió a la plataforma como usuario "${ROL_USER}"
    Acceder a la plataforma como usuario "${ROL_USER}"
    #Espera hasta que se cargue la página
    Wait Until Page Contains    Welcome!
    Recolectar captura de pantalla

Se ingresó a la página de administración
    [Documentation]   Supone browser abierto.
    Go To    ${PAGE_ADMIN}
    #Espera hasta que se cargue la página
    Wait Until Page Contains Element    xpath://h1[contains(text(),'Site administration')]

Se navegó a la pestaña "Users"
    [Documentation]   Se navega a la pestaña users de la pagina de administración.
    ...               Supone browser abierto.
    Go To    ${PAGE_ADMIN_USER}
    #Espera hasta que se cargue la página
    Wait Until Page Contains Element    xpath://h1[contains(text(),'Select user to change')]

Se navegó a la pestaña "Consultancy"
    [Documentation]   Supone browser abierto.
    Go To    ${PAGE_CONSULTANCY}
    #Espera hasta que se cargue la página
    Wait Until Page Contains    Available Consultations
    Recolectar captura de pantalla

Existe un cliente con DNI "${DNI}" en la base de datos 
    Insertar cliente en la DB
        ...    Romina    Cugat    DOCUMENT    ${DNI}    FEMALE    1986-06-23
        ...    "Av Poeta Lugones 12"    5012    SINGLE    HOUSE    COMPLETE_UNIVERSITY
        ...    romina96@gmail.com    704

Existe un panel llamado "${PANEL_NAME}" para el board de la comisión "${COMISION_NAME}"
    # Crear panel
    ${BOARD_ID}    Obtener el ID del board titulado "${COMISION_NAME}" de la DB
    Crear un panel "${PANEL_NAME}" en el board con ID "${BOARD_ID}" desde la DB

Existe una consulta con tag, DNI del cliente, oponente, descripción y estado:
    [Arguments]    ${TAG}   ${DNI}    ${OPP}    ${DESC}    ${PROGRESS}    ${STATE}=ASSIGNED
    ${CLIENT}    Obtener cliente con id_value '${DNI}' de la DB
    ${CLIENT_ID}    Set Variable    ${CLIENT[0]}
    Insertar consulta a la DB    ${CLIENT_ID}    ${TAG}   ${OPP}    ${DESC}    ${STATE}    ${PROGRESS}

Existe un ticket para el panel, de la comisión, con tag, DNI del cliente, oponente, descripción y estado:
    [Documentation]    Crea la consulta con los parametros especificados para el panel ${PANEL_NAME} del board
    ...                titulado ${COMISION_NAME} y por último crea una card, para el nuevo panel y consulta.
    [Arguments]    ${PANEL_NAME}    ${COMISION_NAME}    ${TAG}    ${DNI}    ${OPP}    ${DESC}    ${PROGRESS}
    # Crear consulta
    Existe una consulta con tag, DNI del cliente, oponente, descripción y estado:
    ...    ${TAG}   ${DNI}    ${OPP}    ${DESC}    ${PROGRESS}
    ${CONSULT}    Obtener consulta con TAG '${TAG}' de la DB
    ${CONSULT_ID}    Set Variable    ${CONSULT[0]}

    # Crear card
    ${PANEL_ID}    Obtener el ID del panel titulado "${PANEL_NAME}"
    Crear una card para la consulta "${TAG}" con ID "${CONSULT_ID}" en el panel con ID "${PANEL_ID}" desde la DB

Existe el board "${TITLE}" en la DB
    Insertar el board "${TITLE}" en la DB

El usuario profesor tiene acceso al board "${TITLE_BOARD}"
    [Documentation]    Supone que el usuario profesor es el
    ...                último en agregarse a la base de datos.
    ...                Crea la relación board-user para el
    ...                ultimo usuario y el board titulado ${TITLE_BOARD}.
    ${LAST_USER} =    Obtener el nuevo usuario de la DB
    ${USER_ID} =    Set Variable    ${LAST_USER[0]}
    ${BOARD_ID} =    Obtener el ID del board titulado "${TITLE_BOARD}" de la DB
    Insertar la relación board "${BOARD_ID}" - user "${USER_ID}"
