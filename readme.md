

# mediation-dq

POC contrôle qualité des données du pipeline de médiation Finance One (1F).

## Contenu

- `ddl/` — scripts de création des bases, schemas et tables
- `procedures/` — stored procedures et UDFs
- `params/` — scripts d'insertion du paramétrage initial
- `views/` — vues d'éligibilité par feed

## Stack

Snowflake · SQL natif · Snowflake Scripting · Azure DevOps · GitLab CI

## Déploiement

Le déploiement est géré par Azure DevOps.
Chaque merge sur `main` déclenche le pipeline de déploiement vers l'environnement cible.

```
DEV  →  merge sur main
REC  →  tag release/rec-*
PRD  →  tag release/prd-*
```

## Conventions

- Un fichier par objet Snowflake
- Nommage : `<type>_<objet>.sql` (ex : `sp_ctrl_generique.sql`)
- Les règles métier complexes suivent le contrat de sortie défini dans `controls/README.md`
- Aucun SQL libre dans `PARAM_CONTROLES` — toute règle complexe passe par `controls/`
