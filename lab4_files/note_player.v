module note_player(
    input clk,
    input reset,
    input play_enable,  // When high we play, when low we don't. //cool
    input [5:0] note_to_load,  // The note to play //cool
    input [5:0] duration_to_load,  // The duration of the note to play //cool
    input load_new_note,  // Tells us when we have a new note to load, one cycle //cool
    output reg done_with_note,  // When we are done with the note this stays high. //cool
    input beat,  // This is our 1/48th second beat //cool
    input generate_next_sample,  // Tells us when the codec wants a new sample //cool
    output wire [15:0] sample_out,  // Our sample output //cool
    output wire new_sample_ready  // Tells the codec when we've got a sample //cool
);

`define PLAY 5'b00001
`define PAUSE 5'b00010
`define LOAD 5'b00100
`define DONE 5'b10000

wire [5:0] ref_note;
reg [5:0] new_note;
dffr #(.WIDTH(6)) note_change(.clk(clk), .r(reset), .d(new_note), .q(ref_note));

wire [5:0] ref_dur;
reg [5:0] new_dur;
dffr #(.WIDTH(6)) duration_change(.clk(clk), .r(reset), .d(new_dur), .q(ref_dur));

wire [19:0] step_size;

//wire [5:0] cur_time;
//reg [5:0] new_time;
//dffr #(.WIDTH(6)) timer(.clk(clk), .r(reset), .d(new_time), .q(cur_time));

wire [4:0] state;
reg [4:0] new_state;
dffr #(.WIDTH(5)) state_status(.clk(clk), .r(reset), .d(new_state), .q(state));

frequency_rom find_freq(.clk(clk), .addr(ref_note), .dout(step_size));

sine_reader sine_read(.clk(clk), .reset(reset), .step_size(step_size), .generate_next(generate_next_sample), .sample_ready(new_sample_ready), .sample(sample_out));


always @(*) begin
    if (reset) begin
        new_note = note_to_load; 
        new_dur = duration_to_load; 
        done_with_note = 0;
        new_state = `PLAY;
    end
    
    else begin
        case (state) 
            `PLAY: begin
                if (beat) begin
                    new_dur = new_dur - 1;
                    done_with_note = 0;
                    new_state = `PLAY;
                end 
                else if (load_new_note) begin
                    new_dur = 0;
                    done_with_note = 0;
                    new_state = `LOAD;
                end
                else if (ref_dur == 1) begin
                    new_dur = 0;
                    done_with_note = 1;
                    new_state = `DONE; //we are done with the note, we must pause our operations
                end
                else if (!play_enable) begin
                    new_dur = new_dur;
                    new_state = `PAUSE; //we are done with the note, we must pause our operations
                    done_with_note = 0;
                end
                else begin
                    new_dur = new_dur;
                    new_state = `PLAY;
                    done_with_note = 0;
                end
                    new_note = new_note;
            end 
            `PAUSE: begin
                if (play_enable) begin
                    new_state = `PLAY; //we are done with the note, we must pause our operations
                end
                else begin
                    new_state = `PAUSE; //we are done with the note, we must pause our operations
                end
                    done_with_note = 0; 
                    new_note = new_note;
                    new_dur = new_dur;
            end
            
            `LOAD: begin
                new_note = note_to_load; 
                new_dur = duration_to_load;
                new_state = `PLAY;
                done_with_note = 0;
            end
            `DONE: begin
                new_dur = new_dur;
                new_note = new_note;
                done_with_note = 1;
                if (load_new_note) begin
                    new_state = `LOAD;
                end
            end 
       endcase
       end
end 

endmodule
