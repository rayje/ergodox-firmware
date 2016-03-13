#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    echo "Usage: ./install-custom <update>"
    exit 1
fi

UPDATE=$1
BASE=$HOME/dev/ergodox
CUSTOM=$BASE/ergodox-custom
CUSTOM_SRC=$CUSTOM/src
MASSDROP=$BASE/massdrop
NEW_LAYOUT=$MASSDROP/$UPDATE/keyboard/ergodox/layout/default--layout*

EEP=$CUSTOM_SRC/firmware.eep
HEX=$CUSTOM_SRC/firmware.hex

echo "----------------------------------"
echo "Applying update $MASSDROP/$UPDATE"
echo "----------------------------------"

cp $NEW_LAYOUT $CUSTOM_SRC/keyboard/ergodox/layout/.
cd $CUSTOM_SRC


# Build new layout
make clean
make LAYOUT=default--layout

# Verify expected files were compiled 
for i in ${EEP} ${HEX}; do
    if [ ! -f "$i" ]; then
        echo "----------------------------------"
        echo "File not found: $i"
        echo "----------------------------------"
        exit 1
    fi
done

# Apply new layout
sudo teensy_loader_cli -mmcu=atmega32u4 -w $CUSTOM/src/firmware.eep -v
sudo teensy_loader_cli -mmcu=atmega32u4 -w $CUSTOM/src/firmware.hex -v

echo "----------------------------------"
echo "Update applied $MASSDROP/$UPDATE"
echo "----------------------------------"
