 libre-mesh.org build tool
===============================================================================

LiMe build is a tool for developers to create a development enviroment for libre-mesh.
Basically it consists in one Makefile, so it is executed using the GNU "make" command.

Read Only URL: git://github.com/libre-mesh/lime-build.git
Developer URL: git@github.com:libre-mesh/lime-build.git

CopyRight libre-mesh.org / Distributed under license GPLv3

 Usage
=================================================================================

To compile a LiMe image from scratch, you need to specify the target (next example with target=rspro):
This command will run all necessary commands to compile the image. After the compilation you can see the 
OpenWRT code in directory: build/[target]

    make T=rspro build

Also you can specify the number of parallel processes for compilation and the verbose level:

    make V=99 J=2 T=rspro build

For work in developer mode (uses lime readwrite repository instead readonly one)

    make T=rspro DEV=1 build

To use a specific branch (this should be done first time you run make)

    make T=rspro LIME_GIT_BRANCH=myFeature build

To change the LiMe branch once you have executed make for first time

    make LIME_GIT_BRANCH="myFeature" update_all

---------------------------------------------------------------------------------
To see list of avaiable targets run:

    make list_targets

---------------------------------------------------------------------------------
This will update the repositories on the target specified

    make update T=rspro

---------------------------------------------------------------------------------
This will update all sources

    make update_all

---------------------------------------------------------------------------------
To syncronize config files from configs/ dir to existing target

    make T=rspro sync_config

---------------------------------------------------------------------------------
To run menuconfig (from openwrt):

    make T=rspro menuconfig

After that, the new config file will be applied to destination target and also it will by copied inside build/configs directory

---------------------------------------------------------------------------------
To run kernel menuconfig (from openwrt), in this case config file will be not copied because it is not directly compatible with configs/target/kernel_config:

    make T=rspro kernel_menuconfig

---------------------------------------------------------------------------------
To run the initial checkout:

    make T=rspro checkout

---------------------------------------------------------------------------------
Copy images built before to output directory

    make T=rspro post_build

---------------------------------------------------------------------------------
To clean specific target:

    make T=rspro clean

---------------------------------------------------------------------------------
To clean all targets:

    make clean

---------------------------------------------------------------------------------
To clean just lime packages from a target

    make T=rspro clean_lime

---------------------------------------------------------------------------------
To configure some general parameters from LiMe you can run:

    make config

TODO: This feature is missing


 Directory structure
=================================================================================

There are several directories and files. This is the functionallity for each of them:

    - Makefile: the main makefile

    - targets.mk: file which contains all information related with targets. If you want to add a new supported device you must edit it

    - build: here you will have all needed sources

    - build/configs: if you do some change in config file using "menuconfig" option, the new config is placed here (and also in destination target)

    - dl: download folder for OpenWRT packages

    - configs: config files for each kind of hardware. These are the default ones provided by limefw

    - images: output directory for compiled images, each of them has a different timestamp, so you can have as many as you want

    - files: directories and files inside will be directly copied to the root of the system image

    - scripts: special directory to execute arbitrari script before and/or after the compilation process, see scripts/README

