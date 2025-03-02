 module note_player(
    input clk,
    input reset,
    input play_enable,  // When high we play, when low we don't.
    input [5:0] note_to_load,  // The note to play
    input [5:0] duration_to_load,  // The duration of the note to play
    input load_new_note,  // Tells us when we have a new note to load
    
    output done_with_note,  // When we are done with the note this stays high.
    input beat,  // This is our 1/48th second beat
    input generate_next_sample,  // Tells us when the codec wants a new sample
    output [15:0] sample_out,  // Our sample output
    output new_sample_ready  // Tells the codec when we've got a sample
);

    wire [19:0] step_size;
    wire [5:0] freq_rom_in;
    wire [15:0] sample_out_temp;
    wire new_sample_ready_temp;
    wire [15:0] chord_out; 

    dffre #(.WIDTH(6)) freq_reg (
        .clk(clk),
        .r(reset),
        .en(load_new_note),
        .d(note_to_load),
        .q(freq_rom_in)
    );
    
    dffre #(.WIDTH(16)) sample_out_ff (
        .clk(clk),
        .r(reset),
        .en(send_sample),
        .d(chord_out),
        .q(sample_out)
    );

    frequency_rom freq_rom(
        .clk(clk),
        .addr(freq_rom_in),
        .dout(step_size)
    );

    sine_reader sine_read(
        .clk(clk),
        .reset(reset),
        .step_size(step_size),
        .generate_next(play_enable && generate_next_sample),
        .sample_ready(new_sample_ready_temp),
        .sample(sample_out_temp)
    );

    wire [5:0] state, next_state;
    dffre #(.WIDTH(6)) state_reg (
        .clk(clk),
        .r(reset),
        .en((beat || load_new_note) && play_enable),
        .d(next_state),
        .q(state)
    );
    
    wire [15:0] chord;
    dffre #(.WIDTH(16)) chord_reg ( // combines all the notes in the chord to be played and generated at once 
        .clk(clk),
        .r(reset),
        .en(new_sample_ready_temp),
        .d(chord + (sample_out_temp/4)),
        .q(chord)
    );
    
    assign new_sample_ready = (note_to_load[15] && new_sample_ready_temp); // Indicates that all the note samples in the chord have been generated
    
    assign sample_out = new_sample_ready ? chord : 16'd0;
    
    assign next_state = (reset || done_with_note || load_new_note)
                        ? duration_to_load : state - 1; // if not changing state, continue counting down from 48

    assign done_with_note = (state == 6'b0) && beat;

endmodule
