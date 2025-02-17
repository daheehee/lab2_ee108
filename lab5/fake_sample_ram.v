/*
 * A simple fake RAM that you can use to aid in debugging your wave display.
 */
module fake_sample_ram (
    input clk,
    input [7:0] addr,
    output reg [7:0] dout
);

    wire [19:0] memory [3:0];
    
    always @(posedge clk)
        dout = memory[addr];
        
        assign memory [9'd 0] = 8'b10101010;
        assign memory [9'b110000001] = 8'b01010101;
        assign memory [9'b11000010] = 8'b01101101;

endmodule

