module song_reader(
    input clk,
    input reset,
    input play,
    input [1:0] song,
    input note_done,
    output reg song_done,
    output [5:0] note,
    output [5:0] duration,
    output reg new_note
);

    // define states
    `define STATE_IDLE_0       3'b000 
    `define STATE_NOTE_IN      3'b001
    `define STATE_IDLE_1       3'b010
    `define STATE_NOTE_OUT     3'b011
    `define STATE_IDLE_2       3'b100


    // instantiate flip flops
	wire [6:0] address;
	wire [11:0] note_data;
	song_rom db(.clk(clk), .addr(address), .dout(note_data));

	reg [2:0] next_state;
	wire [2:0] state;
	dffr #(.WIDTH(3)) state_reg(.clk(clk), .r(reset), .d(next_state), .q(state));
	
	reg [4:0] next_note;
	wire [4:0] note_now;
	dffr #(.WIDTH(5)) note_reg(.clk(clk),.r(reset), .d(next_note), .q(note_now));
	
	// assign statements
    assign address = {song, note_now};
    assign {note, duration} = note_data;
	
	always @(*) begin
		case(state)
			`STATE_IDLE_0 : begin
			    song_done = 0; 
				new_note = 0;
				next_state = `STATE_NOTE_OUT;
				next_note = note_now;
			 end
			`STATE_NOTE_IN : begin
			     song_done = (note_now == 5'd31) ? 1:0;
			     new_note = 0;
			     next_note = note_now + 5'd1;
			     next_state = `STATE_IDLE_1;
			 end
			`STATE_IDLE_1 : begin
			     song_done = 0;
			     new_note = 0;
			     next_note = note_now;
			     if (play == 1) begin
			         next_state = `STATE_NOTE_OUT;
                 end
                 else begin
                    next_state = `STATE_IDLE_1;
                 end
			 end
			`STATE_NOTE_OUT : begin
			     song_done = 0;
			     new_note = 1;
			     next_note = note_now;
			     next_state = `STATE_IDLE_2;
			 end
			`STATE_IDLE_2 : begin
			     song_done = 0;
			     new_note = 0;
			     next_note = note_now;
			     if (note_done == 1) begin
			         next_state = `STATE_NOTE_IN;
                 end
                 else begin
                    next_state = `STATE_IDLE_2;
                 end
			 end
			 
			 default : begin
			    song_done = 0;
			    new_note = 0;
			    next_note = note_now;
				next_state = state;
			 end 
		endcase
	end
    
endmodule
