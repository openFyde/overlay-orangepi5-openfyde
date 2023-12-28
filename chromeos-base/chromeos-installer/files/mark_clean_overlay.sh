#!/bin/bash

ARC_DIR="/mnt/stateful_partition/unencrypted/android"
CLEAN_OVERLAY="$ARC_DIR/.clean_overlay"

main() {
 if [ -d "$ARC_DIR" ]; then
   touch "$CLEAN_OVERLAY"
 fi 
}

main "$@"
