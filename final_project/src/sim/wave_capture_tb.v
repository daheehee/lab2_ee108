module wave_capture_tb ();
    reg clk, reset, new_sample_ready;
    reg [15:0] new_sample_in;
    reg wave_display_idle;
    
    wire [8:0] write_address;
    wire write_enable;
    wire [7:0] write_sample;
    wire read_index;
    
    wave_capture dut(
        .clk(clk),
        .reset(reset),
        .new_sample_ready(new_sample_ready),
        .new_sample_in(new_sample_in),
        .wave_display_idle(wave_display_idle),
        .write_address(write_address),
        .write_enable(write_enable),
        .write_sample(write_sample),
        .read_index(read_index)
    );
    
    
    // Clock and reset
    initial begin
        clk = 1'b0;
        new_sample_ready = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever begin
            #5 
            clk = ~clk;
            new_sample_ready = ~new_sample_ready;
        end 
    end
    
    initial begin
        //testing ARMED state, counter should be 0
        reset = 1;
        
        wave_display_idle = 0;
        new_sample_in = 16'd0;

        #20 
        reset = 0;
        
        
        // give 2 new negative samples (stays in ARMED state)
        // write sample should be 
        #10 
        new_sample_in = -16'd2; 
        #10 
        new_sample_in = -16'd1;
        
        // now give positive sample (triggers ACTIVE state) 
        // 
        #10 
        new_sample_in = 16'd5;        
        #10 

        
        //now we need 256 samples...
        
        // first recreate the first quarter of the wave,the write_sample values should all be above 128
        repeat (64) begin
            new_sample_in = new_sample_in + 16'b0000000100000000;
            #10;
        end
        
        // the write_sample values should all be above 128
        repeat (64) begin
            new_sample_in = new_sample_in - 16'b0000000100000000;
            #10;
        end
        
        // the write_sample values should be below 128
        repeat (64) begin
            new_sample_in = new_sample_in - 16'b0000000100000000;
            #10;
        end
        
        // write_sample values should be below 128
        repeat (64) begin
            new_sample_in = new_sample_in + 16'b0000000100000000;
            #10;
        end

        //once counter is 255, then we should go into the wait state
        
        
        
        // toggle wave_display_idle to high to exit the wait state and go into armed
        #10
        wave_display_idle = 1'b1;
        #10
        wave_display_idle = 1'b0;

       
        #100;

        
        $finish;
        
        
    end
    
endmodule