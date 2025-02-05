module programmable_blinker_tb ();
//define inputs
reg clk;
reg rst;
reg shift_left;
reg shift_right;
reg count_en;
wire switch1;
wire switch2;

//beat32 beat(.clk (clk), .rst(rst), .count_en(count_en));

//First Flash
programmable_blinker #(.n(1)) DUT1 (
    .clk(clk), 
    .rst(rst), 
    .shift_left(shift_left), 
    .shift_right(shift_right),
    .count_en(count_en),
    .switch(switch1)
    );
    
 //Second Flash
 programmable_blinker #(.n(2)) DUT2 (
    .clk(clk), 
    .rst(rst), 
    .shift_left(shift_left), 
    .shift_right(shift_right),
    .count_en(count_en),
    .switch(switch2)
    );

    always begin 
        #0.1 clk = 0; 
        #0.1 clk = 1;
    end

    always begin
        #0.2 count_en = 1;
        #0.2 count_en = 0;
    end
    
    
    initial begin
        count_en = 0;
        $dumpfile( "dump.vcd " ) ;
        $dumpvars ;
        
        shift_right = 0;
        shift_left = 0;
        
        rst = 1;
        #10
        rst = 0;
        
        //Test behavior when nothing is pressed 
        //Both flashes shouuld output the same thing
        #1000
        $display("Nothing applied observing output.");
        
        //Test Shift_Left x3 from 0001 to 1000
        //For Flash 1, goes slower from 1s on / 1s off to 8s on / 8s off
        //For Flash 2, goes faster from 1s on / 1s off to 1/8s on / 1/8s off
        shift_left = 1; //Shift left first time
        #20 shift_left = 0;
        
        #20  
        
        shift_left = 1; //Shift left second time
        #20 shift_left = 0;
        
        #20
        
        shift_left = 1; //Shift left third time
        #20 shift_left = 0;
        
        #20
        
        shift_left = 1; //Shift left third time
        #20 shift_left = 0;
       
        #1000;
        $display("Shift Left x3 applied, observing output,");
  

        //Test Shift_Right x2 from 1000 to 0010
        //For Flash 1, goes faster from 8s on / 8s off to 2s on / 2s off
        //For Flash 2, goes faster from 1/8s on / 1/8s off to 1/2s on / 1/2s off
        shift_right = 1;
        #20 shift_right = 0;
        
//        #10
        
//        shift_right = 1;
//        #10 shift_right = 0;
        
        #500;
        $display("Shift Right x2 applied, observing output...");


        //Test Shift_Right x2 from 0010 to 0001 (hits boundary)
        //For Flash 1, goes faster from 2s on / 2s off to 1s on / 1s off
        //For Flash 2, goes faster from 1/2s on / 1/2s off to 1s on / 1s off
        shift_right = 1;
        #20 shift_right = 0;
        
//        #10
        
//        shift_right = 1;
//        #10 shift_right = 0;
        
        #500;
        $display("Shift Right x2 applied, observing output...");


        rst = 1;
        #10
        rst = 0;
        
        // Stop simulation
        $stop; 
    end


endmodule