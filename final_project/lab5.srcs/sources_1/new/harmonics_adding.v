

module harmonics_adding(
    input [15:0] note_harm1, note_harm2, note_harm3, note_harm4, note_harm5,
    input [5:0] amp_1, amp_2, amp_3, amp_4, amp_5,

    output [15:0] note_with_harms
    );
    
    wire [15:0] note_harm_adjusted1, note_harm_adjusted2, note_harm_adjusted3, note_harm_adjusted4, note_harm_adjusted5;
    assign note_harm_adjusted1 = |amp_1 ? (note_harm1[15] ? -((-note_harm1 + 1'b1) / (amp_1))+1'b1 : (note_harm1 / amp_1)) : 16'd0;
    assign note_harm_adjusted2 = |amp_2 ? (note_harm2[15] ? -((-note_harm2 + 1'b1) / (amp_2))+1'b1 : (note_harm2 / amp_2)) : 16'd0;
    assign note_harm_adjusted3 = |amp_3 ? (note_harm3[15] ? -((-note_harm3 + 1'b1) / (amp_3))+1'b1 : (note_harm3 / amp_3)) : 16'd0;
    assign note_harm_adjusted4 = |amp_4 ? (note_harm4[15] ? -((-note_harm4 + 1'b1) / (amp_4))+1'b1 : (note_harm4 / amp_4)) : 16'd0;
    assign note_harm_adjusted5 = |amp_5 ? (note_harm5[15] ? -((-note_harm5 + 1'b1) / (amp_5))+1'b1 : (note_harm5 / amp_5)) : 16'd0;
    
    assign note_with_harms = note_harm_adjusted1 + note_harm_adjusted2 + note_harm_adjusted3 + note_harm_adjusted4 + note_harm_adjusted5;
    

endmodule
