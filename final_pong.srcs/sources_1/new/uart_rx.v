`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2023 11:23:26 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(
    input clk,
    input bit_in,
    output reg received,
    output reg [7:0] data_out
    );
    
    reg last_bit;
    reg receiving = 0;
    reg [7:0] count;
    
    always@(posedge clk) begin
        if (~receiving & last_bit & ~bit_in) begin
            receiving <= 1;
            received <= 0;
            count <= 0;
        end

        last_bit <= bit_in;
        count <= (receiving) ? count+1 : 0;
//        // Set data_out to 8'h00 if not receiving
//        if (~receiving) begin
//            data_out <= 8'h00;
//        end
        // sampling every 16 ticks
        case (count)
            8'd24:  data_out[0] <= bit_in;
            8'd40:  data_out[1] <= bit_in;
            8'd56:  data_out[2] <= bit_in;
            8'd72:  data_out[3] <= bit_in;
            8'd88:  data_out[4] <= bit_in;
            8'd104: data_out[5] <= bit_in;
            8'd120: data_out[6] <= bit_in;
            8'd136: data_out[7] <= bit_in;
            8'd152: begin received <= 1; receiving <= 0; end
        endcase
    end
endmodule
