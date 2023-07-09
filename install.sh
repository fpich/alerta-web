#!/bin/bash

# configurer le nom de domaine sur ionos
#Nom : @ et www
#Type : A
#Valeur : <adresse IP de votre serveur c70ca0b.online-server.cloud 212.227.73.52>

# Installer Certbot
sudo apt update -y && sudo apt upgrade -y
sudo apt install apache2 certbot python3-certbot-apache -y

# Créer un fichier de configuration pour le site alerta-alicia.com
sudo tee /etc/apache2/sites-available/alerta-alicia.com.conf > /dev/null <<EOF
<VirtualHost *:80>
  ServerName alerta-alicia.com
  DocumentRoot /var/www/html
  #Redirect permanent / https://www.alerta-alicia.com/
</VirtualHost>

<VirtualHost *:443>
  ServerName alerta-alicia.com
  DocumentRoot /var/www/html

  #SSLEngine on
  #SSLCertificateFile /etc/letsencrypt/live/alerta-alicia.com/fullchain.pem
  #SSLCertificateKeyFile /etc/letsencrypt/live/alerta-alicia.com/privkey.pem
  #SSLCertificateChainFile /etc/letsencrypt/live/alerta-alicia.com/chain.pem
</VirtualHost>
EOF

# Activer ssl
sudo a2enmod ssl

# Activer le site alerta-alicia.com a2dissite
sudo a2ensite alerta-alicia.com.conf

# Redémarrer Apache2
sudo systemctl restart apache2

# Générer les certificats SSL Let's Encrypt
sudo certbot certonly --webroot -w /var/www/html -d alerta-alicia.com -d www.alerta-alicia.com -d c70ca0b.online-server.cloud

# test renouvellement certificat
sudo certbot renew --dry-run

# enlever les commentaires ssl et redirect
sudo nano /etc/apache2/sites-available/alerta-alicia.com.conf

# Redémarrer Apache2
sudo systemctl restart apache2


