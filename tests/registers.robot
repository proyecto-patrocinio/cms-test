*** Settings ***
Documentation     Suite de test para el registro de usuarios.

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

Suite Teardown    Run Keywords
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
    Given se accedió a la página "SignUp"
    And se completó el formulario con los datos del usuario
    And se aceptaron los términos y condiciones

    When se presiona el botón SignUp

    Then deberı́a recibir un correo electrónico con el enlace de confirmación
    And deberı́a ser redirigido a la página de inicio de sesión
    And deberı́a recibir un error al intentar iniciar sesión
    And en la base de datos deberı́a existir el nuevo usuario registrado SIN ACTIVAR


PAT-SYS-02: Activación de un Usuario Registrado
    [Documentation]    Se loguea como usuario administrador y se activa un usuario previamente registrado.
    ...                Luego se corrobora que dicho usuario puede acceder correctamente.
    [Tags]  Automatico   SYS   PAT-SYS-02    PAT-139
    Given existe un superusuario administrador
    And existe un usuario registrado sin activar
    And se accedió a la plataforma como usuario "administrador"
    And se ingresó a la página de administración
    And se navegó a la pestaña "Users"

    When se edita el estado del usuario "nuevo" a "Activo"
    And se desloguea de la página de administración

    Then el usuario "nuevo" debería poder iniciar sesión en la plataforma con éxito
