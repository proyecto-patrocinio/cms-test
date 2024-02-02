*** Settings ***
Documentation     Suite de test para pruebas relacionadas a la trazabilidad de
...               las consultas en la página de consultoría.

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
PAT-SYS-7: Visualización del estado de una comisión
    [Documentation]    Se ingresa al aplataforma como tomador de caso, y se verifica
    ...                que se pueda obtener información de cada comisión.
    ...                Dicha información debe contener la cantidad de tickets asignados
    ...                clasificados por estado de progreso.
    [Tags]  Automatico   SYS   PAT-SYS-07    PAT-144
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And existe un cliente con DNI "32165498" en la base de datos
    And se accedió a la plataforma como usuario "Tomador de Caso"
    And existe el board "Comisión A1" en la DB
    And existe un panel llamado "Panel A1" para el board de la comisión "Comisión A1"
    And existe un ticket para el panel, de la comisión, con tag, DNI del cliente, oponente, descripción y estado:
    ...    Panel A1
    ...    Comisión A1
    ...    Garantía1
    ...    32165498
    ...    Samsung
    ...    Dummy
    ...    TODO
    And existe un ticket para el panel, de la comisión, con tag, DNI del cliente, oponente, descripción y estado:
    ...    Panel A1
    ...    Comisión A1
    ...    Garantía2
    ...    32165498
    ...    Samsung
    ...    Dummy
    ...    IN_PROGRESS
    And existe un ticket para el panel, de la comisión, con tag, DNI del cliente, oponente, descripción y estado:
    ...    Panel A1
    ...    Comisión A1
    ...    Garantía3
    ...    32165498
    ...    Samsung
    ...    Dummy
    ...    TODO
    And se navegó a la pestaña "Consultancy"

    When se selecciona el botón de información del panel "Comisión A1"

    Then el Popper de la comisión debería contener "3 total cards"
    And el Popper de la comisión debería contener "2 cards to do"
    And el Popper de la comisión debería contener "1 cards in progress"
    And el Popper de la comisión debería contener "0 cards stopped"


