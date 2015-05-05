# hackBytes.com

hackBytes is a website dedicated to the mastery of software engineering and 
computer science.

## Requirements

To best reproduce this website, be sure to have 
[Ruby](https://www.ruby-lang.org/en/downloads/) installed. All scripts are 
built on version 2.0.0.

## Setup

Clone the hackbytes.com repository, or alternatively, clone your fork
of the hackbytes.com repository, along with its submodules.

For git version 1.6.5 or higher, run:

    git clone --recursive https://github.com/byronsanchez/hackbytes.com.git
    cd hackbytes.com

For other versions of git, run:

    git clone https://github.com/byronsanchez/hackbytes.com.git
    cd hackbytes.com
    git submodule update --init

Afterwards, run:

    ./init.sh

Now you're all set and can use hackBytes as a baseline to building
your own custom Jekyll website!

To remove material that is copyrighted by me, run the following
command from the root of the project directory:

    bundle exec rake nuke

## Configuration

hackbytes.com uses several tools that provide a lot of flexibility and ease 
when it comes to managing and maintaining the website.

Be aware of the following configurations:

  - \_config.yml - The main Jekyll configuration file.

    - hackbytes.com treats this file as the "global" configuration file. All 
      settings defined in this file are available to every maintenance script 
      via the @config instance variable; thus, capistrano files, rake files, 
      and ruby support files have access to this data.

  - config.rb - The Compass configuration file for the scss compiler.

  - config/ - The Capistrano configuration directory.

## Usage

The following is a list of all available commands for managing the website.  

To build the website:

    bundle exec rake build

To build and run both the website and all tests:

    bundle exec rake test

To build the tests without running them:

    bundle exec rake build-tests

To run the tests without building them (this assumes you have previously built
them):

    bundle exec rake run-tests

To clean all built files:

    bundle exec rake clean

To deploy the website to the server:

    bundle exec rake deploy

## Comments

The comments database is created upon submission of the first comment. The 
following is a list of all available commands for managing comments once the 
database is created.

To pull the comments database from the server:

    bundle exec rake comments-pull

To display a list of all comments along with their ids:

    bundle exec rake comments-list

To view the contents of a comment:

    bundle exec rake comments-view[id]

To publish a comment:

    bundle exec rake comments-publish[id]

To unpublish a comment:

    bundle exec rake comments-unpublish[id]

To delete a comment:

    bundle exec rake comments-delete[id]

To push the modified database back to the server:

    bundle exec rake comments-push

## Copyright / License

The COPYRIGHT file contains copyright information for all content used in this 
project.

