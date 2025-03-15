`timescale 1ns / 1ps
module wave_display_tb(
);
    
reg clk;
reg reset;
reg read_index;
reg [10:0] x;
reg [9:0] y;
wire [7:0] read_value;
wire [8:0] read_address;
wire valid_pixel;
wire [7:0] r,g,b;
	
wave_display display(.clk(clk),
                    .reset(reset), 
                    .x(x), 
                    .y(y), 
                    .valid(1'b1), 
                    .read_value(read_value),
                    .read_index(read_index),
                    .read_address(read_address),
                    .valid_pixel(valid_pixel), 
                    .r(r),
                    .g(g), 
                    .b(b)
);
									
fake_sample_ram f_ram(.clk(clk), .addr(read_address), .dout(read_value));

initial begin
		read_index = 1;
        clk = 0;
        reset = 1;
        #5
        
        reset = 0;
        forever 
        #5 clk = ~clk; 
end

reg [8:0] expected_address;
reg [7:0] expected_value;
reg expected_valid_pixel;
reg [23:0] expected_rgb;

initial begin
    #5
    x = 11'b10000000001;
    y = 10'b1100100; // 100
    expected_address = 9'd0;
    expected_value = 8'b10101010; //170
    expected_valid_pixel = 0;
    expected_rgb = 24'h000000;
    $display ("read_address: expected %b, actual %b", expected_address, read_address);
    $display ("read_value: expected %b, actual %b", expected_value, read_value);
    $display ("valid_pixel expected %b, actual %b", expected_valid_pixel, valid_pixel);
    $display ("valid_pixel expected %b, actual %b", expected_rgb, {r,g,b});
    
    #10
    x = 11'b01000000011;
    y = 10'b1100100; // 100, between RAM[X-1] = 170 and RAM[X] = 85
    expected_address = 9'b110000001;
    expected_value = 8'b01010101; //85
    expected_valid_pixel = 1;
    expected_rgb = 24'hFFFFFF;
    $display ("read_address: expected %b, actual %b", expected_address, read_address);
    $display ("read_value: expected %b, actual %b", expected_value, read_value);
    $display ("valid_pixel expected %b, actual %b", expected_valid_pixel, valid_pixel);
    $display ("valid_pixel expected %b, actual %b", expected_rgb, {r,g,b});
    
    #10
    x = 11'b0100000101;
    y = 10'b1100101; // 101, between RAM[X-1] = 85 and RAM[X] = 109
    expected_address = 9'b11000010;
    expected_value = 8'b01101101; //109
    expected_valid_pixel = 1;
    expected_rgb = 24'hFFFFFF;
    $display ("read_address: expected %b, actual %b", expected_address, read_address);
    $display ("read_value: expected %b, actual %b", expected_value, read_value);
    $display ("valid_pixel expected %b, actual %b", expected_valid_pixel, valid_pixel);
    $display ("valid_pixel expected %b, actual %b", expected_rgb, {r,g,b});
    
end

endmodule