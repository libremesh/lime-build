#
# Copyright (C) 2011 qmp.cat
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

HW_AVAILABLE := alix rs rspro x86 fonera nsm5 nsm2

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
endif

ifeq ($(T),nsm5)
  NAME:=NanoStationM5
  ARCH:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-nano-m-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-ubnt-nano-m-squashfs-sysupgrade.bin
endif

ifeq ($(T),freestation)
  NAME:=Freestation
  ARCH:=ramips
  IMAGE:=bin/$(ARCH)/openwrt-ramips-rt305x-fonera20n-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ramips-rt305x-fonera20n-squashfs-sysupgrade.bin
  override OWRT_SVN = -r 30470 svn://svn.openwrt.org/openwrt/trunk
  override OWRT_PKG_SVN = -r 30470 svn://svn.openwrt.org/openwrt/packages
endif

ifeq ($(T),tplink2543)
  NAME:=Tplink-2543
  ARCH:=ar71xx
  IMAGE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wr2543n-v1-squashfs-factory.bin
  SYSUPGRADE:=bin/$(ARCH)/openwrt-ar71xx-generic-tl-wr2543n-v1-squashfs-sysupgrade.bin
  override OWRT_SVN = -r 29800 svn://svn.openwrt.org/openwrt/trunk
  override OWRT_PKG_SVN = -r 29800 svn://svn.openwrt.org/openwrt/packages
endif

ifeq ($(T),fonera)
  NAME:=Fonera
  ARCH:=atheros
  IMAGE:=bin/$(ARCH)/openwrt-atheros-root.squashfs $(NAME)-TIMESTAMP-root.squashfs
  SYSUPGRADE:=bin/$(ARCH)/openwrt-atheros-vmlinux.lzma $(NAME)-TIMESTAMP-vmlinux.lzma
endif


