module shifter #(parameter TIMER = 1) (
    input wire clk,
    input wire rst,
    input wire shift_left,
    input wire shift_right,
    output reg [3:0] out
);

`define STATE_FIRST     4'b0001
`define STATE_SECOND    4'b0010
`define STATE_THIRD     4'b0100
`define STATE_FOURTH    4'b1000

reg [3:0] next_state;
wire [3:0] state;
dffr #(.WIDTH(4)) state_reg(.clk(clk), .r(rst), .d(next_state), .q(state)); // state register

//reg [3:0] next_blink_rate;
//wire [3:0] blink_rate;
//dffr #(.WIDTH(4)) value_reg(.clk(clk), .r(rst), .d(next_blink_rate), .q(blink_rate)); // value register

always @(*) begin
    if (rst == 1)begin
            if (TIMER == 1) begin
                next_state = 4'b0001;
            end
            else begin
                next_state = 4'b1000;
            end
            out = 4'b0;
    end
    else begin
    case (state)
        4'b0001: begin
            if (shift_left == 1 && shift_right == 0) begin
                next_state = 4'b0010;
            end
            else begin
                next_state = 4'b0001;
            end
            out = state;
            
            end
        4'b0010: begin
            if (shift_left == 1 && shift_right == 0) begin
                next_state = 4'b0100;
            end
            else if (shift_left == 0 && shift_right == 1) begin
               next_state = 4'b0001;
            end
            else begin
                next_state = 4'b0010;
            end
            out = state;
            end
         4'b0100: begin
            if (shift_left == 1 && shift_right == 0) begin
                next_state = 4'b1000;
            end
            else if (shift_left == 0 && shift_right == 1) begin
               next_state = 4'b0010;
            end
            else begin
                next_state = 4'b0100;
            end
            out = state;
            end
         4'b1000: begin
            if (shift_left == 0 && shift_right == 1) begin
               next_state = 4'b0100;
            end
            else begin
                next_state = 4'b1000;
            end
            out = state;
            end
         default: begin
            if (TIMER == 1) begin
                next_state = 4'b0001;
            end
            else begin
                next_state = 4'b1000;
            end
            out = state;
         end
     endcase
     end
end


// Implement state machine
//always @(*) begin
//    if (rst == 1) begin
//        if (TIMER == 2) begin
//        next_blink_rate = 4'b1000;
//        out = 4'b1000;
//        end
//        else begin
//        next_blink_rate = 4'b0001;
//        out = 4'b0001;
//        end 
//        next_state = `STATE_BEGIN;
        
//    end
//    else if (rst == 0) begin
//        case (state)
//            `STATE_BEGIN: begin
//                if (shift_left == 0 && shift_right == 0) begin
//                    next_state = `STATE_DONE; 
//                end
//                else if (shift_left == 1 && shift_right == 0) begin
//                    next_state = `STATE_SHIFT_LEFT;
//                end
//                else if (shift_left == 0 && shift_right == 1) begin
//                    next_state =  `STATE_SHIFT_RIGHT;
//                end
//                else begin
//                    next_state = `STATE_DONE; // don't do anything if both buttons are pressed at the same time
//                end
                
//                if (TIMER == 2) begin
//                next_blink_rate = 4'b1000;
//                out = 4'b1000;
//                end
//                else begin
//                next_blink_rate = 4'b0001;
//                out = 4'b0001;
//                end
//            end
//            `STATE_SHIFT_RIGHT: begin
//                next_blink_rate = (blink_rate == 4'b0001) ? 4'b0001 : (blink_rate >> 4'b1);
//                out = blink_rate; 
//                next_state = `STATE_DONE;
//            end
//            `STATE_SHIFT_LEFT: begin
//                next_blink_rate = (blink_rate == 4'b1000) ? 4'b1000 : (blink_rate << 4'b1);
//                out = blink_rate; 
//                next_state = `STATE_DONE;
//            end
//            `STATE_DONE: begin
//                next_blink_rate = blink_rate;
//                out = blink_rate;
//                next_state = `STATE_BEGIN;
//            end
//            default: begin
            
//                    if (TIMER == 2) begin
//                    next_blink_rate = 4'b1000;
//                    out = 4'b1000;
//                    end
//                    else begin
//                    next_blink_rate = 4'b0001;
//                    out = 4'b0001;
//                    end
                    
//                    next_state = `STATE_BEGIN;
//            end
//        endcase
//    end
//end

endmodule