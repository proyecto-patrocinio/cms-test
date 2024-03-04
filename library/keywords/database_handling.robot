*** Settings ***
Documentation   Keywords para manejo de la base de datos postgres.

Library  SeleniumLibrary
Library  String
Library  DatabaseLibrary
Library    DateTime

Resource    ../../settings.robot


*** Keywords ***

#####################################################################
# Conections

Conectar a Base de Datos existente
    [Documentation]    Conexion a base de datos que usa la unidad con sus credenciales.
    ...                Utilizada como paso previo a la ejecucion de querys
    ...                a una base de datos ya creada.
    Conectar a Base de Datos "${DB_NAME}"

Conectar a Base de Datos "${DATABASE_TO_CONNECT}"
    [Documentation]    Esta instancia se utiliza para conectar a una base de datos segun si fue creada anteriormente o no.
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
    ${RESULT} =    Query    ${QUERY}
    Disconnect From Database
    RETURN    ${RESULT[-1]}

Obtener consulta con TAG '${TAG}' de la DB
    [Documentation]    Obtiene la consulta segun el ${TAG}. Si no la encuentra devuelve ${None}.
    Conectar a Base de Datos existente
    ${QUERY}    Set Variable    SELECT * FROM "Consultation_consultation" where tag = '${TAG}' LIMIT 1;
    ${RESULT} =    Query    ${QUERY}
    ${FIRST_RESULT} =    Set Variable If    ${RESULT}    ${RESULT[0]}    ${None}
    Disconnect From Database
    RETURN    ${FIRST_RESULT}

Obtener consultante con ${KEY_TYPE} '${VALUE}' de la DB
    [Documentation]    Obtiene el consultante segun su ${KEY_TYPE} (id, dni). Si no lo encuentra devuelve ${None}.
    Conectar a Base de Datos existente
    ${QUERY}    Set Variable    SELECT * FROM "Clients_client" where ${KEY_TYPE} = '${VALUE}';
    ${RESULT} =    Query    ${QUERY}
    ${FIRST_RESULT} =    Set Variable If    ${RESULT}    ${RESULT[0]}    ${None}
    Disconnect From Database
    RETURN    ${FIRST_RESULT}

Obtener el ID del board titulado "${TITLE_BOARD}" de la DB
    [Documentation]    Obtiene el ID del board segun el titulo. Si no lo encuentra devuelve ${None}.
    Conectar a Base de Datos existente
    ${QUERY}    Set Variable    SELECT * FROM "Board_board" where title = '${TITLE_BOARD}';
    ${RESULT} =    Query    ${QUERY}
    ${FIRST_RESULT} =    Set Variable If    ${RESULT}    ${RESULT[0][0]}    ${None}
    Disconnect From Database
    RETURN    ${FIRST_RESULT}

Obtener el ID del panel titulado "${PANEL_NAME}"
    Conectar a Base de Datos existente
    ${QUERY}    Set Variable    SELECT * FROM "Panel_panel" where title = '${PANEL_NAME}';
    ${RESULT} =    Query    ${QUERY}
    ${FIRST_RESULT} =    Set Variable If    ${RESULT}    ${RESULT[0][0]}    ${None}
    Disconnect From Database
    RETURN    ${FIRST_RESULT}

Obtener el token de la ultima sesion
    Conectar a Base de Datos existente
    ${QUERY}    Set Variable    SELECT "key" FROM public.authtoken_token ORDER BY created ASC;
    ${RESULT} =    Query    ${QUERY}
    ${LAST_RESULT} =    Set Variable If    ${RESULT}    ${RESULT[-1]}    ${None}
    ${TOKEN}    Set Variable    ${LAST_RESULT[0]}
    Disconnect From Database
    RETURN    ${TOKEN}

Obtener la Request Consultation para la consulta con ID "${CONSULT_ID}"
    Conectar a Base de Datos existente
    ${QUERY}    Set Variable    SELECT * FROM public."Consultation_requestconsultation" where consultation_id = ${CONSULT_ID};
    ${RESULT} =    Query    ${QUERY}
    ${FIRST_RESULT} =    Set Variable If    ${RESULT}    ${RESULT[0]}    ${None}
    Disconnect From Database
    RETURN    ${FIRST_RESULT}

