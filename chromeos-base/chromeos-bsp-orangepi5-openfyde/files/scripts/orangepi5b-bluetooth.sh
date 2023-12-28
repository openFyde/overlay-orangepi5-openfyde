#!/bin/bash

bt_status=$(cat /proc/device-tree/wireless-bluetooth/status)
if [[ ${bt_status} == "okay" ]]; then
    /usr/sbin/rfkill unblock bluetooth
    /usr/bin/hciconfig hci0 up
fi
