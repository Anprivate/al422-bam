/***************************************************************************************************/
// definitions for modes of operation
/***************************************************************************************************/

// input color data format - only one line must be uncommented
// RGB888 -  3 bytes per pixel, 
// RGB161616 - 6 bytes per pixel, 16 bit per color
`define RGB888	1
//`define RGB161616	1

// LED panel RGB inputs quantity (1 or 2)
`define RGB_outs	2

// LED panel scan type - only one line must be uncommented
`define SCAN_x8 	1
//`define SCAN_x16 	1
//`define SCAN_x32	1

// LED panels total pixels count
`define PIXEL_COUNT 	64

// phases of output signals for LED. If commented - active HIGH and RISING for CLK
//`define LED_LAT_ACTIVE_LOW	1
`define LED_OE_ACTIVE_LOW	1
//`define LED_CLK_ON_FALL		1

`define OE_PRESCALER	16
`define OE_PREDELAY	31
`define OE_POSTDELAY	31

/***************************************************************************************************/
// main modules body - DON'T MODIFY ANYTHING BELOW THIS LINE!!!
/***************************************************************************************************/
module al422_bam (
	input wire in_clk, in_nrst,
	// al422 pins
	input wire [7:0] in_data,
	output wire al422_nrst_out, al422_re_out,
	// led outpur pins HUB75E
	output wire led_clk_out, led_oe_out, led_lat_out,
	// up to 1/32 scan
	output wire [4:0] led_row,
	// up to 2 RGB outputs
	output wire [2:0] rgb1, rgb2
);

	wire led_oe;
	wire led_lat;
	wire led_clk;
	
	parameter BIT_COUNTER_WIDTH = 3;
	reg [BIT_COUNTER_WIDTH - 1:0] bit_counter;

`ifdef LED_LAT_ACTIVE_LOW
	assign led_lat_out = ~led_lat;
`else
	assign led_lat_out = led_lat;
`endif

`ifdef LED_OE_ACTIVE_LOW
	assign led_oe_out = ~led_oe;
`else
	assign led_oe_out = led_oe;
`endif
	
	
`ifdef LED_CLK_ON_FALL
	assign led_clk_out = ~led_clk;
`else
	assign led_clk_out = led_clk;
`endif

`ifdef SCAN_x8
	reg [2:0] led_row_in;
	parameter led_row_preload = 3'b111;
`endif

`ifdef SCAN_x16
	reg [3:0] led_row_in;
	parameter led_row_preload = 4'b1111;
`endif

`ifdef SCAN_x32
	reg [4:0] led_row_in;
	parameter led_row_preload = 5'b11111;
`endif
	
	// first stage io
	wire first_stage_module_start;
	reg first_stage_address_reset;
	wire first_stage_is_busy;
	wire first_stage_data_ready;
	
	// oe_processor io
	wire oe_processor_start;
	wire oe_processor_is_busy;
		
	wire data_ready_and_oe_not_busy;
	assign data_ready_and_oe_not_busy = first_stage_data_ready & !oe_processor_is_busy;
	
	wire both_modules_not_busy;
	assign both_modules_not_busy = !(first_stage_is_busy | oe_processor_is_busy);
	
	assign first_stage_module_start = both_modules_not_busy;
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			first_stage_address_reset <= 1'b0;
		else
			first_stage_address_reset <= (led_row_in == (led_row_preload - 1'b1));
			
	al422_bam_first_stage #(`PIXEL_COUNT, `RGB_outs) first_stage(
		.in_nrst(in_nrst), .in_clk(in_clk),
		.in_data(in_data),
		.bit_counter(bit_counter), 
		.module_start(first_stage_module_start),
		.from_zero_address(first_stage_address_reset),
		.rgb_out1(rgb1), .rgb_out2(rgb2),
		.led_clk(led_clk),
		.al422_re(al422_re_out), .al422_nrst(al422_nrst_out),
		.module_is_busy(first_stage_is_busy),
		.row_data_ready(first_stage_data_ready)
	);

	assign oe_processor_start = data_ready_and_oe_not_busy; 
	assign led_lat = data_ready_and_oe_not_busy;
			
	al422_bam_oe_processor #(`OE_PRESCALER, `OE_PREDELAY, `OE_POSTDELAY, 3) oe_processor ( 
		.in_nrst(in_nrst), .in_clk(in_clk),
		.module_start(oe_processor_start),
		.bit_counter(bit_counter),
		.module_is_busy(oe_processor_is_busy),
		.led_oe(led_oe)
	);
		
	assign led_row = led_row_in;
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			led_row_in <= led_row_preload;
		else
			if (data_ready_and_oe_not_busy)
				led_row_in <= led_row_in + 1'b1;

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			bit_counter <= 1'b0;
		else
			if ((led_row_in == (led_row_preload - 1'b1)) & data_ready_and_oe_not_busy) 
				bit_counter <= bit_counter + 1'b1;
endmodule