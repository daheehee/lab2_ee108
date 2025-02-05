module blinker (
    input wire clk,
    input wire rst,
    input wire switch,
    output reg out
);

//define states
`define STATE_OFF    2'd0
`define STATE_ON    2'd1


reg [1:0] next_state;
wire [1:0] state;
dffr #(.WIDTH(2)) state_reg( .clk (clk), .r (rst), .d (next_state), .q (state)
);


always @(*) begin
    //if the rst is hit, output should go to 0
    if (rst) begin
        next_state = `STATE_OFF;
    end 
    //while rst is 0
    else begin
        //check if switch goes high
        if (switch) begin
            next_state = ~state;
        end
        //if switch is 0
        else begin
            next_state = state;
        end
    end
    //we're going to set next_state to rst or vice versa, not sure, and then
    //we need to determine what rst is
   out = state;
    
end


endmodule