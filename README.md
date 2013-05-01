# Neat
[![Build Status](https://travis-ci.org/abe33/neat.png?branch=0.0.70)](https://travis-ci.org/abe33/neat)
[![Dependency Status](https://gemnasium.com/abe33/neat.png)](https://gemnasium.com/abe33/neat)
[![NPM version](https://badge.fury.io/js/neat.png)](http://badge.fury.io/js/neat)

A command line tool for [Coffeescript][coffee] and [Node.js][node] projects inspired by [Rails][rails].

### Documentation

Please take a look at the [project pages](http://abe33.github.com/neat/) for documentation.

### Install

Install [Node.js][node], and then the [Coffeescript][coffee] compiler through
`npm` (having a global installation of Coffeescript is a good practice if you
plan to work on Neat itself):

    npm install -g coffee-script

Installing Neat through `npm`:

    npm install -g neat

Installing Neat from sources:

    git clone git://github.com/abe33/neat.git
    cd neat
    cake install
    cake deploy

### Usage

Creating a new project:

    neat generate project my_project

#### Inside a project directory

Installing the dependencies of a project:

    neat install

Creating a new Neat command:

    neat generate command my_command

Creating a new Neat initializer:

    neat generate initializer my_init

Creating a new Neat task:

    neat generate task my_task

Creating the `package.json` file for the project:

    neat generate package.json

#### Project Cake Tasks

Compiling sources:

    cake compile

Testing the project:

    cake test

Passing the project sources through [Coffeelint][lint]:

    cake lint

### Useful Resources

To suggest a feature, report a bug, or general discussion:

[http://github.com/abe33/neat/issues/](http://github.com/abe33/neat/issues/)

The source repository:

[git://github.com/abe33/neat.git](git://github.com/abe33/neat.git)

[coffee]: http://jashkenas.github.com/coffee-script
[node]:   http://nodejs.org/
[rails]:  http://rubyonrails.org/
[lint]:   http://www.coffeelint.org/

