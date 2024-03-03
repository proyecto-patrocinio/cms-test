*** Settings ***
Documentation     Suite de test para pruebas relacionadas al CRUD de la consulta
...    y a la visualizacion basica de la informacion de la misma en el detalle de la consulta.

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

PAT-SYS-5: Creacion y visualizacion de una consulta como usuario Tomador de Caso
    [Documentation]    Se crea una nueva consulta como usuario tomador de caso
    ...                desde la pagina Consultancy, y se verfica la existencia
    ...                de la nueva consulta en la base de datos y en el panel de
    ...                entrada de nuevas consultas de dicha pagina.
    [Tags]  Automatico   SYS   PAT-SYS-05    PAT-142
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And existe un cliente con DNI "11111111" en la base de datos
    And se accedio a la plataforma como usuario "Tomador de Caso"
    And se navego a la pestaña "Consultancy"
    
    When se crea la consulta "Garantia" con Cliente "11111111", oponente "Samsung" y descripcion "Dummy"
    
    Then la consulta "Garantia" para el cliente con DNI "11111111" deberia existir en base de datos
    And el ticket "Garantia" deberia estar visible en el panel de entrada de la pizarra "CONSULTANCY"
    And la informacion de la consulta "Garantia" deberia contener el cliente con DNI "11111111"
    And la informacion de la consulta "Garantia" deberia contener el campo "Description" en "Dummy"
    And la informacion de la consulta "Garantia" deberia contener el campo "Progress State" en "TODO"
    And la informacion de la consulta "Garantia" deberia contener el campo "Opponent" en "Samsung"
    And la informacion de la consulta "Garantia" deberia contener el campo "Availability State" en "CREATED"


PAT-SYS-06: Visualizacion de una consulta como usuario Profesor
    [Documentation]    Se valida la correcta visualizacion de la informacion
    ...                de una consulta como usuario profesor.
    [Tags]  Automatico   SYS   PAT-SYS-06    PAT-143
    Given existe el board "Comision A1" en la DB
    And existe un usuario registrado activo con permisos "common" y "professor" en la DB
    And el usuario profesor tiene acceso al board "Comision A1"
    And existe un cliente con DNI "11111111" en la base de datos
    And existe un panel llamado "Panel A1" para el board de la comision "Comision A1"
    And existe un ticket para el panel, de la comision, con tag, DNI del cliente, oponente, descripcion y estado:
    ...    Panel A1
    ...    Comision A1
    ...    Garantia
    ...    11111111
    ...    Samsung
    ...    Dummy
    ...    TODO
    And se accedio a la plataforma como usuario "profesor"


    When se navega a la pestaña "Board/Comision A1"

    Then el ticket "Garantia" deberia estar visible en el panel de entrada de la pizarra "Comision A1"
    And la informacion de la consulta "Garantia" deberia contener el cliente con DNI "11111111"
    And la informacion de la consulta "Garantia" deberia contener el campo "Description" en "Dummy"
    And la informacion de la consulta "Garantia" deberia contener el campo "Opponent" en "Samsung"
    And la informacion de la consulta "Garantia" deberia contener el campo "Availability State" en "ASSIGNED"


PAT-SYS-13: Realizar cambios de una consulta como usuario Profesor
    [Documentation]    Dado que se ingresa a la plataforma como usuario profesor,
    ...    con permisos a una comision con una consulta asignada, se valida que
    ...    el usuario, pueda realizar cambios 'Description', 'Opponent', 'Progress State', 'Tag'
    ...    en los campos de la consulta.
    [Tags]  Automatico   SYS   PAT-SYS-13    PAT-148
    Given existe el board "Comision A1" en la DB
    And existe un usuario registrado activo con permisos "common" y "professor" en la DB
    And el usuario profesor tiene acceso al board "Comision A1"
    And existe un cliente con DNI "11111111" en la base de datos
    And existe un panel llamado "Panel A1" para el board de la comision "Comision A1"
    And existe un ticket para el panel, de la comision, con tag, DNI del cliente, oponente, descripcion y estado:
    ...    Panel A1
    ...    Comision A1
    ...    Divorcio
    ...    11111111
    ...    Samsung
    ...    Dummy
    ...    TODO
    And se accedio a la plataforma como usuario "profesor"
    And se navega a la pestaña "Board/Comision A1"

    When se edita el campo "Description" a "otra descripcion" del ticket "Divorcio"
    And se edita el campo "Opponent" a "otro oponente" del ticket "Divorcio"
    And se edita el campo "Progress State" seleccionando la opcion "IN_PROGRESS" del ticket "Divorcio"
    And se edita el campo "Tag" a "CODE-123: Divorcio" del ticket "Divorcio"

    Then No deberia existir el ticket "Divorcio" en el board
    Then el ticket "CODE-123: Divorcio" deberia estar visible en el panel de entrada de la pizarra "Comision A1"
    And la informacion de la consulta "CODE-123: Divorcio" deberia contener el campo "Tag" en "CODE-123: Divorcio"
    And la informacion de la consulta "CODE-123: Divorcio" deberia contener el cliente con DNI "11111111"
    And la informacion de la consulta "CODE-123: Divorcio" deberia contener el campo "Description" en "otra descripcion"
    And la informacion de la consulta "CODE-123: Divorcio" deberia contener el campo "Opponent" en "otro oponente"
    And la informacion de la consulta "CODE-123: Divorcio" deberia contener el campo "Availability State" en "ASSIGNED"
