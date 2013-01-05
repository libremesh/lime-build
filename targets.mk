# targets.mk
# Copyright (C) 2011 qmp.cat
#
# This is free software, licensed under the GNU General Public License v3. 
# See LICENSE for more information.
# 
#
# For each target the next variables must be defined
#  NAME := The name of the device used for output firmware file name
#  ARCH := The OpenWRT architecture
#  IMAGE := The file path (relative to buildroot) to the firmware

# Optional
#  TBUILD := The buildroot directory (relative to BUILD_DIR)
#  TARGET_MASTER := If defined the config files will be taken from the master target
#  SYSUPGRADE := The file path (relative to buildroot) to the firmware sysupgrade image
#
# Any option defined in Makefile can be overrided from here, for instance
#  override OWRT_SVN = svn://mysvn.com/owrt

HW_AVAILABLE := alix vbox rs rspro nsm5 nsm2 tl-2543 tl-841 tl-842 tl-N750 freestation rocket bullet wpe72 pico2

ifeq ($(T),alix)
  NAME:=Alix
  ARCH:=x86
  TBUILD:=x86
  IMAGE:=bin/$(ARCH)/openwrt-x86-generic-combined-squashfs.img
  SYSUPGRADE:=bin/$(ARCH)/openwrt-x86-generic-combined-squashfs.img
endif

ifeq ($(T),nsm5)
  NAME:=NanoStationM5
  ARCH:=ar71xx
  TBUILD:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-nano-m-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-nano-m-squashfs-sysupgrade.bin
endif

ifeq ($(T),pico2)
  NAME:=PicoStation2
  ARCH:=atheros
  TBUILD:=atheros
  BUILD_PATH:=$(BUILD_DIR)/atheros
  IMAGE:=bin/$(ARCH)/openwrt-atheros-ubnt2-pico2-squashfs.bin
endif

ifeq ($(T),rspro)
  NAME:=RouterStationPro
  ARCH:=ar71xx
  TBUILD:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-rspro-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-rspro-squashfs-sysupgrade.bin
endif

ifeq ($(T),rs)
  NAME:=RouterStation
  ARCH:=ar71xx
  TBUILD:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-rs-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-rs-squashfs-sysupgrade.bin
endif

ifeq ($(T),vbox)
  NAME:=VBox
  ARCH:=x86
  TBUILD:=x86
  IMAGE:=bin/$(ARCH)/openwrt-x86-generic-combined-ext2.vdi
  SYSUPGRADE:=bin/$(ARCH)/openwrt-x86-generic-combined-ext2.vdi
endif

ifeq ($(T),nsm2)
  NAME:=NanoStationM2
  ARCH:=ar71xx
  TBUILD:=ar71xx
  TARGET_MASTER:=nsm5
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-nano-m-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-nano-m-squashfs-sysupgrade.bin
endif

ifeq ($(T),rocket)
  NAME:=Rocket
  ARCH:=ar71xx
  TBUILD:=ar71xx
  TARGET_MASTER:=nsm5
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-rocket-m-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-rocket-m-squashfs-sysupgrade.bin
endif

ifeq ($(T),bullet)
  NAME:=Bullet
  ARCH:=ar71xx
  TBUILD:=ar71xx
  TARGET_MASTER:=nsm5
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-bullet-m-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-bullet-m-squashfs-sysupgrade.bin
endif

ifeq ($(T),freestation)
  NAME:=Freestation
  ARCH:=ramips
  IMAGE:=bin/$(ARCH)/openwrt-ramips-rt305x-freestation5-squashfs-sysupgrade.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ramips-rt305x-freestation5-squashfs-sysupgrade.bin
  override OWRT_SVN = -r 31673 svn://svn.openwrt.org/openwrt/trunk
  override OWRT_PKG_SVN = -r 31673 svn://svn.openwrt.org/openwrt/packages
endif

ifeq ($(T),tl-2543)
  NAME:=Tplink2543
  ARCH:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wr2543n-v1-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wr2543n-v1-squashfs-sysupgrade.bin
  override OWRT_SVN = -r 32353 svn://svn.openwrt.org/openwrt/trunk
  override OWRT_PKG_SVN = -r 32353 svn://svn.openwrt.org/openwrt/packages
endif

ifeq ($(T),tl-842)
  NAME:=Tplink842
  ARCH:=ar71xx
  TBUILD:=tl-84X
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wr842n-v1-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wr842n-v1-squashfs-sysupgrade.bin
  override OWRT_SVN = -r 31348 svn://svn.openwrt.org/openwrt/trunk
  override OWRT_PKG_SVN = -r 31348 svn://svn.openwrt.org/openwrt/packages
endif

ifeq ($(T),tl-841)
  NAME:=Tplink841
  ARCH:=ar71xx
  TBUILD:=tl-84X
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wr841nd-v7-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wr841nd-v7-squashfs-sysupgrade.bin
  override OWRT_SVN = -r 31348 svn://svn.openwrt.org/openwrt/trunk
  override OWRT_PKG_SVN = -r 31348 svn://svn.openwrt.org/openwrt/packages
endif

ifeq ($(T),tl-N750)
  NAME:=TplinkN750
  ARCH:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wdr4300-v1-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wdr4300-v1-squashfs-sysupgrade.bin
  override OWRT_SVN = -r 32638 svn://svn.openwrt.org/openwrt/trunk
  override OWRT_PKG_SVN = -r 32638 svn://svn.openwrt.org/openwrt/packages
endif

ifeq ($(T),tl-mr3020)
  NAME:=TplinkMR3020
  ARCH:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-mr3020-v1-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-mr3020-v1-squashfs-sysupgrade.bin
  override OWRT_SVN = -r 31673 svn://svn.openwrt.org/openwrt/trunk
  override OWRT_PKG_SVN = -r 31673 svn://svn.openwrt.org/openwrt/packages
endif

ifeq ($(T),wpe72)
  NAME:=CompexWPE72
  ARCH:=ar71xx
  TBUILD:=tl-mr3020
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-generic-wpe72-squashfs-8M-factory.img
  override OWRT_SVN = -r 31673 svn://svn.openwrt.org/openwrt/trunk
  override OWRT_PKG_SVN = -r 31673 svn://svn.openwrt.org/openwrt/packages
endif

ifeq ($(T),wispstation)
  NAME:=WispStation
  ARCH:=atheros
  TBUILD:=atheros
  IMAGE:=bin/$(ARCH)/openwrt-atheros-ubnt5-squashfs.bin
endif


