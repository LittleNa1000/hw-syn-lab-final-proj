`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2023 11:23:26 PM
// Design Name: 
// Module Name: uart
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


module uart(
    input clk,
    input RsRx,
    output RsTx,
    output wire [7:0] data_out,
    output wire received,
    output reg [1:0] press,
    output reg [1:0] press_2
//    output reg last_rec
    );
    
    reg en, last_rec;
//    reg en;
    reg [7:0] data_in;
//    wire [7:0] data_out;
    wire sent,  baud;
    
    baudrate_gen baudrate_gen(clk, baud);
    uart_rx receiver(baud, RsRx, received, data_out);
    uart_tx transmitter(baud, data_in, en, sent, RsTx);
    
//    integer counter;
    always @(posedge baud) begin
        if (en) en = 0;
//        if ((press == 2'b01 || press == 2'b10)) counter = counter + 1; else counter = 0;
//        if ((counter >= 24000) && (press == 2'b01 || press == 2'b10)) begin counter = 0; press = 2'b11; end
//        if (counter % 24000 == 0) begin press[1] = ~press[1]; end
        if (~last_rec & received) begin
            data_in = data_out;
            case (data_out)
                8'h77: press = 2'b01;
                8'h73: press = 2'b10;
//                default: press = 2'b00;
            endcase
            case (data_out)
                8'h69: press_2 = 2'b01;
                8'h6B: press_2 = 2'b10;
//                default: press_2 = 2'b00;
            endcase
            if (data_in <= 8'h7A && data_in >= 8'h41) en = 1;
        end   
        last_rec = received;
    end
    
endmodule
