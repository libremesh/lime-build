# targets.mk
#  
#  OUTDIR := Output directory relative to the OpenWRT/LEDE root (build/src)
#  ARCH := Architecture according OpenWRT/LEDE

TARGETS_AVAILABLE:=ar71xx ar71xx-mini x86 mt7620 mt7621

ifeq ($(T),ar71xx)
  ARCH:=ar71xx
  OUTDIR:=bin/targets/$(ARCH)/generic
endif

ifeq ($(T),ar71xx-mini)
  ARCH:=ar71xx
  OUTDIR:=bin/targets/$(ARCH)/generic
endif

ifeq ($(T),x86)
  ARCH:=x86
  OUTDIR:=bin/targets/$(ARCH)/generic
endif

ifeq ($(T),mt7620)
  ARCH:=ramips
  OUTDIR:=bin/targets/$(ARCH)/mt7620
endif

ifeq ($(T),mt7621)
  ARCH:=ramips
  OUTDIR:=bin/targets/$(ARCH)/mt7621
endif