Obtener el comentario "${COMMENT}" de la DB
    Conectar a Base de Datos existente
    ${QUERY}    Set Variable    SELECT * FROM public."Comment_comment" where text = '${COMMENT}';
    ${RESULT} =    Query    ${QUERY}
    ${FIRST_RESULT} =    Set Variable If    ${RESULT}    ${RESULT[0]}    ${None}
    Disconnect From Database
    RETURN    ${FIRST_RESULT}

Obtener el evento "${EVENT_TITLE}" de la card con ID ${CARD_ID} en DB
    [Documentation]    Obtiene de la base de datos, el evento de titulado $EVENT_TITLE,
    ...    para la consulta con ID proporcionado.
    ...    Los datos retornados son: id, title, description , start , end y card_id.
    @{QUERY}    Create List
    ...    SELECT e.id, e.title, e.description , e."start" , e."end", c.card_id
    ...    FROM public."Calendar_event" e
    ...    JOIN public."Calendar_calendar" c ON e.calendar_id = c.id
    ...    WHERE e.title = '${EVENT_TITLE}' AND c.card_id = ${CARD_ID};
    ${QUERY}    Evaluate    ' '.join($QUERY)

    Conectar a Base de Datos existente
    ${RESULT} =    Query    ${QUERY}
    ${FIRST_RESULT} =    Set Variable If    ${RESULT}    ${RESULT[0]}    ${None}
    Disconnect From Database
    RETURN    ${FIRST_RESULT}

Obtener el campo "${FIELD}" del consultante con id_value '${DNI}' de la DB
    [Documentation]    Obtiene el campo solicitado del consultante con DNI ${DNI}.
    ...    Para la obtencion del campo, se tiene en cuenta todas las relaciones
    ...    uno a uno del consultante (Familia, Patrimonio y Consultante).
    @{QUERY}    Create List
    ...    SELECT ${FIELD}
    ...    FROM public."Clients_client" cc
    ...    JOIN public."Clients_family" cf ON cc.id = cf.id_id
    ...    JOIN public."Clients_patrimony" cp ON cp.id_id = cc.id
    ...    WHERE cc.id_value = '${DNI}';
    ${QUERY}    Evaluate    ' '.join($QUERY)

    Conectar a Base de Datos existente
    ${RESULT} =    Query    ${QUERY}
    ${FIRST_RESULT} =    Set Variable If    ${RESULT}    ${RESULT[0]}    ${None}
    Disconnect From Database
    RETURN    ${FIRST_RESULT}

######################################################################
# Inserts

Insertar consultante en la DB
    [Arguments]    ${FIRST_NAME}    ${LAST_NAME}    ${ID_TYPE}    ${ID_VALUE}    ${SEX}    ${BIRTH_DATE}    ${ADDRESS}    ${POSTAL}    ${MARITAL_STATUS}    ${HOUSING_TYPE}    ${STUDIES}    ${EMAIL}    ${LOCALITY_ID}
    Conectar a Base de Datos existente
    ${KEYS}    Set Variable    first_name,last_name,id_type,id_value,sex,birth_date,address,postal,marital_status,housing_type,studies,email,locality_id
    ${VALUES}    Set Variable    '${FIRST_NAME}','${LAST_NAME}','${ID_TYPE}','${ID_VALUE}','${SEX}','${BIRTH_DATE}','${ADDRESS}',${POSTAL},'${MARITAL_STATUS}','${HOUSING_TYPE}','${STUDIES}','${EMAIL}',${LOCALITY_ID}
    ${QUERY}    Set Variable    INSERT INTO public."Clients_client" (${KEYS}) VALUES (${VALUES});
    Execute SQL String    ${QUERY}
    Disconnect From Database

Insertar el board "${TITLE}" en la DB
    [Documentation]    Carga a la base de datos un nuevo board con titulo ${TITLE}.
    Conectar a Base de Datos existente
    ${QUERY}    Set Variable    INSERT INTO public."Board_board" (title) VALUES ('${TITLE}');
    Execute SQL String    ${QUERY}
    Disconnect From Database

Insertar la relacion board "${BOARD_ID}" - user "${USER_ID}"
    [Documentation]    Carga a la DB, la relacion board-user segun los argumentos.
    Conectar a Base de Datos existente
    ${CURRENT_DATE}    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${KEYS}    Set Variable    created_at,board_id,user_id
    ${VALUES}    Set Variable    '${CURRENT_DATE}',${BOARD_ID},${USER_ID}
    ${QUERY}    Set Variable    INSERT INTO public."BoardUser_boarduser" (${KEYS}) VALUES (${VALUES});
    Execute SQL String    ${QUERY}
    Disconnect From Database

