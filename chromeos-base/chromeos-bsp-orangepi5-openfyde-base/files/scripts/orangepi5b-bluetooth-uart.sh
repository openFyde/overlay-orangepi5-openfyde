#!/bin/bash

source /usr/share/orange/common.sh

case ${BOARD} in
        orangepi5|orangepi5b|orangepi5plus|orangepitab|orangepi900)
                [[ $BOARD =~ orangepi5|orangepi5b ]] && echo host > /sys/kernel/debug/usb/fc000000.usb/mode

                bt_status=$(cat /proc/device-tree/wireless-bluetooth/status)
		wifi_chip=$(cat /proc/device-tree/wireless-wlan/wifi_chip_type)
		if [[ ${bt_status} == "okay" ]]; then
			# OrangePi5b
			if [[ ${wifi_chip} == "ap6275p" ]]; then
				fw=BCM4362A2.hcd
				tty=ttyS9
			# OrangePi5 Max
			elif [[ ${wifi_chip} == "ap6611"  ]]; then
				fw=SYN43711A0.hcd
				tty=ttyS7
			# OrangePi5 Pro
			elif [[ ${wifi_chip} == "ap6256"   ]]; then
				fw=BCM4345C5.hcd
				tty=ttyS9
			fi

			/usr/sbin/rfkill unblock all
			/usr/sbin/brcm_patchram_plus --bd_addr_rand --enable_hci --no2bytes --use_baudrate_for_download --tosleep 200000 \
				--baudrate 1500000 --patchram /lib/firmware/${fw} /dev/${tty} &
		fi
			;;
esac

#bt_status=$(cat /proc/device-tree/wireless-bluetooth/status)
#if [[ ${bt_status} == "okay" ]]; then
#        /usr/sbin/rfkill unblock all
#        /usr/sbin/brcm_patchram_plus --bd_addr_rand --enable_hci --no2bytes --use_baudrate_for_download --tosleep 200000 \
#                --baudrate 1500000 --patchram /lib/firmware/ap6275p/BCM4362A2.hcd /dev/ttyS9
#fi
