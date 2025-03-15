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
wire [7:0] value;

wire [7:0] read_value_adjusted;
assign read_value_adjusted = (read_value >> 1'b1) + 8'd32;

// Flip Flops
dffre #(.WIDTH(8)) value_ff (.r(reset), .clk(clk), .en((prev_addr != read_address)), .d(read_value_adjusted), .q(value));
dffr #(.WIDTH(9)) addr_ff (.r(reset), .clk(clk), .d(addr_reg), .q(prev_addr));

always @(*) begin
    // Process X- and Y- coordinate inputs
    
    case(x[9:8]) // Check quadrant of x-coordinate
        2'b01: addr_reg = {read_index, 1'b0, x[7:1]};
        2'b10: addr_reg = {read_index, 1'b1, x[7:1]};
        default: addr_reg =  0; // If not in quadrant 2 or 3
    endcase
    
        if ((value <= y[8:1]) && (y[8:1] <= read_value_adjusted) || (read_value_adjusted <= y[8:1]) && (y[8:1] <= value)) display = 1;
        else display = 0;
    
end

assign valid_pixel = (~y[9]) & (x[9] ^ x[8]) & valid; // only valid if they are in the pre-defined waveform 
assign read_address = addr_reg;
assign {r,g,b} = (display & valid) ? 24'hFFFFFF : 24'h000000;

endmodule