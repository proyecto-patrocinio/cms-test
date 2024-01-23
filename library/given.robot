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
Resource  ../library/keywords/testing_environment.robot

*** Keywords ***
Se accedió a la página "SignUp"
    [Documentation]    Navega a la página de registro "SignUp".
    ...                Supone browser abierto.
    Go To    http://localhost:80/signup

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
