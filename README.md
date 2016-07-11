libre-mesh.org build tool
=====================
LiMe build is a tool to easy compile a libre-mesh firmware image and a development enviroment for developers.

It consists in a Makefile, so it is executed using the GNU "make" command.

CopyRight libre-mesh.org / Distributed under license GPLv3

Preparing environment
===================
In Ubuntu/Debian 

    sudo apt-get install \
    git subversion zlib1g-dev gawk flex unzip bzip2 gettext build-essential \
    libncurses5-dev libncursesw5-dev libssl- dev binutils cpp psmisc docbook-to-man

And if your system is 64bits

     sudo apt-get install gcc-multilib


Basic  Usage
==========
An example of basic usage would be:

    make T=ar71xx P=generic J=4

Where:

* T indicates de target
* P indicates de profile
* J indicates the number of cores to use  

Target makes reference to hardware architecture or a specific hardware device. 

Profile references to a libre-mesh flavor, the generic one is the standard but each community network might has its own.

To see the list of targets/profiles available type:

    make info

Extended  Usage
==============
To specify custom packages instead of the profile ones

    make T=ar71xx PACKAGES="pkg1 pkg2..."

To work in developer mode (uses lime read-write repository )

    make DEV=1 T=ar71xx P=geneirc

Or to use your own LiMe packages git repository and/or OpenWRT/LEDE (must be executed the first time make is invoked or after clean).

    make LIME_GIT="http://foo.git" T=ar71xx P=generic OWRT_GIT="http://foo.git"

To use a specific branch (UPDATE=1 might be required in order to fetch the branch files)

    make T=ar71xx LIME_GIT_BRANCH=develop UPDATE=1


To syncronize config files from configs/ dir to existing target

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


 Directory structure
================
There are several directories and files. This is the functionallity for each of them:

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
