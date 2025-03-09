//
//  music_player module
//
//  This music_player module connects up the MCU, song_reader, note_player,
//  beat_generator, and codec_conditioner. It provides an output that indicates
//  a new sample (new_sample_generated) which will be used in lab 5.
//

module music_player(
    // Standard system clock and reset
    input clk,
    input reset,

    // Our debounced and one-pulsed button inputs.
    input play_button,
    input next_button,

    // The raw new_frame signal from the ac97_if codec.
    input new_frame,

    // This output must go high for one cycle when a new sample is generated.
    output wire new_sample_generated,

    // Our final output sample to the codec. This needs to be synced to
    // new_frame.
    output wire [15:0] sample_out
);
    // The BEAT_COUNT is parameterized so you can reduce this in simulation.
    // If you reduce this to 100 your simulation will be 10x faster.
    parameter BEAT_COUNT = 1000;


//
//  ****************************************************************************
//      Master Control Unit
//  ****************************************************************************
//   The reset_player output from the MCU is run only to the song_reader because
//   we don't need to reset any state in the note_player. If we do it may make
//   a pop when it resets the output sample.
//
 
    wire play;
    wire reset_player;
    wire [1:0] current_song;
    wire song_done;
    mcu mcu(
        .clk(clk),
        .reset(reset),
        .play_button(play_button),
        .next_button(next_button),
        .play(play),
        .reset_player(reset_player),
        .song(current_song),
        .song_done(song_done)
    );

//
//  ****************************************************************************
//      Song Reader
//  ****************************************************************************
//
    wire [17:0] note_to_play;
    wire [5:0] time_dur; 
    wire [17:0] duration_for_note;
    wire [3:0] new_note;
    wire [3:0] note_done;
    
    //instantiate mult
    song_reader song_reader(
        .clk(clk),
        .reset(reset | reset_player),
        .play(play),
        .song(current_song),
        .song_done(song_done),
        .time_dur(time_dur), //output
        .note(note_to_play),
        .duration(duration_for_note),
        .new_note(new_note),
        .note_done(note_done)
    );

