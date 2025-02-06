module beat32 (
    input wire clk,
    input wire rst,
    output reg count_en
);

wire [21:0] load = 22'd3215000;
//wire [4:0] load = 5'd11111;

reg [21:0] next_val;
wire [21:0] val; 
dffr #(.WIDTH(22)) current_val(
.clk (clk), .r (rst), .d (next_val), .q (val)
);

always @(*) begin
    
    case (rst)
        1'b1: begin
            next_val = 0;
            count_en = 1'b0;
        end 
        1'b0: begin
            if (val == 5'b0) begin
                count_en = 1'b1;
                next_val = load ;
            end 
            else begin
                count_en = 1'b0;
                next_val = val - 1'b1 ;

            end
       end
     endcase

end
endmodule
