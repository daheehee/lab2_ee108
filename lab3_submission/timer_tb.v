module timer_tb ();
    reg clk;
    reg [7:0] load_val;
    reg rst;
    wire done;
    
     timer DUT (.clk(clk), .load_val(load_val), .rst(rst), .done(done));
     always begin 
     #5 clk = 0;
     #5 clk = 1;
     end
     
     initial begin
        $dumpfile( "dump.vcd " ) ;
        $dumpvars ;
        rst = 1;
        load_val = 8'b0000_0001;
        #10
        rst = 0;
  
        #1000
      $stop;
     end
endmodule 
