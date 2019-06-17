// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.1 (win64) Build 2188600 Wed Apr  4 18:40:38 MDT 2018
// Date        : Mon Jun 17 10:28:38 2019
// Host        : WYU running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/MyProject/FELIX_USTC/source/HDL/ip/xc7k410tffg900-2L/si5345_spi_configuration_vio/si5345_spi_configuration_vio_stub.v
// Design      : si5345_spi_configuration_vio
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k410tffg900-2L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2018.1" *)
module si5345_spi_configuration_vio(clk, probe_in0, probe_in1, probe_in2, probe_out0, 
  probe_out1, probe_out2, probe_out3, probe_out4, probe_out5)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_in0[0:0],probe_in1[0:0],probe_in2[7:0],probe_out0[0:0],probe_out1[0:0],probe_out2[15:0],probe_out3[7:0],probe_out4[0:0],probe_out5[1:0]" */;
  input clk;
  input [0:0]probe_in0;
  input [0:0]probe_in1;
  input [7:0]probe_in2;
  output [0:0]probe_out0;
  output [0:0]probe_out1;
  output [15:0]probe_out2;
  output [7:0]probe_out3;
  output [0:0]probe_out4;
  output [1:0]probe_out5;
endmodule
