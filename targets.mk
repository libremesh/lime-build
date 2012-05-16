#
# Copyright (C) 2011 qmp.cat
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

HW_AVAILABLE := alix rs rspro fonera nsm5 nsm2 tplink2543 tplink842 freestation rocket wpe72 wispstation

ifeq ($(T),rspro)
  NAME:=RouterStationPro
  ARCH:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-rspro-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-rspro-squashfs-sysupgrade.bin
endif

ifeq ($(T),rs)
  NAME:=RouterStation
  override TARGET:=rspro
  ARCH:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-rs-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-rs-squashfs-sysupgrade.bin
endif

ifeq ($(T),alix)
  NAME:=Alix
  ARCH:=x86
  IMAGE:=bin/$(ARCH)/openwrt-x86-generic-combined-squashfs.img
  SYSUPGRADE:=bin/$(ARCH)/openwrt-x86-generic-combined-squashfs.img
endif

ifeq ($(T),nsm5)
  NAME:=NanoStationM5
  ARCH:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-nano-m-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-nano-m-squashfs-sysupgrade.bin
endif

ifeq ($(T),nsm2)
  NAME:=NanoStationM2
  override TARGET:=nsm5
  ARCH:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-nano-m-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-nano-m-squashfs-sysupgrade.bin
endif

ifeq ($(T),rocket)
  NAME:=Rocket
  override TARGET:=nsm5
  ARCH:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-rocket-m-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-rocket-m-squashfs-sysupgrade.bin
endif

ifeq ($(T),freestation)
  NAME:=Freestation
  ARCH:=ramips
  IMAGE:=bin/$(ARCH)/openwrt-ramips-rt305x-freestation5-squashfs-sysupgrade.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ramips-rt305x-freestation5-squashfs-sysupgrade.bin
  override OWRT_SVN = -r 31673 svn://svn.openwrt.org/openwrt/trunk
  override OWRT_PKG_SVN = -r 31673 svn://svn.openwrt.org/openwrt/packages
endif

ifeq ($(T),tplink2543)
  NAME:=Tplink2543
  ARCH:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wr2543n-v1-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wr2543n-v1-squashfs-sysupgrade.bin
  override OWRT_SVN = -r 31201 svn://svn.openwrt.org/openwrt/trunk
  override OWRT_PKG_SVN = -r 31201 svn://svn.openwrt.org/openwrt/packages
endif

ifeq ($(T),tplink842)
  NAME:=Tplink842
  ARCH:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wr842n-v1-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wr842n-v1-squashfs-sysupgrade.bin
  override OWRT_SVN = -r 31348 svn://svn.openwrt.org/openwrt/trunk
  override OWRT_PKG_SVN = -r 31348 svn://svn.openwrt.org/openwrt/packages
endif

ifeq ($(T),wpe72)
  NAME:=CompexWPE72
  ARCH:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-generic-wpe72-squashfs-8M-factory.img
  override OWRT_SVN = -r 31673 svn://svn.openwrt.org/openwrt/trunk
  override OWRT_PKG_SVN = -r 31673 svn://svn.openwrt.org/openwrt/packages
endif

ifeq ($(T),wispstation)
  NAME:=WispStation
  ARCH:=atheros
  IMAGE:=bin/$(ARCH)/openwrt-atheros-ubnt5-squashfs.bin
endif


ifeq ($(T),fonera)
  NAME:=Fonera
  ARCH:=atheros
  IMAGE:=bin/$(ARCH)/openwrt-atheros-root.squashfs $(NAME)-TIMESTAMP-root.squashfs
  SYSUPGRADE:=bin/$(ARCH)/openwrt-atheros-vmlinux.lzma $(NAME)-TIMESTAMP-vmlinux.lzma
endif


