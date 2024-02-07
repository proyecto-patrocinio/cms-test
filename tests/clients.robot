*** Settings ***
Documentation     Suite de test para el CRUD del cliente.

Library  SeleniumLibrary
Library  ImapLibrary2
Library  String
Library  DatabaseLibrary
Library  OperatingSystem    WITH NAME    OS
Library  JSONLibrary
Library  Collections

Resource  ../library/keywords/utils.robot
Resource  ../library/keywords/testing_environment.robot
Resource  ../library/keywords/docker.robot
Resource  ../library/preconditions.robot
Resource  ../library/executions.robot
Resource  ../library/validations.robot


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
    ...                Desloguearse de la plataforma
    ...                Cerrar el navegador
    ...                Recolectar las evidencias
    ...                Se limpian las capturas realizadas por selenium


*** Test Cases ***
PAT-SYS-15: Creación edición y eliminación de un cliente como usuario Tomador de Caso
    [Documentation]    Dado el ingreso a la plataforma como tomador de caso, se navega a
    ...    la página de panel de control / clients, se agrega, edita y elimina un registro
    ...    de un cliente y se valida que se haya cargado correctamente contra la base de datos
    ...    y la GUI.
    [Tags]  Automatico   SYS   PAT-SYS-15    PAT-154
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And se accedió a la plataforma como usuario "Tomador de Caso"
    And se navegó a la pestaña "Control Panel - Clients"

    When se crea un nuevo cliente "Marta Paez" con DNI "42301452"

    Then el cliente con DNI "42301452" debería existir en DB

    When se edita el campo "family.partner_salary" a "123" del cliente con DNI "42301452"

    Then el campo "partner_salary" del cliente con DNI "42301452" debería ser "123" en DB

    When se elimina el cliente con DNI "42301452"

    Then el cliente con DNI "42301452" NO debería existir la DB
