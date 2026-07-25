# Migration depuis CDDN Guardian v1

Pendant la phase alpha, conserver les deux systèmes.

Après validation de plusieurs exécutions :

```bash
sudo systemctl disable --now cddn-healthcheck.timer
sudo systemctl enable --now aegis-guardian.timer
```

La maintenance Debian, le redémarrage conditionnel et la maintenance Discourse mensuelle restent indépendants pendant la phase alpha.
