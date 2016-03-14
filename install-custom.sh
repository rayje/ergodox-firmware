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

CURRENT_DATE=$(gdate --rfc-3339 s)
GIT_COMMIT_DATE=$(git log -n 1 --pretty --date=iso | grep 'Date' | cut -c 9- )
GIT_COMMIT_ID=$(git log -n 1 | grep 'commit' | cut -c 8-)

cd $CUSTOM

./build-scripts/gen-ui-info.py \
    --current-date "$CURRENT_DATE" \
    --git-commit-date "$GIT_COMMIT_DATE" \
    --git-commit-id "$GIT_COMMIT_ID" \
    --map-file-path "src/firmware.map" \
    --source-code-path "src" \
    --matrix-file-path "src/keyboard/ergodox/matrix.h" \
    --layout-file-path "src/keyboard/ergodox/layout/default--layout.c" > firmware--ui-info.json

./build-scripts/gen-layout.py --ui-info-file firmware--ui-info.json > firmware--layout.html


echo "--------------------------------------------------"
echo "Created layout file: $CUSTOM/firmware--layout.html"
echo "--------------------------------------------------"
