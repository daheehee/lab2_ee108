module shifter (
    input wire clk,
    input wire rst,
    input wire shift_left,
    input wire shift_right,
    output reg [3:0] out
);

`define STATE_BEGIN         2'b00
`define STATE_SHIFT_LEFT    2'b01
`define STATE_SHIFT_RIGHT   2'b10
`define STATE_DONE          2'b11

reg [1:0] next_state;
wire [1:0] state;
dffr #(.WIDTH(2)) state_reg(.clk(clk), .r(rst), .d(next_state), .q(state)); // state register

reg [3:0] next_blink_rate;
wire [3:0] blink_rate;
dffr #(.WIDTH(4)) value_reg(.clk(clk), .r(rst), .d(next_blink_rate), .q(blink_rate)); // value register

initial begin
    next_blink_rate = 4'b0001;
end

// Implement state machine
always @(*) begin
    next_state = `STATE_BEGIN;
    if (rst == 1) begin
        next_blink_rate = 4'b0001;
    end
    else if (rst == 0) begin
        case (state)
            `STATE_BEGIN: begin
                if (shift_left == 0 && shift_right == 0) begin
                    next_state = `STATE_DONE; 
                end
                else if (shift_left == 1 && shift_right == 0) begin
                    next_state = `STATE_SHIFT_LEFT;
                end
                else if (shift_right == 1 && shift_left == 0) begin
                    next_state =  `STATE_SHIFT_RIGHT;
                end
                else begin
                    next_state = `STATE_DONE; // don't do anything if both buttons are pressed at the same time
                end
            end
            `STATE_SHIFT_RIGHT: begin
                next_blink_rate = ((blink_rate >> 4'b1) < 4'b001) ? 4'b100 : (blink_rate >> 4'b1);
                next_state = `STATE_DONE;
            end
            `STATE_SHIFT_LEFT: begin
                next_blink_rate = ((blink_rate << 4'b1) > 4'b100) ? 4'b001 : (blink_rate << 4'b1);
                next_state = `STATE_DONE;
            end
            `STATE_DONE: begin
                out = next_blink_rate;
                next_state = `STATE_DONE;
            end
        endcase
    end
end

endmodule
