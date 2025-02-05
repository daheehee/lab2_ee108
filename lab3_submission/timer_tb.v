module timer_tb ();
    reg clk;
    reg [3:0] load_val;
    reg rst;
    reg count_en;
    wire done;
  

     timer #(.TIMER(2)) DUT (.clk(clk), .load_val(load_val), .rst(rst),  .count_en(count_en), .done(done));
     
      // Clock generation
    always begin 
        #0.1 clk = 0;  // Toggle clock every 0.1 time units
        #0.1 clk =1;
    end

    // Count Enable toggling (simulating beat32 behavior)
    always begin
        #0.2 count_en = 1;
        #0.2 count_en = 0;
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