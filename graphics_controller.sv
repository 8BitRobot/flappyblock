module graphics_controller(clk, buttons, x, y, dataOut, address);
	 localparam NUM_PIPES = 3;
	 
	 localparam SCALE = 2;
	 localparam MAX_X = 320;
	 localparam MAX_Y = 240;
	 
    input clk;
	 input [1:0] buttons;
    input [9:0] x;
    input [9:0] y;
	 
    // input [2:0] controls;
    output reg [7:0] dataOut; // color going out
    output reg [19:0] address;
	 
	 localparam RUNNING = 0;
	 localparam PAUSED = 1;
	 localparam GAME_OVER = 2;
	 
	 wire [1:0] gameState;

    wire [9:0] bird;
    wire [19:0] pipes [0:(NUM_PIPES - 1)];
	 reg [0:(NUM_PIPES - 1)] pipeExists;

    wire game_clk;
    clock_divider #(25000000) gameclock(clk, 60, 0, game_clk);
    game_controller gamestate(game_clk, buttons, bird, pipes, gameState);

    //YELLOW: 11111000

    always_comb begin
        if (x >= MAX_X || y >= MAX_Y) begin
            address = 0;
        end
        else begin
            address = y * MAX_X + x;
        end
		  
		  for (integer i = 0; i < NUM_PIPES; i = i + 1) begin
				pipeExists[i] = (x >= pipes[i][19:10] && x < pipes[i][19:10] + 30 && (y < pipes[i][9:0] || y >= pipes[i][9:0] + 70));
		  end
		  		
        if ((x >= 30 && x < 50) && (y >= bird && y < bird + 20)) begin
            dataOut = 8'b11110100; //bird
        end else if (|pipeExists) begin
            dataOut = 8'b00010000; // pipe
		  end else begin
            dataOut = 8'b01111011; //background (sky)
        end
    end
endmodule