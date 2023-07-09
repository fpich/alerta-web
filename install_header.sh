#!/bin/bash

# Ajout de la configuration header_checks à main.cf si elle n'existe pas
if ! grep -q "header_checks" /etc/postfix/main.cf; then
    echo "header_checks = regexp:/etc/postfix/header_checks" >> /etc/postfix/main.cf
fi

# Création du fichier header_checks s'il n'existe pas, et ajout de la règle pour ignorer X-Mailer
if [ ! -f /etc/postfix/header_checks ]; then
    echo "/^X-Mailer:/ IGNORE" > /etc/postfix/header_checks
else
    if ! grep -q "^X-Mailer:" /etc/postfix/header_checks; then
        echo "/^X-Mailer:/ IGNORE" >> /etc/postfix/header_checks
    fi
fi

# Rechargement de la configuration de Postfix
sudo service postfix reload

