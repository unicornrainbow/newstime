![NEWSTIME](https://raw.githubusercontent.com/blakefrost/newstime/master/screenshots/2014/02/01/composer.png)

A printing press for internet newspapers.

## Quick Setup

Check [system requirements](#system-requirement)

Clone the project and install gem dependencies.

    $ git clone https://github.com/newstime/newstime.git
    $ cd newstime
    $ bundle install

Start the application from the project root.

    $ foreman start

Visit http://localhost:5000/, in your browser, where the application will now be available.

Congrats! You should now have a running installation of Newstime. Continue to
the next section to install line breaking service which is used by the
typesetter.


## Install and Configure Line Breaking Service

Newstime is a typesetting application and uses the [line breaking
service](https://github.com/newstime/line_breaking_service) for this function.
The service must be available, and Newstime configured accordingly for proper
functionality.

For quick installation of the line breaking service.

    git clone https://github.com/newstime/line_breaking_service.git
    cd line_breaking_service
    bundle install

To start the service on port 9000

    $ foreman start -p 9000

And then to configure Newstime to point at it, update, or add the following
line to the .env file in the root of this project

    LINEBREAK_SERVICE_URL='http://localhost:9000'

Ensure that you restart Newstime so that these change are recognized.

Quicktip: Ctrl-c will stop foreman. Reissue the start command to start it back
up.


## System Requirement

Newstime can run anywhere you can run Ruby on Rails. It currently requires
version 2.0.0 of Ruby and version 4.0.2 of Rails. This may change in the future.
Check the source code for exact version numbers, which are recorded in the
.ruby-version file, and Gemfile.lock files in the project source code root
respectively.

I recommend using [rbenv](https://github.com/sstephenson/rbenv) to manage the
Ruby version, and associated gems such as Rails. This is available, and works
well on many operating systems.

If you have rbenv installed, along with it's sister project,
[ruby-build](https://github.com/sstephenson/ruby-build), you can install Ruby
2.0.0 with the following command.

    $ rbenv install 2.0.0-p247

On OSX, ruby-build can be installed used the [Homebrew Package
Manager](http://brew.sh/), so you may wish to install that first, if you haven't
already, and this applies to you.

Brew is wonderful for installing system packages on OSX. Regardless of the
underlying operating system, you probably have a preferred package manager, and
that should suffice in installing the required system packages.

### Mongo Database

Newstime uses the fabulous [https://www.mongodb.org/](MongoDB) database system
as it's backing data store.

Mongo should be installed, if functionality is expected.

    $ brew install mongodb

### Image Magick

Newstime uses [Image Magick](http://imagemagick.org/) for image manipulation.
Ensure this is installed to avoid related errors, and enable this functionality.

Image Magick can be installed with the following brew command on OSX.

    $ brew install imagemagick

Likewise, on a GNU/Linux based operating system, using apt-get.

    $ sudo apt-get install imagemagick

### FFmpeg

[FFmpeg](http://ffmpeg.org/) is used for video processing and generating frames from video source.

Install with the following brew command

     $ brew install ffmpeg

### Webkit2png

[Webkit2png](http://www.paulhammond.org/webkit2png/) is used for creating screenshots of the finished edition.

    $ brew install webkit2png

### Further Dependencies

There are a number of other dependencies, which I will not go into such detail
here for brevity sake, but will include their names, and installation commands,
and brief description of purpose for completeness.

    # sqlite3
    $ brew install sqlite3  # Not 100% Sure what this is used for, may be possible to omit.

    # curl
    $ brew install curl     # Used for certain api calls.

    # nodejs
    $ brew install nodejs   # Used for javascript compilation


Check [here](doc/installing-newstime-on-ubuntu-12.04.md) for further packages that might be required if installing on Ubuntu.

Please open an issue, submit a pull request, or otherwise contact us if you
would like to help us improve these setup instructions.

## License

Be there such a thing, you have it.
