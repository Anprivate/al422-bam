/***************************************************************************************************/
// definitions for modes of operation
/***************************************************************************************************/

// input color data format - only one line must be uncommented
// RGB888 -  3 bytes per pixel, 
// RGB161616 - 6 bytes per pixel, 16 bit per color
`define RGB888	1
//`define RGB161616	1

// LED panel RGB inputs quantity - only one line must be uncommented
`define RGB_out1	1
//`define RGB_out2	1

// LED panel scan type - only one line must be uncommented
`define SCAN_x8 	1
//`define SCAN_x16 	1
//`define SCAN_x32	1

// LED panels total pixels count
`define PIXEL_COUNT 	8

// phases of output signals for LED. If commented - active HIGH and RISING for CLK
//`define LED_LAT_ACTIVE_LOW	1
`define LED_OE_ACTIVE_LOW	1
//`define LED_CLK_ON_FALL		1

// bits in PWM counter. Maximum is 8 bits for TRUECOLOR and 5 bits for HIGHCOLOR
`define PWM_COUNTER_WIDTH	2

/***************************************************************************************************/
// main modules body - DON'T MODIFY ANYTHING BELOW THIS LINE!!!
/***************************************************************************************************/
module al422_bam (
	input wire in_clk, in_nrst,
	// al422 pins
	input wire [7:0] in_data,
	output reg al422_nrst, al422_re,
	// led outpur pins HUB75E
	output wire led_clk_out, led_oe_out, led_lat_out,
	// up to 1/32 scan
	output reg [4:0] led_row,
	// up to 2 RGB outputs
	output reg [2:0] rgb1, rgb2
);

	reg led_oe;
	reg led_lat;
	reg led_clk;
	
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
	
	// in_data_buffer
	reg [7:0] in_data_buffer;
	reg data_in_data_buffer_valid;
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
		begin
			data_in_data_buffer_valid <= 1'b0;
			in_data_buffer <= 8'h00;
		end
		else
		begin
			data_in_data_buffer_valid <= 1'b1;
			in_data_buffer <= in_data;
		end

	reg [1:0] phase_cntr;
	wire [2:0] phase_reg;
	
	assign phase_reg[0] = (phase_cntr == 2'h0);
	assign phase_reg[1] = (phase_cntr == 2'h1);
	assign phase_reg[2] = (phase_cntr == 2'h2);
	
	wire last_phase;
	assign last_phase = phase_reg[2];
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			phase_cntr <= 0;
		else
			if (data_in_data_buffer_valid)
				if (last_phase)
					phase_cntr <= 0;
				else
					phase_cntr <= phase_cntr + 1;

	reg first_cycle_finished;
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			first_cycle_finished <= 1'b0;
		else
			if (last_phase)
				first_cycle_finished <= 1'b1;
	
	// pixel counter
	parameter PIXEL_COUNTER_WIDTH = $clog2(`PIXEL_COUNT);
	reg [PIXEL_COUNTER_WIDTH:0] pixel_counter;

	wire last_pixel;
	assign last_pixel = (pixel_counter == (`PIXEL_COUNT + 2));
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			pixel_counter <= 0;
		else
			if (data_in_data_buffer_valid & last_phase)
				if (last_pixel)
					pixel_counter <= 0;
				else
					pixel_counter <= pixel_counter + 1;

	reg data_in_panel_row_ready;
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			data_in_panel_row_ready <= 1'b0;
		else
			if (data_in_data_buffer_valid & last_phase & last_pixel)
				data_in_panel_row_ready <= 1'b1;
	
	parameter BIT_COUNTER_WIDTH = 3;
	reg [BIT_COUNTER_WIDTH - 1:0] bit_counter;

	reg [2:0] rgb_tmp;
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			rgb_tmp <= 0;
		else
			if (data_in_data_buffer_valid)
				rgb_tmp[phase_cntr] <= in_data_buffer[bit_counter];
	
	wire tmp_rgb_strobe;
	assign tmp_rgb_strobe = phase_reg[0];
	reg out_data_valid;
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
		begin
			rgb1 <= 0;
			rgb2 <= 0;
			out_data_valid <= 1'b0;
		end
		else
			if (data_in_data_buffer_valid & tmp_rgb_strobe & first_cycle_finished)
			begin
				rgb1 <= rgb_tmp;
				out_data_valid <= 1'b1;
			end
			else
				out_data_valid <= 1'b0;

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			led_clk <= 1'b0;
		else
			led_clk <= out_data_valid;
				
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			bit_counter <= 0;
		else
			bit_counter <= 0;
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			al422_re <= 1'b0;
		else
			if ((pixel_counter == (`PIXEL_COUNT - 1)) & phase_reg[1])
				al422_re <= 1'b1;

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			al422_nrst <= 1'b1;
		else
			al422_nrst <= 1'b1;
endmodule