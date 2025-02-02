module timer (
    input wire clk,
    input wire [7:0] load_val,
    input wire rst,
    output reg done
);

`define STATE_BEGIN   2'd0
`define STATE_COUNTING    2'd1
`define STATE_DONE    2'd2

wire count_en;

reg [1:0] next_state;
wire [1:0] state;
dffre #(.WIDTH(2)) current_state( .clk (clk), .r (rst), .en(count_en),
.d (next_state), .q (state)
);

reg [7:0] next_count;
wire [7:0] count; 
dffr #(.WIDTH(8)) current_val(
.clk (clk), .r (rst), .d (next_count), .q (count)
);


beat32 beat(.clk (clk), .rst(rst), .count_en(count_en));

always @(*) begin
    next_state= `STATE_BEGIN;
    if (rst == 0) begin
    case (state)
        `STATE_BEGIN: begin
            next_count = load_val;
            next_state = (next_count == 8'b0000_00001) ? `STATE_DONE: `STATE_COUNTING;
        end    
        `STATE_COUNTING: begin
            next_count = count - 1'd1;
            next_state = (count == 8'b0000_0010) ? `STATE_DONE : `STATE_COUNTING;
        end
        `STATE_DONE: begin
            next_count = 8'd0;
            next_state = `STATE_BEGIN;
        end
    endcase 
            if (count == 8'b0) begin
                done = 1'b1;
            end
            else begin
                done = 1'b0;
            end
    end
    end
endmodule