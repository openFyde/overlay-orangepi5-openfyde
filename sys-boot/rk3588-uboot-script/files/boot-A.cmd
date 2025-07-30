# Recompile with:
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr

setenv rootpart 3
setenv load_addr "0x9000000"
setenv overlay_error "false"

# setenv overlay_prefix rk3588
# default values
setenv verbosity "1"
setenv console "both"
setenv bootlogo "false"
setenv rootfstype "ext4"
setenv docker_optimizations "off"
setenv earlycon "on"
setenv user_overlay "/fyde/overlay"
setenv stateful_part "1"

echo "Boot script loaded from ${devtype} ${devnum}:${distro_bootpart}"

part uuid ${devtype} ${devnum}:${rootpart} root_uuid

# here we load ${efi}/boot/Env.txt first, then /fyde/Env.txt can override envs
if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}Env.txt; then
	load ${devtype} ${devnum}:${distro_bootpart} ${load_addr} ${prefix}/Env.txt
	env import -t ${load_addr} ${filesize}
	echo "loaded envs from  ${devtype} ${devnum}:${distro_bootpart} ${prefix}Env.txt"
fi

# NOTE: stateful ext4 partition reads may fail due to BAD uboot
if test -e ${devtype} ${devnum}:${stateful_part} /fyde/Env.txt; then
	load ${devtype} ${devnum}:${stateful_part} ${load_addr} /fyde/Env.txt
	env import -t ${load_addr} ${filesize}
	echo "loaded envs from  ${devtype} ${devnum}:1 /fyde/Env.txt"
fi

if test "${logo}" = "disabled"; then setenv logo "logo.nologo"; fi

if test "${console}" = "display" || test "${console}" = "both"; then setenv consoleargs "console=tty1"; fi
if test "${console}" = "serial" || test "${console}" = "both"; then setenv consoleargs "console=ttyS2,1500000 ${consoleargs}"; fi
if test "${earlycon}" = "on"; then setenv consoleargs "earlycon ${consoleargs}"; fi
if test "${bootlogo}" = "true"; then setenv consoleargs "bootsplash.bootfile=bootsplash.orangepi ${consoleargs}"; fi

echo "rootpart: ${devtype} ${devnum}:${rootpart} uuid:${root_uuid}"
setenv bootargs rootwait ro cros_debug cros_legacy console=ttyS2,1500000n8 root=PARTUUID=${root_uuid} usbstoragequirks=0x2537:0x1066:u,0x2537:0x1068:u

load ${devtype} ${devnum}:${rootpart} ${kernel_addr_r} ${prefix}Image

echo "fdtfile: ${prefix}${fdtfile}"
load ${devtype} ${devnum}:${rootpart} ${fdt_addr_r} ${prefix}${fdtfile}
fdt addr ${fdt_addr_r}
fdt resize 65536
for overlay_file in ${overlays}; do
	if load ${devtype} ${devnum}:${rootpart} ${load_addr} ${prefix}/rockchip/overlay/${overlay_prefix}${overlay_file}.dtbo; then
		echo "Applying kernel provided DT overlay ${overlay_prefix}${overlay_file}.dtbo"
		fdt apply ${load_addr} || setenv overlay_error "true"
	fi
done

for overlay_file in ${user_overlays}; do
	if load ${devtype} ${devnum}:${stateful_part} ${load_addr} ${user_overlay}/${overlay_file}.dtbo; then
		echo "Applying user provided DT overlay ${overlay_file}.dtbo"
		fdt apply ${load_addr} || setenv overlay_error "true"
	fi
done

if test "${overlay_error}" = "true"; then
	echo "Error applying DT overlays, restoring original DT"
	load ${devtype} ${devnum}:${rootpart} ${fdt_addr_r} ${prefix}${fdtfile}
else
	if load ${devtype} ${devnum}:${rootpart} ${load_addr} ${prefix}/rockchip/overlay/${overlay_prefix}fixup.scr; then
		echo "Applying kernel provided DT fixup script (${overlay_prefix}fixup.scr)"
		source ${load_addr}
	fi
	if test -e ${devtype} ${devnum}:${rootpart} ${prefix}fixup.scr; then
		load ${devtype} ${devnum}:${rootpart} ${load_addr} ${prefix}fixup.scr
		echo "Applying user provided fixup script (fixup.scr)"
		source ${load_addr}
	fi
fi

if test "${ethernet_phy}" = "rtl8211f"; then
        fdt set /ethernet@ff540000 tx_delay <0x24>
        fdt set /ethernet@ff540000 rx_delay <0x18>
fi

booti ${kernel_addr_r} - ${fdt_addr_r}
