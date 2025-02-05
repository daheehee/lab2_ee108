module programmable_blinker #(
    parameter n = 1) (
    
    input wire clk,
    input wire rst,
    input wire shift_left,
    input wire shift_right,
    input wire count_en,
    output wire switch
    
);

    wire [3:0] shift_out_to_timer;
    
    //wire count_en;
    
    //beat32 beat(.clk (clk), .rst(rst), .count_en(count_en));
    shifter pb_s (
         .clk(clk), 
         .rst(rst), 
         .shift_left(shift_left), 
         .shift_right(shift_right), 
         .out(shift_out_to_timer)
    );

    wire switch_timer_1;
    wire switch_timer_2;
    
    //Flash 1, slower timer
    timer #(.TIMER(1)) pb_t_1 (
        .clk(clk),  
        .load_val(shift_out_to_timer), 
        .rst(rst), 
        .count_en(count_en),
        .done(switch_timer_1)
    );

    //Flash 2, faster timer
    timer #(.TIMER(2)) pb_t_2 (
        .clk(clk),  
        .load_val(shift_out_to_timer), 
        .rst(rst), 
        .count_en(count_en),
        .done(switch_timer_2)
    );

    
    assign switch = (n == 1) ? switch_timer_1 : switch_timer_2;
//    always @(*) begin
//        //check to see if flash is 1
//        if (n==1) begin
//            switch = switch_timer_1;
//        end
//        //if flash is 2
//        else begin
//            switch = switch_timer_2;
//        end
//    end
    
//    blinker pb_b (
//        .clk(clk),
//        .rst(rst),
//        .switch(switch),
//        .out(out)
//    );
        //assign out = 1'd0;
    

endmodule