# Copyright (c) 2022 Fyde Innovations Limited and the openFyde Authors.
# Distributed under the license specified in the root directory of this project.

unset -f cros_pre_src_prepare_openfyde_patches

cros_post_src_install_orangepi5_openfyde_base() {
  exeinto /usr/sbin
  doexe ${ORANGEPI5_OPENFYDE_BASE_BASHRC_FILESDIR}/flash_spi.sh
  doexe ${ORANGEPI5_OPENFYDE_BASE_BASHRC_FILESDIR}/copy_kernel.sh
}

cros_pre_src_prepare_orangepi5_openfyde_base_patches() {
  eapply -p2 ${ORANGEPI5_OPENFYDE_BASE_BASHRC_FILESDIR}/install.patch
  eapply -p2 ${ORANGEPI5_OPENFYDE_BASE_BASHRC_FILESDIR}/postinst.patch
}
