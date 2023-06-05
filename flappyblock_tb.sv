module flappyblock_tb(clk);
	output reg clk;
	wire [9:0] bird;
	wire [19:0] pipes [0:2];
	
	initial begin
		clk = 0;
	end
	
	always begin
		#10 clk = ~clk;
	end
	
	vga_top vga_driver(clk, 0, 0, hsync, vsync, red, green, blue);
endmodule