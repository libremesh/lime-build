# profiles.mk
PROFILES_AVAILABLE:=generic freifunk chef

ifeq ($(P),generic)
  PROFILE_PACKAGES:=lime-full
endif

ifeq ($(P),freifunk)
  PROFILE_PACKAGES:=lime-freifunk
endif

ifeq ($(P),chef)
  PROFILE_PACKAGES:=lime-full lime-freifunk
endif
