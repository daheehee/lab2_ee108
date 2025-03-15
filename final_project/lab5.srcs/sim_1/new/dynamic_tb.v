

module dynamic_tb();

    reg [2:0] voicing;
    reg beat, reset, clk;
    wire [5:0] amplitude_total;
    
dynamics hello(
    .voicing(voicing),
    .clk(clk),
    .reset(reset),
    .beat(beat), 
    .amplitude_total(amplitude_total)
    );
    
        // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        beat = 1'b0;
        repeat (4) #5 beat = ~beat;
        forever #5 beat = ~beat;
    end
    initial begin
        voicing = 3'b0; 
        #6000;
        #10; 
        voicing = 3'b10; 
        #100;
        voicing = 3'b01; 
        #100;
    end 
    
endmodule
