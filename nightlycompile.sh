#!/bin/bash

# This is a dummy script to be used with crontab for nighly compilations and so.
# Not recommended to use in a read/write development environment.
#
# Example of usage:
# FORCE="1" TARGETS="alix rspro" COMMUNITY="myNet" BRANCH="testing" ./nightlycompile.sh
# 

# Mail to send alerts in case something goes wrong
MAIL="admin@libre-mesh.org"

# In the output directory, files older than this will be removed
DAYS_TO_PRESERVE="10"

COMMUNITY=${COMMUNITY:-LiMe}
BRANCH=${BRANCH:-develop}

# If target is not specified, compiling for all targets
TARGETS=${TARGETS:-$(make list_targets)}

# Targets which are not gonna be compiled
NOTARGETS=${NOTARGETS:-}

# Extra packages (separated by spaces)
EXTRA_PACKS=${EXTRA_PACKS:-}

# If $FORCE is not set, then not forced by default
FORCE=${FORCE:-0}

# If no "IMAGES" file is supossed there are no binary images compiled, then force to compile
[ ! -f "images/IMAGES" ] && FORCE=1

# Check if it is up to date
[ "$(make is_up_to_date LIME_GIT_BRANCH=$BRANCH)" != "0" ] && make update_all && FORCE=1

# Number of parallel procs
[ -z "$J" ] && J=$(cat /proc/cpuinfo | grep -c processor)

#(cd build/lime-packages && git pull && git checkout $BRANCH && git pull origin $BRANCH)

# Date of the last commit
LAST_COMMIT_DATE=$(cd build/lime-packages && git log -1 origin/${BRANCH} --format="%ct")

# If force is not 1 at this point it means we should not compile
[ $FORCE -eq 0 ] && exit 0

# Let's compile
for t in $TARGETS; do
	[[ "$NOTARGETS" =~ "$t" ]] && echo "Ignoring target $t. Not compiling." && continue
	# If not forced, check if there is already compiled an image for the target with the last commit
	echo "Compiling target $t"
	echo "nice -n 25 make T=$t build J=$J LIME_GIT_BRANCH=$BRANCH COMMUNITY=$COMMUNITY EXTRA_PACKS=$EXTRA_PACKS"
	nice -n 25 make T=$t build J=$J LIME_GIT_BRANCH=$BRANCH COMMUNITY=$COMMUNITY EXTRA_PACKS=$EXTRA_PACKS
	
	[ $? -ne 0 ] && [ ! -z "$MAIL" ] && echo "Error detected during LiMe compilation process (for target $t)" | mail -s "[LiMe] build system" $MAIL 
done

[ $DAYS_TO_PRESERVE -gt 0 ] && find images/ -iname "*.bin" -type f -mtime +$DAYS_TO_PRESERVE -exec rm -f '{}' \;

(cd images && md5sum *.bin > IMAGES)

