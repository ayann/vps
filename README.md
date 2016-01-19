# vps
Setup Vps with Unicorn - Nginx - PostgreSql - Ruby On Rails - Mina

# vps_setup
apt-get install language-pack-fr -y
apt-get install curl

dpkg-reconfigure tzdata

adduser rails --disabled-password
adduser rails sudo
sudo chown rails /srv/

mkdir /home/rails/.ssh
cp ~/.ssh/authorized_keys /home/rails/.ssh/
chown rails.rails /home/rails/.ssh -R
chmod go-rwx /home/rails/.ssh -R

echo '\nrails ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

rails ALL=(ALL) NOPASSWD: ALL

# passwd -l rails
ssh-keygen
ssh-copy-id rails@46.101.150.159

netstat --listening --tcp
ufw allow 22 && ufw logging off && ufw enable && ufw status

sed -i -e "s/chaines1/chaine2/g" fichier
sed -i -e "/$v1/$v2/g" nginx.host
