`define SWIDTH 1
`define PAUSE 2'b00
`define PLAY 2'b01
`define REWIND 2'b10
`define FORWARD 2'b11

module mcu(
    input clk,
    input reset,
    input play_button,
    input next_button,
//    input forward_button,
//    input rewind_button,
    
//    output reg rewind, //rewind and forward will turn on if they are pressed once. they will stop once a)beginning/end of the song or b)they are pressed again
//    output reg forward,
    output play,
    output reset_player,
    output [1:0] song,
    input song_done
);

    dffre #(.WIDTH(2)) song_reg (
        .clk(clk),
        .r(reset),
        .en(next_button || song_done),
        .d(song + 1'b1),
        .q(song)
    );

    wire state;
    reg  next_state;

    dffr #(.WIDTH(`SWIDTH)) playing_reg (
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(state)
    );

    assign play = (state == `PLAY);
    assign reset_player = next_button || song_done;

    always @* begin
        case (state)
            `PAUSE:  begin
                next_state = play_button ? `PLAY : state;
//                forward = 0;
//                rewind = 0;
                
             end
            `PLAY:  begin 
                next_state = (play_button || next_button || song_done) ? `PAUSE : state;
//                forward = (forward_button && !rewind_button);
//                rewind = (!forward_button && rewind_button);
             end
            default: next_state = `PAUSE;
        endcase
    end

endmodule
