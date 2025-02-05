module blinker_tb ();
    reg clk;
    reg rst;
    reg switch;
    wire out;
    
    blinker DUT (.clk(clk), .rst(rst), .switch(switch), .out(out));
    always begin
        #5 
        clk = 1;
        #5
        clk = 0;
    end
    
    
    //we need to test that when switch is high, output will be toggle
     initial begin
        $dumpfile( "dumpBlinker.vcd " ) ;
        $dumpvars ;
        
        //reset everything, makes sure switch is 0 and that we're in the waiting stage
        rst = 1;
        switch = 0;
        
        #10
        rst = 0;
        
        //just check what the output is to start, 
        $display("switch=%b, out=%b (starting output)", switch, out);
        
        //pulse switch, the next clock cycle will toggle the output
        #10
        switch = 1;
        #10
        switch = 0;
        
        #20;
        $display("switch=%b, out=%b (output should change)", switch, out);
  
        #10
        switch = 1;
        #10
        switch = 0;
        #10
        switch = 1;
        #10
        switch = 0;
        #20;
        $display("switch=%b, out=%b (output should change)", switch, out);
  
        
        
        #1000
      $stop;
     end
     
endmodule