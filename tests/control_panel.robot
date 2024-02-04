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
PAT-SYS-09: Visualización y manipulación de la tabla en la ventana consultations
    [Documentation]    Dado el ingreso como usuario tomador de caso, se valida que se pueda ingresar
    ...    a la página de consultas del panel de control. Valida que contenga los valores en la tabla
    ...    esperados. Valida el funcionamiento del filtro por 'Tag' y el correcto funcionamiento de la
    ...    exportación de la tabla a CSV.
    [Tags]  Automatico   SYS   PAT-SYS-09    PAT-147
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And existe un cliente con DNI "32165498" en la base de datos
    And se accedió a la plataforma como usuario "Tomador de Caso"
    And existe una consulta con tag, DNI del cliente, oponente, descripción y estado:
    ...    Garantía1
    ...    32165498
    ...    Samsung
    ...    Dummy
    ...    TODO
    ...    CREATED
    And existe una consulta con tag, DNI del cliente, oponente, descripción y estado:
    ...    Garantía2
    ...    32165498
    ...    Samsung
    ...    Dummy
    ...    TODO
    ...    CREATED

    When se navegó a la pestaña "Control Panel - Consultations"

    Then la tabla debería contener 2 filas
    And la tabla debería contener la consulta:
    ...    Garantía1
    ...    32165498
    ...    Samsung
    ...    Dummy
    And la tabla debería contener la consulta:
    ...    Garantía2
    ...    32165498
    ...    Samsung
    ...    Dummy

    When se descarga el csv de la tabla

    Then el archivo se debería haber descargado correctamente
    And el archivo de consultas descargado debería ser el esperado 'expected_consultations.csv'

    When se crea el filtro "Tag" con "Garantía2"

    Then la tabla debería contener 1 filas
    And la tabla debería contener la consulta:
    ...    Garantía2
    ...    32165498
    ...    Samsung
    ...    Dummy

    When se descarga el csv de la tabla

    Then el archivo se debería haber descargado correctamente
    And el archivo de consultas descargado debería ser el esperado 'expected_filter_consultations.csv'


PAT-SYS-10: Visualización y manipulación de la tabla en la ventana clients
    [Documentation]    Dado el ingreso como usuario tomador de caso, se valida que se pueda ingresar
    ...    a la página de clients del panel de control. Valida que contenga los valores en la tabla
    ...    esperados. Valida el funcionamiento del filtro por 'Last Name' y el correcto funcionamiento de la
    ...    exportación de la tabla a CSV.
    [Tags]  Automatico   SYS   PAT-SYS-10    PAT-148
    Given existe un usuario registrado activo con permisos "common" y "case_taker" en la DB
    And existe el cliente en la base de datos:
        ...    Romina    Cugat    DOCUMENT    32165498    FEMALE    1996-06-23
        ...    "Av Poeta Lugones 12"    5012    SINGLE    HOUSE    COMPLETE_UNIVERSITY
        ...    romina96@gmail.com
    And existe el cliente en la base de datos:
        ...    Pedro    Cugat    DOCUMENT    22145685    FEMALE    1980-06-25
        ...    "Av Poeta Lugones 12"    5012    SINGLE    HOUSE    COMPLETE_UNIVERSITY
        ...    pedro80@gmail.com
    And se accedió a la plataforma como usuario "Tomador de Caso"

    When se navegó a la pestaña "Control Panel - Clients"
    
    Then la tabla debería contener 2 filas
    And la tabla debería contener el cliente:
        ...    32165498    Romina    Cugat    Document    Female    1996-06-23
        ...    Av Poeta Lugones 12    5,012    Single    House    Complete University
        ...    romina96@gmail.com
    And la tabla debería contener el cliente:
        ...    22145685    Pedro    Cugat    Document    Female    1980-06-25
        ...    Av Poeta Lugones 12    5,012    Single    House    Complete University
        ...    pedro80@gmail.com


    When se descarga el csv de la tabla

    Then el archivo se debería haber descargado correctamente
    And el archivo de clientes descargado debería ser el esperado 'expected_clients.csv'

    When se crea el filtro "First Name" con "Romina"

    Then la tabla debería contener 1 filas
    And la tabla debería contener el cliente:
        ...    32165498    Romina    Cugat    Document    Female    1996-06-23
        ...    Av Poeta Lugones 12    5,012    Single    House    Complete University
        ...    romina96@gmail.com

    When se descarga el csv de la tabla

    Then el archivo se debería haber descargado correctamente
    And el archivo de clientes descargado debería ser el esperado 'expected_filter_clients.csv'