sudo apt update -y && sudo apt upgrade -y
sudo apt install ufw fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl enable ufw
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

sudo adduser nicogt
sudo usermod -aG sudo nicogt

# ordi local
# Enter file in which to save the key (/home/fabien/.ssh/id_rsa)
ssh-keygen
ssh-copy-id nicogt@212.227.73.52

sudo nano /etc/ssh/sshd_config
PubkeyAuthentication yes
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
systemctl restart sshd
sudo systemctl restart sshd
sudo reboot
sudo dpkg-reconfigure locales





