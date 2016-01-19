#!/bin/bash

echo "================== ssh keygen ======================="
  ssh-keygen
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

echo "================== Install default gems =============="
  rvm @global do gem install bundler
  rvm @global do gem install unicorn
  gem install rails --no-ri --no-rdoc
echo ""

echo "================== Define application ================"
  read -p  "Enter your application name : " app_name
  until [[ ! ${#app_name} = 0 ]]; do
    echo "Application name are not filled"
    read -p  "Enter your application name : " app_name
  done
  echo ""
  echo "Your application name is : $app_name"
  rvm gemset create $app_name
echo ""

echo "================== Install postgresql ================"
  echo "Do you wish to install postgresql?"
  select yn_psql in "Yes" "No"; do
    case $yn_psql in
      Yes )
      sudo apt-get install -y postgresql libpq-dev
      sudo -u postgres createuser rails
      sudo -u postgres createdb $app_name --owner=rails
      sudo service postgresql restart
      break
      ;;
      No ) break;;
    esac
  done
echo ""

echo "================== Download unicorn conf ============"
  curl https://raw.githubusercontent.com/ayann/vps/master/unicorn.conf.rb > ~/unicorn.conf.rb
  mkdir -p $app_name/shared/config
  mv unicorn.conf.rb $app_name/shared/config/unicorn.conf.rb
echo ""

echo "================== Download unicorn init script ============"
  curl https://raw.githubusercontent.com/ayann/vps/master/unicorn.sh > ~/unicorn.sh
  sed -i.bak -e "s/rails-demo/$app_name/g" unicorn.sh
  sudo mv ~/unicorn.sh /etc/init.d/unicorn
  sudo chmod 755 /etc/init.d/unicorn
  sudo update-rc.d unicorn defaults
echo ""

echo "================== Instal nginx ============"
  sudo apt-get install nginx -y
echo ""

echo "================== Download & set nginx host ============="
  sudo rm /etc/nginx/sites-enabled/*

  curl https://raw.githubusercontent.com/ayann/vps/master/nginx.host > ~/nginx.host
  sed -i.bak -e "s/rails-demo/$app_name/g" nginx.host
  sudo mv ~/nginx.host /etc/nginx/sites-available/$app_name
  sudo ln -s /etc/nginx/sites-available/$app_name /etc/nginx/sites-enabled/$app_name
echo ""

echo "================== Reload nginx ============"
  # Reload nginx. Make sure to use the `reload` action so that nginx can check
  # your configuration before reloading, thereby saving you from causing downtime.
  sudo nginx -t && sudo service nginx reload
echo ""

echo "================== Reload nginx ============"
  sudo ufw allow 80
echo ""

echo "================== Reboot VPS ============"
  sudo reboot
echo ""
