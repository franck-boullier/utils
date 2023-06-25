# Overview

This is where we store all the scripts and stuff that help us configure things faster.

These are (most of the time) bash scripts that you can use to install stuff on a Linux machine.

# How to use this:

I try to explain how to use the code that I store there in the tutorial or article that uses this code.

- [How I’ve slashed the cost of my DEV environments by 90%](https://itnext.io/how-ive-slashed-the-cost-of-my-dev-environments-by-90-9c1082ad1baf?source=your_stories_page---------------------------).

See also [How to create DEV machines](./create_dev_machines.md) in this repo for more details.

You can also open each file: I try to add a lot of comments there to describe, understand, and remember what everything is supposed to do. These comments will hopefully help you too.

# Available Development machines:

## Common to all the machines:

- Ubuntu 20.04lts (2004-focal-v20210927)
- Chrome Remote Desktop
- Xcfe: a GUI for Ubuntu
- Firefox
- Chrome
- Google Cloud SDK
- AWS CLI
- VS Code (Visual Studio)

## [Golang](./golang-dev-machine.sh):

- All the things common to all the machines.
- Golang v1.14.6

## [Python](./python-dev-machine.sh):

- All the things common to all the machines.
- Python 3.

## [Terraform](./terraform-dev-machine.sh):

- All the things common to all the machines.
- Latest version of Terraform

## [MySQL](./mysql-dev-machine.sh):

- All the things common to all the machines.
- Wine <-- run Windows App.
- A MySQL client for the CLI.
- The MySQL Workbench interface.

## [node.js](./node-js-dev-machine.sh):

- All the things common to all the machines.
- Node JS.

Once the machine is configured, install the following things.

### On Chrome: 

n/a

### On Visual Studio: 

n/a
## [VUE](./vue-dev-machine.sh):

- All the things common to all the machines.
- npm
- Node JS.
- yarn
- VUE CLI.

Once the machine is configured, install the following things.
### On Chrome: 

- [Vue DEVTOOLS](https://github.com/vuejs/devtools#vue-devtools).

### On Visual Studio: 

See the [How to use recommended extensions to develop with Vue](https://www.vuemastery.com/blog/vs-code-for-vuejs-developers/)

  - Material Icons: Better looling icons in VS navbar
  - [Vue Extension](https://marketplace.visualstudio.com/items?itemName=jcbuisson.vue).
  - [es6-string-html](https://marketplace.visualstudio.com/items?itemName=Tobermory.es6-string-html)
  - Live Server: Right click to see the code in action.
  - Vetur: Vue tooling.
  - Vue: Vue Syntax Highlight
  - es6-string-html: html syntax highlight inside VUE
  - ESLint: make sure the indentation is correct.

## [Flutter (Native and Web apps)](./flutter-dev-machine.sh):

- All the things common to all the machines.
- npm
- Node JS.
- yarn
- Flutter.

Once the machine is configured, install the following things.

## On Chrome: 

n/a
## On Visual Studio: 

  - [es6-string-html](https://marketplace.visualstudio.com/items?itemName=Tobermory.es6-string-html)
  - ESLint: make sure the indentation is correct.


# Tips and Tricks:

To check the status of a bash script that is currently running in the background you can open a terminal window on the machine and run the command
```
sudo journalctl -f -o cat
```
This displays the output of the script that's running in the background.
Once done you can exit with `Crtl C`.

# DISCLAIMER:

There is no guarantee that the code here will work for you. 

It's always a good idea to make sure that you understand what you're doing, and anyway, you use the code in this repository at your own risks!

For more details on the legalese, read the LICENSE file.