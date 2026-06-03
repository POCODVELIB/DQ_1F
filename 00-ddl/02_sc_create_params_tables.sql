
use role sysadmin;


/* ============================================================
   Création de la table PARAM_FEED
   ============================================================ */
CREATE TABLE IF NOT EXISTS DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_FEED (

    FEED_ID        VARCHAR(100) NOT NULL,
    SOURCE_CODE    VARCHAR(50)  NOT NULL,
    FEED_CODE      VARCHAR(100) NOT NULL,
    FEED_NAME      VARCHAR(255),         
    RAW_DATABASE   VARCHAR(100) NOT NULL,
    RAW_SCHEMA     VARCHAR(100) NOT NULL,
    RAW_TABLE      VARCHAR(100) NOT NULL,
    IS_ACTIVE      BOOLEAN DEFAULT TRUE,

    CREATED_AT     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT     TIMESTAMP_NTZ

);


/* ============================================================
   Création de la table PARAM_CONTROLES
   ============================================================ */
CREATE TABLE  IF NOT EXISTS DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES (
    CONTROL_ID          VARCHAR(100) NOT NULL, 
    FEED_ID             VARCHAR(100) NOT NULL, 
    CONTROL_ORDER       NUMBER(10,0) NOT NULL, -- ordre d'exécution
    CONTROL_CODE        VARCHAR(100) NOT NULL, 
    CONTROL_TYPE        VARCHAR(50)  NOT NULL,
    ON_FAILURE_ACTION   VARCHAR(30)  NOT NULL, -- rejet_ligne : potentielleemnt à enlever si meme traitement pour tout rejet
    ERROR_CODE          VARCHAR(100) NOT NULL,
    ERROR_MESSAGE       VARCHAR(1000) NOT NULL,
    PARAMS              VARIANT NOT NULL, -- paramètre en JSON 
    IS_ACTIVE           BOOLEAN DEFAULT TRUE,
    CREATED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT          TIMESTAMP_NTZ
);
