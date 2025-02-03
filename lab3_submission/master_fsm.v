module master_fsm ( 
    input wire clk, reset, next, up_button, down_button,
    output wire [3:0] state,
    output wire f1_shift_left, f1_shift_right, f2_shift_left, f2_shift_right
);

`define STATE_OFF   4'b0001
`define STATE_ON    4'b0010
`define STATE_F1    4'b0100
`define STATE_F2    4'b1000

reg [3:0] next_state;
dffre #(.WIDTH(4)) state_reg(.clk(clk), .r(reset), .en(next), .d(next_state), .q(state)); 

reg f1_left_next;
dffr #(.WIDTH(1)) f1_left_reg(.clk(clk), .r(reset), .d(f1_left_next), .q(f1_shift_left));

reg f1_right_next;
dffr #(.WIDTH(1)) f1_right_reg(.clk(clk), .r(reset), .d(f1_right_next), .q(f1_shift_right));

reg f2_left_next;
dffr #(.WIDTH(1)) f2_left_reg(.clk(clk), .r(reset), .d(f2_left_next), .q(f2_shift_left));

reg f2_right_next;
dffr #(.WIDTH(1)) f2_right_reg(.clk(clk), .r(reset), .d(f2_right_next), .q(f2_shift_right));

reg [3:0] prev_state;
initial begin
    next_state = `STATE_OFF;
    prev_state = `STATE_OFF;
    f1_left_next = 0;
    f1_right_next = 0;
    f2_left_next = 0;
    f2_right_next = 0;
end

always @(*) begin
    if (reset == 0) begin
        f1_left_next = 0;
        f1_right_next = 0;
        f2_left_next = 0;
        f2_right_next = 0;
        
        case(state) // OFF > ON > OFF > FLASH 1 > OFF > FLASH 2
            `STATE_OFF: begin
                if (next == 1 && prev_state == `STATE_OFF) begin // OFF #1
                    next_state = `STATE_ON;
                end
                else if (next == 1 && prev_state == `STATE_ON) begin // OFF #2
                    next_state = `STATE_F1;
                end
                else if (next == 1 && prev_state == `STATE_F1) begin // OFF #3
                    next_state = `STATE_F2;
                end
                else if (next == 1 && prev_state == `STATE_F2) begin // OFF #1 again, restart cycle but remember F1 and F2 speeds
                    next_state = `STATE_ON;
                end
                else begin // resets to here
                    next_state = `STATE_OFF; // pass time until next cycle
                end
            end
            `STATE_ON: begin
                prev_state = `STATE_ON;
                if (next == 1) begin
                    next_state = `STATE_OFF;
                end 
                else begin
                    next_state = `STATE_ON;
                end
            end
            `STATE_F1: begin
                prev_state = `STATE_F1;
                if (next == 1) begin
                    next_state = `STATE_OFF;
                end
                else begin
                    if (up_button == 1) begin
                        f1_right_next = 1;
                    end
                    else if (down_button == 1) begin
                        f1_left_next = 1;
                    end
                    next_state = `STATE_F1;
                end
            end
            `STATE_F2: begin
                prev_state = `STATE_F2;
                if (next == 1) begin
                    next_state = `STATE_OFF;
                end
                else begin
                    if (up_button == 1) begin
                        f2_right_next = 1;
                    end
                    else if (down_button == 1) begin
                        f2_left_next = 1;
                    end
                    next_state = `STATE_F2;
                end
            end
            default: begin
                next_state = `STATE_OFF;
            end
        endcase
    end
    else begin
        prev_state = `STATE_OFF;
        next_state = `STATE_OFF;
        f1_left_next = 0;
        f1_right_next = 0;
        f2_left_next = 0;
        f2_right_next = 0;
    end
end

endmodule
