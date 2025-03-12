`timescale 1ns / 1ps

module adsr_envelope_generator(
    input clk,
    input rst,
    input enable,
    input load_new_note,
    input beat,
    input [5:0] t_a,
    input [5:0] t_d,
    input [5:0] t_s,
    input [5:0] t_r,
    
    output [15:0] envelope,
    output reg done
);

    // State machine
    `define INITIAL     3'd0
    `define ATTACK      3'd1
    `define DECAY       3'd2
    `define SUSTAIN     3'd3
    `define RELEASE     3'd4
    
    // State register
    reg [2:0] next_state;
    wire [2:0] state;
    dffr #(.WIDTH(3)) state_reg(.clk(clk), .r(reset), .d(next_state), .q(state));
    
    // Amplitude register
    reg signed [15:0] next_amplitude;
    wire [15:0] amplitude;
    dffre #(.WIDTH(16)) amplitude_reg(.clk(clk), .r(reset), .en(beat), .d(next_amplitude), .q(amplitude));
    
    // Max and min amplitudes
    wire [15:0] MAX, MID, MIN;
    assign MAX = 16'b1111111111111111;
    assign MID = 16'b1000000000000000;
    assign MIN = 16'b0;
    
    
    // A helpful counter
    reg [5:0] next_count;
    wire [5:0] count;
    dffr #(.WIDTH(6)) counter(.clk(clk), .r(reset), .d(next_count), .q(count));
    
    // Calculate gradients for linear steps
    wire [15:0] step_a, step_d, step_r;
    assign step_a = MAX/t_a;
    assign step_d = MAX/t_d;
    assign step_r = MAX/t_r;
    
    always @ (*) begin
        case(state)
            `INITIAL: begin
                done = 0;
                next_amplitude = 0;
                next_count = 0;
                next_state = enable ? `ATTACK : `INITIAL;
            end
            `ATTACK: begin
                done = 0;
                next_amplitude = ((amplitude + step_a) < MAX) ? amplitude + step_a : amplitude;
                next_count = 0;
                next_state = ((amplitude + step_a)< MAX) ? `ATTACK : `DECAY;
            end
            `DECAY: begin   
                done = 0;
                next_amplitude = ((amplitude - step_d) > MID) ? amplitude - step_d : amplitude;
                next_count = 0;
                next_state = ((amplitude - step_d) > MID) ? `DECAY : `SUSTAIN;
            end
            `SUSTAIN: begin
                done = 0;
                next_amplitude = MID;
                next_count = count + 6'd1;
                next_state = (count < t_s) ? `SUSTAIN : `RELEASE;
            end
            `RELEASE: begin
                done = 1;
                next_amplitude = ((amplitude - step_r) > MIN) ? amplitude - step_r : amplitude;
                next_count = 0;
                next_state = ((amplitude - step_r) > MIN) ? `RELEASE : `INITIAL;
            end
            default: begin
                done = 0;
                next_amplitude = 0;
                next_count = 0;
                next_state = `INITIAL;
            end
        endcase
    end
    
    assign envelope = amplitude;
   
endmodule
