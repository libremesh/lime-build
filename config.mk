# config.mk
DEV ?=
OWRT_GIT ?= https://github.com/lede-project/source.git
OWRT_SCM = git clone $(OWRT_GIT)
LIME_GIT_RW = git@github.com:libremesh/lime-packages.git
LIME_GIT_RO = git://github.com/libremesh/lime-packages.git
LIME_GIT_BRANCH ?= develop
BUILD_DIR = build
CONFIG_DIR = targets
MY_CONFIGS = $(BUILD_DIR)/configs
IMAGES = output
SHELL = bash
SCRIPTS_DIR= scripts
LIME_PKG_DIR = lime-packages
TBUILD ?= src
UPDATE ?=
