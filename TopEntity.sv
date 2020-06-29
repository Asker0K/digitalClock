module TopEntity
#(
    parameter p_initial = 17'b 0_1011_0111_1010_1100
)
(
    input logic reset,
    input logic clk,
	 input logic pause,
	 input logic set,
    
    output logic [6:0] seg [5:0],
	 output logic [3:0] num [5:0],
	 output logic [3:0] LEDs
);

    //logic [3:0] num [5:0];
    Counter
    #(
        .initial_value(p_initial)
    )
    counter
    (
        .reset(reset),
		  .set(set),
		  .pause(pause),
		  .clk(clk),
		  .num(num)
		  
    );
    Display display (
		  .num(num),
        .seg(seg),
		  .LEDs(LEDs)
    );
endmodule
