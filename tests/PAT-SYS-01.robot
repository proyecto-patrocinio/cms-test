*** Settings ***
Library  SeleniumLibrary
Library  ImapLibrary2
Library  String
Library  DatabaseLibrary
Library  OperatingSystem
Library  JSONLibrary
Library  Collections

Resource  ../library/keywords/utils.robot
Resource  ../library/keywords/testing_environment.robot
Resource  ../library/keywords/docker.robot
Resource  ../library/given.robot
Resource  ../library/when.robot
Resource  ../library/then.robot

Suite Setup    Run Keywords
    ...                Se inician los contenedores del CMS
Suite Teardown
    ...                Se paran los contenedores del CMS

Test Setup    Run Keywords
    ...                Preparar una estructura limpia de directorios
    ...                Configurar el ID del Test
    ...                Abrir la plataforma en el navegador
    ...                Limpiar base de datos

Test Teardown    Run Keywords
    ...                Cerrar el navegador
    ...                Recolectar las evidencias
    ...                Se limpian las capturas realizadas por selenium

*** Test Cases ***
PAT-SYS-01: Registro de un Nuevo Usuario
    [Documentation]    Se crea un nuevo usuario y se corrobora la
    ...    llegada exitosa del email de confirmación.
    ...    Además se corrobora que el usuario autenticado no pueda
    ...    ingresar sesión si no es activado.
    [Tags]  Automatico   SYS   PAT-SYS-01    PAT-138
    Given Se accedió a la página "SignUp"
    And Se completó el formulario con los datos del usuario
    And Se aceptaron los términos y condiciones

    When Se presiona el botón SignUp

    Then Deberı́a recibir un correo electrónico con el enlace de confirmación
    And Deberı́a ser redirigido a la página de inicio de sesión
    And Deberı́a recibir un error al intentar iniciar sesión
    And En la base de datos deberı́a existir el nuevo usuario registrado SIN ACTIVAR
