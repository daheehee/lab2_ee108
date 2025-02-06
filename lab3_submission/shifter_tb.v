`timescale 1ns/1ps
module shifter_tb ();
    reg clk;
    reg shift_left;
    reg shift_right;
    reg rst;
    wire [3:0] out;
    wire [3:0] out2;
    
    
    shifter #(.TIMER (1)) DUT (
    .clk(clk), 
    .rst(rst), 
    .shift_left(shift_left), 
    .shift_right(shift_right),
    .out(out)
    );
    
    shifter #(.TIMER (2)) DUT2 (
    .clk(clk), 
    .rst(rst), 
    .shift_left(shift_left), 
    .shift_right(shift_right),
    .out(out2)
    );
    
    always begin
        #0.05 clk = 0;
        #0.05 clk = 1;
    end
    
    reg [3:0] expected;
    
    initial begin
        $dumpfile( "dump.vcd " ) ;
        $dumpvars ;
        
        // shift to the left
        #5 rst = 1;
        #5 
        rst = 0;
        shift_left = 1'd1;
        #0.3
        shift_left = 1'd0;
        shift_right = 1'd0;
        expected = 4'b010;
        #5 $display("shift left by one -> %b, expected %b", out, expected);
        
        // shift to the right
        #5 rst = 1;
        #5
        rst = 0;
        shift_left = 1'd0;
        shift_right = 1'd1;
        #0.3
        shift_right = 1'd0;
        expected = 4'b001;
        #5 $display("shift right by one -> %b, expected %b", out, expected);
        
        // no shift
        #5 rst = 1;
        #5
        rst = 0;
        shift_left = 1'd0;
        shift_right = 1'd0;
        expected = 4'b001;
        #5
        $display("no shift -> %b, expected %b", out, expected);
        #5
        
        // both shifts pressed
        #5 rst = 1;
        #5
        rst = 0;
        shift_left = 1'd1;
        shift_right = 1'd1;
        expected = 4'b001;
        #5
        $display("both shift -> %b, expected %b", out, expected);
        #5
        
        // shift left to more than 4'b100
        #10 rst = 1;
        #5
        rst = 0;
        #5
        shift_left = 1'd1;
        shift_right = 1'd0;
        #0.3
        shift_left = 1'd1;
        shift_right = 1'd0;
        #0.3
        shift_left = 1'd1;
        shift_right = 1'd0;
        #0.3
        shift_left = 1'd0;
        shift_right = 1'd0;
        #0.3
        expected = 4'b1000;
        #1
        $display("shift left exceeding 4'b1000 -> %b, expected %b", out, expected);
        
        // shift right
        #5
        shift_left = 1'd0;
        shift_right = 1'd1;
        #0.3
        shift_right = 1'd0;
        expected = 4'b0100;
        #1
        $display("store previous states -> %b, expected %b", out, expected);
        #1
        
        #10 rst = 1;
        #10 rst = 0;
           
        $stop;
    end
    
    
endmodule