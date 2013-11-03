# LibreMesh firmware generator (http://libre-mesh.org)
#
#    Copyright (C) 2011-2012 libre-mesh.org
#
#    This program is free software: you can redistribute it and/or modify
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
#    Contributors: Pau Escrich <p4u@dabax.net>, Simó Albert i Beltran, Agustí Moll,
#                  Gui Iribarren <gui@altermundi.net>


J ?= 1
V ?= 0
T =
MAKE_SRC = -j$(J) V=$(V)

include config.mk
include targets.mk

PROFILE ?= ath-qmp-tiny-node
TIMESTAMP = $(shell date +%Y%m%d_%H%M)

#Checking if developer mode is enabled and if target is defined before
$(eval $(if $(DEV),LIME_GIT=$(LIME_GIT_RW),LIME_GIT=$(LIME_GIT_RO)))

#Define TARGET_CONFIGS and TARGET
$(eval $(if $(TARGET_MASTER),TARGET_CONFIGS=$(TARGET_MASTER),TARGET_CONFIGS=$(T)))
$(eval $(if $(TARGET),,TARGET=$(T)))

#Define BUILD_PATH based on TBUILD (defined in targets.mk)
$(eval $(if $(TBUILD),,TBUILD=$(TARGET)))
BUILD_PATH=$(BUILD_DIR)/$(TBUILD)

#Getting output image paths
IMAGE_PATH = $(IMAGE)
SIMAGE_PATH = $(SYSUPGRADE)

CONFIG = $(BUILD_PATH)/.config
KCONFIG = $(BUILD_PATH)/target/linux/$(ARCH)/config-*

.PHONY: checkout update clean config menuconfig kernel_menuconfig list_targets build clean_lime_pkg


define build_src
	$(eval BRANCH_GIT=$(shell git --git-dir=$(BUILD_DIR)/$(LIME_PKG_DIR)/.git branch|grep ^*|cut -d " " -f 2))
	$(eval REV_GIT=$(shell git --git-dir=$(BUILD_DIR)/$(LIME_PKG_DIR)/.git --no-pager log -n 1 --oneline|cut -d " " -f 1))
	make -C $(BUILD_PATH) $(MAKE_SRC) BRANCH_GIT=$(BRANCH_GIT) REV_GIT=$(REV_GIT)
endef

define copy_feeds_file
	$(if $(1),$(eval FEEDS_DIR=$(1)),$(eval FEEDS_DIR=$(TBUILD)))
	$(if $(FEEDS_DIR),,$(call target_error))	
	cp -f feeds.conf $(BUILD_DIR)/$(FEEDS_DIR)
	sed -i -e "s|src-link packages PATH/|src-link packages `pwd`/$(BUILD_DIR)/$(TBUILD)-|" $(BUILD_DIR)/$(FEEDS_DIR)/feeds.conf
	sed -i -e "s|PATH|`pwd`/$(BUILD_DIR)|" $(BUILD_DIR)/$(FEEDS_DIR)/feeds.conf
endef

define checkout_src
	$(OWRT_SCM) $(BUILD_PATH)
	mkdir -p dl
	ln -fs ../../dl $(BUILD_PATH)/dl
	ln -fs ../$(LIME_PKG_DIR)/files $(BUILD_PATH)/files
	ln -fs $(BUILD_DIR)/$(LIME_PKG_DIR)/files
	rm -rf $(BUILD_PATH)/feeds/
	$(call copy_feeds_file,$(TBUILD))
endef

define checkout_owrt_pkg_override
	${OWRT_PKG_SCM} $(BUILD_DIR)/packages.$(TARGET)
	sed -i -e "s|src-link packages .*|src-link packages `pwd`/$(BUILD_DIR)/packages.$(TARGET)|" $(BUILD_PATH)/feeds.conf
endef

define copy_config
	@echo "Using profile $(PROFILE)"
	cp -f $(CONFIG_DIR)/$(PROFILE) $(CONFIG) || echo "WARNING: Config file not found!"
	[ -f $(CONFIG_DIR)/targets/$(TARGET) ] && cat $(CONFIG_DIR)/targets/$(TARGET) >> $(CONFIG) || true
	cd $(BUILD_PATH) && make defconfig
endef

