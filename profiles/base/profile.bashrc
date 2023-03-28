
orangepi5_openfyde_base_stack_bashrc() {
  local cfg 

  cfgd="/mnt/host/source/src/overlays/overlay-orangepi5-openfyde-base/${CATEGORY}/${PN}"
  for cfg in ${PN} ${P} ${PF} ; do
    cfg="${cfgd}/${cfg}.bashrc"
    [[ -f ${cfg} ]] && . "${cfg}"
  done

  export ORANGEPI5_OPENFYDE_BASE_BASHRC_FILESDIR="${cfgd}/files"
}

orangepi5_openfyde_base_stack_bashrc
