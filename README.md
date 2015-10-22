![NEWSTIME](https://raw.githubusercontent.com/blakefrost/newstime/master/screenshots/2014/02/01/composer.png)

A free and versatile press system for static hypermedia publications.

This Newstime press software caters to the needs of publishers and those
looking to inform the public. It has a deep focus on typographic solutions within
digital media. The end goal of this conceptual software, is to quickly and
easily layout type, images and videos in a manner suitable for composing daily
publications.

## Setup the System

Newstime is composed of a number of pieces, and installing it requires knowledge
of Linux and it's inner workings. This is the current working configuration used
by the developer of this software. We encourage the customization of this
configuration to best meet your specific needs.

This is the recommended installation procedure for Newstime, based on Ubuntu
12.04.

**Step 1)** Once connected and logged into the box Newstime will be installed on, be
sure to do an apt-get update, to ensure you are working with the latest
recommended packages.

    sudo apt-get -y update

**Step 2)** Install system packages required in one way or another by Newstime.

    sudo apt-get install zlib1g zlib1g-dev
    sudo apt-get install build-essential
    sudo apt-get install openssl libssl-dev
    sudo apt-get install libmysqlclient18 libmysqlclient-dev
    sudo apt-get install libyaml-dev
    sudo apt-get install git-core
    sudo apt-get install python-software-properties
    sudo apt-get install libpq-dev
    sudo apt-get install nodejs
    sudo apt-get install mongodb

    # Need curl libraries install for curb gem in newstime project
    sudo apt-get install curl libcurl3 libcurl3-gnutls libcurl4-openssl-dev

    # Need the sqlite libraries
    sudo apt-get install sqlite3 libsqlite3-dev

    ## Install ImageMagik for paperclip
    sudo apt-get install imagemagick


**Step 3)** Install Rbenv for managing the ruby environment, and Ruby 2.0.0

See: https://github.com/sstephenson/rbenv#installation

**Step 4)** Install the bundler gem

    gem install bundler

**Step 5)** Clone the project, and run bundle to install dependencies

    mkdir -p /var/www
    cd /var/www
    git clone https://github.com/newstime/newstime.git
    cd newstime
    bundle

**Step 6)** Configure line breaking service URL

The following configuration is made in the .env file in the root of the project.
If this file does not exist, create it, and add the following line configured as
such.

    LINEBREAK_SERVICE_URL='http://localhost:9000'


**Step 7)** Create pid and socket folders for unicorn.

    mkdir -p /home/vagrant/newstime/tmp/pids/
    mkdir -p /home/vagrant/newstime/tmp/sockets

**Step 8)** Start the application

    bundle exec script/start_unicorn

**Step 9)** Copy and setup nginx config

    sudo cp /var/www/newstime/config/example.nginx.conf /etc/nginx/sites-available/newstime.conf
    cd /etc/nginx/sites-enabled
    ln -d ../sites-available/newstime.conf
    sudo nginx -s reload

**Step 8)** Setup and start line breaking service

    cd /var/www
    git clone https://github.com/newstime/line_breaking_service.git
    cd line_breaking_service
    bundle
    foreman start -p 9000

## License

Be there such a thing, you have it.
