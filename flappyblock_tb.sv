module flappyblock_tb(clk);
	output reg clk;
	reg [1:0] buttons;
	wire [9:0] bird;
	wire [19:0] pipes [0:6];
	wire [1:0] gameState;
	wire [7:0] score;
	
	initial begin
		clk = 0;
	end
	
	always begin
		#10 clk = ~clk;
	end
	
	game_controller game(clk, 2'b0, bird, pipes, gameState, score);
endmodule