# LibreMesh firmware generator (http://libre-mesh.org)
#
#    Copyright (C) 2013-2016 libre-mesh.org
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
T ?= ar71xx
P ?= generic
MAKE_SRC = -j$(J) V=$(V)

include config.mk
include targets.mk
include profiles.mk

TIMESTAMP = $(shell date +%Y%m%d_%H%M)

#Checking if LIME_GIT is already defined by user and developer mode is enabled
$(eval $(if $(LIME_GIT),,$(if $(DEV),LIME_GIT=$(LIME_GIT_RW),LIME_GIT=$(LIME_GIT_RO))))
$(info Using LiMe Git repository $(LIME_GIT))

#Define BUILD_PATH based on TBUILD (defined in targets.mk)
BUILD_PATH=$(BUILD_DIR)/$(TBUILD)

CONFIG = $(BUILD_PATH)/.config
KCONFIG = $(wildcard $(BUILD_PATH)/target/linux/$(ARCH)/config-*)

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
	sed -i -e "s|PATH|`pwd`/$(BUILD_DIR)|" $(BUILD_DIR)/$(FEEDS_DIR)/feeds.conf || true
endef

define checkout_src
	$(OWRT_SCM) $(BUILD_PATH)
	mkdir -p dl
	mkdir -p files
	ln -fs ../../dl $(BUILD_PATH)/dl
	ln -fs ../../files $(BUILD_PATH)/files
	rm -rf $(BUILD_PATH)/feeds/
	$(call copy_feeds_file,$(TBUILD))
endef

define add_profile_packages
	@echo "Adding profile packages: $(PROFILE_PACKAGES) $(PACKAGES)"
	@for PKG in $(PROFILE_PACKAGES) $(PACKAGES); do echo "CONFIG_PACKAGE_$$PKG=y" >> $(CONFIG); done
endef

define copy_config
	@echo "Using profile $(P)"
	@cp -f $(CONFIG_DIR)/$(T) $(CONFIG) || read -p 'WARNING: Target $(T) does not exist. Press ENTER to continue' 
	$(call add_profile_packages)
	@cp -f $(CONFIG_DIR)/$(T).kernel $(KCONFIG) || true
	@echo "Compiling for target: $(T)"
	make -C $(BUILD_PATH) defconfig
endef

define copy_myconfig
	@echo "Syncronizing configuration from previous one"
	@cp -f $(MY_CONFIGS)/$(T)/config $(CONFIG) || echo "WARNING: Config file not found in $(MY_CONFIGS)!"
	make -C $(BUILD_PATH) defconfig
	@[ -f $(MY_CONFIGS)/$(T)/kernel_config ] && @cp -f $(MY_CONFIGS)/$(T)/kernel_config $(KCONFIG) || @cp -f $(CONFIG_DIR)/$(T).kernel $(KCONFIG) || true
endef

define update
	cd $(BUILD_DIR)/$(LIME_PKG_DIR) && git fetch origin $(LIME_GIT_BRANCH) && git checkout $(LIME_GIT_BRANCH)
	$(call copy_feeds_file)
	$(call update_feeds,$(TBUILD))
endef

define update_feeds
	@echo "Updating feed $(1)"
	./$(BUILD_DIR)/$(1)/scripts/feeds update -a
	./$(BUILD_DIR)/$(1)/scripts/feeds install -a
endef

define menuconfig_owrt
	make -C $(BUILD_PATH) menuconfig
	mkdir -p $(MY_CONFIGS)/$(T)
	( cd $(BUILD_PATH) && ./scripts/diffconfig.sh ) > $(MY_CONFIGS)/$(T)/config
endef

define kmenuconfig_owrt
	make -C $(BUILD_PATH) kernel_menuconfig
	mkdir -p $(MY_CONFIGS)/$(T)
	cp -f $(KCONFIG) $(MY_CONFIGS)/$(T)/kernel_config
endef

define pre_build
endef

define post_build
	$(eval LIME_GIT_BRANCH_CLEAN=$(shell echo $(LIME_GIT_BRANCH) | tr [:punct:] _))
	$(if $(IMAGES),,$(eval IMAGES=output))
	@mkdir -p $(IMAGES)
	$(eval CURRENT_OUTPUT_DIR=$(IMAGES)/$T-$P-$(LIME_GIT_BRANCH_CLEAN)-$(REV_GIT))
	@rm -rf $(CURRENT_OUTPUT_DIR) 2>/dev/null || true
	cp -rf $(BUILD_PATH)/$(OUTDIR) $(CURRENT_OUTPUT_DIR)
	$(foreach SCRIPT, $(wildcard $(SCRIPTS_DIR)/*.script), $(shell $(SCRIPT) POST_BUILD $(TBUILD) $(T)) )
	@echo "LiMe firmware compiled, you can find output files in $(IMAGES) directory."
endef

define clean_all
	rm -rf $(BUILD_DIR)/*
	rm -f .checkout_*
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
	cd $(BUILD_DIR)/$(LIME_PKG_DIR) && git checkout $(LIME_GIT_BRANCH) && cd ..
	@touch $@

.checkout_owrt:
	$(if $(TBUILD),,$(call target_error))
	$(if $(wildcard .checkout_$(TBUILD)),,$(call checkout_src))
	@touch $@

checkout: .checkout_lime_pkg .checkout_owrt
	$(if $(T),,$(call target_error))
	$(if $(UPDATE),$(call update),)
	$(if $(wildcard .checkout_$(TBUILD)),,$(call update_feeds,$(TBUILD)))
	$(if $(wildcard .checkout_$(TBUILD)),,$(call copy_config))
	@touch .checkout_$(TBUILD)

sync_config:
	$(if $(T),,$(call target_error))
	$(if $(wildcard $(MY_CONFIGS)/$(T)/config), $(call copy_myconfig),$(call copy_config))

update: .checkout_lime_pkg
	$(if $(TBUILD),,$(call target_error))
	$(call update)

menuconfig: checkout sync_config
	$(call menuconfig_owrt)

kernel_menuconfig: checkout sync_config
	$(call kmenuconfig_owrt)

clean:
	$(call clean_all)

post_build: checkout
	$(call post_build)

pre_build: checkout
	$(call pre_build)

info:
	$(info (T)ARGETS -> $(TARGETS_AVAILABLE))
	$(info (P)ROFILES -> $(PROFILES_AVAILABLE))
	@exit 0

config:
	@select HW in $(HW_AVAILABLE); do break; done; echo $$HW > .config.tmp;
	mv .config.tmp .config

help:
	cat README.md | more || true

build: checkout sync_config
	$(call pre_build)
	$(if $(T),$(call build_src))
	$(call post_build)

is_up_to_date:
	@(cd $(BUILD_DIR)/$(LIME_PKG_DIR) && \
	test "$$($(call get_git_local_revision,$(LIME_GIT_BRANCH)))" == "$$($(call get_git_remote_revision,$(LIME_GIT_BRANCH)))";\
	echo $$?)
