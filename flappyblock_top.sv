module flappyblock_top(clk, rst, btn, hsync, vsync, red, green, blue);
    input clk, rst, btn;
    output hsync, vsync;
    output [3:0] red, green, blue;

    wire vga_clk;
    pll clocks(clk, vga_clk);
	 
	 wire [1:0] buttons;
	 
	 assign buttons = {btn, 1'b0};

    vga_top vga_driver(vga_clk, rst, buttons, hsync, vsync, red, green, blue);
endmodule