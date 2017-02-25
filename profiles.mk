# profiles.mk
PROFILES_AVAILABLE:=generic basic freifunk chef ui-ng-test custom

ifeq ($(P),generic)
  PROFILE_PACKAGES:=lime-full
endif

ifeq ($(P),basic)
  PROFILE_PACKAGES:=lime-basic
endif

ifeq ($(P),freifunk)
  PROFILE_PACKAGES:=lime-freifunk
endif

ifeq ($(P),chef)
  PROFILE_PACKAGES:=lime-full lime-freifunk
endif

ifeq ($(P),ui-ng-test)
  PROFILE_PACKAGES:=lime-basic-uing
endif

ifeq ($(P),custom)
  PROFILE_PACKAGES:=
endif

ifeq ($(P),bmx7olsr1)
  PROFILE_PACKAGES:=lime-system lime-webui luci-app-bmx7 \
		lime-proto-wan luci-app-batman-adv lime-hwd-openwrt-wan \
		lime-proto-batadv lime-proto-olsr lime-proto-bmx7 \
		lime-proto-anygw lime-proto-wan dnsmasq-lease-share \
		dnsmasq-distributed-hosts lime-debug kmod-ath5k
endif
