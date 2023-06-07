module flappyblock_top(clk, rst, btn, sda, scl, hsync, vsync, red, green, blue, seg_out);
    input clk, rst, btn;
	 inout sda;
	 output scl;
    output hsync, vsync;
    output [3:0] red, green, blue;
	 output [7:0] seg_out [0:5];
	 wire [7:0] score;

    wire vga_clk;
    pll clocks(clk, vga_clk);
	 
	 wire [1:0] buttons;
	 
	 assign buttons = {z, c};

    vga_top vga_driver(vga_clk, rst, buttons, hsync, vsync, red, green, blue, score);
	 nunchuckDriver UUT2(clk, sda, scl, _, _, _, _, _, z, c, ~rst);
	 Combined_Seven_Seg sevenseg(score, 0, seg_out[0], seg_out[1], seg_out[2], seg_out[3], seg_out[4], seg_out[5]);
endmodule