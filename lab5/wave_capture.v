module wave_capture (
    input clk,
    input reset,
    input new_sample_ready,
    input [15:0] new_sample_in,
    input wave_display_idle,

    output reg [8:0] write_address,
    output reg write_enable,
    output reg [7:0] write_sample,
    output reg read_index
);

    
//internal signals

    // define states
    `define STATE_ARMED       2'b00 
    `define STATE_ACTIVE      2'b01
    `define STATE_WAIT        2'b10

// Flip Flops

//should sample be a dffre... it will only allow write_sample to be changed when new_sample_ready is high
//reg [7:0] next_sample;
wire [15:0] cur_sample;
//next_sample = new_sample_in[15:8] + 8'b10000000;
dffre #(.WIDTH(16)) sample_ff (.r(reset), .clk(clk), .en(new_sample_ready), .d(new_sample_in), .q(cur_sample));

reg [1:0] next_state;
wire [1:0] state;
dffr #(.WIDTH(2)) state_ff (.r(reset), .clk(clk), .d(next_state), .q(state));


// Flip-Flop for counter
wire [7:0] counter;
reg [7:0] next_counter;
dffre #(.WIDTH(8)) counter_ff (.r(reset), .clk(clk), .en(new_sample_ready), .d(next_counter), .q(counter));

//wire [8:0] cur_addr;
//reg [8:0] next_addr;
//dffr #(.WIDTH(9)) addr_ff (.r(reset), .clk(clk), .d(next_addr), .q(cur_addr));


always @(*) begin
    if (reset) begin
        next_state = `STATE_ARMED;
        next_counter = 0;
        read_index = 0;
        write_enable = 0;
        write_sample = 0;
    end
    else begin
        case (state) 
            `STATE_ARMED: begin
                write_enable = 1'b0;
                next_counter=0;
               // instead of doing (cur_sample < 0 && new_sample_in > 0)... only look at 1st bit to see if pos or neg
                //if (new_sample_ready && cur_sample[15] == 1 && new_sample_in[15] == 0) begin
                if (cur_sample[15] == 1 && new_sample_in[15] == 0) begin
                    next_state = `STATE_ACTIVE;
                end
                else begin
                    next_state = `STATE_ARMED;
                end
              end
             `STATE_ACTIVE: begin
                if (counter != 8'b11111111) begin
                  next_counter = counter+1; 
                  write_enable = 1'b1; 
                  write_sample = cur_sample[15:8] + 8'b10000000;
                  write_address = {read_index, counter};
                  next_state = `STATE_ACTIVE;
                end
                else if (counter == 8'b11111111) begin
                   next_state = `STATE_WAIT;
                end
                else begin
                    //write_enable = 1'b0;
                    next_state = `STATE_ACTIVE;
                    
                end
              end
            `STATE_WAIT: begin
                write_enable = 1'b0;
              
                if (wave_display_idle == 1) begin
                    read_index = ~read_index;
                    next_state = `STATE_ARMED;
                end
                else begin
                    read_index = read_index;
                    next_state = `STATE_WAIT;
                end
            end
            default: begin
                next_counter = 0;
                next_state = `STATE_ARMED;
            end
        endcase
    end
end


endmodule
