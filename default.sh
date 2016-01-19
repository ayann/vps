#!/bin/bash
echo "================== Reconfigure time zone ============"
  dpkg-reconfigure tzdata
echo ""

echo "================== Update all packages: ==============="
  apt-get update -y && apt-get upgrade -y &&  apt-get autoremove -y
  apt-get install language-pack-fr -y
echo ""

echo "================== Install curl git nodejs ==========="
  apt-get -y install curl python-software-properties git-core nodejs
echo ""

echo "================== Disable SSH password authentication ==============="
  echo -e "PasswordAuthentication no" >> /etc/ssh/sshd_config
  sed -i -e "s/UsePAM yes/UsePAM no/g" /etc/ssh/sshd_config
echo ""

echo "================== Generate missing SSH host keys ==============="
  /etc/init.d/ssh reload
  ssh-keygen -A
echo ""

echo "================== Check the open portls (should be only SSH): ==============="
  netstat --listening --tcp
echo ""

echo "================== Enable the Ubuntu firewall so that unconfigured services are not be exposed: ==============="
  ufw allow 22 && ufw logging off && ufw enable && ufw status
echo ""

echo "================== Create User Rails ==============="
  adduser deploy --disabled-password
  chown rails /srv/
echo ""

echo "================== Grant User Rails sudo ==============="
  adduser deploy sudo
  echo -e "\nrails ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo ""

echo "================== Copy authorized_keys ==============="
  mkdir /home/rails/.ssh
  cp ~/.ssh/authorized_keys /home/rails/.ssh/
  chown rails.rails /home/rails/.ssh -R
  chmod go-rwx /home/rails/.ssh -R
echo ""

echo "================== Reboot ==============="
  echo 'After reboot log with rails user'
  reboot
echo ""
