`define NONE    3'b000
`define GUITAR  3'b001
`define FLUTE   3'b010
`define HARP    3'b100

`define ATTACK      3'b000
`define DECAY       3'b001
`define SUSTAIN     3'b010
`define RELEASE     3'b011
`define INITIAL     3'b100

module dynamics(
    input wire [2:0] voicing,
    input wire clk,
    input wire reset,
    input wire beat, 
    input wire new_note,
    output wire [5:0] amplitude_total
    );
    
wire [5:0]count;
reg [5:0] next_count;
dffre #(.WIDTH(6)) beat_count(.clk(clk), .r(reset || count == 6'd10 || new_note), .en(super_beat == 3'd5), .d(next_count), .q(count));

wire [9:0] super_beat;
dffre #(.WIDTH(10)) sixty_count(.clk(clk), .r(reset || super_beat == 3'd5 || new_note), .en(beat), .d(super_beat+1'b1), .q(super_beat));

reg [5:0] amplitude_total_next; 
dffre #(.WIDTH(6)) amplitude(.clk(clk), .r(reset || (|voicing && new_note)), .d(amplitude_total_next), .q(amplitude_total), .en(super_beat == 3'd5));

wire [1:0] state;
reg [1:0]next_state;
dffre #(.WIDTH(2)) state_change(.clk(clk), .r(reset || new_note), .en(super_beat == 3'd5), .d(next_state), .q(state));
// 0, 30/60 (2), 60/60 (1) , 30/60 (2), 15/60 (4), 15/120(8), 4/60(16), 2/60(32), 1/60 (64), 
always @(*) begin
    case(state)
    `INITIAL: begin
        amplitude_total_next = 0;
        next_count = 0;
        next_state = (new_note) ? `ATTACK : `INITIAL;
    end
    `ATTACK: begin
        amplitude_total_next = (voicing == 3'b000) ? 6'd1 :
            ((amplitude_total == 6'd0) ? 6'd2 : // If just beginning, start at 1/2 amplitude
            ((voicing == 3'b001) ? amplitude_total - 6'd1:
            amplitude_total - 6'd2)); // Otherwise, increase amplitude by different increments based on voicing
        next_count = count + 1'b1;
        next_state = (count == 6'd1) ? `DECAY : `ATTACK;
    end 
    `DECAY: begin
        amplitude_total_next = (voicing == 3'b000) ? 6'd1 : 
            ((voicing == 3'b001) ? amplitude_total + (amplitude_total << 2):
            amplitude_total << 1);
        next_count = count + 1'b1;
        next_state = (count == 6'd4) ? `SUSTAIN : state;
    end
    `SUSTAIN: begin
        amplitude_total_next = (voicing == 3'b000) ? 6'd1 : amplitude_total;
        next_count = count + 1'b1;
        next_state = (voicing == 3'b000 || count == 6'd7) ? `RELEASE : `SUSTAIN;
    end
    `RELEASE: begin
        amplitude_total_next = (voicing == 3'b000) ? 6'd1 :
            ((amplitude_total == 6'd0) ? 6'b111111 : 
            amplitude_total + 6'd1);
        next_count = count + 1'b1;
        next_state = (count == 6'd10) ? `INITIAL : `RELEASE;
    end
    default: begin
        amplitude_total_next = 0;
        next_count = 0;
        next_state = (new_note) ? `ATTACK : `INITIAL;
    end 
    endcase

end

endmodule
