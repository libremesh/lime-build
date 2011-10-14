# [qMp] firmware generator (http://qmp.cat)
#
#    Copyright (C) 2011 qmp.cat
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

OWRT_SVN = svn://svn.openwrt.org/openwrt/branches/backfire
OWRT_SVN_REV = 27617
QMP_GIT = ssh://gitosis@qmp.cat:221/qmp.git
QMP_GIT_BRANCH = autoconfig
EIGENNET_GIT = git://gitorious.org/eigennet/packages.git
BUILD_DIR = build
CONFIG_DIR = configs
MY_CONFIGS = $(BUILD_DIR)/configs
IMAGES = images
SHELL = bash
J ?= 1
V ?= 99
T =
MAKE_SRC = make -j$(J) V=$(V)

include targets.mk

TIMESTAMP = $(shell date +%d%m%y_%H%M)
CONFIG = $(BUILD_DIR)/$(T)/.config
KCONFIG = $(BUILD_DIR)/$(T)/target/linux/$(ARCH)/config-* 

.PHONY: checkout update clean config menuconfig kernel_menuconfig list_targets build

define build_src
	cd $(BUILD_DIR)/$(T) && $(MAKE_SRC)
endef

define checkout_src
	svn --quiet co -r $(OWRT_SVN_REV) $(OWRT_SVN) $(BUILD_DIR)/$(T)
	@if [ ! -d dl ]; then mkdir dl; fi 
	ln -s ../../dl $(BUILD_DIR)/$(T)/dl
	ln -s ../qmp/files $(BUILD_DIR)/$(T)/files
	rm -rf $(BUILD_DIR)/$(T)/feeds/
	cp -f $(BUILD_DIR)/qmp/feeds.conf $(BUILD_DIR)/$(T)/
	sed -i -e "s|PATH|`pwd`/$(BUILD_DIR)|" $(BUILD_DIR)/$(T)/feeds.conf
	cp -f $(CONFIG_DIR)/$(T)/config $(CONFIG)
	[ -f $(CONFIG_DIR)/$(T)/kernel_config ] && cp -f $(CONFIG_DIR)/$(T)/kernel_config $(KCONFIG) || true
endef

define update_feeds
	@echo "Updateing feed $(T)"
	./$(BUILD_DIR)/$(T)/scripts/feeds update -a
	./$(BUILD_DIR)/$(T)/scripts/feeds install -a
endef

define menuconfig_owrt
	cd $(BUILD_DIR)/$(T) && make menuconfig
	[ ! -d $(MY_CONFIGS)/$(T) ] && mkdir -p $(MY_CONFIGS)/$(T) || true
	cp -f $(CONFIG) $(MY_CONFIGS)/$(T)/config
endef

define kmenuconfig_owrt
	cd $(BUILD_DIR)/$(T) && make kernel_menuconfig
	[ ! -d $(MY_CONFIGS)/$(T) ] && mkdir -p $(MY_CONFIGS)/$(T) || true
	cp -f $(KCONFIG) $(MY_CONFIGS)/$(T)/kernel_config
endef

define post_build
	[ ! -d $(IMAGES) ] && mkdir $(IMAGES) || true
	cp -f $(BUILD_DIR)/$(T)/$(IMAGE) $(IMAGES)/$(T)-factory-$(TIMESTAMP).bin
	cp -f $(BUILD_DIR)/$(T)/$(SYSUPGRADE) $(IMAGES)/$(T)-upgrade-$(TIMESTAMP).bin
	@echo 
	@echo "qMp firmware compiled, you can find output files in $(IMAGES) directory"
endef

define clean_all
	[ -d "$(BUILD_DIR)" ] && rm -rf $(BUILD_DIR)/* || true
	rm -f .checkout_* 2>/dev/null || true
	[ -d "$(BUILD_DIR)" ] && rm -f $(IMAGES)/* || true
endef

define clean_target
	[ -d "$(BUILD_DIR)/$(T)" ] && rm -rf $(BUILD_DIR)/$(T) || true
	rm -f .checkout_$(T) 2>/dev/null || true
endef

define target_error
	@echo "You must specify target using T var (make T=alix build)"
	@echo "To see avialable targets run: make list_targets"
	@exit 1
endef

.checkout_qmp:
	git clone $(QMP_GIT) $(BUILD_DIR)/qmp
	cd $(BUILD_DIR)/qmp; git checkout --track origin/$(QMP_GIT_BRANCH); cd ..
	@touch $@

.checkout_eig:
	git clone $(EIGENNET_GIT) $(BUILD_DIR)/eigennet/packages
	@touch $@

checkout: .checkout_qmp .checkout_eig 
	$(if $(T),,$(call target_error))
	$(if $(wildcard .checkout_$(T)),,$(call checkout_src))
	$(if $(wildcard .checkout_$(T)),,$(call update_feeds))
	@touch .checkout_$(T)
	
update: .checkout_eig .checkout_qmp
	cd $(BUILD_DIR)/qmp && git pull
	cd $(BUILD_DIR)/eigennet/packages && git pull
	$(if $(T),HW_AVAILABLE=$(T)) 
	$(foreach dir,$(HW_AVAILABLE),$(if $(wildcard $(BUILD_DIR)/$(dir)),$(call update_feeds,$(dir))))

menuconfig: checkout
	$(call menuconfig_owrt)
	
kernel_menuconfig: checkout
	$(call kmenuconfig_owrt)

clean:
	$(if $(T),$(call clean_target),$(call clean_all))

list_targets:
	$(info $(HW_AVAILABLE))
	@exit 0

config:
	select HW in alix rs rspro x86 fonera nsm5 nsm2; do break; done; echo $HW > .config.tmp;
	mv .config.tmp .config 

build: checkout
	$(if $(T),$(call build_src))
	$(call post_build)

