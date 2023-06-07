module game_controller(clk, buttons, bird, pipes, gameState, score);
	 localparam NUM_PIPES = 5;
	 
	 // Ports
    input clk;
	 input [1:0] buttons;
    output reg signed [9:0] bird;
    output reg [19:0] pipes [0:NUM_PIPES-1];
	 
	 localparam RUNNING = 0;
	 localparam PAUSED = 1;
	 localparam GAME_OVER = 2;
	 localparam RESETTING = 3;
	 output reg [1:0] gameState = RUNNING;
	 
	 // Scoring
	 reg [0:(NUM_PIPES - 1)] pipeIsZero;
	 output reg [7:0] score;
	 reg [7:0] score_d;
	 
	 // Game State
	 reg [1:0] gameState_d;

	 // Bird and Pipe Next Values
    reg signed [9:0] bird_d;
    reg [19:0] pipes_d [0:NUM_PIPES-1];
	 
	 // Physics
	 localparam GRAVITY = 10'sd13;
	 localparam INIT_VELOCITY = 11'sd225;
	 
	 reg signed [10:0] precise_velocity;
	 reg signed [10:0] precise_velocity_d;
	 
	 // Collisions
	 localparam BIRD_LEFT = 30;
	 localparam BIRD_RIGHT = 50;
	 wire [9:0] bird_bottom = bird + 20;
	 reg collision;
	 
	 // Pipe Generation
	 localparam PIPE_GEN_PERIOD = 90; // 1 pipe every 180 frames
	 wire pipe_clk;
	 reg [1:0] pipe_clk_sr;
	 wire [9:0] randOut;
	 
	 // Controls
	 wire jump_btn = buttons[0];
	 reg [1:0] jump_btn_sr;
	 
	 wire pause_btn = buttons[1];
	 reg [1:0] pause_btn_sr;

    initial begin
		bird = 10'sd110;
		precise_velocity = INIT_VELOCITY;
		score = 0;
	 end

    clock_divider #(PIPE_GEN_PERIOD) newpipeclock(clk, 1, 0, pipe_clk); // divide 60 Hz to 0.5 Hz
	 rng random(pipe_clk, 0, randOut);

    always @(posedge clk) begin
        bird <= bird_d;
		  pipe_clk_sr <= {pipe_clk_sr[0], pipe_clk};
		  jump_btn_sr <= {jump_btn_sr[0], jump_btn};
		  pause_btn_sr <= {pause_btn_sr[0], pause_btn};
		  gameState <= gameState_d;
		  score <= score_d;
		  
        for (integer i = 0; i < NUM_PIPES; i = i + 1) begin
            pipes[i] <= pipes_d[i];
        end
		  precise_velocity <= precise_velocity_d;
    end

	   
	 integer pipePassed;
    always_comb begin
	     if (pipes[3][19:10] < pipes[4][19:10]) begin
				collision = (bird_bottom > 240) || (pipes[3][19:10] < 10'sd50 && (pipes[3][9:0] > bird || bird_bottom > (pipes[3][9:0] + 10'sd70)) && pipes[3] != 20'b0);
		  end else begin
				collision = (bird_bottom > 240) || (pipes[4][19:10] < 10'sd50 && (pipes[4][9:0] > bird || bird_bottom > (pipes[4][9:0] + 10'sd70)) && pipes[4] != 20'b0);
		  end
			
		  for (integer i = 0; i < NUM_PIPES; i = i + 1) begin
				if ((pipes[i][19:10] == 0 && pipes[i][9:0] != 0)) begin
					pipeIsZero[i] = 1;
				end else begin
					pipeIsZero[i] = 0;
				end
		  end
		  
		  case (gameState)
				RUNNING: begin
					if (collision) begin
						gameState_d = GAME_OVER;
					end else if (pause_btn_sr == 2'b01) begin
						gameState_d = PAUSED;
					end else begin
						gameState_d = RUNNING;
					end
				end
				PAUSED: begin
					if (pause_btn_sr == 2'b01) begin
						gameState_d = RUNNING;
					end else begin
						gameState_d = PAUSED;
					end
				end
				GAME_OVER: begin
					if (pause_btn_sr == 2'b01) begin
						gameState_d = RESETTING;
					end else begin
						gameState_d = GAME_OVER;
					end
				end
				RESETTING: begin
					gameState_d = RUNNING;
				end
				default: begin
					gameState_d = gameState;
				end
		  endcase
		  
		  if (gameState == PAUSED || gameState == GAME_OVER) begin
			  bird_d = bird;
			  precise_velocity_d = precise_velocity;
			  for (integer i = 0; i < NUM_PIPES; i = i + 1) begin
					pipes_d[i] = pipes[i];
			  end
			  score_d = score;
		  end else if (gameState == RESETTING) begin
				bird_d = 10'sd100;
				precise_velocity_d = INIT_VELOCITY;
				for (integer i = 0; i < NUM_PIPES; i = i + 1) begin
					pipes_d[i] = 0;
			   end
				score_d = 0;
		  end else begin
			  bird_d = bird - (precise_velocity / 50);
		     score_d = score + |pipeIsZero;
			  
			  if (jump_btn_sr == 2'b01) begin
					precise_velocity_d = INIT_VELOCITY;
			  end else begin
					if (precise_velocity - GRAVITY > precise_velocity) begin
						precise_velocity_d = precise_velocity;
					end else begin
						precise_velocity_d = precise_velocity - GRAVITY;
					end
			  end
			  
			  if (pipe_clk_sr == 2'b01) begin
					for (integer i = 0; i < NUM_PIPES - 1; i = i + 1) begin
						pipes_d[i] = pipes[i + 1];
					end
					pipes_d[NUM_PIPES - 1] = { 10'd300, randOut };
			  end else begin
					for (integer i = 0; i < NUM_PIPES; i = i + 1) begin
						if (pipes[i] == 0) begin
							 pipes_d[i] = 0;
						end else begin
							 pipes_d[i] = { pipes[i][19:10] - 1, pipes[i][9:0] };
						end
					end
			  end
		 end
    end
endmodule