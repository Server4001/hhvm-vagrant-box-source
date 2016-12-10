#!/usr/bin/env bash

# Install HHVM.
apt-get install software-properties-common
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
add-apt-repository "deb http://dl.hhvm.com/ubuntu $(lsb_release -sc) main"
apt-get update
apt-get install -y hhvm

# Configure HHVM
cp /vagrant/config/hhvm/etc.default.hhvm /etc/default/hhvm
chmod 664 /etc/default/hhvm
chown -R vagrant: /var/run/hhvm
cp /vagrant/config/apache/hhvm_proxy_fcgi.conf /etc/apache2/mods-available/hhvm_proxy_fcgi.conf
chmod 664 /etc/apache2/mods-available/hhvm_proxy_fcgi.conf
chown -R vagrant: /var/log/hhvm/
cp /vagrant/config/php/php.ini /etc/hhvm/php.ini
chmod 664 /etc/hhvm/php.ini
cp /vagrant/config/hhvm/server.ini /etc/hhvm/server.ini
chmod 664 /etc/hhvm/server.ini

# Start HHVM.
update-rc.d hhvm defaults
service hhvm restart

# Install MySQL 5.7.
export DEBIAN_FRONTEND=noninteractive
wget https://dev.mysql.com/get/mysql-apt-config_0.6.0-1_all.deb
echo mysql-apt-config mysql-apt-config/repo-distro select ubuntu | debconf-set-selections
echo mysql-apt-config mysql-apt-config/repo-codename select trusty | debconf-set-selections
echo mysql-apt-config mysql-apt-config/select-server select mysql-5.7 | debconf-set-selections
echo mysql-community-server mysql-community-server/root-pass password password | debconf-set-selections
echo mysql-community-server mysql-community-server/re-root-pass password password | debconf-set-selections
dpkg -i mysql-apt-config_0.6.0-1_all.deb
apt-get update
apt-get install -y mysql-server augeas-tools
augtool set /etc/mysql/my.cnf/target[3]/character-set-server utf8
augtool set /etc/mysql/my.cnf/target[3]/collation-server utf8_unicode_ci
rm mysql-apt-config_0.6.0-1_all.deb

# Start MySQL Server.
service mysql restart

# Install Nginx.
add-apt-repository -y ppa:nginx/stable
apt-get update
apt-get install -y nginx

# Configure Nginx.
cp /vagrant/config/nginx/nginx.conf /etc/nginx/nginx.conf
cp /vagrant/config/nginx/nginx.sites-available.hhvm.conf /etc/nginx/sites-available/hhvm.conf
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/hhvm.conf /etc/nginx/sites-enabled/hhvm.conf
cp /vagrant/config/nginx/nginx.hhvm.conf /etc/nginx/hhvm.conf
chmod 664 /etc/nginx/hhvm.conf
touch /var/www/html/.hhconfig
chown -R vagrant: /var/www/html
hh_client

# Restart HHVM
service hhvm restart

# Start Nginx.
service nginx restart
update-rc.d nginx defaults

# Install Beanstalkd.
apt-get install -y beanstalkd

# Configure Beanstalkd.
cp /vagrant/config/beanstalkd/beanstalkd.conf /etc/default/beanstalkd

# Start Beanstalkd.
service beanstalkd restart
update-rc.d beanstalkd defaults

# Install composer.
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/bin/composer

# Install Redis.
apt-get install -y redis-server

# Configure Redis.
cp /vagrant/config/redis/redis.conf /etc/redis/redis.conf

# Start Redis.
service redis-server restart
update-rc.d redis-server defaults

# Install Memcached.
apt-get install -y memcached

# Configure Memcached.
cp /vagrant/config/memcached/memcached.conf /etc/memcached.conf

# Start Memcached.
service memcached restart
update-rc.d memcached defaults

# Install other useful utils.
apt-get install -y tree git

# Install Vim Pathogen.
mkdir -p /home/vagrant/.vim/{autoload,bundle,colors} && curl -LSso /home/vagrant/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
mkdir -p /root/.vim/{autoload,bundle,colors} && curl -LSso /root/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Install Vim Hack.
git clone git://github.com/hhvm/vim-hack.git /home/vagrant/.vim/bundle/vim-hack
git clone git://github.com/hhvm/vim-hack.git /root/.vim/bundle/vim-hack

# Install Vim Tomorrow Night Eighties theme.
cp /vagrant/config/vim/TomorrowNightEighties.vim /home/vagrant/.vim/colors/TomorrowNightEighties.vim
cp /vagrant/config/vim/TomorrowNightEighties.vim /root/.vim/colors/TomorrowNightEighties.vim

# Add custom Vim config.
cp /vagrant/config/vim/vimrc /home/vagrant/.vimrc
cp /vagrant/config/vim/vimrc /root/.vimrc

# Custom bashrc.
cp /vagrant/config/bash/vagrant.bashrc /home/vagrant/.bashrc
cp /vagrant/config/bash/root.bashrc /root/.bashrc

# Chown vagrant user's files and folders.
chown -R vagrant: /home/vagrant/.vim
chown vagrant: /home/vagrant/.bashrc
