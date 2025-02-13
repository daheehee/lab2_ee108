module note_player(
    input clk,
    input reset,
    input play_enable,  // When high we play, when low we don't. //cool
    input [5:0] note_to_load,  // The note to play //cool
    input [5:0] duration_to_load,  // The duration of the note to play //cool
    input wire load_new_note,  // Tells us when we have a new note to load, one cycle //cool
    input beat,  // This is our 1/48th second beat //cool
    input generate_next_sample,  // Tells us when the codec wants a new sample //cool
    
    output wire done_with_note,  // When we are done with the note this stays high. //cool
    output wire [15:0] sample_out,  // Our sample output //cool
    output wire new_sample_ready  // Tells the codec when we've got a sample //cool
);

wire [5:0] ref_note;
reg [5:0] new_note;
dffr #(.WIDTH(6)) note_change(.clk(clk), .r(reset), .d(new_note), .q(ref_note));

wire [5:0] ref_dur;
reg [5:0] new_dur;
dffre #(.WIDTH(6)) duration_change(.clk(clk), .en(play_enable), .r(reset | (ref_dur == duration_to_load)), .d(new_dur), .q(ref_dur));

wire [19:0] freq_out;
wire [19:0] step_size;


frequency_rom find_freq(.clk(clk), .addr(ref_note), .dout(freq_out));

assign step_size = play_enable ? freq_out : 20'b0;

sine_reader sine_read(.clk(clk), .reset(reset), .step_size(step_size), .generate_next(generate_next_sample & play_enable), .sample_ready(new_sample_ready), .sample(sample_out));

assign done_with_note = (ref_dur == duration_to_load);

always @(*) begin
    case (beat)
        1'b1: new_dur = ref_dur + 6'b000001;
        1'b0: new_dur = ref_dur;
        default: new_dur = 6'b0;
    endcase
    case (load_new_note)
        1'b1: begin
            // implement delay
            new_note = ref_dur == duration_to_load ? note_to_load : ref_note;
        end
        1'b0: new_note = ref_note;
        default: new_note = note_to_load;
    endcase
end

endmodule
