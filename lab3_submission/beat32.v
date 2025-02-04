module beat32 (
    input wire clk,
    input wire rst,
    output reg count_en
);

`define STATE_BEGIN   2'd0
`define STATE_COUNTING    2'd1
`define STATE_DONE    2'd2



wire [4:0] load = 5'b11111;


reg [1:0] next_state;
wire [1:0] state;
dffr #(.WIDTH(2)) current_state( .clk (clk), .r (rst), 
.d (next_state), .q (state)
);

reg [4:0] next_val;
wire [4:0] val; 
dffr #(.WIDTH(5)) current_val(
.clk (clk), .r (rst), .d (next_val), .q (val)
);

always @(*) begin
    if (rst == 0) begin
    case (state)
        `STATE_BEGIN: begin
        count_en = 1'b1;
            next_val = load;
            next_state = `STATE_COUNTING;
        end    
        `STATE_COUNTING: begin
            next_val = val - 1'd1;
            next_state = (val == 5'd2) ? `STATE_DONE : `STATE_COUNTING;
        end
        `STATE_DONE: begin
            next_val = 5'd0;
            next_state = `STATE_BEGIN;
        end
        default: begin
            next_state= `STATE_BEGIN;
            next_val = 5'd0;
        end
    endcase 
        if (val == 5'b00) begin
        count_en = 1'b1;
        end
        else begin
        count_en = 1'b0;
        end
    end
end 

endmodule
