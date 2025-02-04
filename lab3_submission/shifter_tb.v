`timescale 1ns/1ps
module shifter_tb ();
    reg clk;
    reg shift_left;
    reg shift_right;
    reg rst;
    wire [3:0] out;
    
    shifter DUT (
    .clk(clk), 
    .rst(rst), 
    .shift_left(shift_left), 
    .shift_right(shift_right),
    .out(out)
    );
    
    always begin
        #5 clk = 0;
        #5 clk = 1;
    end
    
    reg [3:0] expected;
    
    initial begin
        $dumpfile( "dump.vcd " ) ;
        $dumpvars ;
        
        // shift to the left
        #10 rst = 1;
        #10 
        rst = 0;
        shift_left = 1'd1;
        shift_right = 1'd0;
        expected = 4'b010;
        #20 $display("shift left by one -> %b, expected %b", out, expected);
        
        // shift to the right
        #10 rst = 1;
        #10
        rst = 0;
        shift_left = 1'd0;
        shift_right = 1'd1;
        expected = 4'b001;
        #20 $display("shift right by one -> %b, expected %b", out, expected);
        
        // no shift
        #10 rst = 1;
        #10
        rst = 0;
        shift_left = 1'd0;
        shift_right = 1'd0;
        expected = 4'b001;
        #20
        $display("no shift -> %b, expected %b", out, expected);
        #10
        
        // both shifts pressed
        #10 rst = 1;
        #10
        rst = 0;
        shift_left = 1'd1;
        shift_right = 1'd1;
        expected = 4'b001;
        #20
        $display("both shift -> %b, expected %b", out, expected);
        #10
        
        // shift left to more than 4'b100
        #10 rst = 1;
        #10
        rst = 0;
        #20
        shift_left = 1'd1;
        shift_right = 1'd0;
        #20
        shift_left = 1'd1;
        shift_right = 1'd0;
        #20
        shift_left = 1'd1;
        shift_right = 1'd0;
        #20
        shift_left = 1'd1;
        shift_right = 1'd0;
        #20
        expected = 4'b1000;
        #20
        $display("shift left exceeding 4'b1000 -> %b, expected %b", out, expected);
        
        // store previous states
        #10 
        shift_left = 1'd0;
        shift_right = 1'd1;
        #20
        expected = 4'b0100;
        #20
        $display("store previous states -> %b, expected %b", out, expected);
        #20
        
        $stop;
    end
    
    
endmodule
