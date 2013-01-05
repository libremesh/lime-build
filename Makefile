# [qMp] firmware generator (http://qmp.cat)
#
#    Copyright (C) 2011-2012 qmp.cat
#
#    Thiss program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Contributors: Simó Albert i Beltran
#

#OWRT_SVN = svn://svn.openwrt.org/openwrt/trunk
#OWRT_SVN_REV = 29592
OWRT_SVN = svn://svn.openwrt.org/openwrt/branches/backfire
OWRT_PKG_SVN =  svn://svn.openwrt.org/openwrt/branches/packages_10.03.1
QMP_GIT_RW = ssh://gitosis@qmp.cat:221/qmp.git
QMP_GIT_RO = git://qmp.cat/qmp.git
QMP_GIT_BRANCH ?= master
BUILD_DIR = build
CONFIG_DIR = configs
MY_CONFIGS = $(BUILD_DIR)/configs
IMAGES = images
SHELL = bash
QMP_FEED = package/feeds/qmp_packages
COMMUNITY ?= qMp
SCRIPTS_DIR= scripts
J ?= 1
V ?= 0
T =
MAKE_SRC = -j$(J) V=$(V)

include targets.mk

TIMESTAMP = $(shell date +%Y%m%d_%H%M)

#Checking if developer mode is enabled and if target is defined before
$(eval $(if $(DEV),QMP_GIT=$(QMP_GIT_RW),QMP_GIT=$(QMP_GIT_RO)))
$(eval $(if $(TARGET),,TARGET=$(T)))

#Getting output image paths
IMAGE_PATH = $(IMAGE)
SIMAGE_PATH = $(SYSUPGRADE)

CONFIG = $(BUILD_DIR)/$(TARGET)/.config
KCONFIG = $(BUILD_DIR)/$(TARGET)/target/linux/$(ARCH)/config-*

.PHONY: checkout update clean config menuconfig kernel_menuconfig list_targets build clean_qmp

define build_src
	$(eval BRANCH_GIT=$(shell git --git-dir=$(BUILD_DIR)/qmp/.git branch|grep ^*|cut -d " " -f 2))
	$(eval REV_GIT=$(shell git --git-dir=$(BUILD_DIR)/qmp/.git --no-pager log -n 1 --oneline|cut -d " " -f 1))
	make -C $(BUILD_DIR)/$(TARGET) $(MAKE_SRC) BRANCH_GIT=$(BRANCH_GIT) REV_GIT=$(REV_GIT)
endef

define checkout_src
	svn --quiet co $(OWRT_SVN) $(BUILD_DIR)/$(TARGET)
	mkdir -p dl
	ln -fs ../../dl $(BUILD_DIR)/$(TARGET)/dl
	ln -fs ../qmp/files $(BUILD_DIR)/$(TARGET)/files
	ln -fs $(BUILD_DIR)/qmp/files
	rm -rf $(BUILD_DIR)/$(TARGET)/feeds/
	cp -f $(BUILD_DIR)/qmp/feeds.conf $(BUILD_DIR)/$(TARGET)/
	sed -i -e "s|PATH|`pwd`/$(BUILD_DIR)|" $(BUILD_DIR)/$(TARGET)/feeds.conf
endef

define checkout_owrt_pkg_override
	svn --quiet co ${OWRT_PKG_SVN} $(BUILD_DIR)/packages.$(TARGET)
	sed -i -e "s|src-link packages .*|src-link packages `pwd`/$(BUILD_DIR)/packages.$(TARGET)|" $(BUILD_DIR)/$(TARGET)/feeds.conf
endef

define copy_config
	cp -f $(CONFIG_DIR)/$(TARGET)/config $(CONFIG) || echo "WARNING: Config file not found!"
	cd $(BUILD_DIR)/$(TARGET) && ./scripts/diffconfig.sh > .config.tmp
	cp -f $(BUILD_DIR)/$(TARGET)/.config.tmp $(BUILD_DIR)/$(TARGET)/.config
	cd $(BUILD_DIR)/$(TARGET) && make defconfig
	[ -f $(CONFIG_DIR)/$(TARGET)/kernel_config ] && cat $(CONFIG_DIR)/$(TARGET)/kernel_config >> $(CONFIG) || true
endef

define update_feeds
	@echo "Updating feed $(1)"
	./$(BUILD_DIR)/$(1)/scripts/feeds update -a
	./$(BUILD_DIR)/$(1)/scripts/feeds install -a
endef

define menuconfig_owrt
	make -C $(BUILD_DIR)/$(TARGET) menuconfig
	mkdir -p $(MY_CONFIGS)/$(TARGET)
	cp -f $(CONFIG) $(MY_CONFIGS)/$(TARGET)/config
endef

define kmenuconfig_owrt
	make -C $(BUILD_DIR)/$(TARGET) kernel_menuconfig
	mkdir -p $(MY_CONFIGS)/$(TARGET)
	cp -f $(KCONFIG) $(MY_CONFIGS)/$(TARGET)/kernel_config
endef

