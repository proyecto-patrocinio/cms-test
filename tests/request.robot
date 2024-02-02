*** Settings ***
Documentation     Suite de test para pruebas relacionadas las solicitudes de asignación de consulta.

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
PAT-SYS-08: Creación de solicitud de asignación de caso a una comisión
    [Documentation]    Se valida la creación y eliminación existosa de una solicitud de asignación
    ...                de una consulta a una comisión como usuario tomador de caso.
    [Tags]  Automatico   SYS   PAT-SYS-08    PAT-145
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And existe un cliente con DNI "32165498" en la base de datos
    And se accedió a la plataforma como usuario "Tomador de Caso"
    And existe el board "Comisión A1" en la DB
    And existe un panel llamado "Panel A1" para el board de la comisión "Comisión A1"
    And existe una consulta con tag, DNI del cliente, oponente, descripción y estado:
    ...    Garantía
    ...    32165498
    ...    Samsung
    ...    Dummy
    ...    TODO
    ...    CREATED
    And se navegó a la pestaña "Consultancy"

    When se crea la solicitud de asignación de consulta "Garantía" a la comisión "Comisión A1"

    Then debería existir una "request consultation" de la consulta "Garantía" al board "Comisión A1" en la DB
    And el ticket "Garantía" debería estar en el primer panel "Comisión A1" de la comisión

    When se elimina la solicitud de asignación de consulta "Garantía"

    Then debería haberse eliminado la "request consultation" de la consulta "Garantía" de la DB
    And el ticket "Garantía" debería estar en el panel de entrada "Available Consultations" de la comisión


PAT-SYS-11: Aceptar y eliminar solicitudes de asignación de caso
    [Documentation]    Se valida la aceptación existosa de una solicitud de asignación
    ...                de una consulta a una comisión como usuario profesor, integrante de dicha comisión.
    [Tags]  Automatico   SYS   PAT-SYS-11    PAT-146
    Given existe el board "Comisión A1" en la DB
    And existe un cliente con DNI "32165498" en la base de datos
    And existe una consulta con tag, DNI del cliente, oponente, descripción y estado:
    ...    Garantía1
    ...    32165498
    ...    Samsung
    ...    Dummy
    ...    TODO
    ...    CREATED
    And existe una solicitud de asignación de la consulta "Garantía1" a la comisión "Comisión A1"
    And existe una consulta con tag, DNI del cliente, oponente, descripción y estado:
    ...    Garantía2
    ...    32165498
    ...    Samsung
    ...    Dummy
    ...    TODO
    ...    CREATED
    And existe una solicitud de asignación de la consulta "Garantía2" a la comisión "Comisión A1"
    And existe un panel llamado "Panel A1" para el board de la comisión "Comisión A1"
    And existe un usuario registrado activo con permisos "common" y "professor" en la DB
    And el usuario profesor tiene acceso al board "Comisión A1"
    And se accedió a la plataforma como usuario "Profesor"
    And se navega a la pestaña "Board/Comisión A1"

    When se acepta la solicitud de asignación de consulta "Garantía1" y se asigna al panel "Panel A1"

    Then debería haberse eliminado la "request consultation" de la consulta "Garantía1" de la DB
    And el ticket "Garantía1" debería estar en el primer panel "Panel A1" del board

    When se selecciona la opción rejected del menu del ticket "Garantía2"

    Then debería haberse eliminado la "request consultation" de la consulta "Garantía2" de la DB
    And no debería existir el ticket "Garantía2" en el board
