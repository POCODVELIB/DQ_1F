
/*
Description :  DDL Création des tables de controles, parametrages 
------------------------------------------------------------------------------------------------------
Author      : SHO   
Created     : 2026-06-04
------------------------------------------------------------------------------------------------------
*/



use role sysadmin;


/* ============================================================
   Création de la table PARAM_FEED
   ============================================================ */

CREATE TABLE IF NOT EXISTS DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_FEED (
    FEED_ID      VARCHAR(100) NOT NULL,
    SOURCE_CODE  VARCHAR(50)  NOT NULL,
    FEED_CODE    VARCHAR(100) NOT NULL,
    RAW_TABLE    VARCHAR(100) NOT NULL,
    IS_ACTIVE    BOOLEAN DEFAULT TRUE,
    CREATED_AT   TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT   TIMESTAMP_NTZ,

    CONSTRAINT PK_PARAM_FEED PRIMARY KEY (FEED_ID)
);

/* 
INSERT INTO DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_FEED (
    FEED_ID,
    SOURCE_CODE,
    FEED_CODE,
    RAW_TABLE,
    IS_ACTIVE
)
VALUES
(
    'ULIS_PRESTATIONS',
    'ULIS',
    'PRESTATIONS',
    'RAW_ULIS_PRESTATIONS',
    TRUE
),
(
    'ULIS_CONTRATS',
    'ULIS',
    'CONTRATS',
    'RAW_ULIS_CONTRATS',
    FALSE
),
(
    'ULIS_ASSURES',
    'ULIS',
    'ASSURES',
    'RAW_ULIS_ASSURES',
    FALSE
);

*/



/* ============================================================
   Création de la table PARAM_FIELD_MAPPING
   ============================================================ */


CREATE TABLE IF NOT EXISTS DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_FIELD_MAPPING (
    FIELD_ID        VARCHAR(100) NOT NULL,
    FEED_ID         VARCHAR(100) NOT NULL,
    FIELD_NAME      VARCHAR(100) NOT NULL,
    FIELD_ORDER     NUMBER(10,0) NOT NULL,
    START_POSITION  NUMBER(10,0) NOT NULL,
    FIELD_LENGTH    NUMBER(10,0) NOT NULL,
    TARGET_TYPE     VARCHAR(50)  NOT NULL,
    DATE_FORMAT     VARCHAR(50),
    NUMERIC_SCALE   NUMBER(10,0),
    TRIM_VALUE      BOOLEAN DEFAULT TRUE,
    IS_ACTIVE       BOOLEAN DEFAULT TRUE,
    CREATED_AT      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT      TIMESTAMP_NTZ,

    CONSTRAINT PK_PARAM_FIELD_MAPPING PRIMARY KEY (FIELD_ID)
);

-- init   

/*
INSERT INTO DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_FIELD_MAPPING (
    FIELD_ID,
    FEED_ID,
    FIELD_NAME,
    FIELD_ORDER,
    START_POSITION,
    FIELD_LENGTH,
    TARGET_TYPE,
    DATE_FORMAT,
    NUMERIC_SCALE,
    TRIM_VALUE,
    IS_ACTIVE
)
VALUES
(
    'FLD_ULIS_PREST_ID_PRESTATION',
    'ULIS_PRESTATIONS',
    'id_prestation',
    10,
    1,
    12,
    'STRING',
    NULL,
    NULL,
    TRUE,
    TRUE
),
(
    'FLD_ULIS_PREST_ID_CONTRAT',
    'ULIS_PRESTATIONS',
    'id_contrat',
    20,
    13,
    12,
    'STRING',
    NULL,
    NULL,
    TRUE,
    TRUE
),
(
    'FLD_ULIS_PREST_ID_ASSURE',
    'ULIS_PRESTATIONS',
    'id_assure',
    30,
    25,
    12,
    'STRING',
    NULL,
    NULL,
    TRUE,
    TRUE
),
(
    'FLD_ULIS_PREST_NOM_ASSURE',
    'ULIS_PRESTATIONS',
    'nom_assure',
    40,
    37,
    30,
    'STRING',
    NULL,
    NULL,
    TRUE,
    TRUE
),
(
    'FLD_ULIS_PREST_DATE_SOIN',
    'ULIS_PRESTATIONS',
    'date_soin',
    50,
    67,
    8,
    'DATE',
    'YYYYMMDD',
    NULL,
    TRUE,
    TRUE
),
(
    'FLD_ULIS_PREST_DATE_PAIEMENT',
    'ULIS_PRESTATIONS',
    'date_paiement',
    60,
    75,
    8,
    'DATE',
    'YYYYMMDD',
    NULL,
    TRUE,
    TRUE
),
(
    'FLD_ULIS_PREST_MONTANT',
    'ULIS_PRESTATIONS',
    'montant',
    70,
    83,
    10,
    'NUMBER',
    NULL,
    2,
    TRUE,
    TRUE
),
(
    'FLD_ULIS_PREST_DEVISE',
    'ULIS_PRESTATIONS',
    'devise',
    80,
    93,
    3,
    'STRING',
    NULL,
    NULL,
    TRUE,
    TRUE
),
(
    'FLD_ULIS_PREST_STATUT',
    'ULIS_PRESTATIONS',
    'statut',
    90,
    96,
    12,
    'STRING',
    NULL,
    NULL,
    TRUE,
    TRUE
),
(
    'FLD_ULIS_PREST_TYPE_PRESTATION',
    'ULIS_PRESTATIONS',
    'type_prestation',
    100,
    108,
    15,
    'STRING',
    NULL,
    NULL,
    TRUE,
    TRUE
);
*/


