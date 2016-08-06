[Libre-Mesh](http://libre-mesh.org) firmware build tool
=====================
LiMe build is a tool to easily and locally compile a Libre-Mesh firmware image. It also creates a development environment.

It consists in a Makefile file, so it is executed using the GNU "make" command.


CopyRight libre-mesh.org / Distributed under license GPLv3

Get in Touch with Libre-Mesh Community
======================================

Mailing Lists
-------------

The project offers the following mailing lists

* [dev@lists.libre-mesh.org](https://lists.libre-mesh.org/mailman/listinfo/dev) - This list is used for general development related work.
* [users@lists.libre-mesh.org](https://lists.libre-mesh.org/mailman/listinfo/users) - This list is used for project organizational purposes. And for user specific questions.

IRC Channel
-----------

The project uses an IRC channel on freenode.net

* #libre-mesh - a public channel for everyone to join and participate

Preparing the Compilation Environment
===================
In Ubuntu/Debian 

    sudo apt-get install \
    git subversion zlib1g-dev gawk flex unzip bzip2 gettext build-essential \
    libncurses5-dev libncursesw5-dev libssl-dev binutils cpp psmisc docbook-to-man

Additionally, if your system is 64bits

     sudo apt-get install gcc-multilib

Basic Usage
==========
An example of basic usage would be:

    make T=ar71xx P=generic J=4

Where:

* T indicates the target
* P indicates the profile
* J indicates the number of cores to use  

Target makes reference to hardware architecture or a specific hardware device. 

Profile references to a libre-mesh flavour, the generic one is the standard but each community network might has its own.

To see the list of targets/profiles available type:

    make info

Extended Usage
==============
To compile an image for hardware with less than 4 MB of flash memory

    make T=ar71xx-mini P=basic

To include more packages than the profile ones

    make T=ar71xx PACKAGES="pkg1 pkg2..."

To specify manually the list of the packages using a void profile

    make T=ar71xx P=custom PACKAGES="pkg1 pkg2..."

To work in developer mode (uses lime read-write repository)

    make DEV=1 T=ar71xx P=generic

Or to use your own LiMe packages git repository and/or OpenWRT/LEDE (must be executed the first time make is invoked or after a make clean).

    make LIME_GIT="http://foo.git" T=ar71xx P=generic OWRT_GIT="http://foo.git"

To synchronize config files from configs/ dir to existing target

    make T=ar71xx sync_config

------------------------------------------
To run menuconfig (from openwrt):

    make T=ar71xx menuconfig

After that, the new config file will be applied to destination target and also it will by copied to build/configs directory

------------------------------------------
To run kernel menuconfig (from openwrt), in this case config file will be not copied because it is not directly compatible with configs/target/kernel_config:

    make T=ar71xx kernel_menuconfig

------------------------------------------
To run just the initial code checkout:

    make T=ar71xx checkout

------------------------------------------
To clean all:

    make clean

------------------------------------------
To clean just lime packages from a target

    make T=ar71xx clean_lime

------------------------------------------

Branches in _lime-build_
------------------------

The idea behind _lime-build_ is to use one branch per each [lime-packages](/libre-mesh/lime-packages) branch. 
So to compile the lime-packages branch "develop" the lime-build branch develop must be used (same for releases).

Note that a lime branch involves a specific OpenWRT/LEDE branch and also a specific set of feeds.
So using lime-build branch develop to compile lime-packages branch release XX.YY would probably result in a non working firmware.
Anyway if you want to try this you can specify which branch of _lime-packaged_ has to be used in combination with current _lime-build_ branch (UPDATE=1 might be required in order to fetch the branch files).

    make T=ar71xx LIME_GIT_BRANCH=develop UPDATE=1


Directory structure
================
There are several directories and files. This is the functionality for each of them:

* Makefile: the main makefile

* targets.mk: contains all information related with targets.

* profiles.mk: contains all information related with profiles.

* build: directory with source files

* build/configs: if you do some change in config file using "menuconfig" option, the new config is saved here

* dl: download folder for OpenWRT packages

* targets: config files for each kind of hardware. 

* output: output directory for compiled images firmwares

* files: everything inside will be directly copied to the root of the system firmware image

* scripts: special directory to execute scripts before and/or after the compilation process, see scripts/README
