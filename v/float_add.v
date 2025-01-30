module float_add (
    input wire [7:0] aIn,
    input wire [7:0] bIn,
    output wire [7:0] result
);

//declare any intermediate signals
wire [7:0] aBig, bSmall;
wire [2:0] exp_diff;
wire [4:0] shifted_b;

//find the bigger
big_number_first big_1(.aIn(aIn), .bIn(bIn), .aOut(aBig), .bOut(bSmall));

//align 
assign exp_diff = aBig[7:5] - bSmall[7:5];
shifter shift_1(.in(bSmall[4:0]), .direction(1'b1), .dist(exp_diff), .out(shifted_b));

//add
wire overflow;
wire [4:0] sum; 
adder add_1(.a(aBig[4:0]), .b(shifted_b), .sum(sum), .cout(overflow));

reg [2:0] exp;
reg [4:0] final_sum;
    always @(*) begin
        if (overflow == 1) begin
            if (aBig[7:5] == 3'b111) begin
                exp = 3'b111;
                final_sum = 5'b11111;
            end
            else begin
                exp = aBig[7:5] + 1'b1;
                final_sum = {overflow, sum[4:1]};
            end
        end
        else begin 
            exp = aBig[7:5];
            final_sum = sum;
        end
    end
    
 assign result = {exp, final_sum}; 
 
endmodule

