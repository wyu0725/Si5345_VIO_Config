# Import elink top files for a new project
#
# One must change the script_dir to one's own path 
puts "INFO: Reading si5345 configuration vreilog files and IP core..."
set script_dir D:/MyProject/Si5345_VIO_Config/script
set source_dir $script_dir/../source
set target_fpga xc7k410tffg900-2L
# Read SPI main file
read_verilog $source_dir/SI5345_SPI/spi_master_4wire.v
read_verilog $source_dir/SI5345_SPI/si5345_reg_write_read_spi.v
# Read Top and clock gen file
read_verilog $source_dir/SI5345_SPI/si5345_config_top.v
read_verilog $source_dir/SI5345_SPI/spi_sys_clock_gen.v
# Read VIO
add_files -norecurse $source_dir/ip/$target_fpga/si5345_spi_configuration_vio/si5345_spi_configuration_vio.xci
puts "INFO: Read si5345 configuration vreilog files and IP core done"
