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
    output [15:0] sample_out_1,  // Our sample output
    output [15:0] sample_out_2,
    output [15:0] sample_out_3,
    output [15:0] sample_out_4,
    output [15:0] sample_out_5,
    output new_sample_ready  // Tells the codec when we've got a sample
);

    wire [19:0] step_size;
    wire [5:0] freq_rom_in;

    wire [19:0] inter_1;  // Our sample output
    wire [19:0] inter_2;
    wire [19:0] inter_3;
    wire [19:0] inter_4;
    wire [19:0] inter_5;
    
    assign inter_1 = step_size[19] ? -((-step_size + 1'b1) * 5'd2)+1'b1 : (step_size * 5'd2);
    assign inter_2 = step_size[19] ? -((-step_size + 1'b1) * 5'd2)+1'b1 : (step_size * 5'd2);
    assign inter_3 = step_size[19] ? -((-step_size + 1'b1) * 5'd3)+1'b1 : (step_size * 5'd3);
    assign inter_4 = step_size[19] ? -((-step_size + 1'b1) * 5'd4)+1'b1 : (step_size * 5'd4);
    assign inter_4 = step_size[19] ? -((-step_size + 1'b1) * 5'd5)+1'b1 : (step_size * 5'd5);
    
    dffre #(.WIDTH(6)) freq_reg (
        .clk(clk),
        .r(reset),
        .en(load_new_note),
        .d(note_to_load),
        .q(freq_rom_in)
    );

    frequency_rom freq_rom(
        .clk(clk),
        .addr(freq_rom_in),
        .dout(step_size)
    );

    //created a different instantiation of sine reader for each harmonic
    //five total below
    sine_reader sine_read_1(
        .clk(clk),
        .reset(reset),
        .step_size(inter_1),
        .generate_next(play_enable && generate_next_sample),
        .sample_ready(new_sample_ready),
        .sample(sample_out_1)
    );

    
    sine_reader sine_read_2(
        .clk(clk),
        .reset(reset),
        .step_size(6'd2 * step_size),
        .generate_next(play_enable && generate_next_sample),
        .sample_ready(new_sample_ready),
        .sample(sample_out_2)
    );
    
    
    sine_reader sine_read_3(
        .clk(clk),
        .reset(reset),
        .step_size(6'd3 * step_size),
        .generate_next(play_enable && generate_next_sample),
        .sample_ready(new_sample_ready),
        .sample(sample_out_3)
    );
    
    
    sine_reader sine_read_4(
        .clk(clk),
        .reset(reset),
        .step_size(6'd4 * step_size),
        .generate_next(play_enable && generate_next_sample),
        .sample_ready(new_sample_ready),
        .sample(sample_out_4)
    );

    
    sine_reader sine_read_5(
        .clk(clk),
        .reset(reset),
        .step_size(6'd5 * step_size),
        .generate_next(play_enable && generate_next_sample),
        .sample_ready(new_sample_ready),
        .sample(sample_out_5)
    );


    //adjust amplitude of higher harmonics
 
    
    wire [5:0] state, next_state;
    dffre #(.WIDTH(6)) state_reg (
        .clk(clk),
        .r(reset),
        .en((beat || load_new_note) && play_enable),
        .d(next_state),
        .q(state)
    );
    assign next_state = (reset || done_with_note || load_new_note)
                        ? duration_to_load : state - 1;

    assign done_with_note = (state == 6'b0) && beat;

endmodule
