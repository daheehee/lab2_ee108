module timer_tb ();
    reg clk;
    reg [3:0] load_val;
    reg rst;
    wire done;
    
     timer #(.TIMER(2)) DUT (.clk(clk), .load_val(load_val), .rst(rst), .done(done));
     always begin 
     #0.1 clk = 0;
     #0.1 clk = 1;
     end
     
     initial begin
        $dumpfile( "dump.vcd " ) ;
        $dumpvars ;
        rst = 1;
        load_val = 4'b0001;
        #10
        rst = 0;
        #100
        
        rst = 1;
        load_val = 4'b1000;
        #10
        rst = 0;
  
        #1000
      $stop;
     end
endmodule 
