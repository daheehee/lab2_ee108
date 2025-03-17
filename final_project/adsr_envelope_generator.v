`define NONE    3'b000
`define GUITAR  3'b001
`define FLUTE   3'b010
`define HARP    3'b100

`define INITIAL     5'b00000
`define ATTACK      5'b00001
`define DECAY       5'b00010
`define SUSTAIN     5'b00100
`define RELEASE     5'b01000
`define DONE        5'b10000

module dynamics(
    input wire [2:0] voicing,
    input wire clk,
    input wire reset,
    input wire beat, 
    input wire new_note,
    
    output wire [5:0] amplitude
    );
    
wire [5:0]count;
reg [5:0] next_count;
dffre #(.WIDTH(6)) beat_count(.clk(clk), .r(reset || count == 6'd10 || new_note), .en(super_beat == 3'd5), .d(next_count), .q(count));

wire [9:0] super_beat;
dffre #(.WIDTH(10)) sixty_count(.clk(clk), .r(reset || super_beat == 3'd5 || new_note), .en(beat), .d(super_beat+1'b1), .q(super_beat));

reg [5:0] next_amplitude; 
dffre #(.WIDTH(6)) amplitude_reg(.clk(clk), .r(reset || (|voicing && new_note)), .d(next_amplitude), .q(amplitude), .en(super_beat == 3'd5));

wire [4:0] state;
reg [4:0]next_state;
dffre #(.WIDTH(2)) state_change(.clk(clk), .r(reset || new_note), .en(super_beat == 3'd5), .d(next_state), .q(state));
// 0, 30/60 (2), 60/60 (1) , 30/60 (2), 15/60 (4), 15/120(8), 4/60(16), 2/60(32), 1/60 (64), 

// Calculate gradients for linear steps
reg [5:0] step_a, step_r, t_s;
wire [5:0] MAX, MID, MIN;
assign MAX = 6'd1;
assign MID = 6'b100000;
assign MIN = 6'b000000;

always @(*) begin
    case (voicing)
        3'b000: begin
            step_a = 0;
            t_s = 0;
        end
        3'b001: begin // Flute
            step_a = 6'd1;
            t_s = 6'd1;
        end
        3'b010: begin // Harp
            step_a = 6'd1;
            t_s = 6'd1;
        end
        3'b100: begin // Guitar
            step_a = 6'd1;
            t_s = 6'd1;
        end
        default: begin
            step_a = 0;
            t_s = 0;
        end
    endcase
end

// Precompute state transitions to reduce timing issues
wire attack_done = amplitude >= MAX;
wire decay_done = (amplitude == MID) || (voicing == 3'b000);
wire sustain_done = count >= t_s;
wire release_done = (amplitude - step_r) <= MIN;

always @(*) begin
    case(state)
//    `INITIAL: begin
//        next_amplitude = (voicing == 3'b000) ? MAX : 6'd0;
//        next_count = 0;
//        next_state = `ATTACK;
//    end
    `ATTACK: begin
        next_amplitude = (voicing == 3'b000) ? MAX : // Normal note
            (amplitude == MIN) ? 6'd2 : // Flute
            amplitude - 6'd1; // Harp, Guitar - fast attack
        next_count = count + 1'b1;
        next_state = (count ==  2'd1) ? `DECAY: `ATTACK;
    end 
    `DECAY: begin
        next_amplitude = (voicing == 3'b000) ? MAX : (voicing == 3'b001) ? amplitude - (amplitude >> 3) : amplitude >> 1;
        next_count = 0;
        next_state = decay_done ? `SUSTAIN: `DECAY; // Stop once amplitude hits MID
    end
    `SUSTAIN: begin
        next_amplitude = (voicing == 3'b000) ? MAX : MID;
        next_count = count + 1'b1; // count up (on every beat) towards sustain period
        next_state = sustain_done ? `RELEASE : `SUSTAIN; // sustain period over
    end
    `RELEASE: begin
        next_amplitude = release_done ? amplitude - step_a : amplitude;
        next_count = 0;
        next_state = release_done ? `DONE : `RELEASE;
    end
    `DONE: begin
        next_amplitude = MIN;
        next_count = 0;
        next_state = (reset || (|voicing && new_note)) ? `INITIAL : `DONE;
    end
    default: begin
        next_amplitude = (voicing == 3'b000) ? MAX : 6'd0;
        next_count = 0;
        next_state = `INITIAL;
    end
    endcase

end

endmodule
