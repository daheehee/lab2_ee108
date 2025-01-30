`timescale 1ns/1ps
module big_number_first_tb ();
    reg [7:0] aIn; 
    reg [7:0] bIn; 
    reg [7:0] aExpect; 
    reg [7:0] bExpect; 
    wire [7:0] aOut;
    wire [7:0] bOut;
    big_number_first dut (.aIn(aIn), .bIn(bIn), .aOut(aOut), .bOut(bOut));

initial begin
aIn = 8'b1000_0000;
bIn = 8'b0000_0001;
aExpect = 8'b1000_0000;
bExpect = 8'b0000_0001;
#5
$display("%b and %d, %b and %d", aOut, bOut, aExpect, bExpect);

aIn = 8'b0000_0100;
bIn = 8'b0001_0000;
aExpect = 8'b0001_0000;
bExpect = 8'b0000_0100;
#5
$display("%b and %d, %b and %d", aOut, bOut, aExpect, bExpect);

$stop;

end

endmodule