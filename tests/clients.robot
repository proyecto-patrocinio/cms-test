*** Settings ***
Documentation     Suite de test para el CRUD del consultante.

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
PAT-SYS-15: Creacion edicion y eliminacion de un consultante como usuario Tomador de Caso
    [Documentation]    Dado el ingreso a la plataforma como tomador de caso, se navega a
    ...    la pagina de panel de control / clients, se agrega, edita y elimina un registro
    ...    de un consultante y se valida que se haya cargado correctamente contra la base de datos
    ...    y la GUI.
    [Tags]  Automatico   SYS   PAT-SYS-15    PAT-154
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And se accedio a la plataforma como usuario "Tomador de Caso"
    And se navego a la pestaña "Control Panel - Clients"

    When se crea un nuevo consultante "Dummy Client" con DNI "11111111"

    Then el consultante con DNI "11111111" deberia existir en DB

    When se edita el campo "family.partner_salary" a "123" del consultante con DNI "11111111"

    Then el campo "partner_salary" del consultante con DNI "11111111" deberia ser "123" en DB

    When se elimina el consultante con DNI "11111111"

    Then el consultante con DNI "11111111" NO deberia existir la DB
