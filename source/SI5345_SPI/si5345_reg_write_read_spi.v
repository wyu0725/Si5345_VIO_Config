`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2019/04/29 11:20:47
// Design Name:
// Module Name: si5345_reg_write_spi
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


module si5345_reg_write_read_spi
    #(
        parameter SPI_DOUT_WIDTH = 16,
        parameter SPI_DIN_WIDTH = 8
    )(
        input sys_clk,
        input reset_n,

        input start_i,
        input rw_i, // 1: read, 0: write
        input [11:0] spi_clk_div2,
        input [15:0] reg_addr_i,
        input [7:0] reg_value_wr_i,
        output [7:0] reg_value_rd_o,

        output busy_o,
        output done_o,

        output cs_n_o,
        output sclk_o,
        output sdo_o,//Master output, connected to si5345 SDI
        input sdi_i //Master input, connected to si5345 SDO
        );

    reg [2:0] state;
    reg [2:0] state_temp;
    localparam [2:0]
    IDLE = 3'd0,
    WRITE_PAGE_ADDR = 3'd1,
    WRITE_PAGE = 3'd2,
    WRITE_DATA_ADDR = 3'd3,
    WRITE_DATA = 3'd4,
    READ_DATA = 3'd5,
    DONE = 3'd6,
    WAIT = 3'd7;

    reg busy_r;
    reg done_r;
    assign busy_o = busy_r;
    assign done_o = done_r;

    reg [15:0] wait_cnt;
    reg [15:0] spi_clk_div2_r;
    reg spi_start_r;
    reg spi_rw_r;
    wire spi_busy_w;
    wire spi_done_w;
    reg [15:0] spi_dout_r;
    reg rw_r;

    localparam [7:0] PAGE_ADDR = 8'h01;
    localparam [7:0] SPI_ADDR_CMD = 8'h00;
    localparam [7:0] SPI_WR_CMD = 8'h40;
    localparam [7:0] SPI_RD_CMD = 8'h80;
    reg [7:0] page_addr_r;
    reg [7:0] reg_addr_byte_r;
    reg [7:0] reg_value_wr_r;
    always @(posedge sys_clk or negedge reset_n)
    begin
        if(~reset_n) begin
            busy_r <= 1'b0;
            done_r <= 1'b0;
            wait_cnt <= 16'b0;
            spi_start_r <= 1'b0;
            spi_rw_r <= 1'b0;
            spi_dout_r <= 16'b0;
            page_addr_r <= 8'b0;
            reg_addr_byte_r <= 8'b0;
            reg_value_wr_r <= 8'b0;
            spi_clk_div2_r <= 16'b0;
            rw_r <= 1'b0;
            state <= IDLE;
            state_temp <= IDLE;
        end
        else begin
            case(state)
                IDLE:begin
                    done_r <= 1'b0;
                    if(start_i) begin
                        page_addr_r <= reg_addr_i[15:8];
                        reg_addr_byte_r <= reg_addr_i[7:0];
                        reg_value_wr_r <= reg_value_wr_i;
                        rw_r <= rw_i;
                        spi_dout_r <= {SPI_ADDR_CMD, PAGE_ADDR};
                        busy_r <= 1'b1;
                        spi_clk_div2_r <= spi_clk_div2 << 3;
                        state <= WRITE_PAGE_ADDR;
                    end
                end
                WRITE_PAGE_ADDR: begin
                    if(spi_done_w) begin
                        state <= WAIT;
                        state_temp <= WRITE_PAGE;
                        spi_dout_r <= {SPI_WR_CMD, page_addr_r};
                    end
                    else if(spi_busy_w == 0) begin
                        spi_start_r <= 1'b1;
                    end
                    else begin
                        spi_start_r <= 1'b0;
                    end
                end
                WRITE_PAGE: begin
                    if(spi_done_w) begin
                        state <= WAIT;
                        state_temp <= WRITE_DATA_ADDR;
                        spi_dout_r <= {SPI_ADDR_CMD, reg_addr_byte_r};
                    end
                    else if(spi_busy_w == 0) begin
                        spi_start_r <= 1'b1;
                    end
                    else begin
                        spi_start_r <= 1'b0;
                    end
                end
                WRITE_DATA_ADDR: begin
                    if(spi_done_w) begin
                        state <= WAIT;
                        state_temp <= rw_r ? READ_DATA : WRITE_DATA;
                        spi_rw_r <= 1'b1;
                        spi_dout_r <= rw_r ? {SPI_RD_CMD, 8'h0} : {SPI_WR_CMD, reg_value_wr_r};
                    end
                    else if(spi_busy_w == 0) begin
                        spi_start_r <= 1'b1;
                    end
                    else begin
                        spi_start_r <= 1'b0;
                    end
                end
                WRITE_DATA:begin
                    if(spi_done_w) begin
                        state <= WAIT;
                        state_temp <= DONE;
                    end
                    else if(spi_busy_w == 0) begin
                        spi_start_r <= 1'b1;
                    end
                    else begin
                        spi_start_r <= 1'b0;
                    end
                end
                READ_DATA:begin
                    if(spi_done_w) begin
                        state <= WAIT;
                        spi_rw_r <= 1'b0;
                        state_temp <= DONE;
                    end
                    else if(spi_busy_w == 0) begin
                        spi_start_r <= 1'b1;
                    end
                    else begin
                        spi_start_r <= 1'b0;
                    end
                end
                DONE:begin
                    busy_r <= 1'b0;
                    done_r <= 1'b1;
                    state <= IDLE;
                end
                WAIT: begin
                    if(wait_cnt == spi_clk_div2_r) begin
                        wait_cnt <= 16'b0;
                        state <= state_temp;
                    end
                    else begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end
                end
            endcase
        end
    end

    spi_master_4wire
    #(
        .SPI_DOUT_WIDTH(SPI_DOUT_WIDTH),
        .SPI_DIN_WIDTH(SPI_DIN_WIDTH)
    )si5345_wr_rd_spi(
        .sys_clk(sys_clk),
        .reset_n(reset_n),

        .mlb_i(1'b1),   // 0-LSB first, 1-MSB first
        .start_i(spi_start_r), // Level signal
        .busy_o(spi_busy_w), // Negedge indicates tramit done
        .rw_i(spi_rw_r),    // 0-write, 1-read
        .spi_clk_div2(spi_clk_div2),

        .spi_dout(spi_dout_r), // Width = SPI_DOUT_WIDTH

        .cs_n_o(cs_n_o),
        .sclk_o(sclk_o),
        .sdo_o(sdo_o),
        .sdi_i(sdi_i),

        .done_o(spi_done_w),
        .spi_din(reg_value_rd_o) // Width = SPI_DIN_WIDTH

        );
endmodule
