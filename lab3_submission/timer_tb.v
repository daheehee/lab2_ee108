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
     #0.1 clk = 0;
     #0.1 clk = 1;
     end
     
     always begin 
     #0.1 count_en = 0;
     #3.1 count_en = 1;
     end
     
     // beat32 needs to instaniated in order to test this individually
     
     initial begin
        $dumpfile( "dump.vcd " ) ;
        $dumpvars ;
        rst = 1;
        
        //trying lowest value for both timer 1 and 2
        load_val = 4'b0001;
        #10
        rst = 0;
        #120
        
        //trying highest value for both timer 1 and 2
        rst = 1;
        load_val = 4'b1000;
        #10
        rst = 0;
  
        #1000
      $stop;
     end
endmodule 
