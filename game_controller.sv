module game_controller(clk, buttons, bird, pipes, gameState);
	 
	 // Ports
    input clk;
	 input [1:0] buttons;
    output reg signed [9:0] bird;
    output reg [19:0] pipes [0:2];
	 output reg [1:0] gameState;

    reg signed [9:0] bird_d;
    reg [19:0] pipes_d [0:2];
	 
	 // Physics
	 localparam GRAVITY = 10'sd13;
	 localparam INIT_VELOCITY = 11'sd300;
	 
	 reg signed [10:0] precise_velocity;
	 reg signed [10:0] precise_velocity_d;
	 
	 // Pipe Generation
	 localparam NUM_PIPES = 3;
	 localparam PIPE_GEN_PERIOD = 240; // 1 pipe every 240 frames
	 wire pipe_clk;
	 reg [1:0] pipe_clk_sr;
	 
	 // Controls
	 wire jump_btn = buttons[1];
	 reg [1:0] jump_btn_sr;

    initial begin
		bird = 10'sd100;
		precise_velocity = INIT_VELOCITY;
	 end

    clock_divider #(PIPE_GEN_PERIOD) newpipeclock(clk, 1, 0, pipe_clk); // divide 60 Hz to 0.5 Hz

    always @(posedge clk) begin
        bird <= bird_d;
		  pipe_clk_sr <= {pipe_clk_sr[0], pipe_clk};
		  jump_btn_sr <= {jump_btn_sr[0], jump_btn};
        for (integer i = 0; i < 3; i = i + 1) begin
            pipes[i] <= pipes_d[i];
        end
		  precise_velocity <= precise_velocity_d;
    end

    always_comb begin
        bird_d = bird - (precise_velocity / 50);
		  
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
				pipes_d[NUM_PIPES - 1] = { 10'd300, 10'd100 };
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
endmodule