# wintersmith-handleize-helper

[![Build Status](https://secure.travis-ci.org/byronsanchez/wintersmith-handleize-helper.png?branch=develop)][travis]

[travis]: https://travis-ci.org/byronsanchez/wintersmith-handleize-helper

wintersmith-handleize-helper is a plugin that registers a handleize function in 
the `env.helpers` object hash. It returns a handleized version of any string 
that is passed to it.

## Requirements

This repo is meant to be used as a plugin for 
[Wintersmith](https://github.com/jnordberg/wintersmith)-generated websites. To 
use this plugin, simply setup a wintersmith website and follow the setup 
instructions below.

## Setup

Setting up the plugin is very simple:

    npm install wintersmith-handleize-helper

Alternatively, you can define the plugin as a dependency in your `package.json` file and run:

    npm install

In your `config.json` file, you must define the location of the plugin:

    "plugins": [
      "./node_modules/wintersmith-handleize-helper/"
    ]

## Usage

Once you have completed the setup, you may use the plugin by invoking:

    handleizedString = env.helpers.handleize "The Wintersmith"

## License

"wintersmith-handleize-helper" is Copyright (c) 2014 by Byron Sanchez, licensed
under the GNU GPL v2.0.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, version 2 of the License.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.

