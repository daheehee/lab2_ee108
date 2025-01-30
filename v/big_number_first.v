module big_number_first (
    input wire [7:0] aIn, bIn,
    output reg [7:0] aOut, bOut
);

//aOut is bigger 

	always @(*) begin
		if (aIn < bIn) begin
			aOut = bIn;
			bOut = aIn;
		end
		else begin
			aOut = aIn;
			bOut = bIn;
		end
	end

endmodule