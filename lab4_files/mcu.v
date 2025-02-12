module mcu(
    input clk,
    input reset,
    input play_button,
    input next_button,
    input song_done,
    output wire play,
    output wire reset_player,
    output wire [1:0] song
);

reg [1:0] next_song;
dffr #(.WIDTH(2)) song_player(.r(reset), .clk(clk),.d(next_song), .q(song));


reg play_next;
dffr #(.WIDTH(1)) play_change(.r(reset), .clk(clk), .d(play_next), .q(play));

assign reset_player = next_button & !play_button;



always @(*) begin
    case (play_button)
        1'b1: begin  // if play is true
            if (song_done | next_button | song_done) begin 
                play_next = 0;
            end
            else begin
                play_next = ~play;
            end 
        end
        1'b0: begin // if play is false
            if (song_done | next_button) begin 
                play_next = 0;
            end
            else begin
                play_next = play;
            end 
        end
        default: play_next = 1'b0; // don't play the next song
    endcase
    case (next_button & !play_button) // if next button is pressed AND play button is NOT pressed
        1'b1: next_song = song + 1 ; // skip to the next song
        1'b0: begin
            if (song_done) begin
                next_song = song + 1;
            end
            else begin
                next_song = song;
            end
        end
        default: next_song = 2'b0;
    endcase
end



endmodule