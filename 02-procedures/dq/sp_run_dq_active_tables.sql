use role sysadmin; 
CREATE OR REPLACE PROCEDURE DB_MEDIATION_BRZ_DEV.SC_CONTROL.SP_RUN_DQ_ACTIVE_TABLES()
RETURNS VARIANT
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    V_FEED_INDEX  NUMBER DEFAULT 1;
    V_NB_FEEDS    NUMBER DEFAULT 0;
    V_FEED_ID     VARCHAR;
    V_RAW_TABLE   VARCHAR;
    V_SQL         VARCHAR;
BEGIN

    SELECT COUNT(*)
    INTO :V_NB_FEEDS
    FROM DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_FEED
    WHERE IS_ACTIVE = TRUE;

    WHILE (V_FEED_INDEX <= V_NB_FEEDS) DO

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
        WHERE RN = :V_FEED_INDEX;

        DELETE FROM DB_MEDIATION_BRZ_DEV.SC_CONTROL.DQ_REJECT_EVENT
        WHERE FEED_ID = :V_FEED_ID;

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
                RAW_LINE,
                STATUS,
                CREATED_AT
            )

            WITH RAW_FIELDS AS (
                SELECT
                    R.RECORD_KEY,
                    R.LOAD_TS,
                    R.RAW_LINE,
                    M.FIELD_NAME,
                    M.TARGET_TYPE,
                    M.DATE_FORMAT,
                    M.NUMERIC_SCALE,
                    IFF(
                        M.TRIM_VALUE,
                        TRIM(SUBSTRING(R.RAW_LINE, M.START_POSITION, M.FIELD_LENGTH)),
                        SUBSTRING(R.RAW_LINE, M.START_POSITION, M.FIELD_LENGTH)
                    ) AS FIELD_VALUE
                FROM DB_MEDIATION_BRZ_DEV.SC_RAW.' || V_RAW_TABLE || ' R
                JOIN DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_FIELD_MAPPING M
                  ON M.FEED_ID = ''' || V_FEED_ID || '''
                 AND M.IS_ACTIVE = TRUE
            ),

            NULLABLE_REJECTS AS (
                SELECT
                    ''' || V_FEED_ID || ''' AS FEED_ID,
                    ''' || V_RAW_TABLE || ''' AS RAW_TABLE,
                    C.CONTROL_ID,
                    RF.RECORD_KEY,
                    RF.LOAD_TS,
                    C.ERROR_CODE,
                    C.ERROR_MESSAGE,
                    RF.FIELD_NAME AS ERROR_FIELD,
                    RF.FIELD_VALUE AS ERROR_VALUE,
                    C.ON_FAILURE_ACTION,
                    RF.RAW_LINE,
                    ''NEW'' AS STATUS,
                    CURRENT_TIMESTAMP() AS CREATED_AT
                FROM DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES C,
                     LATERAL FLATTEN(INPUT => C.PARAMS:fields) F,
                     RAW_FIELDS RF
                WHERE C.FEED_ID = ''' || V_FEED_ID || '''
                  AND C.CONTROL_TYPE = ''NULLABLE''
                  AND C.IS_ACTIVE = TRUE
                  AND RF.FIELD_NAME = F.VALUE::VARCHAR
                  AND (
                        RF.FIELD_VALUE IS NULL
                        OR TRIM(RF.FIELD_VALUE) = ''''
                  )
            ),

            ALLOWED_VALUES_REJECTS AS (
                SELECT
                    ''' || V_FEED_ID || ''' AS FEED_ID,
                    ''' || V_RAW_TABLE || ''' AS RAW_TABLE,
                    C.CONTROL_ID,
                    RF.RECORD_KEY,
                    RF.LOAD_TS,
                    C.ERROR_CODE,
                    C.ERROR_MESSAGE,
                    RF.FIELD_NAME AS ERROR_FIELD,
                    RF.FIELD_VALUE AS ERROR_VALUE,
                    C.ON_FAILURE_ACTION,
                    RF.RAW_LINE,
                    ''NEW'' AS STATUS,
                    CURRENT_TIMESTAMP() AS CREATED_AT
                FROM DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES C,
                     LATERAL FLATTEN(INPUT => C.PARAMS:fields) F,
                     RAW_FIELDS RF
                WHERE C.FEED_ID = ''' || V_FEED_ID || '''
                  AND C.CONTROL_TYPE = ''ALLOWED_VALUES''
                  AND C.IS_ACTIVE = TRUE
                  AND RF.FIELD_NAME = F.VALUE:field::VARCHAR
                  AND (
                        RF.FIELD_VALUE IS NULL
                        OR TRIM(RF.FIELD_VALUE) = ''''
                        OR NOT ARRAY_CONTAINS(
                            TO_VARIANT(RF.FIELD_VALUE),
                            F.VALUE:allowed_values
                        )
                  )
            ),

            AMOUNT_POSITIVE_REJECTS AS (
                SELECT
                    ''' || V_FEED_ID || ''' AS FEED_ID,
                    ''' || V_RAW_TABLE || ''' AS RAW_TABLE,
                    C.CONTROL_ID,
                    RF.RECORD_KEY,
                    RF.LOAD_TS,
                    C.ERROR_CODE,
                    C.ERROR_MESSAGE,
                    RF.FIELD_NAME AS ERROR_FIELD,
                    RF.FIELD_VALUE AS ERROR_VALUE,
                    C.ON_FAILURE_ACTION,
                    RF.RAW_LINE,
                    ''NEW'' AS STATUS,
                    CURRENT_TIMESTAMP() AS CREATED_AT
                FROM DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES C,
                     LATERAL FLATTEN(INPUT => C.PARAMS:fields) F,
                     RAW_FIELDS RF
                WHERE C.FEED_ID = ''' || V_FEED_ID || '''
                  AND C.CONTROL_TYPE = ''AMOUNT_POSITIVE''
                  AND C.IS_ACTIVE = TRUE
                  AND RF.FIELD_NAME = F.VALUE::VARCHAR
                  AND (
                        TRY_TO_NUMBER(RF.FIELD_VALUE) IS NULL
                        OR TRY_TO_NUMBER(RF.FIELD_VALUE) <= 0
                  )
            ),

            DATE_FORMAT_REJECTS AS (
                SELECT
                    ''' || V_FEED_ID || ''' AS FEED_ID,
                    ''' || V_RAW_TABLE || ''' AS RAW_TABLE,
                    C.CONTROL_ID,
                    RF.RECORD_KEY,
                    RF.LOAD_TS,
                    C.ERROR_CODE,
                    C.ERROR_MESSAGE,
                    RF.FIELD_NAME AS ERROR_FIELD,
                    RF.FIELD_VALUE AS ERROR_VALUE,
                    C.ON_FAILURE_ACTION,
                    RF.RAW_LINE,
                    ''NEW'' AS STATUS,
                    CURRENT_TIMESTAMP() AS CREATED_AT
                FROM DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES C,
                     LATERAL FLATTEN(INPUT => C.PARAMS:fields) F,
                     RAW_FIELDS RF
                WHERE C.FEED_ID = ''' || V_FEED_ID || '''
                  AND C.CONTROL_TYPE = ''DATE_FORMAT''
                  AND C.IS_ACTIVE = TRUE
                  AND RF.FIELD_NAME = F.VALUE::VARCHAR
                  AND (
                        RF.FIELD_VALUE IS NULL
                        OR TRIM(RF.FIELD_VALUE) = ''''
                        OR TRY_TO_DATE(RF.FIELD_VALUE, COALESCE(RF.DATE_FORMAT, ''YYYYMMDD'')) IS NULL
                  )
            ),

            DATE_NOT_FUTURE_REJECTS AS (
                SELECT
                    ''' || V_FEED_ID || ''' AS FEED_ID,
                    ''' || V_RAW_TABLE || ''' AS RAW_TABLE,
                    C.CONTROL_ID,
                    RF.RECORD_KEY,
                    RF.LOAD_TS,
                    C.ERROR_CODE,
                    C.ERROR_MESSAGE,
                    RF.FIELD_NAME AS ERROR_FIELD,
                    RF.FIELD_VALUE AS ERROR_VALUE,
                    C.ON_FAILURE_ACTION,
                    RF.RAW_LINE,
                    ''NEW'' AS STATUS,
                    CURRENT_TIMESTAMP() AS CREATED_AT
                FROM DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES C,
                     LATERAL FLATTEN(INPUT => C.PARAMS:fields) F,
                     RAW_FIELDS RF
                WHERE C.FEED_ID = ''' || V_FEED_ID || '''
                  AND C.CONTROL_TYPE = ''DATE_NOT_FUTURE''
                  AND C.IS_ACTIVE = TRUE
                  AND RF.FIELD_NAME = F.VALUE::VARCHAR
                  AND TRY_TO_DATE(RF.FIELD_VALUE, COALESCE(RF.DATE_FORMAT, ''YYYYMMDD'')) IS NOT NULL
                  AND TRY_TO_DATE(RF.FIELD_VALUE, COALESCE(RF.DATE_FORMAT, ''YYYYMMDD'')) > CURRENT_DATE()
            ),

            DATE_ORDER_REJECTS AS (
                SELECT
                    ''' || V_FEED_ID || ''' AS FEED_ID,
                    ''' || V_RAW_TABLE || ''' AS RAW_TABLE,
                    C.CONTROL_ID,
                    MAX_RF.RECORD_KEY,
                    MAX_RF.LOAD_TS,
                    C.ERROR_CODE,
                    C.ERROR_MESSAGE,
                    MAX_RF.FIELD_NAME AS ERROR_FIELD,
                    MAX_RF.FIELD_VALUE AS ERROR_VALUE,
                    C.ON_FAILURE_ACTION,
                    MAX_RF.RAW_LINE,
                    ''NEW'' AS STATUS,
                    CURRENT_TIMESTAMP() AS CREATED_AT
                FROM DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES C,
                     LATERAL FLATTEN(INPUT => C.PARAMS:pairs) P,
                     RAW_FIELDS MIN_RF,
                     RAW_FIELDS MAX_RF
                WHERE C.FEED_ID = ''' || V_FEED_ID || '''
                  AND C.CONTROL_TYPE = ''DATE_ORDER''
                  AND C.IS_ACTIVE = TRUE
                  AND MIN_RF.RECORD_KEY = MAX_RF.RECORD_KEY
                  AND MIN_RF.FIELD_NAME = P.VALUE:min_field::VARCHAR
                  AND MAX_RF.FIELD_NAME = P.VALUE:max_field::VARCHAR
                  AND TRY_TO_DATE(MIN_RF.FIELD_VALUE, COALESCE(MIN_RF.DATE_FORMAT, ''YYYYMMDD'')) IS NOT NULL
                  AND TRY_TO_DATE(MAX_RF.FIELD_VALUE, COALESCE(MAX_RF.DATE_FORMAT, ''YYYYMMDD'')) IS NOT NULL
                  AND TRY_TO_DATE(MAX_RF.FIELD_VALUE, COALESCE(MAX_RF.DATE_FORMAT, ''YYYYMMDD''))
                      < TRY_TO_DATE(MIN_RF.FIELD_VALUE, COALESCE(MIN_RF.DATE_FORMAT, ''YYYYMMDD''))
            ),

            DUPLICATE_RAW_VALUES AS (
                SELECT
                    C.CONTROL_ID,
                    C.ERROR_CODE,
                    C.ERROR_MESSAGE,
                    C.ON_FAILURE_ACTION,
                    RF.FIELD_NAME AS ERROR_FIELD,
                    RF.RECORD_KEY,
                    RF.LOAD_TS,
                    RF.RAW_LINE,
                    RF.FIELD_VALUE AS CHECK_VALUE
                FROM DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES C,
                     LATERAL FLATTEN(INPUT => C.PARAMS:fields) F,
                     RAW_FIELDS RF
                WHERE C.FEED_ID = ''' || V_FEED_ID || '''
                  AND C.CONTROL_TYPE = ''DUPLICATE_VALUE''
                  AND C.IS_ACTIVE = TRUE
                  AND RF.FIELD_NAME = F.VALUE::VARCHAR
                  AND RF.FIELD_VALUE IS NOT NULL
                  AND TRIM(RF.FIELD_VALUE) <> ''''
            ),

            DUPLICATE_VALUES AS (
                SELECT
                    CONTROL_ID,
                    ERROR_FIELD,
                    CHECK_VALUE
                FROM DUPLICATE_RAW_VALUES
                GROUP BY
                    CONTROL_ID,
                    ERROR_FIELD,
                    CHECK_VALUE
                HAVING COUNT(*) > 1
            ),

            DUPLICATE_REJECTS AS (
                SELECT
                    ''' || V_FEED_ID || ''' AS FEED_ID,
                    ''' || V_RAW_TABLE || ''' AS RAW_TABLE,
                    RV.CONTROL_ID,
                    RV.RECORD_KEY,
                    RV.LOAD_TS,
                    RV.ERROR_CODE,
                    RV.ERROR_MESSAGE,
                    RV.ERROR_FIELD,
                    RV.CHECK_VALUE AS ERROR_VALUE,
                    RV.ON_FAILURE_ACTION,
                    RV.RAW_LINE,
                    ''NEW'' AS STATUS,
                    CURRENT_TIMESTAMP() AS CREATED_AT
                FROM DUPLICATE_RAW_VALUES RV
                JOIN DUPLICATE_VALUES DV
                  ON RV.CONTROL_ID = DV.CONTROL_ID
                 AND RV.ERROR_FIELD = DV.ERROR_FIELD
                 AND RV.CHECK_VALUE = DV.CHECK_VALUE
            )

            SELECT * FROM NULLABLE_REJECTS
            UNION ALL SELECT * FROM ALLOWED_VALUES_REJECTS
            UNION ALL SELECT * FROM AMOUNT_POSITIVE_REJECTS
            UNION ALL SELECT * FROM DATE_FORMAT_REJECTS
            UNION ALL SELECT * FROM DATE_NOT_FUTURE_REJECTS
            UNION ALL SELECT * FROM DATE_ORDER_REJECTS
            UNION ALL SELECT * FROM DUPLICATE_REJECTS
        ';

        EXECUTE IMMEDIATE V_SQL;

        V_FEED_INDEX := V_FEED_INDEX + 1;

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

