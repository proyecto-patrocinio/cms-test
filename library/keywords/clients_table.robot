*** Settings ***
Documentation     keywords utilizadas en el manejo de la tabla de clientes
...    de la página del panel de control.

Library  SeleniumLibrary

Resource  ../../constants.robot


*** Keywords ***
Seleccionar la opción "${OPTION}" de la columna "${CURRENT_KEY}"
    [Documentation]    Selecciona la opción elegida para campo especificado.
    ...    Esta keyword funciona para columnas de tipo "selector".
    ...    En caso de no encontrar el elemento visible, esta keyword supone la
    ...    variable de test PREV_LOCATOR seteada con el elemento de tipo "text"
    ...    mas cercano del lado izquierdo al elemento deseado.
    ${ROW_LOCATOR}    Set Variable    xpath=//div[contains(@class,"MuiDataGrid-virtualScrollerRenderZone")]
    ${CURRENT_LOCATOR}    Set Variable    ${ROW_LOCATOR}//div[@data-field="${CURRENT_KEY}"]/div

    ${IS_VISIBLE}    Run Keyword And Return Status
    ...    Element Should Be Visible    ${CURRENT_LOCATOR}
    IF    ${IS_VISIBLE}
        Click Element    ${CURRENT_LOCATOR}
    ELSE
        Press Keys    ${PREV_LOCATOR}    ${TAB_KEY}
        Wait Until Element Is Visible    ${CURRENT_LOCATOR}
        Click Element    ${CURRENT_LOCATOR}
    END
    ${OPTION_LOCATOR}    Set Variable    xpath=//li[@data-value="${OPTION}"]
    Wait Until Element Is Visible    ${OPTION_LOCATOR}
    Click Element    ${OPTION_LOCATOR}

Escribir en la tabla de clientes
    [Documentation]    Ingresa un dato en un elemento de la tabla Clients,
    ...    de la página panel de control. Verifica si el elemento esta visible.
    ...    En caso de no estarlo, presiona la tecla tab del elemento anterior
    ...    y vuelve a intentar escribir.
    ...    Simula un scroll a la derecha, si el elemento no es visible.
    ...    Esta keyword, debe utilizarse en orden de izquierda a derecha
    ...    comenzando por primera vez con un elemento visible.
    [Arguments]    ${CURRENT_KEY}    ${VALUE}
    ${CURRENT_LOCATOR}    Set Variable    xpath=//div[@data-field="${CURRENT_KEY}"]//input

    ${IS_VISIBLE}    Run Keyword And Return Status
    ...    Element Should Be Visible    ${CURRENT_LOCATOR}
    IF    ${IS_VISIBLE}
        Input Text    ${CURRENT_LOCATOR}    ${VALUE}
    ELSE
        Press Keys    ${PREV_LOCATOR}    ${TAB_KEY}
        Wait Until Element Is Visible    ${CURRENT_LOCATOR}
        Input Text    ${CURRENT_LOCATOR}    ${VALUE}
    END
    # Se actualiza el ultimo elemento previo.
    ${PREV_LOCATOR} =    Set Variable    ${CURRENT_LOCATOR}
    Set Test Variable    ${PREV_LOCATOR}
