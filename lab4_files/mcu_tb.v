module mcu_tb();
    reg clk, reset, play_button, next_button, song_done;
    wire play, reset_player;
    wire [1:0] song;

    mcu dut(
        .clk(clk),
        .reset(reset),
        .play_button(play_button),
        .next_button(next_button),
        .play(play),
        .reset_player(reset_player),
        .song(song),
        .song_done(song_done)
    );

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // Tests
    initial begin
        //testing play song 
        #25
        play_button = 1; 
        next_button = 0;
        song_done = 0;
        #10; 
        play_button = 0; 
        #10;
        
        //testing play song 2nd time (pause)
        play_button = 1; 
        next_button = 0;
        song_done = 0;
        #10; 
        play_button = 0;
        #10;
        
        //testing play song again
        play_button = 1; 
        next_button = 0;
        song_done = 0;
        #10; 
        play_button = 0;
        #10
        
        
        //testing next song
        play_button = 0;                  
        next_button = 1;                  
        song_done = 0;                    
        #10;                              
        next_button = 0;             
        #10                               
        
        //testing play song
        play_button = 1;                  
        next_button = 0;                  
        song_done = 0;                    
        #10;                              
        play_button = 0;                  
        #10                               
        
        //testing play song and next song at the same time 
        play_button = 1;                  
        next_button = 1;                  
        song_done = 0;                    
        #10;     
        play_button = 0;                          
        next_button = 0;                  
        #10                               
        
        //testing song done
        play_button = 0;                  
        next_button = 0;                  
        song_done = 1;                    
        #10;                            
        song_done = 0;                  
        #20                               
        
        // testing play song 
        play_button = 1; 
        next_button = 0;
        song_done = 0;
        #10; 
        play_button = 0;
        #10
        
        //skipping songs
        next_button = 1;
        #10
        next_button = 0;
        #10
        next_button = 1;
        #10
        next_button = 0;
        #10
        next_button = 1;
        #10
        next_button = 0;
        #10;
    end

endmodule
