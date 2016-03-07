#!/usr/bin/env bash

# HHVM install branch/tag.
export HHVM_INSTALL_BRANCH_NAME="HHVM-3.12.0"

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

# Install HHVM pre-reqs.
sudo apt-get install -y git-core gawk cmake g++ libmysqlclient-dev libxml2-dev libmcrypt-dev libicu-dev openssl build-essential binutils-dev libcap-dev libgd2-xpm-dev zlib1g-dev libtbb-dev libonig-dev libpcre3-dev autoconf automake libtool libcurl4-openssl-dev wget memcached libreadline-dev libncurses-dev libmemcached-dev libbz2-dev libc-client2007e-dev php5-mcrypt php5-imagick libgoogle-perftools-dev libcloog-ppl0 libelf-dev libdwarf-dev subversion python-software-properties libmagickwand-dev libxslt1-dev libevent-dev gawk libyaml-dev gperf

# Update gcc to 4.8.
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get update -y
sudo apt-get install -y gcc-4.8 g++-4.8

# Make gcc 4.8 the default compiler.
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.8
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6
sudo update-alternatives --set gcc /usr/bin/gcc-4.8

# Install Boost 1.55.
sudo add-apt-repository -y ppa:boost-latest/ppa
sudo apt-get update -y
sudo apt-get install -y libboost1.55-all-dev

# Build newer version of ocaml.
sudo mkdir /opt/build-hhvm
sudo chown vagrant: /opt/build-hhvm
cd /opt/build-hhvm
wget http://caml.inria.fr/pub/distrib/ocaml-4.02/ocaml-4.02.1.tar.gz
tar xvf ocaml-4.02.1.tar.gz
rm ocaml-4.02.1.tar.gz
cd ocaml-4.02.1
./configure
make world.opt
sudo make install
cd ..

# Get HHVM source code.
mkdir dev
cd dev
git clone git://github.com/facebook/hhvm.git --depth=1
cd hhvm
git checkout $HHVM_INSTALL_BRANCH_NAME
git pull
git submodule update --init --recursive
export CMAKE_PREFIX_PATH=`pwd`/..
cd ..

# Build libCurl.
git clone git://github.com/bagder/curl.git --depth=1
cd curl
./buildconf
./configure --prefix=$CMAKE_PREFIX_PATH
make
make install
cd ..

# Build Google glog.
svn checkout http://google-glog.googlecode.com/svn/trunk/ google-glog
cd google-glog
./configure --prefix=$CMAKE_PREFIX_PATH
make
sudo make install
cd ..

# Build JEMalloc 3.x.
wget http://www.canonware.com/download/jemalloc/jemalloc-3.6.0.tar.bz2
tar xjvf jemalloc-3.6.0.tar.bz2
rm jemalloc-3.6.0.tar.bz2
cd jemalloc-3.6.0
./configure --prefix=$CMAKE_PREFIX_PATH
make
sudo make install
cd ..

wget http://fribidi.org/download/fribidi-0.19.6.tar.bz2
tar -jxvf fribidi-0.19.6.tar.bz2
rm fribidi-0.19.6.tar.bz2
cd fribidi-0.19.6
./configure --prefix=$CMAKE_PREFIX_PATH
make
sudo make install
cd ..

sudo apt-get remove -y libglib2.0-dev libglib2.0-cil libglib2.0-bin libglib2.0-cil-dev libglib2.0-data
sudo apt-get install -y libfribidi-dev
sudo apt-get install -y libglib2.0-dev libglibmm-2.4-dev libgmp-dev libgmp-ocaml-dev libmagickwand-dev

# Building HHVM takes more than 1GB of RAM.
cd hhvm
rm CMakeCache.txt
cmake .
make

# Add pre-requisites for hackificator and remove_soft_types.
cd hphp/hack/tools/
wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sudo sh -s /usr/local/bin/
sudo apt-get install -y unzip
opam init -y
#eval `opam config env` # TODO : Maybe do this instead of the next 2 lines
TMP_OPAM_CONFIG=$(opam config env)
eval $TMP_OPAM_CONFIG
opam switch 4.01.0
#eval `opam config env` # TODO : Maybe do this instead of the next 2 lines
TMP_OPAM_CONFIG=$(opam config env)
eval $TMP_OPAM_CONFIG
opam install -y pfff

# Install hackificator.
cd hackificator
make clean
make depend
make
cd ..

# Install remove_soft_types.
cd remove_soft_types
make clean
make depend
make
cd ~

