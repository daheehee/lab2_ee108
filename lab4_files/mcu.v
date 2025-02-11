module mcu(
    input clk,
    input reset,
    input play_button,
    input next_button,
    input song_done,
    
    output reg play,
    output reg reset_player,
    output wire [1:0] song
);

`define PAUSED 2'b00
`define PLAY   2'b01
`define DONE   2'b10
`define RESET  2'b11
    
reg [1:0] next_song;
dffr #(.WIDTH(2)) song_player(.r(reset), .clk(clk),.d(next_song), .q(song));

reg [1:0] next_state;
wire [1:0] state;
dffr #(.WIDTH(2)) state_next(.r(reset), .clk(clk), .d(next_state), .q(state));

always @(*) begin
    if (reset == 1) begin
        next_song = 2'b00;
        reset_player = 0;
        play = 0;
        next_state = `PAUSED;
    end
    else begin
    case (state)
        `PAUSED:begin
            next_song = song;
            reset_player = 0;
            play = 0;
            if (play_button == 1 && next_button == 0) begin
                next_state = `PLAY;
            end
            else if (play_button == 0 && next_button == 1) begin
                next_state = `RESET;
            end
            else begin
                next_state = `PAUSED;
            end
        end
        
        `PLAY: begin
            next_song = song;
            reset_player = 0;
            play = 1;
            if (play_button == 0 && next_button == 1) begin
                next_state = `RESET;
            end
            else if (play_button == 1 && next_button == 0) begin
                next_state = `PAUSED;
            end
            else if (song_done == 1) begin
                next_state = `DONE;
            end 
            else begin
                next_state = `PLAY;
            end
        end
        
        `DONE: begin
            next_song = song;
            reset_player = 0;
            play = 0;
            next_state = `RESET;
        end
        
        `RESET: begin
            next_song = song + 1'b1;
            reset_player = 1;
            play = 0;
            if (play_button == 1 && next_button == 0) begin
                next_state = `PLAY;
            end
            else begin
                next_state = `PAUSED;
            end
        end
        
        default: begin
            next_song = 2'b00;
            reset_player = 0;
            play = 0;
            next_state = `PAUSED;
        end
    endcase
    end
end



endmodule
