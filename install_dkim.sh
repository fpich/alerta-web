#!/bin/bash

# Variables - remplacer par vos valeurs
DOMAIN="alerta-alicia.com"
SELECTOR="dkim"

# Installation de OpenDKIM et ses outils
sudo apt-get install -y opendkim opendkim-tools

# Création des répertoires nécessaires
sudo mkdir -p /etc/opendkim/keys

# Création et configuration des fichiers nécessaires
sudo bash -c "cat > /etc/opendkim.conf" << EOF
Domain                  *
AutoRestart             Yes
AutoRestartRate         10/1h
Umask                   002
Syslog                  Yes
SyslogSuccess           Yes
LogWhy                  Yes

Canonicalization        relaxed/simple

ExternalIgnoreList      refile:/etc/opendkim/TrustedHosts
InternalHosts           refile:/etc/opendkim/TrustedHosts
KeyTable                refile:/etc/opendkim/KeyTable
SigningTable            refile:/etc/opendkim/SigningTable

Mode                    sv
PidFile                 /var/run/opendkim/opendkim.pid
SignatureAlgorithm      rsa-sha256

UserID                  opendkim:opendkim

Socket                  inet:12301@localhost
EOF

sudo bash -c "cat > /etc/opendkim/TrustedHosts" << EOF
127.0.0.1
localhost
*.$DOMAIN
EOF

# Création de la clé DKIM
sudo mkdir -p "/etc/opendkim/keys/$DOMAIN"
sudo opendkim-genkey -D "/etc/opendkim/keys/$DOMAIN/" -d "$DOMAIN" -s "$SELECTOR"
sudo chown -R opendkim:opendkim "/etc/opendkim/keys/$DOMAIN"
sudo chmod -R go-rw "/etc/opendkim/keys/$DOMAIN"

# Ajout de la clé à KeyTable et SigningTable
echo "$SELECTOR._domainkey.$DOMAIN $DOMAIN:$SELECTOR:/etc/opendkim/keys/$DOMAIN/$SELECTOR.private" | sudo tee -a /etc/opendkim/KeyTable
echo "*@$DOMAIN $SELECTOR._domainkey.$DOMAIN" | sudo tee -a /etc/opendkim/SigningTable

# Configuration de Postfix
sudo postconf -e "milter_default_action=accept"
sudo postconf -e "milter_protocol=2"
sudo postconf -e "smtpd_milters=inet:localhost:12301"
sudo postconf -e "non_smtpd_milters=inet:localhost:12301"

# Redémarrage des services
sudo service opendkim restart
sudo service postfix restart

# Affichage de l'enregistrement DNS
echo "Ajoutez l'enregistrement DNS suivant à votre domaine $DOMAIN :"
cat "/etc/opendkim/keys/$DOMAIN/$SELECTOR.txt"

