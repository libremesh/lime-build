# config.mk
DEV ?=
OWRT_GIT ?= git://git.openwrt.org/15.05/openwrt.git
OWRT_SCM = git clone $(OWRT_GIT)
LIME_GIT_RW = git@github.com:libre-mesh/lime-packages.git
LIME_GIT_RO = git://github.com/libre-mesh/lime-packages.git
LIME_GIT_BRANCH ?= testing/16.07
BUILD_DIR = build
CONFIG_DIR = targets
MY_CONFIGS = $(BUILD_DIR)/configs
IMAGES = output
SHELL = bash
SCRIPTS_DIR= scripts
LIME_PKG_DIR = lime-packages
TBUILD ?= src
UPDATE ?=
