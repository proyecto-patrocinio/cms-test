*** Settings ***
Documentation   Keywords para manejo de la base de datos postgres.

Library  SeleniumLibrary
Library  String
Library  DatabaseLibrary

Resource    ../../settings.robot


*** Keywords ***

#####################################################################
# Conections

Conectar a Base de Datos existente
    [Documentation]    Conexión a base de datos que usa la unidad con sus credenciales.
    ...                Utilizada como paso previo a la ejecución de querys
    ...                a una base de datos ya creada.
    Conectar a Base de Datos "${DB_NAME}"

Conectar a Base de Datos "${DATABASE_TO_CONNECT}"
    [Documentation]    Esta instancia se utiliza para conectar a una base de datos según si fue creada anteriormente o no.
    Connect To Database
    ...    dbapiModuleName=psycopg2
    ...    dbName=${DATABASE_TO_CONNECT}
    ...    dbUsername=${DATABASE_USER}
    ...    dbPassword=${DATABASE_PASSWORD}
    ...    dbHost=${DATABASE_IP}
    ...    dbPort=${DB_PORT}
    Set Auto Commit     True

#####################################################################
# Gets

Obtener el nuevo usuario de la DB
    [Documentation]    Se conecta a la base de datos y se obtiene el ultimo usuario registrado.
    Conectar a Base de Datos existente
    ${QUERY}    Set Variable    SELECT * FROM auth_user ORDER BY id ASC;
    ${RESULT}    Query    ${QUERY}
    RETURN    ${RESULT[-1]}
########################################################################
# Clear

Limpiar base de datos
    [Documentation]    Limpia todas la tablas, ignorando las de inicialización como
    ...    la tabla de localidades, grupos, permisos, etc.
    Conectar a Base de Datos existente
    Execute Sql String    DELETE from "Clients_child";
    Execute Sql String    DELETE from "Clients_tel";
    Execute Sql String    DELETE from "Clients_patrimony";
    Execute Sql String    DELETE from "Clients_family";
    Execute Sql String    DELETE from "Consultation_requestconsultation";
    Execute Sql String    DELETE from "Consultation_consultation";
    Execute Sql String    DELETE from "Clients_client";
    Execute Sql String    DELETE from "authtoken_token";
    Execute Sql String    DELETE from "account_emailaddress";
    Execute Sql String    DELETE from "account_emailconfirmation";
    Execute Sql String    DELETE from "auth_user";
    Execute Sql String    DELETE from "Panel_panel";
    Execute Sql String    DELETE from "Card_card";
    Execute Sql String    DELETE from "Comment_file";
    Execute Sql String    DELETE from "Comment_comment";
    Execute Sql String    DELETE from "BoardUser_boarduser";
    Execute Sql String    DELETE from "Board_board";
    Execute Sql String    DELETE from "Calendar_event";
    Execute Sql String    DELETE from "Calendar_calendar";
    Disconnect From Database

