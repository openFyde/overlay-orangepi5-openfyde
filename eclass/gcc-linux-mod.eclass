# Copyright 1999-202r32 FydeOS Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gcc-linux-mod.eclass
# @MAINTAINER:
# Yang Tsao <yang@fydeos.io>
# @SUPPORTED_EAPIS: 6 7 8
# @BLURB: We always build kernel with clang, but a lot of individual kernel modules doesn't support clang.


if [[ -z ${_GCC_LINUX_MOD_ECLASS} ]]; then
_GCC_LINUX_MOD_ECLASS=1
inherit linux-mod

IUSE_KERNEL_VERS=(
  kernel-5_4
  kernel-5_10
  kernel-5_15
  kernel-6_6
)

IUSE="${IUSE_KERNEL_VERS[*]}"

RESTRICT="bindist"
RESTRICT+=" mirror"

COMMON=">=sys-libs/glibc-2.6.1"

DEPEND="
  ${COMMON}
  virtual/linux-sources
  virtual/pkgconfig
"
#  dev-util/dwarves

RDEPEND="virtual/linux-sources"

REQUIRED_USE="?? ( ${IUSE_KERNEL_VERS[*]} )"

# @ECLASS_VARIABLE: MODULE_CONFIGS
# @USER_VARIABLE
# @DESCRIPTION:
# the kernel configs to export before setup build env
MODULE_CONFIGS=

# @ECLASS_VARIABLE: USER_KERNEL_SRC
# @USER_VARIABLE
# @DESCRIPTION:
# the kernel src to override system kernel src
USER_KERNEL_SRC=

# @ECLASS_VARIABLE: USER_KERNEL_PATCH
# @USER_VARIABLE
# @DESCRIPTION:
# the kernel patch to override default patch
USER_KERNEL_PATCH=

_SRC_PATH="/mnt/host/source/src"
_KERNEL_PATCH_PATH="${_SRC_PATH}/overlays/project-openfyde-drivers/eclass/gcc-linux-mod.patches"
_KERNEL_DIR="${_SRC_PATH}/third_party/kernel"

get_makefile_patch() {
  if [ -n "$USER_KERNEL_PATCH" ]; then
    echo $USER_KERNEL_PATCH
  elif use kernel-5_4; then
    echo "${_KERNEL_PATCH_PATH}/Makefile_5_4.patch"
  elif use kernel-5_10; then
    echo "${_KERNEL_PATCH_PATH}/Makefile_5_15.patch"
  elif use kernel-5_15; then
    echo "${_KERNEL_PATCH_PATH}/Makefile_5_15.patch"
  elif use kernel-6_6; then
    echo "${_KERNEL_PATCH_PATH}/Makefile_6_6.patch"
  fi
}

get_kernel_source() {
  if [ -n "$USER_KERNEL_SRC" ]; then
    echo $USER_KERNEL_SRC
  elif use kernel-5_4; then
    echo "${_KERNEL_DIR}/v5.4"
  elif use kernel-5_10; then
    echo "${_KERNEL_DIR}/v5.10"
  elif use kernel-5_15; then
    echo "${_KERNEL_DIR}/v5.15"
  elif use kernel-6_6; then
    echo "${_KERNEL_DIR}/v6.6"
  fi
}

patch_kernel_make() {
  local patch_file=`get_makefile_patch`
  local reverse=$1
  einfo "pushd ${KERNEL_DIR}"
  pushd ${KERNEL_DIR} 2>&1 >/dev/null || true
  patch $reverse  -p1 -i $patch_file || ewarn "failed to patch kernel source"
  popd 2>&1 >/dev/null || true
}

apply_kernel_make_patch() {
  patch_kernel_make "-N"
}

reverse_kernel_make_patch() {
  patch_kernel_make "-R -N"
}

setup_kernel_src() {
  local origin_kernel=`get_kernel_source`
  local home=`pwd`
  local kernel_ro=${WORKDIR}/$(basename $origin_kernel)
  mkdir -m 777 ${WORKDIR}
  mkdir -m 777 $kernel_ro ${kernel_ro}_top ${kernel_ro}_work ${kernel_ro}_rw
  sudo mount -B -o ro $origin_kernel $kernel_ro 2>&1 >/dev/null || ewarn "failed to bind $kernel_ro"
  sudo mount -t overlay overlay -o lowerdir=${kernel_ro},upperdir=${kernel_ro}_top,workdir=${kernel_ro}_work ${kernel_ro}_rw 2>&1 >/dev/null \
     || ewarn "failed to mount overlay: ${kernel_ro}_rw"
  echo ${kernel_ro}_rw
}

umount_kernel() {
  local origin_kernel=`get_kernel_source`
  local kernel_ro=${WORKDIR}/$(basename $origin_kernel)
  sudo umount ${kernel_ro}_rw $kernel_ro
}

gcc-linux-mod_pkg_setup() {
  export DISTCC_DISABLE=1
  export CCACHE_DISABLE=1
  export KERNEL_DIR=`setup_kernel_src`
  export KV_DIR=$KERNEL_DIR
  export KBUILD_OUTPUT=${ROOT}/usr/src/linux
  export KV_OUT_DIR=${ROOT}/usr/src/linux
  tc-export_build_env BUILD_{CC,CXX}
  einfo $KV_OUT_DIR
  linux-mod_pkg_setup
  export KVER="${KV_FULL}"
  export KSRC="$KERNEL_DIR"
  export TopDIR="$S"
  BUILD_PARAMS="-C ${KERNEL_DIR} -I${KBUILD_OUTPUT} O=${KBUILD_OUTPUT} M=${S}"
  einfo KERNELRELEASE:$KERNELRELEASE
  for config in $MODULE_CONFIGS; do
    export ${config}=m
  done
  #apply_kernel_make_patch
}

gcc-linux-mod_src_prepare() {
  default
}

gcc-linux-mod_src_compile() {
  cros_allow_gnu_build_tools
  linux-mod_src_compile
  umount_kernel
}

gcc-linux-mod_src_install() {
  linux-mod_src_install
}

EXPORT_FUNCTIONS pkg_setup src_prepare src_compile src_install
fi #_GCC_LINUX_MOD_ECLASS

