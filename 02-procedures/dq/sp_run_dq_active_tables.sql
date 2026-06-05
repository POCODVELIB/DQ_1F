use role sysadmin; --- à revoir 


CREATE OR REPLACE PROCEDURE DB_MEDIATION_BRZ_DEV.SC_CONTROL.SP_RUN_DQ_ACTIVE_TABLES()
RETURNS VARIANT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    V_I          NUMBER DEFAULT 1;
    V_NB_FEEDS   NUMBER DEFAULT 0;
    V_FEED_ID    VARCHAR;
    V_RAW_TABLE  VARCHAR;
    V_SQL        VARCHAR;
BEGIN

    SELECT COUNT(*)
    INTO :V_NB_FEEDS
    FROM DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_FEED
    WHERE IS_ACTIVE = TRUE;

    WHILE (V_I <= V_NB_FEEDS) DO

        SELECT
            FEED_ID,
            RAW_TABLE
        INTO
            :V_FEED_ID,
            :V_RAW_TABLE
        FROM (
            SELECT
                FEED_ID,
                RAW_TABLE,
                ROW_NUMBER() OVER (ORDER BY FEED_ID) AS RN
            FROM DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_FEED
            WHERE IS_ACTIVE = TRUE
        )
        WHERE RN = :V_I;

        DELETE FROM DB_MEDIATION_BRZ_DEV.SC_CONTROL.DQ_REJECT_EVENT
        WHERE FEED_ID = :V_FEED_ID;

        /* ============================================================
           NULLABLE
           ============================================================ */

        V_SQL := '
            INSERT INTO DB_MEDIATION_BRZ_DEV.SC_CONTROL.DQ_REJECT_EVENT (
                FEED_ID,
                RAW_TABLE,
                CONTROL_ID,
                RECORD_KEY,
                LOAD_TS,
                ERROR_CODE,
                ERROR_MESSAGE,
                ERROR_FIELD,
                ERROR_VALUE,
                ON_FAILURE_ACTION,
                RAW_RECORD,
                STATUS,
                CREATED_AT
            )
            SELECT
                ''' || V_FEED_ID || ''',
                ''' || V_RAW_TABLE || ''',
                C.CONTROL_ID,
                R.RECORD_KEY,
                R.LOAD_TS,
                C.ERROR_CODE,
                C.ERROR_MESSAGE,
                C.PARAMS:json_path::VARCHAR,
                GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR)::VARCHAR,
                C.ON_FAILURE_ACTION,
                R.RAW_RECORD,
                ''NEW'',
                CURRENT_TIMESTAMP()
            FROM DB_MEDIATION_BRZ_DEV.SC_RAW.' || V_RAW_TABLE || ' R
            JOIN DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES C
              ON C.FEED_ID = ''' || V_FEED_ID || '''
             AND C.CONTROL_TYPE = ''NULLABLE''
             AND C.IS_ACTIVE = TRUE
            WHERE
                GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR) IS NULL
                OR TRIM(GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR)::VARCHAR) = ''''
        ';

        EXECUTE IMMEDIATE V_SQL;


        /* ============================================================
           ALLOWED_VALUES
           ============================================================ */

        V_SQL := '
            INSERT INTO DB_MEDIATION_BRZ_DEV.SC_CONTROL.DQ_REJECT_EVENT (
                FEED_ID,
                RAW_TABLE,
                CONTROL_ID,
                RECORD_KEY,
                LOAD_TS,
                ERROR_CODE,
                ERROR_MESSAGE,
                ERROR_FIELD,
                ERROR_VALUE,
                ON_FAILURE_ACTION,
                RAW_RECORD,
                STATUS,
                CREATED_AT
            )
            SELECT
                ''' || V_FEED_ID || ''',
                ''' || V_RAW_TABLE || ''',
                C.CONTROL_ID,
                R.RECORD_KEY,
                R.LOAD_TS,
                C.ERROR_CODE,
                C.ERROR_MESSAGE,
                C.PARAMS:json_path::VARCHAR,
                GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR)::VARCHAR,
                C.ON_FAILURE_ACTION,
                R.RAW_RECORD,
                ''NEW'',
                CURRENT_TIMESTAMP()
            FROM DB_MEDIATION_BRZ_DEV.SC_RAW.' || V_RAW_TABLE || ' R
            JOIN DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES C
              ON C.FEED_ID = ''' || V_FEED_ID || '''
             AND C.CONTROL_TYPE = ''ALLOWED_VALUES''
             AND C.IS_ACTIVE = TRUE
            WHERE
                GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR) IS NULL
                OR TRIM(GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR)::VARCHAR) = ''''
                OR NOT ARRAY_CONTAINS(
                    TO_VARIANT(GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR)::VARCHAR),
                    C.PARAMS:allowed_values
                )
        ';

        EXECUTE IMMEDIATE V_SQL;


        /* ============================================================
           AMOUNT_POSITIVE
           ============================================================ */

        V_SQL := '
            INSERT INTO DB_MEDIATION_BRZ_DEV.SC_CONTROL.DQ_REJECT_EVENT (
                FEED_ID,
                RAW_TABLE,
                CONTROL_ID,
                RECORD_KEY,
                LOAD_TS,
                ERROR_CODE,
                ERROR_MESSAGE,
                ERROR_FIELD,
                ERROR_VALUE,
                ON_FAILURE_ACTION,
                RAW_RECORD,
                STATUS,
                CREATED_AT
            )
            SELECT
                ''' || V_FEED_ID || ''',
                ''' || V_RAW_TABLE || ''',
                C.CONTROL_ID,
                R.RECORD_KEY,
                R.LOAD_TS,
                C.ERROR_CODE,
                C.ERROR_MESSAGE,
                C.PARAMS:json_path::VARCHAR,
                GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR)::VARCHAR,
                C.ON_FAILURE_ACTION,
                R.RAW_RECORD,
                ''NEW'',
                CURRENT_TIMESTAMP()
            FROM DB_MEDIATION_BRZ_DEV.SC_RAW.' || V_RAW_TABLE || ' R
            JOIN DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES C
              ON C.FEED_ID = ''' || V_FEED_ID || '''
             AND C.CONTROL_TYPE = ''AMOUNT_POSITIVE''
             AND C.IS_ACTIVE = TRUE
            WHERE
                TRY_TO_DECIMAL(GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR)::VARCHAR, 18, 4) IS NULL
                OR TRY_TO_DECIMAL(GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR)::VARCHAR, 18, 4) <= 0
        ';

        EXECUTE IMMEDIATE V_SQL;


        /* ============================================================
           DATE_FORMAT
           ============================================================ */

        V_SQL := '
            INSERT INTO DB_MEDIATION_BRZ_DEV.SC_CONTROL.DQ_REJECT_EVENT (
                FEED_ID,
                RAW_TABLE,
                CONTROL_ID,
                RECORD_KEY,
                LOAD_TS,
                ERROR_CODE,
                ERROR_MESSAGE,
                ERROR_FIELD,
                ERROR_VALUE,
                ON_FAILURE_ACTION,
                RAW_RECORD,
                STATUS,
                CREATED_AT
            )
            SELECT
                ''' || V_FEED_ID || ''',
                ''' || V_RAW_TABLE || ''',
                C.CONTROL_ID,
                R.RECORD_KEY,
                R.LOAD_TS,
                C.ERROR_CODE,
                C.ERROR_MESSAGE,
                C.PARAMS:json_path::VARCHAR,
                GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR)::VARCHAR,
                C.ON_FAILURE_ACTION,
                R.RAW_RECORD,
                ''NEW'',
                CURRENT_TIMESTAMP()
            FROM DB_MEDIATION_BRZ_DEV.SC_RAW.' || V_RAW_TABLE || ' R
            JOIN DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES C
              ON C.FEED_ID = ''' || V_FEED_ID || '''
             AND C.CONTROL_TYPE = ''DATE_FORMAT''
             AND C.IS_ACTIVE = TRUE
            WHERE
                GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR) IS NULL
                OR TRY_TO_DATE(GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR)::VARCHAR) IS NULL
        ';

        EXECUTE IMMEDIATE V_SQL;


        /* ============================================================
           DATE_NOT_FUTURE
           ============================================================ */

        V_SQL := '
            INSERT INTO DB_MEDIATION_BRZ_DEV.SC_CONTROL.DQ_REJECT_EVENT (
                FEED_ID,
                RAW_TABLE,
                CONTROL_ID,
                RECORD_KEY,
                LOAD_TS,
                ERROR_CODE,
                ERROR_MESSAGE,
                ERROR_FIELD,
                ERROR_VALUE,
                ON_FAILURE_ACTION,
                RAW_RECORD,
                STATUS,
                CREATED_AT
            )
            SELECT
                ''' || V_FEED_ID || ''',
                ''' || V_RAW_TABLE || ''',
                C.CONTROL_ID,
                R.RECORD_KEY,
                R.LOAD_TS,
                C.ERROR_CODE,
                C.ERROR_MESSAGE,
                C.PARAMS:json_path::VARCHAR,
                GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR)::VARCHAR,
                C.ON_FAILURE_ACTION,
                R.RAW_RECORD,
                ''NEW'',
                CURRENT_TIMESTAMP()
            FROM DB_MEDIATION_BRZ_DEV.SC_RAW.' || V_RAW_TABLE || ' R
            JOIN DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES C
              ON C.FEED_ID = ''' || V_FEED_ID || '''
             AND C.CONTROL_TYPE = ''DATE_NOT_FUTURE''
             AND C.IS_ACTIVE = TRUE
            WHERE
                TRY_TO_DATE(GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR)::VARCHAR) IS NOT NULL
                AND TRY_TO_DATE(GET_PATH(R.RAW_RECORD, C.PARAMS:json_path::VARCHAR)::VARCHAR) > CURRENT_DATE()
        ';

        EXECUTE IMMEDIATE V_SQL;


        /* ============================================================
           DATE_ORDER
           Exemple : date_paiement >= date_soin
           ============================================================ */

        V_SQL := '
            INSERT INTO DB_MEDIATION_BRZ_DEV.SC_CONTROL.DQ_REJECT_EVENT (
                FEED_ID,
                RAW_TABLE,
                CONTROL_ID,
                RECORD_KEY,
                LOAD_TS,
                ERROR_CODE,
                ERROR_MESSAGE,
                ERROR_FIELD,
                ERROR_VALUE,
                ON_FAILURE_ACTION,
                RAW_RECORD,
                STATUS,
                CREATED_AT
            )
            SELECT
                ''' || V_FEED_ID || ''',
                ''' || V_RAW_TABLE || ''',
                C.CONTROL_ID,
                R.RECORD_KEY,
                R.LOAD_TS,
                C.ERROR_CODE,
                C.ERROR_MESSAGE,
                C.PARAMS:date_max_path::VARCHAR,
                GET_PATH(R.RAW_RECORD, C.PARAMS:date_max_path::VARCHAR)::VARCHAR,
                C.ON_FAILURE_ACTION,
                R.RAW_RECORD,
                ''NEW'',
                CURRENT_TIMESTAMP()
            FROM DB_MEDIATION_BRZ_DEV.SC_RAW.' || V_RAW_TABLE || ' R
            JOIN DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES C
              ON C.FEED_ID = ''' || V_FEED_ID || '''
             AND C.CONTROL_TYPE = ''DATE_ORDER''
             AND C.IS_ACTIVE = TRUE
            WHERE
                TRY_TO_DATE(GET_PATH(R.RAW_RECORD, C.PARAMS:date_min_path::VARCHAR)::VARCHAR) IS NOT NULL
                AND TRY_TO_DATE(GET_PATH(R.RAW_RECORD, C.PARAMS:date_max_path::VARCHAR)::VARCHAR) IS NOT NULL
                AND TRY_TO_DATE(GET_PATH(R.RAW_RECORD, C.PARAMS:date_max_path::VARCHAR)::VARCHAR)
                    < TRY_TO_DATE(GET_PATH(R.RAW_RECORD, C.PARAMS:date_min_path::VARCHAR)::VARCHAR)
        ';

        EXECUTE IMMEDIATE V_SQL;


       /* ============================================================
   DUPLICATE_VALUE
   Détection de doublons source sur un champ métier
   ============================================================ */