define copy_config_obsolete
	@echo "Syncronizing new configuration"
	cp -f $(CONFIG_DIR)/$(TARGET_CONFIGS)/config $(CONFIG) || echo "WARNING: Config file not found!"
	cd $(BUILD_PATH) && ./scripts/diffconfig.sh > .config.tmp
	cp -f $(BUILD_PATH)/.config.tmp $(BUILD_PATH)/.config
	make -C $(BUILD_PATH) defconfig
	[ -f $(CONFIG_DIR)/$(TARGET_CONFIGS)/kernel_config ] && cat $(CONFIG_DIR)/$(TARGET_CONFIGS)/kernel_config >> $(CONFIG) || true
endef

define copy_myconfig
	@echo "Syncronizing configuration from previous one"
	@cp -f $(MY_CONFIGS)/$(TARGET_CONFIGS)/config $(CONFIG) || echo "WARNING: Config file not found in $(MY_CONFIGS)!"
	make -C $(BUILD_PATH) defconfig
	@[ -f $(MY_CONFIGS)/$(TARGET_CONFIGS)/kernel_config ] && cat $(MY_CONFIGS)/$(TARGET_CONFIGS)/kernel_config >> $(CONFIG) || true
endef

define update_feeds
	@echo "Updating feed $(1)"
	./$(BUILD_DIR)/$(1)/scripts/feeds update -a
	./$(BUILD_DIR)/$(1)/scripts/feeds install -a
endef

define menuconfig_owrt
	make -C $(BUILD_PATH) menuconfig
	mkdir -p $(MY_CONFIGS)/$(TARGET)
	( cd $(BUILD_PATH) && ./scripts/diffconfig.sh ) > $(MY_CONFIGS)/$(TARGET)/config
endef

define kmenuconfig_owrt
	make -C $(BUILD_PATH) kernel_menuconfig
	mkdir -p $(MY_CONFIGS)/$(TARGET)
	cp -f $(KCONFIG) $(MY_CONFIGS)/$(TARGET)/kernel_config
endef

