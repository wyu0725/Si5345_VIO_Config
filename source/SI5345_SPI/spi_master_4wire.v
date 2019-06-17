`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2019/04/28 20:22:23
// Design Name:
// Module Name: spi_master_4wire
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


module spi_master_4wire
    #(
        parameter SPI_DOUT_WIDTH = 16,
        parameter SPI_DIN_WIDTH  = 8
    )(
        input                          sys_clk,
        input                          reset_n,

        input                          mlb_i,        // 0-LSB first, 1-MSB first
        input                          start_i,      // Level signal
        output                         busy_o,       // Negedge indicates tramit done
        input                          rw_i,         // 0-write, 1-read
        input [11:0]                   spi_clk_div2, // 12 bits = (F_clk / f_sclk)/2 - 1

        input [SPI_DOUT_WIDTH - 1 : 0] spi_dout,     // Width = SPI_DOUT_WIDTH
        output                         cs_n_o,
        output                         sclk_o,
        output                         sdo_o,
        input                          sdi_i,
        output                         done_o,
        output [SPI_DIN_WIDTH - 1 : 0] spi_din       // Width = SPI_DIN_WIDTH

        );

    reg cs_n;
    reg sclk_r;
    reg sdo_r;
    reg done_r;
    reg [SPI_DIN_WIDTH - 1 : 0] spi_din_r;
    reg [SPI_DOUT_WIDTH - 1 : 0] spi_dout_r;
    reg mlb_r;
    reg busy_r;

    assign cs_n_o  = cs_n;
    assign sclk_o  = sclk_r;
    assign sdo_o   = sdo_r;
    assign done_o  = done_r;
    assign busy_o  = busy_r;
    assign spi_din = spi_din_r;

    reg [2:0] state;
    localparam [3:0]
    IDLE       = 3'd0,
    SEND_START = 3'd1,
    DOUT       = 3'd2,
    SHIFT      = 3'd3,
    DONE       = 3'd4;

    wire read_process_en;
    reg [4:0] send_cnt;
    reg [11:0] clk_div_cnt;
    always @(posedge sys_clk or negedge reset_n)
    begin
        if(~reset_n) begin
            cs_n <= 1'b1;
            sclk_r <= 1'b1;
            sdo_r <= 1'b0;
            done_r <= 1'b0;
            spi_dout_r <= {SPI_DOUT_WIDTH{1'b0}};
            send_cnt <= 5'b0;
            clk_div_cnt <= 12'b0;
            mlb_r <= 1'b0;
            done_r <= 1'b0;
            busy_r <= 1'b0;
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    done_r <= 1'b0;
                    if(start_i) begin
                        state <= SEND_START;
                        cs_n <= 1'b0;
                        sclk_r <= 1'b0;
                        spi_dout_r <= spi_dout;
                        mlb_r <= mlb_i;
                        busy_r <= 1'b1;
                        sdo_r <= mlb_i ? spi_dout[SPI_DOUT_WIDTH - 1] : spi_dout[0];
                    end
                end
                SEND_START: begin
                    if(clk_div_cnt == spi_clk_div2) begin
                        clk_div_cnt <= 12'b0;
                        state <= DOUT;
                        sclk_r <= 1'b1;

                    end
                    else begin
                        clk_div_cnt <= clk_div_cnt + 1'b1;
                        state <= SEND_START;
                    end
                end
                DOUT: begin
                    if(clk_div_cnt < spi_clk_div2) begin
                        clk_div_cnt <= clk_div_cnt + 1'b1;
                        state <= DOUT;
                    end
                    else if(send_cnt == 15) begin
                        state <= DONE;
                        clk_div_cnt <= 12'b0;
                        sclk_r <= 1'b1;
                    end
                    else begin
                        clk_div_cnt <= 12'b0;
                        state <= SHIFT;
                        sclk_r <= 1'b0;
                        spi_dout_r <= mlb_r ?
                                      {spi_dout_r[SPI_DOUT_WIDTH - 2 : 0], 1'b1}
                                      :{1'b1, spi_dout_r[SPI_DOUT_WIDTH - 1:1]};
                        send_cnt <= send_cnt + 1'b1;
                    end
                end
                SHIFT: begin
                    sdo_r <= mlb_r ? spi_dout_r[SPI_DOUT_WIDTH - 1] : spi_dout_r[0];
                    if(clk_div_cnt == spi_clk_div2) begin
                        state <= DOUT;
                        clk_div_cnt <= 12'b0;
                        sclk_r <= 1'b1;
                    end
                    else begin
                        clk_div_cnt <= clk_div_cnt + 1'b1;
                        state <= SHIFT;
                    end
                end
                DONE: begin
                    if(clk_div_cnt == spi_clk_div2) begin
                        cs_n <= 1'b1;
                        clk_div_cnt <= 1'b0;
                        send_cnt <= 5'b0;
                        busy_r <= 1'b0;
                        done_r <= 1'b1;
                        state <= IDLE;
                    end
                    else begin
                        state <= DONE;
                        clk_div_cnt <= clk_div_cnt + 1'b1;
                    end
                end
            endcase
        end
    end

    assign read_process_en = send_cnt >= 5'd8;

    always @ (posedge sclk_r or negedge reset_n) begin
        if(~reset_n) begin
            spi_din_r <= {SPI_DIN_WIDTH{1'b0}};
        end
        else if(read_process_en && rw_i) begin
            spi_din_r <= mlb_r ?
                         {spi_din_r[SPI_DIN_WIDTH - 2 : 0], sdi_i}
                         : {sdi_i, spi_din_r[SPI_DIN_WIDTH -1 : 1]};
        end
    end
endmodule
