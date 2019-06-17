`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC
// Engineer: Yu Wang
//
// Create Date: 2019/06/14 21:10:02
// Design Name: Si5345 Configure via VIO
// Module Name: si5345_config_top
// Project Name:
// Target Devices: xc7k410tffg900-2L
// Tool Versions: Vivado 2018.1
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module si5345_config_top(
    input OSC_CLK_40M_PIN,
    input FPGA_RESET_N_PIN,
    // Si5345 Pins
    output SI5345_MOSI_POUT,// SPI data Master output slave input
    input SI5345_MISO_PIN,// SPI data master input slave output
    output SPI_CS_N_POUT,// Chip select
    output SCLK_POUT,// SPI SCLK
    output [1:0] IN_SEL,
    output I2C_OR_SPI_POUT,// 1-I2C, 0-SPI
    output SI5345_RST_N_POUT

    );

    wire reset_n;
    wire top_clk40m;
    wire clock_good_to_vio_w;
    spi_sys_clock_gen top_clock_gen(
        .osc_clk_i(OSC_CLK_40M_PIN),
        .fpga_rst_n_i(FPGA_RESET_N_PIN),
        .clk_40m_o(top_clk40m),
        .reset_n_o(reset_n),
        .clock_good_o(clock_good_to_vio_w)

        );

    wire start_configuration_from_vio_w;
    wire si5345_rw_from_vio_w;
    wire [15:0] si5345_reg_addr_from_vio_w;
    wire [7:0] si5345_reg_wr_value_from_vio_w;
    wire [7:0] si5345_reg_rd_value_to_vio_w;
    wire si5345_spi_busy_to_vio_w;
    wire si5345_spi_done_to_vio;
    wire reset_n_from_vio;

    // The output of vio cannot be accurate as one clock peroid, so that an
    // posedge detect is necessary to generate a pulse signal to start the
    // config.
    wire start_configuration_pulse_w;
    reg [1:0] start_configuration_r;
    always @(posedge top_clk40m or negedge reset_n)
        if(~reset_n)
            start_configuration_r <= 2'b00;
        else
            start_configuration_r <= {start_configuration_r[0], start_configuration_from_vio_w};

    assign start_configuration_pulse_w = start_configuration_r[0]
                                         && (~start_configuration_r[1]);
    si5345_reg_write_read_spi
    #(
        .SPI_DOUT_WIDTH(16),
        .SPI_DIN_WIDTH(8)
    )top_si5345_reg_wr_rd(
        .sys_clk(top_clk40m),
        .reset_n(reset_n && reset_n_from_vio),

        .start_i(start_configuration_pulse_w),
        .rw_i(si5345_rw_from_vio_w), // 1: read, 0: write
        .spi_clk_div2(12'h13),
        .reg_addr_i(si5345_reg_addr_from_vio_w),
        .reg_value_wr_i(si5345_reg_wr_value_from_vio_w),
        .reg_value_rd_o(si5345_reg_rd_value_to_vio_w),

        .busy_o(si5345_spi_busy_to_vio_w),
        .done_o(si5345_spi_done_to_vio),

        .cs_n_o(SPI_CS_N_POUT),
        .sclk_o(SCLK_POUT),
        .sdo_o(SI5345_MOSI_POUT),//Master output, connected to si5345 SDI
        .sdi_i(SI5345_MISO_PIN) //Master input, connected to si5345 SDO
        );
    wire [1:0] si5345_in_sel_from_vio_w;
    si5345_spi_configuration_vio top_si5345_vio(
        .clk(top_clk40m),                // input wire clk
        .probe_in0(si5345_spi_busy_to_vio_w),    // input wire [0 : 0] probe_in0
        .probe_in1(si5345_spi_done_to_vio),    // input wire [0 : 0] probe_in1
        .probe_in2(si5345_reg_rd_value_to_vio_w),    // input wire [7 : 0] probe_in2
        .probe_out0(si5345_rw_from_vio_w),  // output wire [0 : 0] probe_out0
        .probe_out1(start_configuration_from_vio_w),  // output wire [0 : 0] probe_out1
        .probe_out2(si5345_reg_addr_from_vio_w),  // output wire [15 : 0] probe_out2
        .probe_out3(si5345_reg_wr_value_from_vio_w),  // output wire [7 : 0] probe_out3
        .probe_out4(reset_n_from_vio),  // output wire [0 : 0] probe_out4
        .probe_out5(si5345_in_sel_from_vio_w)  // output wire [1 : 0] probe_out4
        );

    assign I2C_OR_SPI_POUT = 1'b0;
    assign SI5345_RST_N_POUT = 1'b1;
    assign IN_SEL = si5345_in_sel_from_vio_w;
endmodule
