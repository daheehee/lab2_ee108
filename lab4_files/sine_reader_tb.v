module sine_reader_tb();

    reg clk, reset, generate_next;
    reg [19:0] step_size;
    wire sample_ready;
    wire [15:0] sample;
    sine_reader reader(
        .clk(clk),
        .reset(reset),
        .step_size(step_size),
        .generate_next(generate_next),
        .sample_ready(sample_ready),
        .sample(sample)
    );

//    module beat_generator(
//    input clk,
//    input reset,
//    input en,
//    output wire beat
//);

    
//    beat_generator sine_read_tb(
//        .clk(clk),
//        .reset(reset),
//        .en(**),
//        .beat()
//    );
    
    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // Tests
    initial begin
        
        //step_size = 20'b00000010101000000000;
        //step_size = 20'b10000000000;
//        step_size = {10'd9, 10'd395};
        step_size = 20'b10000000000;
        generate_next = 1'b0;
        #30;
        
        repeat(6000) begin
        generate_next = 1'b1; 
        #10;
        generate_next = 1'b0;
        #20;
        end
        
        #30 generate_next = 1'b1; 
        #30 generate_next = 1'b0; 
        $display("generate_next = %b, sample_ready = %b, sample = %b", generate_next, sample_ready, sample);

        #30 generate_next = 1'b1; 
        #30 generate_next = 1'b0; 
        $display("generate_next = %b, sample_ready = %b, sample = %b", generate_next, sample_ready, sample);
        #50 $finish; 
    end

endmodule
