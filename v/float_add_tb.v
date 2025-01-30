`timescale 1ns/1ps
module float_add_tb (
);
    reg [7:0] aIn;
    reg [7:0] bIn;
    wire [7:0] result;
    reg [7:0] result_expect;
    float_add dut (.aIn(aIn), .bIn(bIn), .result(result));
    
initial begin

aIn = 8'b000_10000;
bIn = 8'b000_10000;
result_expect = 8'b001_10000;
#5
$display("%b, expected %b", result, result_expect);

aIn = 8'b001_10000;
bIn = 8'b001_10000;
result_expect = 8'b010_10000;
#5
$display("%b, expected %b", result, result_expect);


aIn = 8'b100_10000;
bIn = 8'b001_10000;
result_expect = 8'b100_10010;
#5
$display("%b, expected %b", result, result_expect);


aIn = 8'b111_11111;
bIn = 8'b111_11111;
result_expect = 8'b111_11111;
#5
$display("%b, expected %b", result, result_expect);


aIn = 8'b111_11110;
bIn = 8'b111_11110;
result_expect = 8'b111_11111;
#5
$display("%b, expected %b", result, result_expect);

aIn = 8'b100_10100;
bIn = 8'b011_10100;
result_expect = 8'b100_11110;
#5
$display("%b, expected %b", result, result_expect);


aIn = 8'b111_10000;
bIn = 8'b110_10000;
result_expect = 8'b111_11000;
#5
$display("%b, expected %b", result, result_expect);
  
  
aIn = 8'b111_10000;
bIn = 8'b111_10000;
result_expect = 8'b111_11111;
#5
$display("%b, expected %b", result, result_expect);
  


 $stop;
end 


endmodule