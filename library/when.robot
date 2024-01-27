*** Settings ***
Documentation     Keywords utilizadas bajo el prefijo When.

Library  SeleniumLibrary

Resource  ../library/keywords/testing_environment.robot
Resource  ../library/keywords/session.robot
Resource  ../constants.robot


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
    [Documentation]    Se hace click sobre el botó "+" para agregar una nueva consulta.
    ...                Supone que ya esta en la página Consultancy.
    ...                Luego rellena el formulario y selecciona el botón aceptar.
    ...                Se asume que el cliente existe.
    Click Button    id=add-icon-button
    Wait Until Page Contains    Load New Consultation

    ${LOCATOR_DESC} =    Set Variable    xpath://textarea[@aria-invalid='false']


    Input Text    ${LOCATOR_DESC}   ${DESC}
    Input Text    name:opponent   ${OPP}
    Input Text    name:tag   ${TAG}
    Input Text    name:client   ${DNI}


    Press Keys    name:client    ARROW_DOWN
    Press Keys    name:client    ENTER
    Press Keys    name:client    RETURN

    Recolectar captura de pantalla
    Click Button    id=button-accept
    Sleep    1s
