#!/bin/bash
echo "================== Reconfigure time zone ============"
 sudo dpkg-reconfigure tzdata
echo ""

echo "================== Update and upgrade ==============="
 sudo apt-get update && sudo apt-get upgrade -y
echo ""

echo "================== Auto remove ======================"
 sudo apt-get autoremove
echo ""

echo "================== Install nginx ====================="
 sudo apt-get install nginx -y
echo ""

echo "================== Install curl git nodejs ==========="
 sudo apt-get -y install curl python-software-properties git-core nodejs
echo ""

echo "================== Install RVM ======================="
 echo "gem: --no-document" >> ~/.gemrc

 echo "Do you wish to install rvm?"
 select yn in "Yes" "No"; do
   case $yn in
     Yes )
       curl -sSL https://rvm.io/mpapis.asc | gpg --import -
       curl -sSL https://get.rvm.io | bash -s stable
       source ~/.rvm/scripts/rvm
       rvm requirements
       break
       ;;
     No ) break;;
   esac
 done
echo ""

echo "================== Install Ruby ======================"
 echo "Do you wish to install ruby?"
 select yn_ruby in "Yes" "No"; do
   case $yn_ruby in
     Yes )
       read -p "Enter ruby version you want : 2.2.4 is default" ruby_version
       ruby_version=${ruby_version:-2.2.4}
       rvm install $ruby_version
       rvm use $ruby_version --default
       rvm rubygems current
       break
       ;;
     No ) break;;
   esac
 done
echo ""
