`timescale 1ns/1ps
module beat32_tb ();
     reg clk;
     reg rst;
     wire count_en;
     
     beat32 DUT(.clk(clk), .rst(rst), .count_en(count_en));
     
     always begin 
     #2 clk = 0;
     #2 clk = 1;
     end
     
     initial begin
        $dumpfile( "dump.vcd " ) ;
        $dumpvars ;
        rst = 1;
        #10
        rst = 0;
  
        #1000
      $stop;
     end


endmodule