/* ============================================================
   Création de la table PARAM_CONTROLES
   ============================================================ */

CREATE OR REPLACE TABLE DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES (
    CONTROL_ID         VARCHAR(100) NOT NULL,
    FEED_ID            VARCHAR(100) NOT NULL,
    CONTROL_ORDER      NUMBER(10,0) NOT NULL,
    CONTROL_TYPE       VARCHAR(50)  NOT NULL,
    PARAMS             VARIANT      NOT NULL,
    ON_FAILURE_ACTION  VARCHAR(30)  NOT NULL,
    ERROR_CODE         VARCHAR(100) NOT NULL,
    ERROR_MESSAGE      VARCHAR(1000) NOT NULL,
    IS_ACTIVE          BOOLEAN DEFAULT TRUE,
    CREATED_AT         TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT         TIMESTAMP_NTZ,

    CONSTRAINT PK_PARAM_CONTROLES PRIMARY KEY (CONTROL_ID)
);


--init 

/*
INSERT INTO DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES (
    CONTROL_ID,
    FEED_ID,
    CONTROL_ORDER,
    CONTROL_TYPE,
    PARAMS,
    ON_FAILURE_ACTION,
    ERROR_CODE,
    ERROR_MESSAGE,
    IS_ACTIVE
)
SELECT
    'CTRL_ULIS_PREST_REQUIRED_FIELDS',
    'ULIS_PRESTATIONS',
    10,
    'NULLABLE',
    PARSE_JSON('{
      "fields": [
        "id_prestation",
        "id_contrat",
        "id_assure",
        "nom_assure",
        "date_soin",
        "date_paiement",
        "montant",
        "devise",
        "statut",
        "type_prestation"
      ]
    }'),
    'REJECT_LINE',
    'ERR_REQUIRED_FIELD_MISSING',
    'Un champ obligatoire est absent ou vide',
    TRUE

UNION ALL

SELECT
    'CTRL_ULIS_PREST_ALLOWED_VALUES',
    'ULIS_PRESTATIONS',
    20,
    'ALLOWED_VALUES',
    PARSE_JSON('{
      "fields": [
        {
          "field": "devise",
          "allowed_values": ["EUR"]
        },
        {
          "field": "statut",
          "allowed_values": ["PAYE", "EN_ATTENTE", "ANNULE"]
        },
        {
          "field": "type_prestation",
          "allowed_values": [
            "CONSULTATION",
            "PHARMACIE",
            "DENTAIRE",
            "OPTIQUE",
            "HOSPITALISATION"
          ]
        }
      ]
    }'),
    'REJECT_LINE',
    'ERR_VALUE_NOT_ALLOWED',
    'Une valeur ne fait pas partie de la liste autorisée',
    TRUE

UNION ALL

SELECT
    'CTRL_ULIS_PREST_AMOUNT_POSITIVE',
    'ULIS_PRESTATIONS',
    30,
    'AMOUNT_POSITIVE',
    PARSE_JSON('{
      "fields": [
        "montant"
      ]
    }'),
    'REJECT_LINE',
    'ERR_AMOUNT_NOT_POSITIVE',
    'Le montant doit être strictement positif.',
    TRUE

UNION ALL

SELECT
    'CTRL_ULIS_PREST_DATE_FORMAT',
    'ULIS_PRESTATIONS',
    40,
    'DATE_FORMAT',
    PARSE_JSON('{
      "fields": [
        "date_soin",
        "date_paiement"
      ]
    }'),
    'REJECT_LINE',
    'ERR_DATE_INVALID',
    'Une date est invalide ou absente',
    TRUE

UNION ALL

SELECT
    'CTRL_ULIS_PREST_DATE_NOT_FUTURE',
    'ULIS_PRESTATIONS',
    50,
    'DATE_NOT_FUTURE',
    PARSE_JSON('{
      "fields": [
        "date_soin",
        "date_paiement"
      ]
    }'),
    'REJECT_LINE',
    'ERR_DATE_IN_FUTURE',
    'Une date ne peut pas être dans le futur',
    TRUE

UNION ALL

SELECT
    'CTRL_ULIS_PREST_DATE_ORDER',
    'ULIS_PRESTATIONS',
    60,
    'DATE_ORDER',
    PARSE_JSON('{
      "pairs": [
        {
          "min_field": "date_soin",
          "max_field": "date_paiement"
        }
      ]
    }'),
    'REJECT_LINE',
    'ERR_DATE_ORDER_INVALID',
    'La date de paiement ne peut pas être antérieure à la date de soin',
    TRUE

UNION ALL

SELECT
    'CTRL_ULIS_PREST_DUPLICATE_VALUE',
    'ULIS_PRESTATIONS',
    70,
    'DUPLICATE_VALUE',
    PARSE_JSON('{
      "fields": [
        "id_prestation"
      ]
    }'),
    'REJECT_LINE',
    'ERR_DUPLICATE_VALUE',
    'Une valeur métier est présente plusieurs fois dans le feed.',
    TRUE;
*/