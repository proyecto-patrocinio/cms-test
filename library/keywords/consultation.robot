*** Settings ***
Documentation   Keywords para manejo de consultas.

Library  SeleniumLibrary
Library  String
Library  DatabaseLibrary

Resource    ../../settings.robot
Resource    testing_environment.robot
Resource    utils.robot


*** Keywords ***

Crear la consulta "${TAG}" con Cliente "${DNI}", oponente "${OPP}" y descripcion "${DESC}"
    [Documentation]    Se hace click sobre el botó "+" para agregar una nueva consulta.
    ...                Supone que ya esta en la página Consultancy.
    ...                Luego rellena el formulario y selecciona el botón aceptar.
    ...                Se asume que el cliente existe.
    Click Button    id=add-icon-button
    Wait Until Page Contains    Load New Consultation

    ${LOCATOR_DESC} =    Set Variable    xpath://textarea[@aria-invalid='false']

    Input Text    ${LOCATOR_DESC}   ${DESC}
    Input Text    name:opponent   ${OPP}
    Input Text    name:tag   ${TAG}
    Input Text    name:client   ${DNI}

    Press Keys    name:client    ARROW_DOWN
    Press Keys    name:client    ENTER
    Press Keys    name:client    RETURN

    Recolectar captura de pantalla
    Click Button    id=button-accept
    Sleep    1s

Abrir detalle de la consulta '${TAG}'
    [Documentation]    Abre el detalle de la consulta con el Tag proporcionado.
    ${TICKET_LOCATOR} =    Set Variable    xpath=//p[text()='${TAG}']
    Double Click Element    ${TICKET_LOCATOR}
    Wait Until Page Contains    Consultation Details

Cerrar Info de consulta
    [Documentation]    Cierra la ventana de detalle de consulta.
    Click Button    Close
