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

## Golang:

- All the things common to all the machines.
- Golang v1.14.6

## Terraform:

- All the things common to all the machines.
- Latest version of Terraform

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