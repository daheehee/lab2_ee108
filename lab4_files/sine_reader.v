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
    wire [21:0] incremented_addr; //this is the 22 bit output from adding the cur_addr+step size
    assign incremented_addr = cur_addr + step_size;
    
    wire [1:0] quadrant;
    assign quadrant = cur_addr[21:20];
    
    wire [9:0] sine_rom_input;
    assign sine_rom_input = (quadrant == 2'b01 || quadrant == 2'b11) ? (0 - cur_addr[19:10]) : cur_addr[19:10];
    wire [15:0] sine_rom_output;
   
    
    
//    normal input
    sine_rom sin_rom(
        .clk(clk),
        .addr(sine_rom_input),
        .dout(sine_rom_output)
    );
    
    
    always @(*) begin
        if (reset) begin
            next_addr = 22'b0;
            sample = 16'b0;
        end
        else begin         
            //next_addr = incremented_addr;
            next_addr = {cur_addr[21:20] + 2'b01, incremented_addr[19:0]}; 
            
            case (cur_addr[21:20]) 
                2'b00: begin
                    sample = sine_rom_output;
                end
                2'b01: begin
                    sample = sine_rom_output;
                end
                2'b10: begin
                    sample = 0-sine_rom_output;
                end
                2'b11: begin 
                    sample = 0-sine_rom_output;
                end
                default: begin 
                    sample = 16'b0;
                end
            endcase
        end
        
    end
    
    

endmodule