//   
//  ****************************************************************************
//      Note Player
//  ****************************************************************************
//  
    wire beat;
    wire generate_next_sample;
    wire generate_next_sample0;
    reg [17:0] note_sample;
    wire [15:0] note_sample1, note_sample2, note_sample3, time_sample;
    wire [15:0] note_sample10, note_sample20, note_sample30, time_sample0;
    
    wire note_sample_ready1, note_sample_ready2, note_sample_ready3, time_ready;
    wire note_sample_ready10, note_sample_ready20, note_sample_ready30, time_ready_0;

    // These pipeline registers were added to decrease the length of the critical path!
    dffr pipeline_ff_gen_next_sample1(.clk(clk), .r(reset), .d(generate_next_sample0), .q(generate_next_sample));
    dffr #(.WIDTH(16)) pipeline_ff_note_sample (.clk(clk), .r(reset), .d(note_sample10), .q(note_sample1));
    dffr pipeline_ff_new_sample_ready (.clk(clk), .r(reset), .d(note_sample_ready10), .q(note_sample_ready1));
    
    dffr #(.WIDTH(16)) pipeline_ff_note_sample2 (.clk(clk), .r(reset), .d(note_sample20), .q(note_sample2));
    dffr pipeline_ff_new_sample_ready2 (.clk(clk), .r(reset), .d(note_sample_ready20), .q(note_sample_ready2));

    dffr #(.WIDTH(16)) pipeline_ff_note_sample3 (.clk(clk), .r(reset), .d(note_sample30), .q(note_sample3));
    dffr pipeline_ff_new_sample_ready3 (.clk(clk), .r(reset), .d(note_sample_ready30), .q(note_sample_ready3));

    dffr #(.WIDTH(16)) pipeline_ff_note_sample4 (.clk(clk), .r(reset), .d(time_sample0), .q(time_sample));
    dffr pipeline_ff_new_sample_ready4 (.clk(clk), .r(reset), .d(time_ready_0), .q(time_ready));

    note_player note_player1(
        .clk(clk),
        .reset(reset),
        .play_enable(play),
        .note_to_load(note_to_play[5:0]),
        .duration_to_load(duration_for_note[5:0]),
        .load_new_note(new_note[0]),
        .done_with_note(note_done[0]),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(note_sample10),
        .new_sample_ready(note_sample_ready10)
    );
    
    note_player note_player2(
        .clk(clk),
        .reset(reset ),
        .play_enable(play),
        .note_to_load(note_to_play[11:6]),
        .duration_to_load(duration_for_note[11:6]),
        .load_new_note(new_note[1]),
        .done_with_note(note_done[1]),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(note_sample20),
        .new_sample_ready(note_sample_ready20)
    );
    
    note_player note_player3(
        .clk(clk),
        .reset(reset),
        .play_enable(play),
        .note_to_load(note_to_play[17:12]),
        .duration_to_load(duration_for_note[17:12]),
        
        .load_new_note(new_note[2]),
        .done_with_note(note_done[2]),
        
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(note_sample30),
        .new_sample_ready(note_sample_ready30)
    );
    
    note_player time_dur_player(
        .clk(clk),
        .reset(reset),
        .play_enable(play),
        
        .note_to_load(6'b0),
        .duration_to_load(time_dur),
        
        .load_new_note(new_note[3]),
        .done_with_note(note_done[3]),
        
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(time_sample0),
        .new_sample_ready(time_ready_0)
    );
    
    wire [3:0] note_sample_ready;
    assign note_sample_ready = {note_sample_ready1, note_sample_ready2, note_sample_ready3, time_ready};
    
//   
//  ****************************************************************************
//      Beat Generator
//  ****************************************************************************
//  By default this will divide the generate_next_sample signal (48kHz from the
//  codec's new_frame input) down by 1000, to 48Hz. If you change the BEAT_COUNT
//  parameter when instantiating this you can change it for simulation.
//  
    beat_generator #(.WIDTH(10), .STOP(BEAT_COUNT)) beat_generator(
        .clk(clk),
        .reset(reset | new_note | play_button),
        .en(generate_next_sample),
        .beat(beat)
    );

//  
//  ****************************************************************************
//      Codec Conditioner
//  ****************************************************************************

    wire new_sample_generated0;
    wire [15:0] sample_out0; 

    dffr pipeline_ff_nsg (.clk(clk), .r(reset), .d(new_sample_generated0), .q(new_sample_generated));
    //dffr #(.WIDTH(16)) pipeline_ff_sample_out (.clk(clk), .r(reset), .d(sample_out0), .q(sample_out));
    assign sample_out = sample_out0;
    
    codec_conditioner codec_conditioner(
        .clk(clk),
        .reset(reset),
        .new_sample_in(note_sample_final_final),
        
        .latch_new_sample_in(|note_sample_ready),
        .generate_next_sample(generate_next_sample0),
        
        .new_frame(new_frame),
        .valid_sample(sample_out0)
    );
    
