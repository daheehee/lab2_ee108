module song_reader_tb();

    reg clk, reset, play, note_done;
    reg [1:0] song;
    wire [5:0] note;
    wire [5:0] duration;
    wire song_done, new_note;

    song_reader dut(
        .clk(clk),
        .reset(reset),
        .play(play),
        .song(song),
        .song_done(song_done),
        .note(note),
        .duration(duration),
        .new_note(new_note),
        .note_done(note_done)
    );

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (3) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // Tests
    initial begin
        
        song = 2'b00;
        play = 1;
        note_done = 0;
        #35
        note_done = 1;
        #10
        note_done = 0;
        #50
        while (!song_done) begin
            #10 note_done = ~note_done;
        end
        
        #100 // test wrap-around
        song = 2'b11;
        while (!song_done) begin
            #10 note_done = ~note_done;
        end
        $stop;
        
        
        

    end

endmodule

