# [qMp] firmware generator (http://qmp.cat)
#
# Licence: GPLv3
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
HW_AVAILABLE = alix rs rspro x86 fonera nsm5 nsm2
SHELL = bash
J ?= 1
V ?= 99
T =
MAKE_SRC = make -j$(J) V=$(V)

.PHONY: checkout update clean config menuconfig kernel_menuconfig list_targets build

define build_src
	cd $1/$2 && $(MAKE_SRC)
endef

define checkout_src
	svn --quiet co -r $(OWRT_SVN_REV) $(OWRT_SVN) $(BUILD_DIR)/$(T)
	@if [ ! -d dl ]; then mkdir dl; fi 
	ln -s ../../dl $(BUILD_DIR)/$(T)/dl
	ln -s ../qmp/files $(BUILD_DIR)/$(T)/files
	rm -rf $(BUILD_DIR)/$(T)/feeds/
	cp -f $(BUILD_DIR)/qmp/feeds.conf $(BUILD_DIR)/$(T)/
	sed -i -e "s|PATH|`pwd`/$(BUILD_DIR)|" $(BUILD_DIR)/$(T)/feeds.conf
	cp -f $(CONFIG_DIR)/$(T)/config $(BUILD_DIR)/$(T)/.config
endef

define update_feeds
	@echo "Updateing feed $(1)"
	./$(BUILD_DIR)/$1/scripts/feeds update -a
	./$(BUILD_DIR)/$1/scripts/feeds install -a
endef

define menuconfig_owrt
	cd $(BUILD_DIR)/$1 && make menuconfig
	[ ! -d $(MY_CONFIGS)/$1 ] && mkdir -p $(MY_CONFIGS)/$1
	cp -f $(BUILD_DIR)/$1/.config $(MY_CONFIGS)/$1/config
endef

define kmenuconfig_owrt
	cd $(BUILD_DIR)/$1 && make kernel_menuconfig
endef

define clean_all
	[ -d "$(BUILD_DIR)" ] && rm -rf $(BUILD_DIR)/*
	rm -f .checkout_* 2>/dev/null || true
endef

define clean_target
	[ -d "$(BUILD_DIR)/$1" ] && rm -rf $(BUILD_DIR)/$1
	rm -f .checkout_$1 2>/dev/null || true
endef

define target_error
	@echo "You must specify target using T var (make T=alix build)"
	@echo "To see avialable targets run: make list_targets"
	@exit 1
endef

.checkout_qmp:
	git clone $(QMP_GIT) $(BUILD_DIR)/qmp
	cd $(BUILD_DIR)/qmp; git checkout --track origin/$(QMP_GIT_BRANCH); cd ..
	touch $@

.checkout_eig:
	git clone $(EIGENNET_GIT) $(BUILD_DIR)/eigennet/packages
	touch $@

checkout: .checkout_qmp .checkout_eig 
	$(if $(T),,$(call target_error))
	$(if $(wildcard .checkout_$(T)),,$(call checkout_src))
	$(if $(wildcard .checkout_$(T)),,$(call update_feeds,$(T)))
	touch .checkout_$(T)
	
update: .checkout_eig .checkout_qmp
	cd $(BUILD_DIR)/qmp && git pull
	cd $(BUILD_DIR)/eigennet/packages && git pull
	$(if $(T),HW_AVAILABLE=$(T)) 
	$(foreach dir,$(HW_AVAILABLE),$(if $(wildcard $(BUILD_DIR)/$(dir)),$(call update_feeds,$(dir))))

menuconfig: checkout
	$(call menuconfig_owrt,$(T))
	
kernel_menuconfig: checkout
	$(call kmenuconfig_owrt,$(T))

clean:
	$(if $(T),$(call clean_target,$(T)),$(call clean_all))

list_targets:
	@echo $(HW_AVAILABLE)

config:
	select HW in alix rs rspro x86 fonera nsm5 nsm2; do break; done; echo $HW > .config.tmp;
	mv .config.tmp .config 

build: checkout
	$(if $(T),$(call build_src,$(BUILD_DIR),$(T)))


