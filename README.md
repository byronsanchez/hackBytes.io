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

Afterwards, you must install the packaged gems:

    bundle install

Now you're all set and can use hackBytes as a baseline to building
your own custom Jekyll website!

To remove material that is copyrighted by me, run the following
command from the root of the project directory:

    rake nuke

## Usage

The following is a list of all available commands for managing the website.  
Execute whichever you may need.

To build the website:

    rake build

To build and run both the application and all tests:

    rake test

To build the tests without running them:

    rake build-tests

To run the tests without building them (this assumes you have previously built
them):

    rake run-tests

To clean all built files:

    rake clean

## Copyright / License

hackbytes.com source code is Copyright (c) 2013 by Byron Sanchez, licensed
under the GNU GPL v2.0.

hackbytes.com logo is Copyright (c) 2013 by Byron Sanchez. All rights
reserved.

hackbytes.com images and any media (defined as binary files that are not
software dependencies) are Copyright (c) 2013 Byron Sanchez, licensed
under Creative Commons: BY-SA Attribution 3.0 unless otherwise noted.
http://creativecommons.org/licenses/by-sa/3.0/
Attribution specification is in the COPYRIGHT file.

hackbytes.com copy is Copyright (c) 2013 by Byron Sanchez. All rights
reserved.

hackbytes.com copy "code snippets" in the _posts/ directory and any
subdirectories thereof are Copyright (c) 2013 by Byron Sanchez, licensed
under the MIT license.

---

Read the COPYRIGHT file carefully for the details of what this all
means.

In short:

- You may not use the following content for any reason without my
  explicit permission:

  * The hackBytes logo

  * Any content in the _posts directory (except for code snippets,
    which I am licensing under the MIT license)
  
- You can use anything else, so long as you follow the licensing
  requirements for the content you are using. This is all detailed
  in the COPYRIGHT file.

- Also, remember to:

  * Remove my Google Analytics ID from _includes/analytics.html

  * Remove any custom RSS feeds, twitter embeds, github embeds, etc.
    You probably don't want my stuff to show up on anything you
    decide to build.