V_SQL := '
    INSERT INTO DB_MEDIATION_BRZ_DEV.SC_CONTROL.DQ_REJECT_EVENT (
        FEED_ID,
        RAW_TABLE,
        CONTROL_ID,
        RECORD_KEY,
        LOAD_TS,
        ERROR_CODE,
        ERROR_MESSAGE,
        ERROR_FIELD,
        ERROR_VALUE,
        ON_FAILURE_ACTION,
        RAW_RECORD,
        STATUS,
        CREATED_AT
    )
    WITH CONTROLS AS (
        SELECT
            CONTROL_ID,
            PARAMS:json_path::VARCHAR AS JSON_PATH,
            ERROR_CODE,
            ERROR_MESSAGE,
            ON_FAILURE_ACTION
        FROM DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES
        WHERE FEED_ID = ''' || V_FEED_ID || '''
          AND CONTROL_TYPE = ''DUPLICATE_VALUE''
          AND IS_ACTIVE = TRUE
    ),
    RAW_VALUES AS (
        SELECT
            C.CONTROL_ID,
            C.JSON_PATH,
            C.ERROR_CODE,
            C.ERROR_MESSAGE,
            C.ON_FAILURE_ACTION,
            R.RECORD_KEY,
            R.LOAD_TS,
            R.RAW_RECORD,
            GET_PATH(R.RAW_RECORD, C.JSON_PATH)::VARCHAR AS CHECK_VALUE
        FROM DB_MEDIATION_BRZ_DEV.SC_RAW.' || V_RAW_TABLE || ' R
        JOIN CONTROLS C
          ON 1 = 1
        WHERE GET_PATH(R.RAW_RECORD, C.JSON_PATH) IS NOT NULL
    ),
    DUP_VALUES AS (
        SELECT
            CONTROL_ID,
            CHECK_VALUE
        FROM RAW_VALUES
        GROUP BY
            CONTROL_ID,
            CHECK_VALUE
        HAVING COUNT(*) > 1
    )
    SELECT
        ''' || V_FEED_ID || ''',
        ''' || V_RAW_TABLE || ''',
        RV.CONTROL_ID,
        RV.RECORD_KEY,
        RV.LOAD_TS,
        RV.ERROR_CODE,
        RV.ERROR_MESSAGE,
        RV.JSON_PATH,
        RV.CHECK_VALUE,
        RV.ON_FAILURE_ACTION,
        RV.RAW_RECORD,
        ''NEW'',
        CURRENT_TIMESTAMP()
    FROM RAW_VALUES RV
    JOIN DUP_VALUES DV
      ON RV.CONTROL_ID = DV.CONTROL_ID
     AND RV.CHECK_VALUE = DV.CHECK_VALUE
';

EXECUTE IMMEDIATE V_SQL;

        V_I := V_I + 1;

    END WHILE;

    RETURN OBJECT_CONSTRUCT(
        'status', 'DONE',
        'processed_feeds', V_NB_FEEDS
    );

EXCEPTION
    WHEN OTHER THEN
        RETURN OBJECT_CONSTRUCT(
            'status', 'FAILED',
            'message', SQLERRM
        );

END;
$$;