# Copy over hack files to /usr/bin.
sudo cp /opt/build-hhvm/dev/hhvm/hphp/hhvm/hhvm /usr/bin/hhvm
sudo cp /opt/build-hhvm/dev/hhvm/hphp/hack/bin/h2tp /usr/bin/h2tp
sudo cp /opt/build-hhvm/dev/hhvm/hphp/hack/bin/hh_client /usr/bin/hh_client
sudo cp /opt/build-hhvm/dev/hhvm/hphp/hack/bin/hh_server /usr/bin/hh_server
sudo cp /opt/build-hhvm/dev/hhvm/hphp/tools/oss-repo-mode /usr/bin/hhvm-repo-mode
sudo cp /opt/build-hhvm/dev/hhvm/hphp/hack/bin/tools/hackificator /usr/bin/hackificator
sudo chmod 775 /usr/bin/hackificator
sudo cp /opt/build-hhvm/dev/hhvm/hphp/hack/bin/tools/hack_remove_soft_types /usr/bin/hack_remove_soft_types
sudo chmod 775 /usr/bin/hack_remove_soft_types

# Copy main default HHVM config file.
sudo cp /vagrant/config/hhvm/etc.default.hhvm /etc/default/hhvm
sudo chmod 664 /etc/default/hhvm

# Copy Apache HHVM mod.
sudo cp /vagrant/config/apache/hhvm_proxy_fcgi.conf /etc/apache2/mods-available/hhvm_proxy_fcgi.conf
sudo chmod 664 /etc/apache2/mods-available/hhvm_proxy_fcgi.conf

# Create HHVM configs folder.
sudo mkdir -p /etc/hhvm/
sudo chmod 775 /etc/hhvm/

# Create HHVM log folder/file.
sudo mkdir -p /var/log/hhvm/
sudo touch /var/log/hhvm/error.log
sudo chown -R vagrant: /var/log/hhvm/
sudo chmod 755 /var/log/hhvm/
sudo chmod 664 /var/log/hhvm/error.log

# Copy HHVM PHP config.
sudo cp /vagrant/config/php/php.ini /etc/hhvm/php.ini
sudo chmod 664 /etc/hhvm/php.ini

# Copy HHVM server config.
sudo cp /vagrant/config/hhvm/server.ini /etc/hhvm/server.ini
sudo chmod 664 /etc/hhvm/server.ini

# Copy HHVM init.d script.
sudo cp /vagrant/config/hhvm/hhvm-init.d.sh /etc/init.d/hhvm
sudo chmod 775 /etc/init.d/hhvm

# Copy over hack, license and install/uninstall scripts.
sudo cp -R /vagrant/config/hhvm/usr.share.hhvm /usr/share/hhvm
sudo chmod 775 /usr/share/hhvm/*.sh

# Post install script for HHVM.
# php5-cli uses a priority of 50, so we pick a much smaller number
if [ -f /usr/sbin/update-alternatives ]; then
	sudo /usr/sbin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 10
fi
if [ -f /usr/bin/update-alternatives ]; then
	sudo /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 10
fi

RUN_AS_USER="vagrant"
RUN_AS_GROUP="vagrant"

if [ -f /etc/default/hhvm ]; then
    . /etc/default/hhvm
fi

sudo install -d -m 755 -o $RUN_AS_USER -g $RUN_AS_GROUP /var/run/hhvm
sudo install -d -m 01733 -o $RUN_AS_USER -g $RUN_AS_GROUP /var/lib/hhvm/sessions

if which invoke-rc.d >/dev/null 2>&1; then
    sudo invoke-rc.d hhvm start
fi

# Change PHP so that it calls HHVM instead.
sudo /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60

# Configure HHVM to start on server boot.
sudo update-rc.d hhvm defaults

# Install Nginx.
sudo add-apt-repository -y ppa:nginx/stable
sudo apt-get update -y
sudo apt-get install -y nginx
sudo cp /vagrant/config/nginx/nginx.conf /etc/nginx/nginx.conf
sudo cp /vagrant/config/nginx/nginx.sites-available.hhvm.conf /etc/nginx/sites-available/hhvm.conf
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/hhvm.conf /etc/nginx/sites-enabled/hhvm.conf
sudo service nginx restart
sudo update-rc.d nginx defaults

# Copy default Nginx HHVM fastcgi config.
sudo cp /vagrant/config/nginx/nginx.hhvm.conf /etc/nginx/hhvm.conf
sudo chmod 664 /etc/nginx/hhvm.conf

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

# Configure Memcached.
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

# Install PHPUnit via composer.
composer global require phpunit/phpunit

# Clean up HHVM build folder.
rm -rf /opt/build-hhvm/ocaml-4.02.1/
rm -rf /opt/build-hhvm/dev/curl/
rm -rf /opt/build-hhvm/dev/fribidi-0.19.6
rm -rf /opt/build-hhvm/dev/google-glog/
rm -rf /opt/build-hhvm/dev/jemalloc-3.6.0/
rm -rf /opt/build-hhvm/dev/hhvm/
sudo rm -rf /opt/build-hhvm/dev/share/
sudo rm -rf /opt/build-hhvm/dev/include/
sudo rm -rf /opt/build-hhvm/dev/bin/
