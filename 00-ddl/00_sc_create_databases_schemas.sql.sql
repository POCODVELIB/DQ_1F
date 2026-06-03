
use role sysadmin;

/* ============================================================
   Création des databases Bronze / Silver / Gold
   attention naming draft : à valider
   ============================================================ */
CREATE DATABASE IF NOT EXISTS DB_MEDIATION_BRZ_DEV;
CREATE DATABASE IF NOT EXISTS DB_MEDIATION_SLV_DEV;
CREATE DATABASE IF NOT EXISTS DB_MEDIATION_GLD_DEV;


/* ============================================================
   Création des schemas par couche
   ============================================================ */
-- Bronze
CREATE SCHEMA IF NOT EXISTS DB_MEDIATION_BRZ_DEV.SC_RAW;
CREATE SCHEMA IF NOT EXISTS DB_MEDIATION_BRZ_DEV.SC_CONTROL;

-- Silver
CREATE SCHEMA IF NOT EXISTS DB_MEDIATION_SLV_DEV.SC_CURATED;

-- Gold
CREATE SCHEMA IF NOT EXISTS DB_MEDIATION_GLD_DEV.SC_MART;
