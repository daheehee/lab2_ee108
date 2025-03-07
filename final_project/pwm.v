`timescale 1ns / 1ps

module pwm(
    input clk,
    input reset,
    input [7:0] duty_cycle, //50% D = 8'd128 (128/256=0.5); 25% D = 8'd64 (64/128=0.25)
    input play_enable,
    output reg out
    );

reg [7:0] next_count;
wire [7:0] count;
dffr #(.WIDTH(8)) counter(.clk(clk), .r(reset), .d(next_count), .q(count));

reg next_state;
wire state;
dffr #(.WIDTH(1)) state_reg(.clk(clk), .r(reset), .d(next_state), .q(state));

`define STATE_INITIAL       1'b0
`define STATE_OPERATING     1'b1

always @(*) begin
    case(state)
        `STATE_INITIAL: begin
            next_count = 8'b0;
            out = 0;
        end
        `STATE_OPERATING: begin
            next_count = count + 1;
            out = (count <= duty_cycle); // HIGH until Ton is over
        end
        default: begin
            next_count = 8'b0;
            out = 0;
        end
    endcase
    next_state = play_enable;
end
    
    
endmodule