//  
//  ****************************************************************************
//      Extensions
//  ****************************************************************************

    
//  ** Chords
    wire signed [18:0]sum;     
    reg signed [15:0] note_signed1, note_signed2, note_signed3;
    
    always @(*) begin
        case(|note_sample3+ |note_sample2 + (|note_sample1)) //how many of these ntoes are not 0?
            2'd3: begin
            note_signed1 = note_sample1[15] ? -((-note_sample1 + 1'b1)/3'd3)+1'b1 : (note_sample1)/3'd3;
            note_signed2 = note_sample2[15] ? -((-note_sample2 + 1'b1)/3'd3)+1'b1 : (note_sample2)/3'd3;
            note_signed3 = note_sample3[15] ? -((-note_sample3 + 1'b1)/3'd3)+1'b1 : (note_sample3)/3'd3;
            end
            2'd2: begin
            note_signed1 = note_sample1[15] ? -((-note_sample1 + 1'b1)/3'd2)+1'b1 : (note_sample1)/3'd2;
            note_signed2 = note_sample2[15] ? -((-note_sample2 + 1'b1)/3'd2)+1'b1 : (note_sample2)/3'd2;
            note_signed3 = note_sample3[15] ? -((-note_sample3 + 1'b1)/3'd2)+1'b1 : (note_sample3)/3'd2;
            end
            2'd1: begin 
            note_signed1 = note_sample1;
            note_signed2 = note_sample2;
            note_signed3 = note_sample3;
            end
            default: begin
            note_signed1 = 16'b0;
            note_signed2 = 16'b0;
            note_signed3 = 16'b0;
            end
        endcase
   end
   
    
    wire signed [15:0] note_sample_final;
    assign note_sample_final = note_signed1 + note_signed2 + note_signed3;
    assign new_sample_generated0 = generate_next_sample;
    
// ** Dynamics

    // meta_data > ADSR map
    
    always @ (*) begin
        case (meta_data)
            3'b00:
            3'b01: begin // flute
            
            end
            3'b10:
            3'b11:
            default:
        endcase
    end
    
    // Split up note duration sent to note_player depending on instrument and state 
    
    // Change amplitude of note sample depending on instrument and state
    
    // State machine
    `define INITIAL     3'd0
    `define ATTACK      3'd1
    `define DECAY       3'd2
    `define SUSTAIN     3'd3
    `define RELEASE     3'd4
    
    // Counter to keep track of length of A-D-S-R cycles
    reg [5:0] next_count;
    wire [5:0] count;
    dffre #(.WIDTH(6)) counter(.clk(clk), .r(reset), .en(beat && play_enable), .d(next_count), .q(count));
    
    // Keeps track of sample amplitude
    reg signed [15:0] next_step;
    wire [15:0] step;
    dffr #(.WIDTH(16)) amplitude_reg(.clk(clk), .r(reset), .d(next_amplitude), .q(amplitude));
    
    // Divide note_sample_final by 2 so we have space to change volume for dynamics
    reg signed [15:0] note_sample_dynamic_reg;
    wire signed [15:0] note_sample_final_final;
    wire signed [15:0] note_sample_final_half;
    wire signed [15:0] note_sample_final_adjusted;
    assign note_sample_final_adjusted = (count == t_a + t_d + t_s - 6'd1) ? `RELEASE : `SUSTAIN;
    assign note_sample_final_half = note_sample_final[15] ? -((-note_sample_final + 1'b1)/3'd2)+1'b1 : (note_sample_final)/3'd2;
    
    always @ (*) begin
        case (state)
            `INITIAL: begin
                next_step = 0;
                note_sample_dynamic_reg = 0;
                next_state = `ATTACK;
            end
            `ATTACK: begin // Linear increase
                next_step = step + step_a; 
                note_sample_dynamic_reg = note_sample_final + next_step;
                next_state = (count == t_a - 6'd1) && ? `DECAY : `ATTACK;
            end
            `DECAY: begin // Exponential decrease
                next_step = 0;
                note_sample_dynamic_reg = note_sample_final * decay_factor;
                next_state = (count == t_a + t_d - 6'd1) ? `SUSTAIN : `DECAY;
            end
            `SUSTAIN: begin // Constant
                next_step = 0;
                // sustain at 0.5 * Amplitude_max
                note_sample_dynamic_reg = note_sample_final_half;
                next_state = (count == t_a + t_d + t_s - 6'd1) ? `RELEASE : `SUSTAIN;
            end
            `RELEASE: begin // Linear decrease
                next_step = step - step_d;
                note_sample_dynamic_reg = note_sample_final_half + next_step;
                next_state = (count == t_a + t_d + t_s + t_r - 6'd1) && (note_sample_dynamic_reg == 0) ? `INITIAL: `RELEASE;
            end
            default: begin
                next_step = 0;
                note_sample_dynamic_reg = 0;
                next_state = `INITIAL;
            end
        endcase
    end
    
    assign note_sample_final_final = note_sample_dynamic_reg;
    


endmodule
