orangepi5b_openfyde_stack_bashrc() {
  local cfg 

  cfgd="/mnt/host/source/src/overlays/overlay-orangepi5b-openfyde/${CATEGORY}/${PN}"
  for cfg in ${PN} ${P} ${PF} ; do
    cfg="${cfgd}/${cfg}.bashrc"
    [[ -f ${cfg} ]] && . "${cfg}"
  done

  export ORANGEPI5B_OPENFYDE_BASHRC_FILEPATH="${cfgd}/files"
}

orangepi5b_openfyde_stack_bashrc
