`timescale 1ns / 1ps

module pwm_tb();

reg clk, reset, play_enable;
wire out;
reg [7:0] duty_cycle;

pwm dut (
    .clk(clk),
    .reset(reset),
    .duty_cycle(duty_cycle),
    .play_enable(play_enable),
    .out(out)
);

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
    play_enable = 1;
    duty_cycle = 8'd128; // 50% duty cycle
    #1000;
    duty_cycle = 8'd64; // 25% duty cycle
end

endmodule
