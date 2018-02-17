#!/bin/bash
# hacked official hassio addon

set -e

CONFIG_PATH=/data/options.json

COMPUTERS=$(jq --raw-output '.computers | length' $CONFIG_PATH)

# Read from STDIN aliases to send shutdown
while read -r input; do
    # remove json stuff
    input="$(echo "$input" | jq --raw-output '.')"
    echo "[Info] shutdown-alias: $input"

    # Find aliases -> computer
    for (( i=0; i < "$COMPUTERS"; i++ )); do
        ALIAS=$(jq --raw-output ".computers[$i].alias" $CONFIG_PATH)
        ADDRESS=$(jq --raw-output ".computers[$i].address" $CONFIG_PATH)
        CREDENTIALS=$(jq --raw-output ".computers[$i].credentials" $CONFIG_PATH)
        TIME=$(jq --raw-output ".computers[$i].time" $CONFIG_PATH)
        MESSAGE=$(jq --raw-output ".computers[$i].message" $CONFIG_PATH)

        # Not the correct alias
        if [ "$ALIAS" != "$input" ]; then
            continue
        fi
      
        echo "[Info] shutting down $input -> $ADDRESS"
        if ! msg="$(net rpc shutdown -f -t "$TIME" -C "$MESSAGE" -I "$ADDRESS" -U "$CREDENTIALS")"; then
            echo "[Error] remote shutdown failed -> $msg"
        fi
    done
done