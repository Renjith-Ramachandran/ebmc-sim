`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/18 13:43:33
// Design Name: 
// Module Name: shift_register_tb
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
module KeyPad (
    output reg[15 : 0] last4,
    input[3 : 0] key,
    input pressed,
    input clk
);
    initial begin
        last4 = 0;
    end
    
    always @ (posedge clk) begin    
        // last4 <= (last4 % 1000) * 10 + key;
        if (pressed) begin
            last4[15 : 4] <= last4[11 : 0];
            last4[3 : 0] <= key;
        end 
    end
    
endmodule


///////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////

module Control(output reg unlocked,
    input pressed,
    input[15:0] last4,
    input set_code,
    input clk);
    
    localparam S_TO_SET = 2'b00;
    localparam S_SET_LATENCY = 2'b01;
    localparam S_LOCKED = 2'b11;
    localparam S_UNLOCKED = 2'b10;
    
    // For holding the code
    reg [15:0] secretCode;
    
    // For state machine
    reg [1:0] cur_state;
    reg [1:0] next_state;
    
    // Counters for delaying state transistion
    reg [3:0] hold_lock_ctr;
    reg [7:0] set_latency_ctr;
    reg [8:0] hold_unlock_ctr;
    reg [3:0] set_code_latency = 4'h0;
    
    /*
     * MUST NOT check the input passcode every cycle. Check it only when input changes.
     * Can't check when press==1, either. Because it has one cycle latency.
     */
    // State transition signal
    reg code_correct; // Used to pass status between two always blocks
    
    initial begin
        cur_state = S_TO_SET;
        unlocked = 0;
    end
    
    // State transition
    always @ (posedge clk) begin
        cur_state <= next_state;
    end
    
    // Next state calc logic
    always @ (cur_state, set_latency_ctr, hold_lock_ctr, code_correct, hold_unlock_ctr, pressed, set_code,set_code_latency) begin
        next_state = cur_state;
        case (cur_state)
            S_TO_SET:
                if (set_code_latency == 4'hF) begin
                    next_state = S_SET_LATENCY;
                end
            S_SET_LATENCY:
                if (set_latency_ctr == 8'hFF)
                    next_state = S_LOCKED;
            S_LOCKED:
                if (hold_lock_ctr == 4'hF && code_correct == 1)
                    next_state = S_UNLOCKED;
            S_UNLOCKED:
                if (pressed || hold_unlock_ctr == 9'h1FF)
                    next_state = S_LOCKED;
        endcase
    end
    
    // Behavior of each state
    always @ (posedge clk) begin
        case (cur_state)
            S_TO_SET: begin
                if (set_code_latency != 4'hF && pressed == 1'b1) begin
                    set_code_latency[3:1] <= set_code_latency[2:0];
                    set_code_latency[0] <= 1'b1;  
                    if (set_code_latency == 4'hF)
                        set_latency_ctr <= 8'h00;   // Initialize                
                end
                else if (set_code_latency == 4'hF) begin
                    secretCode <= last4;
                end
            end
            S_SET_LATENCY: begin
                set_latency_ctr[7:1] <= set_latency_ctr[6:0];
                set_latency_ctr[0] <= 1;
                hold_lock_ctr <= 4'h0;         // Initialize
            end
            S_LOCKED: begin
                unlocked <= 1'b0;
                if (hold_lock_ctr != 4'hF) begin
                    hold_lock_ctr[3:1] <= hold_lock_ctr[2:0];
                    hold_lock_ctr[0] <= 1'b1;
                end
                hold_unlock_ctr <= 10'h000;     // Initialize
            end
            S_UNLOCKED: begin
                unlocked <= 1'b1;
                if (hold_unlock_ctr != 9'h1FF) begin
                    hold_unlock_ctr[8:1] <= hold_unlock_ctr[7:0];
                    hold_unlock_ctr[0] <= 1'b1;
                end
                hold_lock_ctr <= 4'h0;          // Initialize
            end
            default: begin
                // Initialize
                set_latency_ctr <= 8'h00;
                hold_lock_ctr <= 4'h0;
                hold_unlock_ctr <= 9'h000;
                set_code_latency = 4'h0;
            end
        endcase
    end
    
    // Combinitional logic for setting code_correct. We want quick reaction on this
    always @ (last4) begin
        if (cur_state == S_LOCKED && last4 == secretCode) begin
            code_correct = 1'b1;
        end else begin
            code_correct = 1'b0;
        end
    end

endmodule

///////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////


module Lock(output wire unlocked, 
            input[3:0]key, 
            input pressed,
            input set_code,
            input clk);

    wire[15:0] last4;
    
    KeyPad keypad(last4, key, pressed, clk);
    Control control(unlocked, pressed, last4, set_code, clk);
    
endmodule





