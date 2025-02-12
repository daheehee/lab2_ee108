module sine_reader(
    input clk,
    input reset,
    input [19:0] step_size,
    input generate_next,

    output wire sample_ready,
    output reg [15:0] sample
);

    //instantiate a flip flop to store the address
    reg [21:0] next_addr;
    wire [21:0] cur_addr;
    dffre #(.WIDTH(22)) current_addr(
    .clk (clk), .r (reset), .en(generate_next), .d (next_addr), .q (cur_addr)
    );
    
    
    //instantiate a flip flop to store the sample
    wire sample_wait1;
    dffr #(.WIDTH(1)) first_sample(
        .clk(clk), .r(reset), .d(generate_next), .q(sample_wait1)
    );
    
    dffr #(.WIDTH(1)) second_sample(
        .clk(clk), .r(reset),.d(sample_wait1), .q(sample_ready)
    );

    
    //declare intermediate wires
    //wire [21:0] incremented_addr; //this is the 22 bit output from adding the cur_addr+step size
    //assign incremented_addr = cur_addr + step_size;
    
    //wire [1:0] quadrant;
    //assign quadrant = cur_addr[21:20];
    
    reg [9:0] sine_rom_input;
    
    wire [15:0] sine_rom_output1;
   
    
    
//    normal input
    sine_rom sin_rom(
        .clk(clk),
        .addr(sine_rom_input),
        .dout(sine_rom_output1)
    );
    
    //assign sample == (
    always @(*) begin
        if (reset) begin
            next_addr = 22'b0;
            sample = sine_rom_output1;
            sine_rom_input = cur_addr[19:10];
            //sample = 16'b0;
        end
        else begin         
            next_addr = cur_addr + step_size;
            case (cur_addr[21:20]) 
                2'b00: begin
                    sine_rom_input = cur_addr[19:10];
                    sample = sine_rom_output1;
                end
                2'b01: begin
                    sine_rom_input = ~cur_addr[19:10];
                    sample = sine_rom_output1;
                end
                2'b10: begin
                    sine_rom_input = cur_addr[19:10];
                    sample = ~sine_rom_output1;
                end
                2'b11: begin 
                    sine_rom_input = ~cur_addr[19:10];
                    sample = ~sine_rom_output1;
                end
                default: begin 
                    sine_rom_input = cur_addr[19:10];
                    sample = sine_rom_output1;
                    next_addr = cur_addr;
                end
            endcase
        end
    end
    

endmodule