module timer #(parameter TIMER = 1)(
    input wire clk,
    input wire [3:0] load_val,
    input wire rst,
    input wire count_en,
    output wire done
);

reg [8:0] next_count;
wire [8:0] count; 

dffre #(.WIDTH(9)) current_val(
.clk (clk), .r (rst), .en(count_en), .d (next_count), .q (count)
);

reg before_done;
one_pulse pulse(.clk(clk), .reset(rst), .in(before_done), .out(done));

wire [8:0] period1;
wire [8:0] period2;

assign period1 = {load_val, 5'b00000};
assign period2 = {3'b000, load_val, 2'b00};


always @(*) begin
             
    if (rst == 1) begin
        next_count = 9'd1;
        before_done = 1'b0;
    end
    
    else begin
        if (count == 9'd1) begin
            if (TIMER == 1) begin
            next_count = period1;
            end
            else begin 
            next_count = period2;
            end
            before_done = 1'b1;
        end
        else if (count > 9'd1) begin
            next_count = count - 1'd1; 
            before_done = 1'b0;
        end 
        else begin
            next_count = 9'd1; 
            before_done = 1'b0;
        end
        
    end
    end
endmodule