Insertar consulta a la DB
    [Documentation]    Carga a DB, una nueva consulta con los parametros otorgados. Supone un usuario existente.
    [Arguments]    ${CLIENT_ID}    ${TAG}   ${OPP}    ${DESC}    ${AVAILABILITY}    ${PROGRESS}
    Conectar a Base de Datos existente
    ${CURRENT_DATE}    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${KEYS}    Set Variable    availability_state, progress_state,"time_stamp", start_time, description, opponent, tag, client_id
    ${VALUES}    Set Variable    '${AVAILABILITY}','${PROGRESS}','${CURRENT_DATE}','${CURRENT_DATE}','${DESC}','${OPP}','${TAG}',${CLIENT_ID}
    ${QUERY}    Set Variable    INSERT INTO public."Consultation_consultation" (${KEYS}) VALUES (${VALUES});
    Execute SQL String    ${QUERY}
    Disconnect From Database

Crear un panel "${PANEL_NAME}" en el board con ID "${BOARD_ID}" desde la DB
    [Documentation]    Crea un panel para el board con ID ${BOARD_ID}.
    Conectar a Base de Datos existente
    ${KEYS}    Set Variable    title,board_id
    ${VALUES}    Set Variable    '${PANEL_NAME}',${BOARD_ID}
    ${QUERY}    Set Variable    INSERT INTO public."Panel_panel" (${KEYS}) VALUES (${VALUES});
    Execute SQL String    ${QUERY}
    Disconnect From Database

Crear una card para la consulta "${TAG}" con ID "${CONSULT_ID}" en el panel con ID "${PANEL_ID}" desde la DB
    [Documentation]    Crea una card, en el panel especificado, relacionada a la consulta especificada.
    Conectar a Base de Datos existente
    ${KEYS}    Set Variable    consultation_id,tag,panel_id
    ${VALUES}    Set Variable    ${CONSULT_ID},'${TAG}',${PANEL_ID}
    ${QUERY}    Set Variable    INSERT INTO public."Card_card" (${KEYS}) VALUES (${VALUES});
    Execute SQL String    ${QUERY}
    Disconnect From Database

Crear una Request Consultation de la consulta con ID "${CONSULT_ID}" al board con ID "${BOARD_ID}" desde la DB
    Conectar a Base de Datos existente
    ${KEYS}    Set Variable    consultation_id,destiny_board_id
    ${VALUES}    Set Variable    ${CONSULT_ID},${BOARD_ID}
    ${QUERY}    Set Variable    INSERT INTO public."Consultation_requestconsultation" (${KEYS}) VALUES (${VALUES});
    Execute SQL String    ${QUERY}
    Disconnect From Database

########################################################################
# Clear

Limpiar base de datos
    [Documentation]    Limpia todas la tablas, ignorando las de inicializacion como
    ...    la tabla de localidades, grupos, permisos, etc.
    Conectar a Base de Datos existente
    Execute Sql String    DELETE from "Clients_child";
    Execute Sql String    DELETE from "Clients_tel";
    Execute Sql String    DELETE from "Clients_patrimony";
    Execute Sql String    DELETE from "Clients_family";
    Execute Sql String    DELETE from "Consultation_requestconsultation";
    Execute Sql String    DELETE from "Calendar_event";
    Execute Sql String    DELETE from "Calendar_calendar";
    Execute Sql String    DELETE from "Card_card";
    Execute Sql String    DELETE from "Comment_comment";
    Execute Sql String    DELETE from "Consultation_consultation";
    Execute Sql String    DELETE from "Clients_client";
    Execute Sql String    DELETE from "authtoken_token";
    Execute Sql String    DELETE from "account_emailaddress";
    Execute Sql String    DELETE from "account_emailconfirmation";
    Execute Sql String    DELETE from "django_admin_log";
    Execute Sql String    DELETE from "auth_user_groups";
    Execute Sql String    DELETE from "BoardUser_boarduser";
    Execute Sql String    DELETE from "auth_user";
    Execute Sql String    DELETE from "Panel_panel";
    Execute Sql String    DELETE from "Comment_file";
    Execute Sql String    DELETE from "Board_board";
    Disconnect From Database
