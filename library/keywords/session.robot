*** Settings ***
Documentation    Keywords para manejo de registros y sesiones de usuarios.

Library  SeleniumLibrary
Library  String
Library  OperatingSystem

Resource    ../../settings.robot

*** Keywords ***
Extraer link desde html
    [Documentation]    Extrae el link del HTML retornado por el email,
    ...    El HTML sigue las pautas del template de accounts, y en este
    ...    se encuetra un link en href, ecerrado entre comillas.
    [Arguments]    ${HTML}
    ${HREF_PATTERN} =    Set Variable    (?i)href=["']?([^"' >]+)["']?
    ${HREF_VALUE} =    Get Regexp Matches    ${HTML}    ${HREF_PATTERN}
    ${LINK} =    Set Variable    ${HREF_VALUE[0][6:-1]}
    RETURN    ${LINK}

Iniciar Sesion con '${USER}' y contraseña '${PASSWORD}'
    [Documentation]    Intenta iniciar sesión a la plataforma con el
    ...    Usuario y contraseña proporcionado.
    ...    No se verifica el inicio de sesión exitoso.
    Input Text    name:username    ${USER}
    Input Text    name:password    ${PASSWORD}
    Click Button    xpath://button[contains(@class, 'MuiButton-root')]
