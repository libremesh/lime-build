# profiles.mk
PROFILES_AVAILABLE:=generic freifunk chef

ifeq ($(P),generic)
  PACKAGES:=lime-full
endif

ifeq ($(P),freifunk)
  PACKAGES:=lime-freifunk
endif

ifeq ($(P),chef)
  PACKAGES:=lime-full lime-freifunk
endif
