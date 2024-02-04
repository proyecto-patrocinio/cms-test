*** Settings ***
Documentation    Keywords para manejo de entorno y archivos de testing.

Library  OperatingSystem    WITH NAME    OS
Library  SeleniumLibrary
Library  ImapLibrary2
Library  String
Library  DatabaseLibrary
Library  JSONLibrary
Library  Collections

Resource        ../../settings.robot

*** Keywords ***

# =============================================================================
# Generales

Preparar una estructura limpia de directorios
    [Documentation]    Limpia el directorio de trabajo temporal y crea nuevas carpetas.
    Log to Console    Preparando estructura limpia de directorios...
    OS.Remove Directory    ${TEST_TEMP_FOLDER}    recursive=True
    OS.Create Directory    ${TEST_TEMP_FOLDER}


Recolectar las evidencias
    [Documentation]    Mueve el directorio de trabajo temporal de la unidad a una
    ...                carpeta de evidencias segun el TestID configurado anteriormente.
    Log to Console      Preparando directorio de almacenamiento de evidencias...
    ${TEST_EVIDENCES_FOLDER} =    Set variable    ${EVIDENCES_FOLDER}/${TEST_ID}
    OS.Remove Directory    ${TEST_EVIDENCES_FOLDER}    recursive=True

    OS.Move Directory      ${TEST_TEMP_FOLDER}
    ...    ${EVIDENCES_FOLDER}/${TEST_ID}
    Log to Console      Evidencias recolectadas.

Existe el archivo local
    [Documentation]    Valida que un archivo exista usando OperatingSystem.
    ...                Retorna True o False.
    [Arguments]    ${FILEPATH_TO_CHECK}
    ${RESULT_STATUS} =    Run Keyword And Return Status    OS.File Should Exist    ${FILEPATH_TO_CHECK}
    IF    $RESULT_STATUS == "PASS"
        ${DOES_EXIST} =    Set Variable    ${TRUE}
    ELSE
        ${DOES_EXIST} =    Set Variable    ${FALSE}
    END
    RETURN    ${DOES_EXIST}

# =============================================================================
# Identificacion de Test ID

Configurar el ID del Test
    [Documentation]    Busca un tag que comience con la subcadena del proyecto y lo configura
    ...                como variable global con fines de administración de tests.
    ${HAS_TAGS} =    Run Keyword And Return Status
    ...              Should Not Be Empty    ${TEST_TAGS}
    IF    $HAS_TAGS == False
        Fail    No se han definido Tags para el Test. Se requiere al menos un identificador.
    END

    FOR    ${TAG_BEGINNING}    IN    @{TEST_ID_BEGINNING_TAGS}
        ${TEST_ID} =    Buscar tag que comience con la cadena "${TAG_BEGINNING}"
        IF    $TEST_ID != "UNDEFINED"
            Set Global Variable    ${TEST_ID}
            Exit For Loop
        END
    END
    IF    $TEST_ID == "UNDEFINED"
        Fail     No se pudo identificar un Tag identificador del Test.
    END

Buscar tag que comience con la cadena "${TAG_BEGINNING}"
    [Documentation]    Busca el Tag identificador del escenario.
    FOR    ${TAG}    IN    @{TEST_TAGS}
        ${DOES_TAG_MATCH} =    Evaluate    $TAG.startswith($TAG_BEGINNING)
        IF    ${DOES_TAG_MATCH}
            ${OUTPUT_STRING} =    Set Variable    ${TAG}
            Exit For Loop
        ELSE
            ${OUTPUT_STRING} =    Set Variable    UNDEFINED
        END
    END
    RETURN    ${OUTPUT_STRING}

# =============================================================================
# Selenium
Se limpian las capturas realizadas por selenium
    OS.Remove Files    selenium-screenshot-*

Recolectar captura de pantalla
    [Documentation]    Recolecta las capturas de pantalla y las almacena en el directorio temporal
    [Arguments]    ${NAME_SCREENSHOT}=screenshot
    ${INDEX_SCREENSHOT} =    Get Variable Value    $INDEX_SCREENSHOT    ${0}
    ${INDEX_SCREENSHOT} =    Evaluate    int($INDEX_SCREENSHOT)+1
    Set Test Variable   ${INDEX_SCREENSHOT}
    Capture Page Screenshot    ${TEST_TEMP_FOLDER}/${INDEX_SCREENSHOT}_${NAME_SCREENSHOT}.png
