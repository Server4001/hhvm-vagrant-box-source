#!/usr/bin/env bash

# Install pre-requisites.
sudo apt-get update -y
sudo apt-get install -y vim curl python-software-properties tree

# Set MySQL config variables.
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

# Install PHP, Apache, MySQL.
sudo add-apt-repository -y ppa:ondrej/php5-5.6
sudo apt-get update -y
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-readline mysql-server-5.5 php5-mysql git-core php5-xdebug
sudo cp /vagrant/config/php/xdebug.ini /etc/php5/mods-available/xdebug.ini
sudo a2enmod rewrite
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
sudo sed -i "s/disable_functions = .*/disable_functions = /" /etc/php5/cli/php.ini
sudo service apache2 stop
sudo update-rc.d mysql defaults

# Install HHVM.
sudo add-apt-repository -y ppa:mapnik/boost
wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
echo deb http://dl.hhvm.com/ubuntu precise main | sudo tee /etc/apt/sources.list.d/hhvm.list
sudo apt-get update -y
sudo apt-get install -y hhvm
sudo apt-get install -y libboost1.49-dev libboost-regex1.49-dev libboost-system1.49-dev libboost-program-options1.49-dev libboost-filesystem1.49-dev libboost-thread1.49-dev
sudo update-rc.d hhvm defaults

# Install Nginx.
sudo add-apt-repository -y ppa:nginx/stable
sudo apt-get update -y
sudo apt-get install -y nginx
sudo cp /vagrant/config/nginx/nginx.conf /etc/nginx/nginx.conf
sudo cp /vagrant/config/nginx/hhvm.conf /etc/nginx/sites-available/hhvm.conf
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/hhvm.conf /etc/nginx/sites-enabled/hhvm.conf
sudo service nginx restart
sudo update-rc.d nginx defaults

# Configure HHVM.
sudo cp /vagrant/config/hhvm/server.ini /etc/hhvm/server.ini
sudo service hhvm stop
sudo cp /vagrant/config/hhvm/hhvm-init.d.sh /etc/init.d/hhvm
sudo service hhvm start
sudo /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60

# Create folder for project root.
sudo mkdir -p /var/www/html
sudo cp /vagrant/config/hhvm/index.php /var/www/html/index.php
sudo chown -R vagrant: /var/www
rm /var/www/html/index.html
rm /var/www/html/index.nginx-debian.html
touch /var/www/html/.hhconfig

# Install Beanstalkd.
sudo apt-get install -y beanstalkd
sudo cp /vagrant/config/beanstalkd/beanstalkd.conf /etc/default/beanstalkd
sudo service beanstalkd start
sudo update-rc.d beanstalkd defaults

# Install composer.
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install Redis.
sudo apt-get install -y redis-server
sudo cp /vagrant/config/redis/redis.conf /etc/redis/redis.conf
sudo service redis-server restart
sudo update-rc.d redis-server defaults

# Install Memcached.
sudo apt-get install -y memcached
sudo cp /vagrant/config/memcached/memcached.conf /etc/memcached.conf
sudo service memcached restart
sudo update-rc.d memcached defaults
sudo apt-get install -y php5-memcache

# Install Vim Pathogen.
mkdir -p /home/vagrant/.vim/autoload /home/vagrant/.vim/bundle /home/vagrant/.vim/colors && curl -LSso /home/vagrant/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
sudo mkdir -p /root/.vim/autoload /root/.vim/bundle /root/.vim/colors && sudo curl -LSso /root/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Install Vim Hack.
git clone git://github.com/hhvm/vim-hack.git /home/vagrant/.vim/bundle/vim-hack
sudo git clone git://github.com/hhvm/vim-hack.git /root/.vim/bundle/vim-hack

# Install Vim Tomorrow Night Eighties theme.
cp /vagrant/config/vim/TomorrowNightEighties.vim /home/vagrant/.vim/colors/TomorrowNightEighties.vim
sudo cp /vagrant/config/vim/TomorrowNightEighties.vim /root/.vim/colors/TomorrowNightEighties.vim

# Add custom Vim config.
cp /vagrant/config/vim/vimrc /home/vagrant/.vimrc
sudo cp /vagrant/config/vim/vimrc /root/.vimrc

# Custom bashrc.
cp /vagrant/config/bash/vagrant.bashrc /home/vagrant/.bashrc
sudo cp /vagrant/config/bash/root.bashrc /root/.bashrc

# Install PHPUnit via composer
composer global require phpunit/phpunit
