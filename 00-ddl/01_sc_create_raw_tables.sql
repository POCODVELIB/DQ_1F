use role sysadmin;

/* ============================================================
   Création des tables RAW Bronze
   ============================================================ */
CREATE TABLE IF NOT EXISTS DB_MEDIATION_BRZ_DEV.SC_RAW.RAW_ALMERYS_PRESTATIONS ( -- à variabiliser. on reste sur dev pour le poc
    RECORD_KEY  NUMBER(38,0) IDENTITY START 1 INCREMENT 1 NOORDER NOT NULL,
    RUN_ID      VARCHAR(100) NOT NULL,
    RAW_RECORD  VARIANT NOT NULL
);
