module master_fsm ( 
    input wire clk, reset, next, up_button, down_button,
    output wire [5:0] state,
    output reg f1_shift_left, f1_shift_right, f2_shift_left, f2_shift_right
);

`define STATE_OFF1  6'b000001
`define STATE_ON    6'b000010
`define STATE_OFF2  6'b000100
`define STATE_F1    6'b001000
`define STATE_OFF3  6'b010000
`define STATE_F2    6'b100000


reg [5:0] next_state;
dffre #(.WIDTH(6)) state_reg(.clk(clk), .r(reset), .en(next), .d(next_state), .q(state)); 

//reg f1_left_next;
//dff #(.WIDTH(1)) f1_left_reg(.clk(clk), .d(f1_left_next), .q(f1_shift_left));

//reg f1_right_next;
//dff #(.WIDTH(1)) f1_right_reg(.clk(clk), .d(f1_right_next), .q(f1_shift_right));

//reg f2_left_next;
//reg f3_left_next;
//dff #(.WIDTH(1)) f2_left_reg(.clk(clk), .d(f2_left_next), .q(f2_shift_left));

//reg f2_right_next;
//dff #(.WIDTH(1)) f2_right_reg(.clk(clk), .d(f2_right_next), .q(f2_shift_right));


always @(*) begin
    if (reset == 1) begin
    next_state = `STATE_OFF1;
        f1_shift_left = 0;
                f2_shift_right = 0;
                f2_shift_left = 0;
                f2_shift_right = 0;
    end
    else begin
        case(state) // OFF > ON > OFF > FLASH 1 > OFF > FLASH 2
            `STATE_OFF1: begin
                if (next == 1) begin // OFF #1 again, restart cycle but remember F1 and F2 speeds
                    next_state = `STATE_ON;
                end
                else begin // resets to here
                    next_state = `STATE_OFF1; // pass time until next cycle
                end
                f1_shift_left = 0; 
                f1_shift_right = 0;
                f2_shift_left = 0; 
                f2_shift_right = 0;
            end
            `STATE_ON: begin
                if (next == 1) begin
                    next_state = `STATE_OFF2;
                end 
                else begin
                    next_state = `STATE_ON;
                end
                f1_shift_left = 0; 
                f1_shift_right = 0;
                f2_shift_left = 0; 
                f2_shift_right = 0;
            end
            
            `STATE_OFF2: begin
                if (next == 1) begin // OFF #1 again, restart cycle but remember F1 and F2 speeds
                    next_state = `STATE_F1;
                end
                else begin // resets to here
                    next_state = `STATE_OFF2; // pass time until next cycle
                end
                f1_shift_left = 0; 
                f1_shift_right = 0;
                f2_shift_left = 0; 
                f2_shift_right = 0;
             end
                
            `STATE_F1: begin
                if (next == 1) begin
                    next_state = `STATE_OFF3;
                end
                else begin
                    next_state = `STATE_F1;
                end
                f1_shift_left = down_button; 
                    f1_shift_right = up_button;
                    f2_shift_left = 0; 
                    f2_shift_right = 0;
            end
            
            `STATE_OFF3: begin
                if (next == 1) begin // OFF #1 again, restart cycle but remember F1 and F2 speeds
                    next_state = `STATE_F2;
                end
                else begin // resets to here
                    next_state = `STATE_OFF3; // pass time until next cycle
                end
                f1_shift_left = 0; 
                f1_shift_right = 0;
                f2_shift_left = 0; 
                f2_shift_right = 0;
             end
             
            `STATE_F2: begin
                if (next == 1) begin
                    next_state = `STATE_OFF1;
                end
                else begin
                    next_state = `STATE_F2;
                end
                f2_shift_left = down_button; 
                        f2_shift_right = up_button;
                        f1_shift_left = 0;
                        f1_shift_right = 0;
            end
            default: begin
                next_state = `STATE_OFF1;
                f1_shift_left = 0;
                f1_shift_right = 0;
                f2_shift_left = 0;
                f2_shift_right = 0;
            end
        endcase
    end
end

endmodule