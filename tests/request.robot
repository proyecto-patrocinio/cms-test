*** Settings ***
Documentation     Suite de test para pruebas relacionadas las solicitudes de asignacion de consulta.

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
PAT-SYS-08: Creacion de solicitud de asignacion de caso a una comision
    [Documentation]    Se valida la creacion y eliminacion existosa de una solicitud de asignacion
    ...                de una consulta a una comision como usuario tomador de caso.
    [Tags]  Automatico   SYS   PAT-SYS-08    PAT-145
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And existe un cliente con DNI "11111111" en la base de datos
    And se accedio a la plataforma como usuario "Tomador de Caso"
    And existe el board "Comision A1" en la DB
    And existe un panel llamado "Panel A1" para el board de la comision "Comision A1"
    And existe una consulta con tag, DNI del cliente, oponente, descripcion y estado:
    ...    Garantia
    ...    11111111
    ...    Samsung
    ...    Dummy
    ...    TODO
    ...    CREATED
    And se navego a la pestaña "Consultancy"

    When se crea la solicitud de asignacion de consulta "Garantia" a la comision "Comision A1"

    Then deberia existir una "request consultation" de la consulta "Garantia" al board "Comision A1" en la DB
    And el ticket "Garantia" deberia estar en el primer panel "Comision A1" de la comision

    When se elimina la solicitud de asignacion de consulta "Garantia"

    Then deberia haberse eliminado la "request consultation" de la consulta "Garantia" de la DB
    And el ticket "Garantia" deberia estar en el panel de entrada "Available Consultations" de la comision


PAT-SYS-11: Aceptar y eliminar solicitudes de asignacion de caso
    [Documentation]    Se valida la aceptacion existosa de una solicitud de asignacion
    ...                de una consulta a una comision como usuario profesor, integrante de dicha comision.
    [Tags]  Automatico   SYS   PAT-SYS-11    PAT-146
    Given existe el board "Comision A1" en la DB
    And existe un cliente con DNI "11111111" en la base de datos
    And existe una consulta con tag, DNI del cliente, oponente, descripcion y estado:
    ...    Garantia1
    ...    11111111
    ...    Samsung
    ...    Dummy
    ...    TODO
    ...    CREATED
    And existe una solicitud de asignacion de la consulta "Garantia1" a la comision "Comision A1"
    And existe una consulta con tag, DNI del cliente, oponente, descripcion y estado:
    ...    Garantia2
    ...    11111111
    ...    Samsung
    ...    Dummy
    ...    TODO
    ...    CREATED
    And existe una solicitud de asignacion de la consulta "Garantia2" a la comision "Comision A1"
    And existe un panel llamado "Panel A1" para el board de la comision "Comision A1"
    And existe un usuario registrado activo con permisos "common" y "professor" en la DB
    And el usuario profesor tiene acceso al board "Comision A1"
    And se accedio a la plataforma como usuario "Profesor"
    And se navega a la pestaña "Board/Comision A1"

    When se acepta la solicitud de asignacion de consulta "Garantia1" y se asigna al panel "Panel A1"

    Then deberia haberse eliminado la "request consultation" de la consulta "Garantia1" de la DB
    And el ticket "Garantia1" deberia estar en el primer panel "Panel A1" del board

    When se selecciona la opcion rejected del menu del ticket "Garantia2"

    Then deberia haberse eliminado la "request consultation" de la consulta "Garantia2" de la DB
    And no deberia existir el ticket "Garantia2" en el board
