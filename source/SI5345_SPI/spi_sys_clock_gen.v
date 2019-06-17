`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/14 21:23:22
// Design Name: 
// Module Name: spi_sys_clock_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_sys_clock_gen(
    input osc_clk_i,
    input fpga_rst_n_i,
    output clk_40m_o,
    output reset_n_o,
    output clock_good_o

    );
    // MMCME2_BASE: Base Mixed Mode Clock Manager
    //              Kintex-7
    // Xilinx HDL Language Template, version 2018.1

    wire clock_fb;
    wire mmcm_40m;
    // F_out = F_ClkIn \times \frac{M}{D\times O}
    // F_ClkIn = 40M
    // M = 40, D = 2
    // CLKOUT0_DIVIDE = 20, F_out = 40M
    MMCME2_BASE #(
        .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
        .CLKFBOUT_MULT_F(40.0),     // Multiply value for all CLKOUT (2.000-64.000). M
        .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (-360.000-360.000).
        .CLKIN1_PERIOD(25.000),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
        .CLKOUT1_DIVIDE(1),
        .CLKOUT2_DIVIDE(1),
        .CLKOUT3_DIVIDE(1),
        .CLKOUT4_DIVIDE(1),
        .CLKOUT5_DIVIDE(1),
        .CLKOUT6_DIVIDE(1),
        .CLKOUT0_DIVIDE_F(20),    // Divide amount for CLKOUT0 (1.000-128.000).
        // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
        .CLKOUT0_DUTY_CYCLE(0.5),
        .CLKOUT1_DUTY_CYCLE(0.5),
        .CLKOUT2_DUTY_CYCLE(0.5),
        .CLKOUT3_DUTY_CYCLE(0.5),
        .CLKOUT4_DUTY_CYCLE(0.5),
        .CLKOUT5_DUTY_CYCLE(0.5),
        .CLKOUT6_DUTY_CYCLE(0.5),
        // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
        .CLKOUT0_PHASE(0.0),
        .CLKOUT1_PHASE(0.0),
        .CLKOUT2_PHASE(0.0),
        .CLKOUT3_PHASE(0.0),
        .CLKOUT4_PHASE(0.0),
        .CLKOUT5_PHASE(0.0),
        .CLKOUT6_PHASE(0.0),
        .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
        .DIVCLK_DIVIDE(2),         // Master division value (1-106) D
        .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
        .STARTUP_WAIT("FALSE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
    )
    MMCME2_BASE_locl_clk (
        // Clock Outputs: 1-bit (each) output: User configurable clock outputs
        .CLKOUT0(mmcm_40m),     // 1-bit output: CLKOUT0
        .CLKOUT0B(),   // 1-bit output: Inverted CLKOUT0
        .CLKOUT1(),     // 1-bit output: CLKOUT1
        .CLKOUT1B(),   // 1-bit output: Inverted CLKOUT1
        .CLKOUT2(),     // 1-bit output: CLKOUT2
        .CLKOUT2B(),   // 1-bit output: Inverted CLKOUT2
        .CLKOUT3(),     // 1-bit output: CLKOUT3
        .CLKOUT3B(),   // 1-bit output: Inverted CLKOUT3
        .CLKOUT4(),     // 1-bit output: CLKOUT4
        .CLKOUT5(),     // 1-bit output: CLKOUT5
        .CLKOUT6(),     // 1-bit output: CLKOUT6
        // Feedback Clocks: 1-bit (each) output: Clock feedback ports
        .CLKFBOUT(clock_fb),   // 1-bit output: Feedback clock
        .CLKFBOUTB(), // 1-bit output: Inverted CLKFBOUT
        // Status Ports: 1-bit (each) output: MMCM status ports
        .LOCKED(clock_good_o),       // 1-bit output: LOCK
        // Clock Inputs: 1-bit (each) input: Clock input
        .CLKIN1(osc_clk_i),       // 1-bit input: Clock
        // Control Ports: 1-bit (each) input: MMCM control ports
        .PWRDWN(1'b0),       // 1-bit input: Power-down
        .RST(~fpga_rst_n_i),             // 1-bit input: Reset
        // Feedback Clocks: 1-bit (each) input: Clock feedback ports
        .CLKFBIN(clock_fb)      // 1-bit input: Feedback clock
        );
    // End of MMCME2_BASE_inst instantiation
    
    assign reset_n_o = clock_good_o;

    BUFG BUFG_40M (
        .O(clk_40m_o),     // 1-bit output: Clock output
        .I(mmcm_40m)  // 1-bit input: Clock input
        );
endmodule
