module shifter (
    input wire [4:0] in,
    input wire [2:0] dist,
    input wire direction,
    output reg [4:0] out
);

	// 0 = left, 1 = right
	wire [12:0] left, right;
	assign left = in << dist;
	assign right = in >> dist;
    	always @(*) begin
		case (direction)
			1'b0: out = left;
			1'b1: out = right;
			default: out = 5'b0;
		endcase
	end

endmodule