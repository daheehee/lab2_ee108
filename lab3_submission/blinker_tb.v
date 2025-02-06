module blinker_tb ();
    reg clk;
    reg rst;
    reg switch;
    wire out;
    
    blinker DUT (.clk(clk), .rst(rst), .switch(switch), .out(out));
    
    //this means one clock cycle is 10, so blinker will toggle its output after #10
    //if switch is high for more than one clock cycle (i.e. not a pulse), then the blinker's output will pulse
    always begin
        #5 
        clk = 1;
        #5
        clk = 0;
    end
    
     initial begin
        $dumpfile( "dumpBlinker.vcd " ) ;
        $dumpvars ;
        
        //reset everything, makes sure switch is 0 and that blinker is 0
        rst = 1;
        switch = 0;
        #10
        rst = 0;
        $display("switch=%b, out=%b (starting output)", switch, out);
        
        //pulse switch, the next clock cycle will have a toggled output of 1
        #10
        switch = 1;
        #10
        switch = 0;
        #40;
        $display("switch=%b, out=%b (output should change)", switch, out);
  
        //pulse switch, the next clock cycle will have a toggled output of 0
        #10
        switch = 1;
        #10
        switch = 0;
        #40;
        $display("switch=%b, out=%b (output should change)", switch, out);
        
        //switch stays high for 5 clock cycles, so output will look like a pulse
        #10
        switch = 1;
        #50 
        switch = 0;
  
        $display("switch=%b, out=%b (output should pulse)", switch, out);
        #10
  
        #10
        switch = 1;
        #50 
        switch = 0;
  
        $display("switch=%b, out=%b (output should pulse)", switch, out);
  
        
        #1000
      $stop;
     end
     
endmodule