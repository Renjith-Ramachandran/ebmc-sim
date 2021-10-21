`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2021 22:55:09
// Design Name: 
// Module Name: Lock_tb
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


module Lock_tb();

    reg [3:0]key;
    reg pressed = 0;
    reg set_code =0;
    reg clk = 0;
    
    
    wire unlocked;
    Lock myLock(unlocked, key, pressed, set_code, clk);
    
    always #5 clk = ~clk;
    initial begin
        #10
        set_code = 1;
        #10
        set_code = 0;
        #10
        pressed = 1;
        key = 4'b1111;
        #10
        key = 4'b1000;
        #10
        key = 4'b1001;
        #10
        key = 4'b1010;
        #10
        pressed = 0;
        #250
        pressed = 1;
        key = 4'b1111;
        #10
        key = 4'b1000;
        #10
        key = 4'b1001;
        #10
        key = 4'b1010;
        #10
        pressed = 0;
        #180
        pressed = 1;
        #10
        pressed = 0;
        #500
        
        $finish;
    end

endmodule