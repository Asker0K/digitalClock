`timescale 1ns/1ns
module TestBench;

logic reset;
logic clk;
logic pause;
logic set;
logic [6:0] seg [5:0];
logic [3:0] num [5:0];
logic [3:0] LEDs;

parameter p_initial = 17'b 0_1011_0111_1010_1100;

TopEntity 
#(
	.p_initial(p_initial)
 )

 topEntity (.*);
 
 initial begin
		clk <= 0;
		reset <= 1;
		pause <= 0;
		set <= 0;
    
		fork 
			// block 1 - clock simulation
			forever #1 clk = ~clk;
			
			// block 2 - signals' vectors
			begin
				#(10000) 	reset = ~reset;
				#(10500) 	reset = ~reset;
				#(11000) 	set = ~set;
				#(12400) 	set = ~set;			
				#(13000)	pause = ~pause;
				#(13500)	pause = ~pause;
			end
		join
	end
endmodule
