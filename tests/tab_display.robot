*** Settings ***
Documentation     Suite de test para chequeal la visibilidad de las pestañas de la página CMS.

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

    Given Existe un usuario registrado activo con permisos “common” y “case_taker” en la DB

    When Se accede a la plataforma como el usuario "Tomador de Caso"

    Then La pestaña “Consultancy” deberı́a estar visible
    And Las pestañas “Consultations” y “Clients” del “Panel de Control” deberı́an estar visibles
    And La pestaña “Boards” no deberı́a estar visible
