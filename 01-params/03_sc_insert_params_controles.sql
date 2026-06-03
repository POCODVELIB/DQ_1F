-- Contrôles MVP — ALMERYS / PRESTATIONS
-- À compléter après validation avec Ahmed et DIP
use role sysadmin
;

/* ============================================================
   insert / init de la table param_controles
   ============================================================ */
INSERT INTO DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_CONTROLES
    (CONTROL_ID, FEED_ID, CONTROL_ORDER, CONTROL_CODE, CONTROL_TYPE,
     ON_FAILURE_ACTION, ERROR_CODE, ERROR_MESSAGE, PARAMS, IS_ACTIVE, CREATED_AT)
VALUES
    ('CTRL_ALM_PREST_001', 'ALMERYS_PRESTATIONS', 10,  'ID_PRESTATION_REQUIRED',   'NULLABLE',       'rejet_ligne', 'ERR_ID_PRESTATION_NULL',       'Le champ id_prestation est obligatoire.',
     PARSE_JSON('{"json_path":"id_prestation"}'),
     TRUE, '2026-06-03 07:09:18.374'),

    ('CTRL_ALM_PREST_002', 'ALMERYS_PRESTATIONS', 20,  'ID_CONTRAT_REQUIRED',       'NULLABLE',       'rejet_ligne', 'ERR_ID_CONTRAT_NULL',           'Le champ id_contrat est obligatoire.',
     PARSE_JSON('{"json_path":"id_contrat"}'),
     TRUE, '2026-06-03 07:09:18.374'),

    ('CTRL_ALM_PREST_003', 'ALMERYS_PRESTATIONS', 30,  'STATUT_ALLOWED_VALUES',     'ALLOWED_VALUES', 'rejet_ligne', 'ERR_STATUT_NOT_ALLOWED',        'Valeur non autorisée',
     PARSE_JSON('{"json_path":"statut","allowed_values":["PAYE","EN_ATTENTE","ANNULE"]}'),
     TRUE, '2026-06-03 07:09:18.374'),

    ('CTRL_ALM_PREST_004', 'ALMERYS_PRESTATIONS', 40,  'DEVISE_EUR_ONLY',           'ALLOWED_VALUES', 'rejet_ligne', 'ERR_DEVISE_NOT_ALLOWED',        'La devise doit être EUR.',
     PARSE_JSON('{"json_path":"devise","allowed_values":["EUR"]}'),
     TRUE, '2026-06-03 07:09:18.374'),

    ('CTRL_ALM_PREST_005', 'ALMERYS_PRESTATIONS', 50,  'MONTANT_NUMERIC_REQUIRED',  'NUMERIC_NOT_NULL','rejet_ligne','ERR_MONTANT_INVALID',           'Le montant doit être renseigné et numérique.',
     PARSE_JSON('{"json_path":"montant"}'),
     TRUE, '2026-06-03 07:09:18.374'),

    ('CTRL_ALM_PREST_006', 'ALMERYS_PRESTATIONS', 60,  'MONTANT_POSITIVE',          'AMOUNT_POSITIVE','rejet_ligne', 'ERR_MONTANT_NEGATIF',           'Le montant doit être strictement positif.',
     PARSE_JSON('{"json_path":"montant"}'),
     TRUE, '2026-06-03 07:09:18.374'),

    ('CTRL_ALM_PREST_007', 'ALMERYS_PRESTATIONS', 70,  'DATE_SOIN_FORMAT',          'DATE_FORMAT',    'rejet_ligne', 'ERR_DATE_SOIN_INVALID',         'La date de soin doit être une date valide.',
     PARSE_JSON('{"json_path":"date_soin","format":"YYYY-MM-DD"}'),
     TRUE, '2026-06-03 07:09:18.374'),

    ('CTRL_ALM_PREST_008', 'ALMERYS_PRESTATIONS', 80,  'DATE_SOIN_NOT_FUTURE',      'DATE_NOT_FUTURE','rejet_ligne', 'ERR_DATE_SOIN_FUTURE',          'La date de soin ne peut pas être dans le futur.',
     PARSE_JSON('{"json_path":"date_soin"}'),
     TRUE, '2026-06-03 07:09:18.374'),

    ('CTRL_ALM_PREST_009', 'ALMERYS_PRESTATIONS', 90,  'DUPLICATE_ID_PRESTATION',   'DUPLICATE_FUNC', 'rejet_ligne', 'ERR_DUPLICATE_ID_PRESTATION',   'Doublon fonctionnel détecté sur id_prestation',
     PARSE_JSON('{"json_paths":["id_prestation"]}'),
     TRUE, '2026-06-03 07:09:18.374'),

    ('CTRL_ALM_PREST_010', 'ALMERYS_PRESTATIONS', 100, 'DATE_PAIEMENT_AFTER_SOIN',  'DATE_ORDER',     'rejet_ligne', 'ERR_DATE_PAIEMENT_BEFORE_SOIN', 'La date de paiement ne peut pas être avant la date de soin.',
     PARSE_JSON('{"date_min_path":"date_soin","date_max_path":"date_paiement"}'),
     TRUE, '2026-06-03 07:09:18.374'),

    ('CTRL_ALM_PREST_011', 'ALMERYS_PRESTATIONS', 110, 'TAUX_REMBOURSEMENT_RANGE',  'RANGE_VALUE',    'rejet_ligne', 'ERR_TAUX_RMB_INVALID',          'Le taux de remboursement doit être compris entre 0 et 1.',
     PARSE_JSON('{"json_path":"taux_remboursement","min":0,"max":1}'),
     TRUE, '2026-06-03 07:09:18.374');


/* ============================================================
   insert / init de la table param_feed
   ============================================================ */
INSERT INTO DB_MEDIATION_BRZ_DEV.SC_CONTROL.PARAM_FEED (FEED_ID, SOURCE_CODE, FEED_CODE, FEED_NAME, RAW_DATABASE, RAW_SCHEMA,  RAW_TABLE, IS_ACTIVE )
VALUES ('ALMERYS_PRESTATIONS', 'ALMERYS', 'PRESTATIONS', 'Prestations santé ALMERYS', 'DB_MEDIATION_BRZ_DEV','SC_RAW', 'RAW_ALMERYS_PRESTATIONS',   TRUE );
