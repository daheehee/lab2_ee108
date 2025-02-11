module note_player_tb();

    reg clk, reset, play_enable, generate_next_sample;
    reg [5:0] note_to_load;
    reg [5:0] duration_to_load;
    reg load_new_note;
    wire done_with_note, new_sample_ready, beat;
    wire [15:0] sample_out;

    note_player np(
        .clk(clk),
        .reset(reset),

        .play_enable(play_enable),
        .note_to_load(note_to_load),
        .duration_to_load(duration_to_load),
        .load_new_note(load_new_note),
        .done_with_note(done_with_note),

        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(sample_out),
        .new_sample_ready(new_sample_ready)
    );

    beat_generator #(.WIDTH(17), .STOP(1500)) beat_generator(
        .clk(clk),
        .reset(reset),
        .en(play_enable),
        .beat(beat)
    );

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
    generate_next_sample = 0;
    forever #10 generate_next_sample = ~generate_next_sample;
    end 
    // Tests
    initial begin
        #15
        play_enable = 1;
        note_to_load = 6'b000001;
        duration_to_load = 6'b000010;
        load_new_note = 0;
        
        #50000;

        note_to_load = 6'b001010;
        duration_to_load = 6'b000100;
        load_new_note = 1;
        
        load_new_note = 1;
        #10
        load_new_note = 0;
        
        #5000;
        
        play_enable = 0;
        
        #10000;
        
        play_enable = 1;
        
        #5000;
        
        $stop;

    end

endmodule
