#!/bin/bash

# This is a dummy script to be used with crontab for nighly compilations and so
#
# Example of usage:
# FORCE="1" TARGETS="alix rspro" COMMUNITY="myNet" BRANCH="testing" ./nightlycompile.sh
# 

# Mail to send alerts in case something goes wrong
MAIL="admin@libre-mesh.org"

# In the output directory, files older than this will be removed
DAYS_TO_PRESERVE="10"

COMMUNITY=${COMMUNITY:-qMp}
BRANCH=${BRANCH:-testing}

# If target is not specified, compiling for all targets
TARGETS=${TARGETS:-$(make list_targets)}

# Targets which are not gonna be compiled
NOTARGETS=${NOTARGETS:-}

# If FORCE is 1, compilation process will be forced
[ -z "$FORCE" ] && FORCE=0

[ $FORCE -eq 0 ] && {
	if make is_up_to_date LIME_GIT_BRANCH=$BRANCH >& /dev/null
	   then
	   echo "Nothing to compile, LiMe in last version"
	   exit 0
	fi
}

make update_all

(cd build/lime && git checkout $BRANCH)

for t in $TARGETS; do
	[[ "$NOTARGETS" =~ "$t" ]] && continue
	echo "Compiling target $t"
	nice -n 25 make T=$t build J=2 LIME_GIT_BRANCH=$BRANCH COMMUNITY=$COMMUNITY

	[ $? -ne 0 ] && [ ! -z "$MAIL" ] && 
	  echo "Error detected during LIME compilation process" | mail -s "[LiMe] build system" $MAIL
done

[ $DAYS_TO_PRESERVE -gt 0 ] && 
  find images/ -iname "*.bin" -type f -mtime +$DAYS_TO_PRESERVE -exec rm -f '{}' \;
  
(cd images && md5sum *.bin > IMAGES)

