# Aegis Guardian

Aegis Guardian est un framework léger, modulaire et auditable de supervision et d’auto-réparation pour serveurs Linux.

Le projet est né dans l’écosystème **Aegis**, un laboratoire Gentoo orienté contrôle, qualité, compréhension du système, automatisation fiable et documentation reproductible.

La CDDN constitue le premier environnement de production.

## Philosophie

La méthode Aegis repose sur six principes :

1. construire proprement ;
2. comprendre avant d’automatiser ;
3. automatiser uniquement ce qui est fiable ;
4. surveiller l’état réel du système ;
5. réparer automatiquement lorsque cela reste sûr ;
6. alerter lorsqu’une décision humaine apporte une vraie valeur.

## État du projet

Version actuelle : **2.0.0-alpha1**

Cette version doit fonctionner en parallèle de CDDN Guardian v1 pendant sa phase de validation.

## Fonctionnalités actuelles

- découverte automatique des modules ;
- configuration centralisée ;
- rapports JSON ;
- supervision systemd ;
- surveillance du disque et de la mémoire ;
- contrôle Docker ;
- contrôle et auto-réparation de Discourse ;
- contrôle et auto-réparation de TeamSpeak ;
- vérification locale du site et du forum via Caddy ;
- timer systemd toutes les 15 minutes.

## Installation

```bash
git clone https://github.com/costamorica/aegis-guardian.git
cd aegis-guardian
sudo ./install.sh
```

Premier contrôle :

```bash
sudo systemctl start aegis-guardian.service
sudo systemctl status aegis-guardian.service --no-pager -l
sudo cat /var/lib/aegis-guardian/reports/latest.json
```

## Mise à jour

```bash
cd /opt/aegis-guardian-src
git pull
sudo ./update.sh
```

## Migration depuis CDDN Guardian v1

Pendant les essais, conserver la v1 active.

Après plusieurs contrôles propres :

```bash
sudo systemctl disable --now cddn-healthcheck.timer
sudo systemctl enable --now aegis-guardian.timer
```

## Licence

GPL-3.0-or-later.
