`timescale 1ns/1ps
module adder_tb ();
    reg [4:0] a;
    reg [4:0] b;
    wire [4:0] sum;
    reg [5:0] sum_expect;
    wire cout;
    adder dut (.a(a), .b(b), .sum(sum), .cout(cout));

initial begin
a = 5'b10000;
b = 5'b01000;
sum_expect = 6'b011000;
#5
$display("%b, expected %b", {cout, sum}, sum_expect);

a = 5'b10000;
b = 5'b10000;
sum_expect = 6'b100000;
#5
$display("%b, expected %b", {cout, sum}, sum_expect);

a = 5'b11111;
b = 5'b11111;
sum_expect = 6'b111110;
#5
$display("%b, expected %b", {cout, sum}, sum_expect);

a = 5'b00001;
b = 5'b00001;
sum_expect = 6'b000010;
#5
$display("%b, expected %b", {cout, sum}, sum_expect);

$stop;
end

endmodule