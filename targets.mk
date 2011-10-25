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

