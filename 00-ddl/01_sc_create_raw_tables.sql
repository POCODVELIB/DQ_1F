use role sysadmin;

/*
Description :  DDL CReation table RAW(BRZ). Données brutes issues des AGI, 
               À minima ces 3 colonnes. D'autres comme un HASH(RAW_RECORD) pourraient être rajoutées
-------------------------------------------------------------------------------------
Author      : SHO   
Created     : 2026-06-04
-------------------------------------------------------------------------------------
*/

CREATE TABLE IF NOT EXISTS DB_MEDIATION_BRZ_DEV.SC_RAW.RAW_ALMERYS_PRESTATIONS (
    RECORD_KEY  NUMBER(38,0) IDENTITY START 1 INCREMENT 1 NOORDER NOT NULL,
    LOAD_TS     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    RAW_RECORD  VARIANT NOT NULL
);