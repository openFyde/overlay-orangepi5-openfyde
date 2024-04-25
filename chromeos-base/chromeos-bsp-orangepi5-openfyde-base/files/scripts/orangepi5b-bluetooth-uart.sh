#!/bin/bash

source /usr/share/orange/common.sh

case ${BOARD} in
        orangepi5|orangepi5b|orangepi5plus|orangepitab|orangepi900)
                [[ $BOARD =~ orangepi5|orangepi5b ]] && echo host > /sys/kernel/debug/usb/fc000000.usb/mode

                bt_status=$(cat /proc/device-tree/wireless-bluetooth/status)
		wifi_chip=$(cat /proc/device-tree/wireless-wlan/wifi_chip_type)
		if [[ ${wifi_chip} == "ap6275p" && ${bt_status} == "okay" ]]; then
				/usr/sbin/rfkill unblock all
				 /usr/sbin/brcm_patchram_plus --bd_addr_rand --enable_hci --no2bytes --use_baudrate_for_download --tosleep 200000 \
					--baudrate 1500000 --patchram /lib/firmware/ap6275p/BCM4362A2.hcd /dev/ttyS9 &
		fi
			;;
esac

#bt_status=$(cat /proc/device-tree/wireless-bluetooth/status)
#if [[ ${bt_status} == "okay" ]]; then
#        /usr/sbin/rfkill unblock all
#        /usr/sbin/brcm_patchram_plus --bd_addr_rand --enable_hci --no2bytes --use_baudrate_for_download --tosleep 200000 \
#                --baudrate 1500000 --patchram /lib/firmware/ap6275p/BCM4362A2.hcd /dev/ttyS9
#fi
