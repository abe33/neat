# Introduction

[![Build Status](https://travis-ci.org/abe33/neat.png?branch=0.0.70)](https://travis-ci.org/abe33/neat)
[![Dependency Status](https://gemnasium.com/abe33/neat.png)](https://gemnasium.com/abe33/neat)
[![NPM version](https://badge.fury.io/js/neat.png)](http://badge.fury.io/js/neat)

A command line tool for [Coffeescript][coffee] projects inspired by [Rails][rails] and running on [Node.js][node] .

### Install

Install [Node.js][node], and then the [Coffeescript][coffee] compiler through
`npm`. Coffeescript is required to access the `cake` command.

```bash
npm install -g coffee-script```

Installing Neat through `npm`:

```bash
npm install -g neat```

Installing Neat from sources:

```bash
git clone git://github.com/abe33/neat.git
cd neat
cake install
cake deploy```

### Usage

Creating a new project:

```bash
neat generate project my_project```

#### Inside a project directory

Installing the dependencies of a project:

```bash
neat install```

Creating a new Neat command:

```bash
neat generate command my_command```

Creating a new Neat initializer:

```bash
neat generate initializer my_init```

Creating a new Neat task:

```bash
neat generate task my_task```

Creating the `package.json` file for the project:

```bash
neat generate package.json```

#### Project Cake Tasks

Compiling sources:

```bash
cake compile```

Testing the project:

```bash
cake test```

Passing the project sources through [Coffeelint][lint]:

```bash
cake lint```

### Useful Resources

To suggest a feature, report a bug, or general discussion:

[http://github.com/abe33/neat/issues/](http://github.com/abe33/neat/issues/)

The source repository:

[git://github.com/abe33/neat.git](git://github.com/abe33/neat.git)

[coffee]: http://jashkenas.github.com/coffee-script
[node]:   http://nodejs.org/
[rails]:  http://rubyonrails.org/
[lint]:   http://www.coffeelint.org/

