`define SONG_WIDTH 5
`define NOTE_WIDTH 6
`define DURATION_WIDTH 6


// edit this code eventually lol


// ----------------------------------------------
// Define State Assignments
// ----------------------------------------------
`define SWIDTH 3
`define PAUSED             3'b000
`define WAIT               3'b001
`define INCREMENT_ADDRESS  3'b010
`define RETRIEVE_NOTE      3'b011
`define NEW_NOTE_READY     3'b100


module song_reader(
    input clk,
    input reset,
    input play,
    input [1:0] song,
    input [2:0] note_done, //note done for each note slot
    
    output wire song_done,
    output wire [17:0] note,
    output wire [17:0] duration,
    output wire [8:0] voicing,
    output wire [2:0] new_note //new note for each note slot
);
    wire [6:0] curr_note_num, next_note_num;
    wire [15:0] note_and_duration1;
    wire [15:0] note_and_duration2;
    wire [15:0] note_and_duration3;
    
    wire [8:0] rom_addr = {song, curr_note_num};

    wire [`SWIDTH-1:0] state;
    reg  [`SWIDTH-1:0] next;

    // For identifying when we reach the end of a song
    wire overflow;

    dffr #(7) note_counter (
        .clk(clk),
        .r(reset),
        .d(next_note_num),
        .q(curr_note_num)
    );
    dffr #(`SWIDTH) fsm (
        .clk(clk),
        .r(reset),
        .d(next),
        .q(state)
    );

    wire [15:0] time_dur_inter;
//edit so we don't necessarily have to follow the strucutre (pain in the ass but whatever)
    song_rom note1_rom(.clk(clk), .addr(rom_addr), .dout(note_and_duration1));
    song_rom note2_rom(.clk(clk), .addr(rom_addr + 1'd1), .dout(note_and_duration2));
    song_rom note3_rom(.clk(clk), .addr(rom_addr + 2'd2), .dout(note_and_duration3));
//    song_rom time_skip(.clk(clk), .addr(rom_addr + 2'd3), .dout(time_dur_inter));
    
    reg [5:0] note1_done, note2_done, note3_done;
//    assign time_dur = time_dur_inter[14:9]; 

    always @(*) begin
        case (state)
            `PAUSED:       begin     next = play ? `RETRIEVE_NOTE : `PAUSED;end
            `RETRIEVE_NOTE:   begin  next = play ? `NEW_NOTE_READY : `PAUSED; end
            `NEW_NOTE_READY:   begin next = play ? `WAIT: `PAUSED; end
            `WAIT:              begin
            next = !play ? `PAUSED : ((|note_done )? `INCREMENT_ADDRESS: `WAIT);
            end
            `INCREMENT_ADDRESS: begin next = (play && ~overflow) ? `RETRIEVE_NOTE
                                                           : `PAUSED; end
            default:      begin      next = `PAUSED; end
        endcase
    end

    assign {overflow, next_note_num} =
        (state == `INCREMENT_ADDRESS) ? {1'b0, curr_note_num} + 3'd4
                                      : {1'b0, curr_note_num}; //adding 4 to go to every 4 notes
    
    wire new_note1, new_note2, new_note3;
    assign new_note1 = (state == `NEW_NOTE_READY) ;
    assign new_note2 = (state == `NEW_NOTE_READY) ;
    assign new_note3 = (state == `NEW_NOTE_READY) ;
    
    assign new_note = {new_note1, new_note2, new_note3};
    
    wire [5:0] note1, note2, note3;
    wire [2:0] voicing1, voicing2, voicing3;
    wire [5:0] duration1, duration2, duration3;
    
    assign {note1, duration1, voicing1} = note_and_duration1;
    assign {note2, duration2, voicing2} = note_and_duration2;
    assign {note3, duration3, voicing3} = note_and_duration3;
    
    assign note = {note1, note2, note3};
    assign duration = {duration1, duration2, duration3};
    assign voicing = {voicing1, voicing2, voicing3};
    
    assign song_done = overflow;

endmodule



//`define SONG_WIDTH 5
//`define NOTE_WIDTH 6
//`define DURATION_WIDTH 6

//// ----------------------------------------------
//// Define State Assignments
//// ----------------------------------------------
//`define SWIDTH 3
//`define PAUSED             3'b000
//`define WAIT               3'b001
//`define INCREMENT_ADDRESS  3'b010
//`define RETRIEVE_NOTE      3'b011
//`define NEW_NOTE_READY     3'b100


//module song_reader(
//    input clk,
//    input reset,
//    input play,
//    input [1:0] song,
//    input note_done,
//    input rewind,
    
//    output wire song_done,
//    output wire [5:0] note,
//    output wire [5:0] duration,
//    //output rom_addr,
//    output wire new_note
    
//);
//    wire [`SONG_WIDTH-1:0] curr_note_num, next_note_num;
//    wire [`NOTE_WIDTH + `DURATION_WIDTH -1:0] note_and_duration;
//    wire [`SONG_WIDTH + 1:0] rom_addr = {song, curr_note_num};

//    wire [`SWIDTH-1:0] state;
//    reg  [`SWIDTH-1:0] next;

//    // For identifying when we reach the end of a song
//    wire overflow;

//    dffr #(`SONG_WIDTH) note_counter (
//        .clk(clk),
//        .r(reset),
//        .d(next_note_num),
//        .q(curr_note_num)
//    );
//    dffr #(`SWIDTH) fsm (
//        .clk(clk),
//        .r(reset),
//        .d(next),
//        .q(state)
//    );

//    song_rom rom(.clk(clk), .addr(rom_addr), .dout(note_and_duration));

//    always @(*) begin
//        case (state)
//            `PAUSED:            next = play ? `RETRIEVE_NOTE : `PAUSED;
//            `RETRIEVE_NOTE:     next = play ? `NEW_NOTE_READY : `PAUSED;
//            `NEW_NOTE_READY:    next = play ? `WAIT: `PAUSED;
//            `WAIT:              next = !play ? `PAUSED
//                                             : (note_done ? `INCREMENT_ADDRESS
//                                                          : `WAIT);
//            `INCREMENT_ADDRESS: next = (play && ~overflow) ? `RETRIEVE_NOTE
//                                                           : `PAUSED;
//            default:            next = `PAUSED;
//        endcase
//    end

//    assign {overflow, next_note_num} =
//        (state == `INCREMENT_ADDRESS) ? (rewind ? {1'b0, curr_note_num} - 1: {1'b0, curr_note_num} + 1)
//                                      : {1'b0, curr_note_num};
//    assign new_note = (state == `NEW_NOTE_READY);
//    assign {note, duration} = note_and_duration;
//    assign song_done = overflow;

////endmodule