define pre_build
	$(foreach SCRIPT, $(wildcard $(SCRIPTS_DIR)/*.script), $(shell $(SCRIPT) PRE_BUILD $(TBUILD) $(TARGET)) )
endef

define post_build
	$(eval BRANCH_GIT=$(shell git --git-dir=$(BUILD_DIR)/$(LIME_PKG_DIR)/.git branch|grep ^*|cut -d " " -f 2))
	$(eval IM_NAME=$(NAME)-$(COMMUNITY)_$(BRANCH_GIT)-factory-$(TIMESTAMP).bin)
	$(eval SIM_NAME=$(NAME)-$(COMMUNITY)_$(BRANCH_GIT)-sysupgrade-$(TIMESTAMP).bin)
	$(eval COMP=$(shell ls $(BUILD_PATH)/$(IMAGE_PATH) 2>/dev/null | grep -c \\.gz))
	mkdir -p $(IMAGES)
	@[ $(COMP) -eq 1 ] && gunzip $(BUILD_PATH)/$(IMAGE_PATH) -c > $(IMAGES)/$(IM_NAME) || true
	@[ $(COMP) -ne 1 -a -f $(BUILD_PATH)/$(IMAGE_PATH) ] && cp -f $(BUILD_PATH)/$(IMAGE_PATH) $(IMAGES)/$(IM_NAME) || true
	@[ $(COMP) -eq 1 -a -n "$(SYSUPGRADE)" ] && gunzip $(BUILD_PATH)/$(SIMAGE_PATH) -c > $(IMAGES)/$(SIM_NAME) || true
	@[ $(COMP) -ne 1 -a -n "$(SYSUPGRADE)" ] && cp -f $(BUILD_PATH)/$(SIMAGE_PATH) $(IMAGES)/$(SIM_NAME) || true
	@[ -f $(IMAGES)/$(IM_NAME) ] || echo No output image configured in targets.mk
	@[ -n "$(OUTDIR)" ] && [ ! -e $(IMAGES)/$(TARGET) ] && ln -s ../$(BUILD_PATH)/$(OUTDIR) $(IMAGES)/$(TARGET) || true
	@echo $(IM_NAME)
	$(if $(SYSUPGRADE),@echo $(SIM_NAME))
	$(foreach SCRIPT, $(wildcard $(SCRIPTS_DIR)/*.script), $(shell $(SCRIPT) POST_BUILD $(TBUILD) $(TARGET)) )
	@echo "LiMe firmware compiled, you can find output files in $(IMAGES) directory."
endef

define clean_all
	rm -rf $(BUILD_DIR)/*
	rm -f .checkout_*
	rm -f $(IMAGES)/*
endef

define clean_target
	rm -rf $(BUILD_PATH) || true
	rm -f .checkout_$(TBUILD) || true
	rm -rf $(BUILD_DIR)/packages.$(TARGET) || true
	rm -f .checkout_owrt_pkg_override_$(TARGET)
endef

define clean_pkg
	echo "Cleaning package $1"
	make $1/clean
endef

define target_error
	@echo "You must specify target using T=target (i.e. 'make T=ar71xx build')"
	@echo "To see available targets run: make list_targets"
	@exit 1
endef

define get_git_local_revision
	git rev-parse origin/$1
endef

define get_git_remote_revision
	git ls-remote origin $1 | awk 'NR==1{print $$1}'
endef

all: build

.checkout_lime_pkg:
	@[ "$(DEV)" == "1" ] && echo "Using developer enviroment" || true
	git clone $(LIME_GIT) $(BUILD_DIR)/$(LIME_PKG_DIR)
	cd $(BUILD_DIR)/$(LIME_PKG_DIR); git checkout $(LIME_GIT_BRANCH); cd ..
	@touch $@

.checkout_owrt_pkg:
	${OWRT_PKG_SCM} $(BUILD_DIR)/$(TBUILD)-packages
	@touch $@

.checkout_owrt_pkg_override:
	$(if $(filter $(origin OWRT_PKG_SCM),override),$(if $(wildcard .checkout_owrt_pkg_override_$(TARGET)),,$(call checkout_owrt_pkg_override)),)
	@touch .checkout_owrt_pkg_override_$(TARGET)

.checkout_owrt:
	$(if $(TBUILD),,$(call target_error))
	$(if $(wildcard .checkout_$(TBUILD)),,$(call checkout_src))
	@touch $@

checkout: .checkout_lime_pkg .checkout_owrt .checkout_owrt_pkg .checkout_owrt_pkg_override
	$(if $(TARGET),,$(call target_error))
	$(if $(wildcard .checkout_$(TBUILD)),,$(call update_feeds,$(TBUILD)))
	$(if $(wildcard .checkout_$(TBUILD)),,$(call copy_config))
	@touch .checkout_$(TBUILD)

sync_config:
	$(if $(TARGET),,$(call target_error))
	$(if $(wildcard $(MY_CONFIGS)/$(TARGET_CONFIGS)), $(call copy_myconfig),$(call copy_config))

update: .checkout_owrt_pkg .checkout_owrt_pkg_override .checkout_lime_pkg
	$(if $(TBUILD),,$(call target_error))
	cd $(BUILD_DIR)/$(LIME_PKG_DIR) && git pull
	$(call copy_feeds_file)

update_all: .checkout_owrt_pkg .checkout_owrt_pkg_override .checkout_lime_pkg
	@echo Updating LiMe repository
	cd $(BUILD_DIR)/$(LIME_PKG_DIR) && git pull
	@echo Updating feeds config files
	$(foreach dir,$(TBUILD_LIST),$(if $(wildcard $(BUILD_DIR)/$(dir)),$(call copy_feeds_file,$(dir))))
	@echo Updating feeds
	$(foreach dir,$(TBUILD_LIST),$(if $(wildcard $(BUILD_DIR)/$(dir)),$(call update_feeds,$(dir))))

update_feeds: update
	$(call update_feeds,$(TBUILD))

menuconfig: checkout sync_config
	$(call menuconfig_owrt)

kernel_menuconfig: checkout sync_config
	$(call kmenuconfig_owrt)

clean:
	$(if $(TARGET),$(call clean_target),$(call clean_all))

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

build: checkout sync_config
	$(call pre_build)
	$(if $(TARGET),$(call build_src))
	$(call post_build)

is_up_to_date:
	cd $(BUILD_DIR)/$(LIME_PKG_DIR) && test "$$($(call get_git_local_revision,$(LIME_GIT_BRANCH)))" == "$$($(call get_git_remote_revision,$(LIME_GIT_BRANCH)))"
