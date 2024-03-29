*** Settings ***
Documentation     Suite de test para pruebas relacionadas al CRUD de los eventos de una consulta.

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
    ...                Se cierra el dialogo de detalle de consulta
    ...                Desloguearse de la plataforma
    ...                Cerrar el navegador
    ...                Recolectar las evidencias
    ...                Se limpian las capturas realizadas por selenium


*** Test Cases ***

PAT-SYS-14: Creacion y eliminacion de eventos de una consulta
    [Documentation]    Dado que se ingresa a la plataforma como usuario profesor,
    ...    se intenta crear, visualizar y eliminar un evento para el dia de la fecha
    ...    en la pestaña 'Calendar', del dialogo 'Detalle de la Consulta'
    ...    para la consulta perteneciente a la comision del profesor.
    [Tags]  Automatico   SYS   PAT-SYS-14    PAT-152
    Given existe el board "Comision A1" en la DB
    And existe un usuario registrado activo con permisos "common" y "professor" en la DB
    And el usuario profesor tiene acceso al board "Comision A1"
    And existe un consultante con DNI "11111111" en la base de datos
    And existe un panel llamado "Panel A1" para el board de la comision "Comision A1"
    And existe un ticket para el panel, de la comision, con tag, DNI del consultante, oponente, descripcion y estado:
    ...    Panel A1
    ...    Comision A1
    ...    Divorcio
    ...    11111111
    ...    Samsung
    ...    Dummy
    ...    TODO
    And se accedio a la plataforma como usuario "profesor"
    And se navega a la pestaña "Board/Comision A1"

    When se agrega el evento para hoy al ticket "Divorcio" titulado "Junta" con descripcion "sucursal principal"

    Then la vista calendario de la consulta "Divorcio" deberia contener el evento "Junta" el dia de la fecha
    And el evento "Junta" hoy para la consulta "Divorcio" y descripcion "sucursal principal" deberia existir en la DB

    When se elimina el evento "Junta" del ticket "Divorcio"

    Then la vista calendario de la consulta "Divorcio" NO deberia contener el evento "Junta"
    And no deberia existir el evento "Junta" para la consulta "Divorcio" en la DB


PAT-SYS-16: Calendario desactivado para una consulta sin asignar
    [Documentation]    Se valida que el calendario no este accesible desde la consultoria
    ...    cuando existe una consulta nueva sin asignar.
    [Tags]  Automatico   SYS   PAT-SYS-16    PAT-170    PI-PAT-SYS-167
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And existe un consultante con DNI "11111111" en la base de datos
    And se accedio a la plataforma como usuario "Tomador de Caso"
    And existe una consulta con tag, DNI del consultante, oponente, descripcion y estado:
    ...    Garantia
    ...    11111111
    ...    Samsung
    ...    Dummy
    ...    TODO
    ...    CREATED
    And se navego a la pestaña "Consultancy"

    When se abre el detalle del ticket "Garantia"

    Then el boton calendario deberia estar desactivado

PAT-SYS-17: Calendario desactivado para una consulta con solicitud pendiente de asignacion
    [Documentation]    Se valida que el calendario no este accesible desde la consultoria
    ...    para una consulta con una Request Consultation pendiente.
    [Tags]  Automatico   SYS   PAT-SYS-17    PAT-171    PI-PAT-SYS-167
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And existe un consultante con DNI "11111111" en la base de datos
    And se accedio a la plataforma como usuario "Tomador de Caso"
    And existe el board "Comision A1" en la DB
    And existe un panel llamado "Panel A1" para el board de la comision "Comision A1"
    And existe una consulta con tag, DNI del consultante, oponente, descripcion y estado:
    ...    Garantia
    ...    11111111
    ...    Samsung
    ...    Dummy
    ...    TODO
    ...    CREATED
    And existe una solicitud de asignacion de la consulta "Garantia" a la comision "Comision A1"
    And se navego a la pestaña "Consultancy"

    When se abre el detalle del ticket "Garantia"

    Then el boton calendario deberia estar desactivado
