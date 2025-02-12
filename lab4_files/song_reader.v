module song_reader(
    input clk,
    input reset,
    input play,
    input [1:0] song,
    input note_done,
    output reg song_done,
    output reg [5:0] note,
    output reg [5:0] duration,
    output reg new_note
);

    // Implementation goes here!
    
    // define states
    `define STATE_PAUSE             5'b1        // begins paused. also stays in this state when we are waiting for the next song from mcu.
    `define STATE_SONG_0            5'b10       // the first 32 bits in song_rom which store song 0
    `define STATE_SONG_1            5'b100      // the second 32 bits in song_rom which store song 1
    `define STATE_SONG_2            5'b1000     // the middle 32 bits in song_rom which store song 2
    `define STATE_SONG_3            5'b10000    // the final 32 bits in song_rom which store song 3
    
    // instantiate song_rom
    wire [6:0] address; // there are 128 addresses in total, and 2^7=128
    wire [11:0] note_data; // data[11:6] = note; data[5:0] = duration
    song_rom db(.clk(clk), .addr(address), .dout(note_data));
    
    // instantiate flip flops
    reg [4:0] next_state;
    wire [4:0] state;
    dffre #(.WIDTH(5)) state_reg(.clk(clk), .r(reset), .en(play), .d(next_state), .q(state)); // the value of state can only change when play==1
    
    reg [6:0] next_address;
    dffre #(.WIDTH(7)) address_reg(.clk(clk), .r(reset), .en(note_done), .d(next_address), .q(address));
    
    // sequential logic begins here
    always @(*) begin
        if (reset == 1) begin
            next_state = `STATE_PAUSE;
            next_address = 7'd0;
            new_note = 0; // default is 0, so we only tell it to play a new note during the clock cycle where we are in the correct song state
            note = note_data[11:6];
            duration = note_data[5:0];
            song_done = 0;
        end
        else begin
            case(state)
                `STATE_PAUSE: begin
                    if (play == 1) begin
                        // switch to state corresponding to 'song' input from mcu
                        if (song == 2'b00) begin 
                            next_state = `STATE_SONG_0;
                        end
                        else if (song == 2'b01) begin 
                            next_state = `STATE_SONG_1;
                        end
                        else if (song == 2'b10) begin 
                            next_state = `STATE_SONG_2;
                        end
                        else if (song == 2'b11) begin 
                            next_state = `STATE_SONG_3;
                        end
                        // if 'song' input is invalid, do nothing
                        else begin 
                            next_state = `STATE_PAUSE;
                        end
                    end
                    else begin // play == 0
                        next_state = `STATE_PAUSE;
                    end
                    // protecting against inferred latches
                    next_address = address;
                    new_note = 0; // pause state, so we dont want note player to latch onto anything
                    note = note_data[11:6];
                    duration = note_data[5:0];
                    song_done = 0;
                end
                
                `STATE_SONG_0: begin
                    // if note is done playing
                    if (note_done == 1) begin   
                        if (address == 7'd31) begin // final note in song
                            next_state = `STATE_SONG_1; // skip to next song
                            song_done = 1;
                            new_note = 0;
                            note = note_data[11:6];
                            duration = note_data[5:0];
                        end
                        else begin // TODO: might need ot add separate case for first note
                            next_state = `STATE_SONG_0;
                            song_done = 0;
                            new_note = 1; // we are sending note_player a new address worth of data, so we want it to latch on
                            note = note_data[11:6];
                            duration = note_data[5:0];
                        end
                        next_address = address + 7'd1; // increment for next round
                    end
                    // if note is still playing
                    else begin
                        next_state = `STATE_SONG_0; // don't do anything
                        new_note = 0; // once note_player already knows to start playing that note, turn it off until a new npte comes around
                        next_address = address;
                        note = note_data[11:6];
                        duration = note_data[5:0];
                        song_done = 0;
                    end
                end
                
                `STATE_SONG_1: begin
                    if (note_done == 1) begin
                        if (address == 7'd63) begin
                            next_state = `STATE_SONG_2; 
                            song_done = 1;
                            new_note = 0;
                            note = note_data[11:6];
                            duration = note_data[5:0];
                        end
                        else begin
                            next_state = `STATE_SONG_1;
                            song_done = 0;
                            new_note = 1; 
                            note = note_data[11:6];
                            duration = note_data[5:0];
                        end
                        next_address = address + 7'd1;
                    end
                    else begin
                        next_state = `STATE_SONG_1; 
                        new_note = 0; 
                        next_address = address;
                        note = note_data[11:6];
                        duration = note_data[5:0];
                        song_done = 0;
                    end
                end
                
                `STATE_SONG_2: begin
                    if (note_done == 1) begin
                        if (address == 7'd95) begin
                            next_state = `STATE_SONG_3; 
                            song_done = 1;
                            new_note = 0;
                            note = note_data[11:6];
                            duration = note_data[5:0];
                        end
                        else begin
                            next_state = `STATE_SONG_2;
                            song_done = 0;
                            new_note = 1; 
                            note = note_data[11:6];
                            duration = note_data[5:0];
                        end
                        next_address = address + 7'd1;
                    end
                    else begin
                        next_state = `STATE_SONG_2; 
                        new_note = 0; 
                        next_address = address;
                        note = note_data[11:6];
                        duration = note_data[5:0];
                        song_done = 0;
                    end
                end
                
                `STATE_SONG_3: begin
                    if (note_done == 1) begin
                        if (address == 7'd127) begin
                            next_state = `STATE_SONG_0; // wrap around
                            song_done = 1;
                            new_note = 0;
                            note = note_data[11:6];
                            duration = note_data[5:0];
                        end
                        else begin
                            next_state = `STATE_SONG_3;
                            song_done = 0;
                            new_note = 1; 
                            note = note_data[11:6];
                            duration = note_data[5:0];
                        end
                        next_address = address + 7'd1;
                    end
                    else begin
                        next_state = `STATE_SONG_3; 
                        new_note = 0;
                        next_address = address;
                        note = note_data[11:6];
                        duration = note_data[5:0];
                        song_done = 0;
                    end
                end
                
                default: begin
                    next_address = address;
                    new_note = 1;
                    note = 6'd0;
                    duration = 6'd12;
                    song_done = 0;
                end
                
            endcase
        end
    end
    

endmodule
