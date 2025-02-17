module wave_display (
    input clk,
    input reset,
    input [10:0] x,  
    input [9:0]  y, 
    input valid,
    input [7:0] read_value,
    input read_index,
    output wire [8:0] read_address,
    output wire valid_pixel,
    output wire [7:0] r,
    output wire [7:0] g,
    output wire [7:0] b
);

// Implement me!

// Internal Signals
wire [8:0] prev_addr;
reg [8:0] addr_reg;
reg valid_pixel_reg;
reg display;
wire value;

// Flip Flops
dffre #(.WIDTH(8)) value_ff (.r(reset), .clk(clk), .en(~(prev_addr == read_address)), .d(read_value), .q(value));
dffr #(.WIDTH(9)) addr_ff (.r(reset), .clk(clk), .d(addr_reg), .q(prev_addr));

always @(*) begin
    // Process X- and Y- coordinate inputs
    valid_pixel_reg = (~y[9]) && ((x[9:8] == 2'b01) || (x[9:8] == 2'b10)); // only valid if they are in the pre-defined waveform display region
    
    case(x[9:8]) // Check quadrant of x-coordinate
        2'b01: addr_reg = {read_index, 1'b0, x[7:1]};
        2'b10: addr_reg = {read_index, 1'b1, x[7:1]};
        default: addr_reg = 9'b0; // If not in quadrant 2 or 3
    endcase
    
    case (prev_addr == read_address) 
        1'b1: begin // Only when the address changes do we accept a new sample from RAM
            // if Y RAM value is between RAM[X-1] and RAM[X]
            if (((value <= y[8:1]) && (y[8:1] <= read_value)) || ((read_value <= y[8:1]) && (y[8:1] <= value))) display = 1;
            else display = 0;
        end
        default display = 0;
    endcase
end

assign valid_pixel = valid_pixel_reg;
assign read_address = addr_reg;
assign {r,g,b} = (display && valid) ? 24'hFFFFFF : 24'h000000;

endmodule
