// Bicycle Light FSM
//
// This module determines how the light functions in the given state and what
// the next state is for the given state.
// 
// It is a structural module: it just instantiates other modules and hooks
// up the wires between them correctly.

/* For this lab, you need to implement the finite state machine following the
 * specifications in the lab hand-out */

module bicycle_fsm(
    input clk, 
    input faster, 
    input slower, 
    input next, 
    input reset, 
    output reg rear_light
);

    // Instantiations of master_fsm, beat32, fast_blinker, slow_blinker here

    //get output
    wire f1_shift_left;
    wire f1_shift_right;
    wire f2_shift_left;
    wire f2_shift_right;
    
    wire [5:0] state;
    
//    wire up_button;
//    wire down_button;
    
//    button_press_unit fast_up(
//        .clk(clk),
//        .reset(reset),
//        .in(faster),
//        .out(up_button)
//    );
    
//    button_press_unit slow_down(
//        .clk(clk),
//        .reset(reset),
//        .in(slower),
//        .out(down_button)
//    );
    
    master_fsm bicycle_m (
         .clk(clk), 
         .reset(reset), 
         .next(next),
         .up_button(faster),
         .down_button(slower),
         .state(state),
         .f1_shift_left(f1_shift_left),
         .f1_shift_right(f1_shift_right),
         .f2_shift_left(f2_shift_left),
         .f2_shift_right(f2_shift_right)
    );
    
    wire beat;
    beat32 bicycle_b (
        .clk(clk),
        .rst(reset),
        .count_en(beat)
    );
   
    wire out1,out2;  
    programmable_blinker #(1) bicycle_b_1 (
        .clk(clk),
        .rst(reset),
        .shift_left(f1_shift_left),
        .shift_right(f1_shift_right),
        .count_en(beat),
        .out(out1)
    );
    
     programmable_blinker #(2) bicycle_b_2 (
        .clk(clk),
        .rst(reset),
        .shift_left(f2_shift_left),
        .shift_right(f2_shift_right),
        .count_en(beat),
        .out(out2)
    );
    
    
    
    //the output from Master FSM
    
    
    always @(*) begin
        if (reset) begin
            rear_light = 1'b0;
        end 
        else begin
        case (state)
            6'b000001:  rear_light = 1'b0;  // false
            6'b000010:  rear_light = 1'b1;  // true
            6'b000100:  rear_light = 1'b0; // out1
            6'b001000:  rear_light = out1; // out2
            6'b010000:  rear_light = 1'b0; // out1
            6'b100000:  rear_light = out2; // out2
            default:  rear_light = 1'b0; // Default case: OFF
        endcase
        end
        
    end

    


endmodule
