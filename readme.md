# DQ_1F

POC DataQuality pour médiation 1 Finance

Le POC met en place un mécanisme simple de DQ des données brutes dans la bronze 

## Principe

* Les lignes brutes sont stockées dans `SC_RAW`.
* Le format positionnel est décrit dans `PARAM_FIELD_MAPPING`.
* Les contrôles sont définis dans `PARAM_CONTROLES`.
* Les rejets sont centralisés dans `DQ_REJECT_EVENT`.


## Arborescence

```text
DQ_1F
├── 00-ddl
│   ├── 00_sc_create_databases_schemas.sql
│   ├── 01_sc_create_raw_tables.sql
│   └── 03_sc_create_table_rejects.sql
│
├── 01-params
│   └── 02_sc_create_params_tables.sql
│
├── 02-procedures/dq
│   └── sp_run_dq_active_tables.sql
│
├── 03-business_rules
├── 04-views
└── readme.md
```

## Architecture Snowflake

```text
DB_MEDIATION_BRZ_DEV
├── SC_RAW
└── SC_CONTROL

DB_MEDIATION_SLV_DEV
└── SC_CURATED

DB_MEDIATION_GLD_DEV
└── SC_MART
```


```sql
CALL DB_MEDIATION_BRZ_DEV.SC_CONTROL.SP_RUN_DQ_ACTIVE_TABLES();
```

## Hors POC

Non inclus à ce stade :

* `DQ_RUN`
* `DQ_WATERMARK`
* workflow de correction
* override métier
* reporting complet des rejets

## Documentation

Notion projet :

```text
https://app.notion.com/p/M-diation-1F-3783aaa772f880228d05e80ce5e72bc4
```
