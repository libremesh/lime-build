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

OWRT_SVN = svn://svn.openwrt.org/openwrt/trunk
OWRT_SVN_REV = 29704
OWRT_PKG_SVN = svn://svn.openwrt.org/openwrt/packages
QMP_GIT_RW = ssh://gitosis@qmp.cat:221/qmp.git
QMP_GIT_RO = git://qmp.cat/qmp.git
QMP_GIT_BRANCH = master
B6M_GIT = git://qmp.cat/b6m.git
B6M_GIT_BRANCH = openwrt
BUILD_DIR = build
CONFIG_DIR = configs
MY_CONFIGS = $(BUILD_DIR)/configs
IMAGES = images
SHELL = bash
QMP_FEED = package/feeds/qmp_packages
J ?= 1
V ?= 0
T =
MAKE_SRC = -j$(J) V=$(V)

include targets.mk

TIMESTAMP = $(shell date +%d%m%y_%H%M)
CONFIG = $(BUILD_DIR)/$(T)/.config
KCONFIG = $(BUILD_DIR)/$(T)/target/linux/$(ARCH)/config-* 

$(eval $(if $(DEV),QMP_GIT=$(QMP_GIT_RW),QMP_GIT=$(QMP_GIT_RO)))
$(eval $(if $(TARGET),,TARGET=$(T)))


.PHONY: checkout update clean config menuconfig kernel_menuconfig list_targets build clean_qmp


define build_src
	make -C $(BUILD_DIR)/$(TARGET) $(MAKE_SRC) BRANCH_GIT=$(shell git --git-dir=$(BUILD_DIR)/qmp/.git branch|grep ^*|cut -d " " -f 2) REV_GIT=$(shell git --git-dir=$(BUILD_DIR)/qmp/.git --no-pager log -n 1 --oneline|cut -d " " -f 1)
endef

define checkout_src
	svn --quiet co -r $(OWRT_SVN_REV) $(OWRT_SVN) $(BUILD_DIR)/$(TARGET)
	@if [ ! -d dl ]; then mkdir dl; fi 
	ln -s ../../dl $(BUILD_DIR)/$(TARGET)/dl
	ln -s ../qmp/files $(BUILD_DIR)/$(TARGET)/files
	rm -rf $(BUILD_DIR)/$(TARGET)/feeds/
	cp -f $(BUILD_DIR)/qmp/feeds.conf $(BUILD_DIR)/$(TARGET)/
	sed -i -e "s|PATH|`pwd`/$(BUILD_DIR)|" $(BUILD_DIR)/$(TARGET)/feeds.conf
endef

define copy_config
	cp -f $(CONFIG_DIR)/$(TARGET)/config $(CONFIG)
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
	[ ! -d $(MY_CONFIGS)/$(TARGET) ] && mkdir -p $(MY_CONFIGS)/$(TARGET) || true
	cp -f $(CONFIG) $(MY_CONFIGS)/$(TARGET)/config
endef

define kmenuconfig_owrt
	make -C $(BUILD_DIR)/$(TARGET) kernel_menuconfig
	[ ! -d $(MY_CONFIGS)/$(TARGET) ] && mkdir -p $(MY_CONFIGS)/$(TARGET) || true
	cp -f $(KCONFIG) $(MY_CONFIGS)/$(TARGET)/kernel_config
endef

define post_build
	[ ! -d $(IMAGES) ] && mkdir $(IMAGES) || true
	@[ "$(COMPRESSED)" == "1" ] && gunzip $(BUILD_DIR)/$(TARGET)/$(IMAGE) -c > $(IMAGES)/$(NAME)-factory-$(TIMESTAMP).bin || true
	@[ "$(COMPRESSED)" != "1" ] && cp -f $(BUILD_DIR)/$(TARGET)/$(IMAGE) $(IMAGES)/$(NAME)-factory-$(TIMESTAMP).bin || true
	@[ "$(COMPRESSED)" == "1" ] && gunzip $(BUILD_DIR)/$(TARGET)/$(SYSUPGRADE) -c > $(IMAGES)/$(NAME)-upgrade-$(TIMESTAMP).bin || true
	@[ "$(COMPRESSED)" != "1" ] && cp -f $(BUILD_DIR)/$(TARGET)/$(SYSUPGRADE) $(IMAGES)/$(NAME)-upgrade-$(TIMESTAMP).bin || true
	@[ -f $(IMAGES)/$(NAME)-factory-$(TIMESTAMP).bin ] || false
	@[ -f $(IMAGES)/$(NAME)-upgrade-$(TIMESTAMP).bin ] || false
	@echo 
	@echo "qMp firmware compiled, you can find output files in $(IMAGES) directory"
endef

define clean_all
	[ -d "$(BUILD_DIR)" ] && rm -rf $(BUILD_DIR)/* || true
	rm -f .checkout_* 2>/dev/null || true
	[ -d "$(BUILD_DIR)" ] && rm -f $(IMAGES)/* || true
endef

define clean_target
	[ -d "$(BUILD_DIR)/$(TARGET)" ] && rm -rf $(BUILD_DIR)/$(TARGET) || true
	rm -f .checkout_$(TARGET) 2>/dev/null || true
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

.checkout_qmp:
	@[ "$(DEV)" == "1" ] && echo "Using developer enviroment" || true
	git clone $(QMP_GIT) $(BUILD_DIR)/qmp
	cd $(BUILD_DIR)/qmp; git checkout $(QMP_GIT_BRANCH); cd ..
	@touch $@

.checkout_b6m:
	git clone $(B6M_GIT) $(BUILD_DIR)/b6m
	cd $(BUILD_DIR)/b6m; git checkout --track origin/$(B6M_GIT_BRANCH); cd ..
	@touch $@	

.checkout_owrt_pkg:
	svn --quiet co -r ${OWRT_SVN_REV} ${OWRT_PKG_SVN} $(BUILD_DIR)/packages
	@touch $@

checkout: .checkout_owrt_pkg .checkout_qmp .checkout_b6m 
	$(if $(TARGET),,$(call target_error))
	$(if $(wildcard .checkout_$(TARGET)),,$(call checkout_src))
	$(if $(wildcard .checkout_$(TARGET)),,$(call update_feeds,$(TARGET)))
	$(if $(wildcard .checkout_$(TARGET)),,$(call copy_config))
	@touch .checkout_$(TARGET)

sync_config:
	$(if $(TARGET),,$(call target_error))
	$(call copy_config)
	
update: .checkout_owrt_pkg .checkout_qmp .checkout_b6m
	cd $(BUILD_DIR)/qmp && git pull
	cd $(BUILD_DIR)/b6m && git pull

update_all: update
	$(if $(TARGET),HW_AVAILABLE=$(TARGET)) 
	$(foreach dir,$(HW_AVAILABLE),$(if $(wildcard $(BUILD_DIR)/$(dir)),$(call update_feeds,$(dir))))

menuconfig: checkout
	$(call menuconfig_owrt)
	
kernel_menuconfig: checkout
	$(call kmenuconfig_owrt)

clean:
	$(if $(TARGET),$(call clean_target),$(call clean_all))

clean_qmp:
	cd $(BUILD_DIR)/$(TARGET) ; \
	for d in $(QMP_FEED)/*; do make $$d/clean ; done

list_targets:
	$(info $(HW_AVAILABLE))
	@exit 0

config:
	select HW in alix rs rspro x86 fonera nsm5 nsm2; do break; done; echo $HW > .config.tmp;
	mv .config.tmp .config 

help:
	cat README | more || true

build: checkout
	$(if $(TARGET),$(call build_src))
	$(call post_build)

all: build

default: build
