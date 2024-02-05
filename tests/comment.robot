*** Settings ***
Documentation     Suite de test para pruebas relacionadas a los comentarios de las consultas.

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
PAT-SYS-12: Creación, edición y elimnación de un comentario de una consulta
    [Documentation]    Dado el ingreso a la plataforma como profesor. Navega al
    ...    board de la comisión perteneciente, abre el detalle de una consulta y
    ...    se verifica que pueda crear, editar y eliminar un comentario en dicha consulta
    ...    validando contra la base de datos y con la GUI.
    [Tags]  Automatico   SYS   PAT-SYS-12    PAT-149
    Given existe el board "Comisión A1" en la DB
    And existe un usuario registrado activo con permisos "common" y "professor" en la DB
    And el usuario profesor tiene acceso al board "Comisión A1"
    And existe un cliente con DNI "32165498" en la base de datos
    And existe un panel llamado "Panel A1" para el board de la comisión "Comisión A1"
    And existe un ticket para el panel, de la comisión, con tag, DNI del cliente, oponente, descripción y estado:
    ...    Panel A1
    ...    Comisión A1
    ...    Divorcio
    ...    32165498
    ...    Samsung
    ...    Dummy
    ...    TODO
    And se accedió a la plataforma como usuario "profesor"
    And se navega a la pestaña "Board/Comisión A1"

    When se agrega el comentario "dummy" al ticket "Divorcio"

    Then la vista de comentarios de la consulta "Divorcio" debería contener "dummy"
    And el comentario "dummy" para la consulta "Divorcio" debería existir en la DB

    When se edita el comentario "dummy" a "lore ipsum" al ticket "Divorcio"

    Then la vista de comentarios de la consulta "Divorcio" debería contener "lore ipsum"
    And el comentario "lore ipsum" para la consulta "Divorcio" debería existir en la DB
    And la vista de comentarios de la consulta "Divorcio" NO debería contener "dummy"
    And el comentario "dummy" para la consulta "Divorcio" NO debería existir en la DB

    When se elimina el comentario "lore ipsum" al ticket "Divorcio"
    
    Then la vista de comentarios de la consulta "Divorcio" NO debería contener "lore ipsum"
    And el comentario "lore ipsum" para la consulta "Divorcio" NO debería existir en la DB
