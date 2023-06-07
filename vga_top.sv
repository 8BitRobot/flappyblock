module vga_top(clk, rst, buttons, hsync, vsync, red, green, blue, score);
    input clk, rst;
    input [1:0] buttons;
    output hsync, vsync;
    output [3:0] red, green, blue;
	 output [7:0] score;
    
    wire [9:0] hc, vc;
    wire [9:0] x, y;
    assign x = hc / 2;
    assign y = vc / 2;

    wire [7:0] dataOut;
    wire [19:0] address;
    wire [7:0] dataIn;

    graphics_controller graphics(clk, buttons, x, y, dataIn, address, score);
    memory_controller pingpongRAM(clk, address, dataIn, hc, vc, dataOut);
    
    wire [2:0] input_red, input_green;
    wire [1:0] input_blue;

    assign input_red = dataOut[7:5];
    assign input_green = dataOut[4:2];
    assign input_blue = dataOut[1:0];

    vga disp(clk, input_red, input_green, input_blue, rst, hc, vc, hsync, vsync, red, green, blue);
endmodule