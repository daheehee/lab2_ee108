`define NONE    3'b000
`define GUITAR  3'b001
`define FLUTE   3'b010
`define HARP    3'b100

module harmonics(
    input wire [2:0]voicing,
    
    output reg [5:0] amplitude_1,
    output reg [5:0] amplitude_2,
    output reg [5:0] amplitude_3,
    output reg [5:0] amplitude_4,
    output reg [5:0] amplitude_5
    );
    
always @(*) begin
    case(voicing)
    `NONE: begin
        amplitude_1 = 6'd1; 
        amplitude_2 = 6'b000000; 
        amplitude_3 = 6'b000000; 
        amplitude_4 = 6'b000000; 
        amplitude_5 = 6'b000000; 
    end
    `GUITAR:begin
        amplitude_1 = 6'd3; 
        amplitude_2 = 6'd2;
        amplitude_3 = 6'd15; 
        amplitude_4 = 6'd30; 
        amplitude_5 = 6'd15; 
    end
    `FLUTE: begin
        amplitude_1 = 6'd2; 
        amplitude_2 = 6'd4;
        amplitude_3 = 6'd10; 
        amplitude_4 = 6'd5; 
        amplitude_5 = 6'd00; 
    end
    `HARP:begin
        amplitude_1 = 6'd1; 
        amplitude_2 = 6'b000000;
        amplitude_3 = 6'b000000; 
        amplitude_4 = 6'b000000; 
        amplitude_5 = 6'b000000; 
    end
    default: begin
        amplitude_1 = 6'd1; 
        amplitude_2 = 6'b000000;
        amplitude_3 = 6'b000000; 
        amplitude_4 = 6'b000000; 
        amplitude_5 = 6'b000000; 
    end
    endcase
end

endmodule
