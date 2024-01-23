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

Se accedió a la plataforma como usuario “${ROL_USER}”
    Acceder a la plataforma como usuario “${ROL_USER}”
    #Espera hasta que se cargue la página
    Wait Until Page Contains    Welcome!

Se ingresó a la página de administración
    [Documentation]   Supone browser abierto.
    Go To    ${PAGE_ADMIN}
    #Espera hasta que se cargue la página
    Wait Until Page Contains Element    xpath://h1[contains(text(),'Site administration')]

Se navegó a la pestaña “Users”
    [Documentation]   Se navega a la pestaña users de la pagina de administración.
    ...               Supone browser abierto.
    Go To    ${PAGE_ADMIN_USER}
    #Espera hasta que se cargue la página
    Wait Until Page Contains Element    xpath://h1[contains(text(),'Select user to change')]
