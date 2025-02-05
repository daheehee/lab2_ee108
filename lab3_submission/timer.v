module timer #(parameter TIMER = 1)(
    input wire clk,
    input wire [3:0] load_val,
    input wire rst,
    input wire count_en,
    output reg done
);

`define STATE_BEGIN   2'd0
`define STATE_COUNTING    2'd1
`define STATE_DONE    2'd2

//wire count_en;

//reg [1:0] next_state;
//wire [1:0] state;
//dffre #(.WIDTH(2)) current_state( .clk (clk), .r (rst), .en(count_en),
//.d (next_state), .q (state)
//);

reg [8:0] next_count;
wire [8:0] count; 

dffre #(.WIDTH(9)) current_val(
.clk (clk), .r (rst), .en(count_en), .d (next_count), .q (count)
);


//beat32 beat(.clk (clk), .rst(rst), .count_en(count_en));

wire [8:0] period1;
wire [8:0] period2;

assign period1 = {load_val, 5'b00000};
assign period2 = {3'b000, load_val, 2'b00};
//wire [8:0] test = 9'b0000_00100;


always @(*) begin
             
    if (rst == 1) begin
//    case (state)
        next_count = 9'd0;
    end
    
    else begin
        if (next_count == 9'd0) begin
            if (TIMER == 1) begin
            next_count = period1;
            end
            else begin 
            next_count = period2;
            done = 1'b1;
            end
        end
        else begin
            next_count = count - 1'd1;
            done = 1'b0;
        end
        
//        `STATE_BEGIN: begin
//            if (TIMER == 1) begin
//            next_count = period1;
//            end
//            else begin 
//            next_count = period2;
//            end
//            next_state = (next_count == 9'b00000_0001) ? `STATE_DONE: `STATE_COUNTING;
//        end    
//        `STATE_COUNTING: begin
//            next_count = count - 1'd1;
//            next_state = (count == 9'b00000_010) ? `STATE_DONE : `STATE_COUNTING;
//        end
//        `STATE_DONE: begin
//            next_count = 9'd0;
//            next_state = `STATE_BEGIN;
//        end
//        default: begin
//            next_count = test;
//            next_state = (next_count == 9'b00000_0001) ? `STATE_DONE: `STATE_COUNTING;
//        end 
//    endcase 
//            if (count == 9'b0) begin
//                done = 1'b1;
//            end
//            else begin 
//                done = 1'b0;
//            end
//            end
    end
    end
endmodule
