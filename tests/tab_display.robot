*** Settings ***
Documentation     Suite de test para chequear la visibilidad de las pestañas de la página CMS.

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
PAT-SYS-3: Visibilidad de Pestañas para Usuario Tomador de Caso
    [Documentation]    Se ingresa a la plataforma como usuario tomador de caso
    ...                Y se valida que se visualicen unicamente las pestañas
    ...                correspondientes al rol.
    [Tags]  Automatico   SYS   PAT-SYS-03    PAT-140
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB

    When se accede a la plataforma como el usuario "Tomador de Caso"

    Then la pestaña "Consultancy" deberı́a estar visible
    And las pestañas "Consultations" y "Clients" del "Panel de Control" deberı́an estar visibles
    And la pestaña "Boards" no deberı́a estar visible


PAT-SYS-4: Visibilidad de Pestañas para Usuario Profesor
    [Documentation]    Se ingresa a la plataforma como usuario profesor
    ...                Y se valida que se visualicen unicamente las pestañas
    ...                correspondientes al rol.
    [Tags]  Automatico   SYS   PAT-SYS-04    PAT-141
    Given existe un usuario registrado activo con permisos "common" y "professor" en la DB
    When se accede a la plataforma como el usuario "Profesor"
    Then la pestaña "Boards" deberı́a estar visible
    And la pestaña "Consultancy" no deberı́a estar visible
    And las pestañas "Consultations" y "Clients" del "Panel de Control" no deberı́an estar visibles
