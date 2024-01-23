*** Settings ***
Documentation    Keywords utilitarias.

Library  SeleniumLibrary
Library  OperatingSystem

Resource    ../../settings.robot

*** Keywords ***
Abrir la plataforma en el navegador
    Open Browser    http://localhost:80/   ${BROWSER}

Cerrar el navegador
    Close Browser
