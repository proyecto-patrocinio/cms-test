*** Settings ***
Documentation    Keywords utilitarias.

Library  SeleniumLibrary
Library  OperatingSystem

Resource    ../../settings.robot

*** Keywords ***
Abrir la plataforma en el navegador
    Open Browser    ${PAGE_BASE_CMS}   ${BROWSER}

Cerrar el navegador
    Close Browser
