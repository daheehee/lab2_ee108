`timescale 1ns/1ps
module shifter_tb ();
    reg [4:0] in;
    reg [2:0] dist;
    reg direction;
    wire [4:0] out;
    reg [4:0] out_expected;
    
    shifter dut (.in(in), .dist(dist), .direction(direction), .out(out));

initial begin

in = 5'b00001;
dist = 3'b010;
direction = 1'b0;
out_expected = 5'b00100;
#5
$display("%b, expected %b", out, out_expected);

in = 5'b10000;
dist = 3'b010;
direction = 1'b1;
out_expected = 5'b00100;
#5
$display("%b, expected %b", out, out_expected);


in = 5'b11111;
dist = 3'b010;
direction = 1'b0;
out_expected = 5'b11100;
#5
$display("%b, expected %b", out, out_expected);


in = 5'b11111;
dist = 3'b100;
direction = 1'b0;
out_expected = 5'b10000;
#5
$display("%b, expected %b", out, out_expected);


in = 5'b11111;
dist = 3'b100;
direction = 1'b1;
out_expected = 5'b00001;
#5
$display("%b, expected %b", out, out_expected);

$stop; 
end
endmodule