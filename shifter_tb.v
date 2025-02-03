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
        rst = 1;
        #70
        $display(out);
        shift_left = 1'd1;
        shift_right = 1'd0;
        rst = 0;
        expected = 4'b010;
        #70
        $display("shift left by one -> %b, expected %b", out, expected);
        #70
        
        // shift to the right
        rst = 1;
        #70
        rst = 0;
        shift_left = 1'd0;
        shift_right = 1'd1;
        expected = 4'b100;
        #70
        $display("shift right by one -> %b, expected %b", out, expected);
        #70
        
        // no shift
        rst = 1;
        #70
        rst = 0;
        shift_left = 1'd0;
        shift_right = 1'd0;
        expected = 4'b001;
        #70
        $display("no shift -> %b, expected %b", out, expected);
        #70
        
        // both shifts pressed
        rst = 1;
        #70
        rst = 0;
        shift_left = 1'd1;
        shift_right = 1'd1;
        expected = 4'b001;
        #70
        $display("both shift -> %b, expected %b", out, expected);
        #70
        
        // shift left to more than 4'b100
        rst = 1;
        #70
        rst = 0;
        shift_left = 1'd5;
        shift_right = 1'd0;
        expected = 4'b010;
        #70
        $display("shift left exceeding 4'b100 -> %b, expected %b", out, expected);
        #70
        
        // store previous states
        shift_left = 1'd1;
        expected = 4'b100;
        #70
        $display("store previous states -> %b, expected %b", out, expected);
        #70
        
        $stop;
    end
    
    
endmodule
