module programmable_blinker #(
    parameter n = 1) (
    
    input wire clk,
    input wire rst,
    input wire shift_left,
    input wire shift_right,
    input wire count_en,
    output wire out
    
);

    wire [3:0] shift_out_to_timer;
    
    //wire count_en;
    
    //beat32 beat(.clk (clk), .rst(rst), .count_en(count_en));
    
    shifter #(.TIMER(n)) pb_s (
         .clk(clk), 
         .rst(rst), 
         .shift_left(shift_left), 
         .shift_right(shift_right), 
         .out(shift_out_to_timer)
    );

    wire switch;
    
    //Flash 1, slower timer
    timer #(.TIMER(n)) pb_t_1 (
        .clk(clk),  
        .load_val(shift_out_to_timer), 
        .rst(rst), 
        .count_en(count_en),
        //.done(switch_timer_1)
        .done(switch)
    );

    
    //assign switch = (n == 1) ? switch_timer_1 : switch_timer_2;
    
    blinker pb_b (
        .clk(clk),
        .rst(rst),
        .switch(switch),
        .out(out)
    );
    
    

endmodule