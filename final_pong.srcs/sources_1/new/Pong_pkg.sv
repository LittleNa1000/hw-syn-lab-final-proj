`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2023 11:14:00 PM
// Design Name: 
// Module Name: Pong_pkg
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


package Pong_Pkg;

  //-----------------------------------------------------------------------------
  // Constants
  //-----------------------------------------------------------------------------

  // Set the Width and Height of the Game Board
  parameter c_Game_Width    = 40;
  parameter c_Game_Height   = 30;

  // Set the number of points to play to
  parameter c_Score_Limit   = 9;

  // Set the Height (in board game units) of the paddle.
  parameter c_Paddle_Height = 6;

  // Set the Speed of the paddle movement. In this case, the paddle will move
  // one board game unit every 50 milliseconds that the button is held down.
  parameter c_Paddle_Speed  = 1250000;

  // Set the Speed of the ball movement. In this case, the ball will move
  // one board game unit every 50 milliseconds that the button is held down.
  parameter c_Ball_Speed    = 1250000;

  // Sets Column index to draw Player 1 & Player 2 Paddles.
  parameter c_Paddle_Col_Location_P1 = 0;
  parameter c_Paddle_Col_Location_P2 = c_Game_Width-1;

  //-----------------------------------------------------------------------------
  // Component Declarations
  //-----------------------------------------------------------------------------
  module Pong_Paddle_Ctrl #(parameter g_Player_Paddle_X);

    input         i_Clk;
    input  [5:0]  i_Col_Count_Div;
    input  [5:0]  i_Row_Count_Div;
    input         i_Paddle_Up;
    input         i_Paddle_Dn;
    output        o_Draw_Paddle;
    output [5:0]  o_Paddle_Y;

  endmodule

  module Pong_Ball_Ctrl;

    input         i_Clk;
    input         i_Game_Active;
    input  [5:0]  i_Col_Count_Div;
    input  [5:0]  i_Row_Count_Div;
    output        o_Draw_Ball;
    output [5:0]  o_Ball_X;
    output [5:0]  o_Ball_Y;

  endmodule

endpackage
