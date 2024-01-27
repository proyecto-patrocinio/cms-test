*** Settings ***
Documentation     Suite de test para pruebas relacionadas al CRUD de la consulta.

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

PAT-SYS-5: Creación y visualización de una consulta como usuario Tomador de Caso
    [Documentation]    Se crea una nueva consulta como usuario tomador de caso
    ...                desde la página Consultancy, y se verfica la existencia
    ...                de la nueva consulta en la base de datos y en el panel de
    ...                entrada de nuevas consultas de dicha página.
    [Tags]  Automatico   SYS   PAT-SYS-05    PAT-142
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And existe un cliente con DNI "32165498" en la base de datos
    And se accedió a la plataforma como usuario "Tomador de Caso"
    And se navegó a la pestaña "Consultancy"
    
    When se crea la consulta "Garantía" con Cliente "32165498", oponente "Samsung" y descripcion "Dummy"
    
    Then la consulta "Garantía" para el cliente con DNI "32165498" deberı́a existir en base de datos
    And el ticket "Garantía" deberı́a estar visible en el panel de entrada de la pizarra "CONSULTANCY"
    And la información de la consulta "Garantía" deberı́a contener el cliente con DNI "32165498"
    And la información de la consulta "Garantía" deberı́a contener el campo "Description" en "Dummy"
    And la información de la consulta "Garantía" deberı́a contener el campo "Progress State" en "TODO"
    And la información de la consulta "Garantía" deberı́a contener el campo "Opponent" en "Samsung"
    And la información de la consulta "Garantía" deberı́a contener el campo "Availability State" en "CREATED"


Visualización de una consulta como usuario Profesor
    [Documentation]    Se valida la correcta visualización de la información
    ...                de una consulta como usuario profesor.
    [Tags]  Automatico   SYS   PAT-SYS-06    PAT-143
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And existe el board "Comisión A1" en la DB
    And se accedió a la plataforma como usuario "profesor"
    And el usuario Profesor tiene acceso al board "Comisión A1"
    And existe una consulta "Garantía" con Cliente "32165498", oponente "Samsung" y descripcion "Dummy"

    When Se navega a la pestaña "Board/Comisión A1"

    Then el ticket "Garantía" deberı́a estar visible en el panel de entrada de la pizarra "Comisión A1"
    And la información de la consulta "Garantía" deberı́a contener el cliente con DNI "32165498"
    And la información de la consulta "Garantía" deberı́a contener el campo "Description" en "Dummy"
    And la información de la consulta "Garantía" deberı́a contener el campo "Opponent" en "Samsung"
    And la información de la consulta "Garantía" deberı́a contener el campo "Availability State" en "ASSIGNED"
