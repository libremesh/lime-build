#!/bin/bash

# This is a dummy script to be used with crontab for nighly compilations and so
#
# Example of usage:
# FORCE="1" TARGETS="alix rspro" COMMUNITY="myNet" BRANCH="testing" ./nighlycompile.sh
# 

# Mail to send alerts in case something goes wrong
MAIL="admin@qmp.cat"

# In the output directory, files older than this will be removed
DAYS_TO_PRESERVE="10"

[ -z "$COMMUNITY" ] && COMMUNITY=qMp
[ -z "$BRANCH" ] && BRANCH=testing

# If target is not specified, compiling for all targets
[ -z "$TARGETS" ] && TARGETS="$(make list_targets)"

# If FORCE is 1, compilation process will be forced
[ -z "$FORCE" ] && FORCE=0

[ ! $FORCE ] && [ "$(cd build/qmp && git pull)" == "Already up-to-date." ] && { echo "Nothing to compile, qMp in last version"; exit 0; }

make update_all

for t in $TARGETS; do

	echo "Syncronizing configuration..."
	make T=$t sync_config

	echo "Compiling target $t"
	nice -n 25 make T=$t build J=2 QMP_GIT_BRANCH=$BRANCH COMMUNITY=$COMMUNITY

	[ $? -ne 0 ] && [ ! -z "$MAIL" ] && echo "Error detected during QMP compilation process" | mail -s "[qMp] build system" $MAIL
done

find images/ -type f -mtime +$DAYS_TO_PRESERVE -exec rm -f '{}' \;
cd images && md5sum *.bin > IMAGES

