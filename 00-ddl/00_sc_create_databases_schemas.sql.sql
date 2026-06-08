
/*
Description :  DDL CReation DBs et schemas. On reste sur l'environnement DEV. 
               Architecture médaillon, BRZ, SLV et GLD. 
               La base BRZ possède 2 schémas, RAW contenant la donnée brute et CONTROL (moteur DQ)
------------------------------------------------------------------------------------------------------
Author      : SHO   
Created     : 2026-06-04
------------------------------------------------------------------------------------------------------
*/


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
