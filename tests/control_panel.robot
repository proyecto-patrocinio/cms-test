*** Settings ***
Documentation     Suite de test para pruebas relacionadas al panel de control.

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
PAT-SYS-09: Visualizacion y manipulacion de la tabla en la ventana consultations
    [Documentation]    Dado el ingreso como usuario tomador de caso, se valida que se pueda ingresar
    ...    a la pagina de consultas del panel de control. Valida que contenga los valores en la tabla
    ...    esperados. Valida el funcionamiento del filtro por 'Tag' y el correcto funcionamiento de la
    ...    exportacion de la tabla a CSV.
    [Tags]  Automatico   SYS   PAT-SYS-09    PAT-147
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And existe un consultante con DNI "11111111" en la base de datos
    And se accedio a la plataforma como usuario "Tomador de Caso"
    And existe una consulta con tag, DNI del consultante, oponente, descripcion y estado:
    ...    Garantia1
    ...    11111111
    ...    Samsung
    ...    Dummy
    ...    TODO
    ...    CREATED
    And existe una consulta con tag, DNI del consultante, oponente, descripcion y estado:
    ...    Garantia2
    ...    11111111
    ...    Samsung
    ...    Dummy
    ...    TODO
    ...    CREATED

    When se navego a la pestaña "Control Panel - Consultations"

    Then la tabla deberia contener 2 filas
    And la tabla deberia contener la consulta:
    ...    Garantia1
    ...    11111111
    ...    Samsung
    ...    Dummy
    And la tabla deberia contener la consulta:
    ...    Garantia2
    ...    11111111
    ...    Samsung
    ...    Dummy

    When se descarga el csv de la tabla

    Then el archivo se deberia haber descargado correctamente
    And el archivo de consultas descargado deberia ser el esperado 'expected_consultations.csv'

    When se crea el filtro "Tag" con "Garantia2"

    Then la tabla deberia contener 1 filas
    And la tabla deberia contener la consulta:
    ...    Garantia2
    ...    11111111
    ...    Samsung
    ...    Dummy

    When se descarga el csv de la tabla

    Then el archivo se deberia haber descargado correctamente
    And el archivo de consultas descargado deberia ser el esperado 'expected_filter_consultations.csv'


PAT-SYS-10: Visualizacion y manipulacion de la tabla en la ventana clients
    [Documentation]    Dado el ingreso como usuario tomador de caso, se valida que se pueda ingresar
    ...    a la pagina de clients del panel de control. Valida que contenga los valores en la tabla
    ...    esperados. Valida el funcionamiento del filtro por 'Last Name' y el correcto funcionamiento de la
    ...    exportacion de la tabla a CSV.
    [Tags]  Automatico   SYS   PAT-SYS-10    PAT-151
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And existe el consultante en la base de datos:
        ...    Emily    Davis    DOCUMENT    11111111    FEMALE    1996-06-23
        ...    "Dummy Street 01"    1111    SINGLE    HOUSE    COMPLETE_UNIVERSITY
        ...    emily96@gmail.com
    And existe el consultante en la base de datos:
        ...    John    Davis    DOCUMENT    22222222    FEMALE    1980-06-25
        ...    "Dummy Street 01"    1111    SINGLE    HOUSE    COMPLETE_UNIVERSITY
        ...    john80@gmail.com
    And se accedio a la plataforma como usuario "Tomador de Caso"

    When se navego a la pestaña "Control Panel - Clients"
    
    Then la tabla deberia contener 2 filas
    And la tabla deberia contener el consultante:
        ...    11111111    Emily    Davis    Document    Female    1996-06-23
        ...    Dummy Street 01    1,111    Single    House    Complete University
        ...    emily96@gmail.com
    And la tabla deberia contener el consultante:
        ...    22222222    John    Davis    Document    Female    1980-06-25
        ...    Dummy Street 01    1,111    Single    House    Complete University
        ...    john80@gmail.com


    When se descarga el csv de la tabla

    Then el archivo se deberia haber descargado correctamente
    And el archivo de consultantes descargado deberia ser el esperado 'expected_clients.csv'

    When se crea el filtro "First Name" con "Emily"

    Then la tabla deberia contener 1 filas
    And la tabla deberia contener el consultante:
        ...    11111111    Emily    Davis    Document    Female    1996-06-23
        ...    Dummy Street 01    1,111    Single    House    Complete University
        ...    emily96@gmail.com

    When se descarga el csv de la tabla

    Then el archivo se deberia haber descargado correctamente
    And el archivo de consultantes descargado deberia ser el esperado 'expected_filter_clients.csv'