define pre_build
	$(foreach SCRIPT, $(wildcard $(SCRIPTS_DIR)/*.script), $(shell $(SCRIPT) PRE_BUILD $(TARGET)) )
endef

define post_build
	$(eval BRANCH_GIT=$(shell git --git-dir=$(BUILD_DIR)/qmp/.git branch|grep ^*|cut -d " " -f 2))
	$(eval IM_NAME=$(NAME)-$(COMMUNITY)_$(BRANCH_GIT)-factory-$(TIMESTAMP).bin)
	$(eval SIM_NAME=$(NAME)-$(COMMUNITY)_$(BRANCH_GIT)-sysupgrade-$(TIMESTAMP).bin)
	$(eval COMP=$(shell ls $(BUILD_DIR)/$(TARGET)/$(IMAGE_PATH) 2>/dev/null | grep -c \\.gz))
	mkdir -p $(IMAGES)
	@[ $(COMP) -eq 1 ] && gunzip $(BUILD_DIR)/$(TARGET)/$(IMAGE_PATH) -c > $(IMAGES)/$(IM_NAME) || true
	@[ $(COMP) -ne 1 ] && cp -f $(BUILD_DIR)/$(TARGET)/$(IMAGE_PATH) $(IMAGES)/$(IM_NAME) || true
	@[ $(COMP) -eq 1 -a -n "$(SYSUPGRADE)" ] && gunzip $(BUILD_DIR)/$(TARGET)/$(SIMAGE_PATH) -c > $(IMAGES)/$(SIM_NAME) || true
	@[ $(COMP) -ne 1 -a -n "$(SYSUPGRADE)" ] && cp -f $(BUILD_DIR)/$(TARGET)/$(SIMAGE_PATH) $(IMAGES)/$(SIM_NAME) || true
	@[ -f $(IMAGES)/$(IM_NAME) ] || false
	@echo $(IM_NAME)
	$(if $(SYSUPGRADE),@echo $(SIM_NAME))
	$(foreach SCRIPT, $(wildcard $(SCRIPTS_DIR)/*.script), $(shell $(SCRIPT) POST_BUILD $(TARGET)) )
	@echo "qMp firmware compiled, you can find output files in $(IMAGES) directory."
endef

define clean_all
	rm -rf $(BUILD_DIR)/*
	rm -f .checkout_*
	rm -f $(IMAGES)/*
endef

define clean_target
	rm -rf $(BUILD_DIR)/$(TARGET)
	rm -f .checkout_$(TARGET)
	rm -rf $(BUILD_DIR)/packages.$(TARGET)
	rm -f .checkout_owrt_pkg_override_$(TARGET)
endef

define clean_pkg
	echo "Cleaning package $1"
	make $1/clean
endef

define target_error
	@echo "You must specify target using T var (make T=alix build)"
	@echo "To see avialable targets run: make list_targets"
	@exit 1
endef

all: build

.checkout_qmp:
	@[ "$(DEV)" == "1" ] && echo "Using developer enviroment" || true
	git clone $(QMP_GIT) $(BUILD_DIR)/qmp
	cd $(BUILD_DIR)/qmp; git checkout $(QMP_GIT_BRANCH); cd ..
	@touch $@

.checkout_owrt_pkg:
	svn --quiet co ${OWRT_PKG_SVN} $(BUILD_DIR)/packages
	@touch $@

.checkout_owrt_pkg_override:
	$(if $(filter $(origin OWRT_PKG_SVN),override),$(if $(wildcard .checkout_owrt_pkg_override_$(TARGET)),,$(call checkout_owrt_pkg_override)),)
	@touch .checkout_owrt_pkg_override_$(TARGET)

.checkout_owrt:
	$(if $(TARGET),,$(call target_error))
	$(if $(wildcard .checkout_$(TARGET)),,$(call checkout_src))

checkout: .checkout_qmp .checkout_owrt .checkout_owrt_pkg .checkout_owrt_pkg_override .checkout_qmp
	$(if $(wildcard .checkout_$(TARGET)),,$(call update_feeds,$(TARGET)))
	$(if $(wildcard .checkout_$(TARGET)),,$(call copy_config))
	@touch .checkout_$(TARGET)

sync_config:
	$(if $(TARGET),,$(call target_error))
	$(call copy_config)

update: .checkout_owrt_pkg .checkout_owrt_pkg_override .checkout_qmp
	cd $(BUILD_DIR)/qmp && git pull

update_all: update
	$(if $(TARGET),$(call update_feeds,$(TARGET)),$(foreach dir,$(HW_AVAILABLE),$(if $(wildcard $(BUILD_DIR)/$(dir)),$(call update_feeds,$(dir)))))

menuconfig: checkout
	$(call menuconfig_owrt)

kernel_menuconfig: checkout
	$(call kmenuconfig_owrt)

clean:
	$(if $(TARGET),$(call clean_target),$(call clean_all))

clean_qmp:
	cd $(BUILD_DIR)/$(TARGET) ; \
	for d in $(QMP_FEED)/*; do make $$d/clean ; done

post_build: checkout
	$(call post_build)

pre_build: checkout
	$(call pre_build)


list_targets:
	$(info $(HW_AVAILABLE))
	@exit 0

config:
	@select HW in $(HW_AVAILABLE); do break; done; echo $$HW > .config.tmp;
	mv .config.tmp .config

help:
	cat README | more || true

build: checkout
	$(call pre_build)
	$(if $(TARGET),$(call build_src))
	$(call post_build)

