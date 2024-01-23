*** Settings ***
Documentation     Keywords utilizadas bajo el prefijo Then.

Library  SeleniumLibrary
Library  ImapLibrary2
Library  String

Resource  ../settings.robot
Resource  ../constants.robot
Resource  ../library/keywords/database_handling.robot
Resource  ../library/keywords/session.robot
Resource  ../library/keywords/testing_environment.robot

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
    Acceder a la plataforma como usuario “${ROL_USER}”
    Wait Until Page Contains    Welcome!
    Page Should Not Contain    Sign in
