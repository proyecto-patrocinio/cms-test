*** Settings ***
Documentation    Keywords para manejo de registros y sesiones de usuarios.

Library  SeleniumLibrary
Library  String
Library  OperatingSystem    WITH NAME    OS

Resource    ../../settings.robot
Resource    ../../constants.robot
Resource    testing_environment.robot

*** Keywords ***


# =======================================================================
# Keywords para el registro
Extraer link desde html
    [Documentation]    Extrae el link del HTML retornado por el email,
    ...    El HTML sigue las pautas del template de accounts, y en este
    ...    se encuetra un link en href, ecerrado entre comillas.
    [Arguments]    ${HTML}
    ${HREF_PATTERN} =    Set Variable    (?i)href=["']?([^"' >]+)["']?
    ${HREF_VALUE} =    Get Regexp Matches    ${HTML}    ${HREF_PATTERN}
    ${LINK} =    Set Variable    ${HREF_VALUE[0][6:-1]}
    RETURN    ${LINK}

Iniciar sesion con usuario '${USER}' y contraseña '${PASSWORD}'
    [Documentation]    Intenta iniciar sesion a la plataforma con el
    ...    Usuario y contraseña proporcionado.
    ...    No se verifica el inicio de sesion exitoso.
    Input Text    name:username    ${USER}
    Input Text    name:password    ${PASSWORD}
    Click Button    xpath://button[contains(@class, 'MuiButton-root')]
    Recolectar captura de pantalla    signin_data

Acceder a la plataforma como usuario "${ROL_USER}"
    [Documentation]    Ingresa a la plataforma con un usuario definido por
    ...                el rol ${ROL_USER} (administrator, profesor, profesor o random),
    ...                suponiendo que dicho usuario existe en base de datos.
    ${ROL_USER} =    Convert To Lower Case    ${ROL_USER}
    IF    '${ROL_USER}' == 'administrador'
        Iniciar sesion con usuario '${CMS_SUPERUSER_USERNAME}' y contraseña '${CMS_SUPERUSER_PASSWORD}'
    ELSE IF    '${ROL_USER}' == 'profesor'
        Iniciar sesion con usuario '${CMS_PROFESSOR_USER_USERNAME}' y contraseña '${CMS_PROFESSOR_USER_PASSWORD}'
    ELSE IF    '${ROL_USER}' == 'tomador de caso'
        Iniciar sesion con usuario '${CMS_CASE_TAKER_USER_USERNAME}' y contraseña '${CMS_CASE_TAKER_USER_PASSWORD}'
    ELSE
        Iniciar sesion con usuario '${CMS_RANDOM_USER_USERNAME}' y contraseña '${CMS_RANDOM_USER_PASSWORD}'
    END

Editar el estado del usuario "${USERNAME}" a "${NEW_STATE}"
    [Documentation]    Se edita el estado de habilitacion del usuario segun ${NEW_STATE}.
    ...                Los valores posibles son "activo", o "desactivo".
    # Seleccionar editar el usuario
    Click Element    //a[text()='${USERNAME}']
    # actualizar el estado
    IF    '${NEW_STATE}' == 'activo'  # Activa un usuario
        ${is_checked}=    Get Element Attribute    id=id_is_active    checked
        Run Keyword If    '${is_checked}' != 'true'    Click Element    id=id_is_active
    ELSE    # Desactiva un usuario
        ${is_checked}=    Get Element Attribute    id=id_is_active    checked
        Run Keyword If    '${is_checked}' != 'false'    Click Element    id=id_is_active
    END
    # Guardar cambios
    Recolectar captura de pantalla    user_state_edited_${NEW_STATE}
    Click Element    xpath://input[@name='_save']

# =======================================================================
# Deslogueos

Desloguearse de la administracion
    Click Button    xpath://button[@type='submit' and contains(text(),'Log out')]
    Wait Until Page Contains    Logged out
    Recolectar captura de pantalla    close_sesion_from_admin

Desloguearse de la plataforma
    Click Element    xpath://span[@class='MuiTypography-root MuiTypography-body1 MuiListItemText-primary css-10hburv-MuiTypography-root' and contains(text(),'Logout')]
    Wait Until Page Contains    Sign in
    Recolectar captura de pantalla    close_sesion
