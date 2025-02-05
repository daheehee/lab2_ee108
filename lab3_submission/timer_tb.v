module timer_tb ();
    reg clk;
    reg [3:0] load_val;
    reg rst;
    reg count_en;
    wire done;
    wire done2;
    
    
     timer #(.TIMER(1)) DUT1 (.clk(clk), .load_val(load_val), .rst(rst), .count_en(count_en), .done(done));
     timer #(.TIMER(2)) DUT2 (.clk(clk), .load_val(load_val), .rst(rst), .count_en(count_en), .done(done2));
     always begin 
     #0.05 clk = 0;
     #0.05 clk = 1;
     end
     
     //beat 32 simulator
     always begin 
     #0.1 count_en = 0;
     #3.1 count_en = 1;
     end
     
     initial begin
        $dumpfile( "dump.vcd " ) ;
        $dumpvars ;
        rst = 1;
        
        //trying lowest value for both timer 1 and 2
        load_val = 4'b0001; // 1 unit for timer 1, 1/8 unit for timer 2
        #5
        rst = 0;
        #103 
        $display("done should be high once, done2 should be high 8 times");

        //trying highest value for both timer 1 and 2
        rst = 1;
        load_val = 4'b1000;
        #5
        rst = 0;
        $display("done should be high never, done2 should be high once");
  
        #830
      $stop;
     end
endmodule 
