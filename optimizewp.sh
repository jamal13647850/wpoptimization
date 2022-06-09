#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

. $SCRIPTPATH/settings.conf






wp post delete $(wp post list --post_status=trash --format=ids --path=$wpPath) --force --path=$wpPath

wp post delete $(wp post list --post_status=draft --format=ids --path=$wpPath) --force --path=$wpPath

wp post delete $(wp post list --post_type='revision' --format=ids --path=$wpPath) --force --path=$wpPath

wp comment delete $(wp comment list --status=spam --format=ids --path=$wpPath) --force --path=$wpPath

wp transient delete --expired --path=$wpPath

# create array of MyISAM tables
WPTABLES=($(wp db query "SHOW TABLE STATUS WHERE Engine = 'MyISAM'" --allow-root --silent --skip-column-names --path=$wpPath | awk '{ print $1}'))

# loop through array and alter tables
for WPTABLE in ${WPTABLES[@]}
do
    echo "Converting ${WPTABLE} to InnoDB"
    wp db query "ALTER TABLE ${WPTABLE} ENGINE=InnoDB"  --path=$wpPath
    echo "Converted ${WPTABLE} to InnoDB"
done

wp db optimize --path=$wpPath