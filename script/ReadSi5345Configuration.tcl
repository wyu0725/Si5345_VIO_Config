set script_path D:/MyProject/FELIX_USTC/si5345Config
set ConfigFilePath $script_path/../Config_Files
set fp [open $ConfigFilePath/Si5345_ZeroDelay.txt r]
# Read text header
gets $fp
# Read all configuration files
set dataContent [read $fp]
set dataFile [split $dataContent "\n"]
set active 1
set deactive 0
foreach dataLine $dataFile {
    set RealData [split $dataLine ,]
    lassign $RealData RegAddr RegData
    # Remove the "0x" from hex data and set the Reg addr
    set RegAddr_real [regsub -all "0x" $RegAddr ""]
    set_property OUTPUT_VALUE $RegAddr_real [get_hw_probes si5345_reg_addr_from_vio_w]
    commit_hw_vio [get_hw_probes {si5345_reg_addr_from_vio_w}]

    # Remove the "0x" from hex data and set the Reg addr
    set RegData_real [regsub -all "0x" $RegData ""]
    set_property OUTPUT_VALUE $RegData_real [get_hw_probes si5345_reg_wr_value_from_vio_w]
    commit_hw_vio [get_hw_probes {si5345_reg_wr_value_from_vio_w}]

    # Active start
    set_property OUTPUT_VALUE $active [get_hw_probes start_configuration_from_vio_w]
    commit_hw_vio [get_hw_probes {start_configuration_from_vio_w}]
    # Dective start
    set_property OUTPUT_VALUE $deactive [get_hw_probes start_configuration_from_vio_w]
    commit_hw_vio [get_hw_probes {start_configuration_from_vio_w}]
}
