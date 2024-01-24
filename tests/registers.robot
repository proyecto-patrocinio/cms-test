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
    Given Se accedió a la página "SignUp"
    And Se completó el formulario con los datos del usuario
    And Se aceptaron los términos y condiciones

    When Se presiona el botón SignUp

    Then Deberı́a recibir un correo electrónico con el enlace de confirmación
    And Deberı́a ser redirigido a la página de inicio de sesión
    And Deberı́a recibir un error al intentar iniciar sesión
    And En la base de datos deberı́a existir el nuevo usuario registrado SIN ACTIVAR


PAT-SYS-02: Activación de un Usuario Registrado
    [Documentation]    Se loguea como usuario administrador y se activa un usuario previamente registrado.
    ...                Luego se corrobora que dicho usuario puede acceder correctamente.
    [Tags]  Automatico   SYS   PAT-SYS-02    PAT-139
    Given Existe un superusuario administrador
    And Existe un usuario registrado sin activar
    And Se accedió a la plataforma como usuario “administrador”
    And Se ingresó a la página de administración
    And Se navegó a la pestaña “Users”

    When Se edita el estado del usuario "nuevo" a "Activo"
    And Se desloguea de la página de administración

    Then El usuario "nuevo" debería poder iniciar sesión en la plataforma con éxito