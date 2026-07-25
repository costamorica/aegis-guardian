# Installation

```bash
git clone https://github.com/costamorica/aegis-guardian.git
cd aegis-guardian
sudo ./install.sh
```

Éditer ensuite :

```bash
sudo nano /etc/aegis-guardian/guardian.conf
```

Premier test :

```bash
sudo systemctl start aegis-guardian.service
sudo systemctl status aegis-guardian.service --no-pager -l
sudo cat /var/lib/aegis-guardian/reports/latest.json
```
