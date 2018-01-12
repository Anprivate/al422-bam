module al422_bam_first_stage(
	input wire in_nrst,
	input wire in_clk,
	input wire [7:0] in_data,
	input wire [2:0] bit_counter,
	input wire module_start,
	input wire from_zero_address,
	output reg [2:0] rgb_out1, rgb_out2,
	output wire led_clk,
	output reg al422_re,
	output reg al422_nrst,
	output reg module_is_busy,
	output reg row_data_ready
);

	parameter PIXEL_COUNT;
	parameter RGB_outputs;

	parameter bits_in_phase_cntr = (RGB_outputs == 2) ? 3 : 2;
	parameter bits_in_phase_reg = (RGB_outputs == 2) ? 6 : 3;
	
	reg [bits_in_phase_cntr - 1:0] phase_cntr;
	wire [bits_in_phase_reg - 1:0] phase_reg;
	
	wire last_phase;
	//
	reg local_en;
	reg first_cycle_finished;

	wire local_reset;
	assign local_reset = !module_is_busy & module_start;
	
	parameter PIXEL_COUNTER_WIDTH = $clog2(PIXEL_COUNT);
	reg [PIXEL_COUNTER_WIDTH - 1:0] pixel_counter;

	reg [2:0] rgb_tmp;

	wire last_pixel;
	
	genvar i;
	generate
	for (i = 0; i < bits_in_phase_reg; i = i + 1)
	begin : phase_regs_gen
		assign phase_reg[i] = (phase_cntr == i);
	end
	endgenerate

	assign last_phase = phase_reg[bits_in_phase_reg - 1];
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			phase_cntr <= 0;
		else
			if (local_reset)
				phase_cntr <= 0;
			else
				if (module_is_busy & al422_nrst)
					if (last_phase)
						phase_cntr <= 0;
					else
						phase_cntr <= phase_cntr + 1'b1;
	
	// first_cycle_finished
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			first_cycle_finished <= 1'b0;
		else
			if (local_reset)
				first_cycle_finished <= 1'b0;
			else
				if (last_phase)
					first_cycle_finished <= 1'b1;

	assign led_clk = first_cycle_finished & phase_reg[2];

	// pixel counter
	assign last_pixel = (pixel_counter == (PIXEL_COUNT - 1));
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			pixel_counter <= 0;
		else
			if (local_reset)
				pixel_counter <= 0;
			else
				if (last_phase & first_cycle_finished)
					if (last_pixel)
						pixel_counter <= 0;
					else
						pixel_counter <= pixel_counter + 1'b1;

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			rgb_tmp <= 0;
		else
		begin
			rgb_tmp[0] <= in_data[bit_counter];
			rgb_tmp[2:1] <= rgb_tmp[1:0];
		end
	
	
	wire load_rgb1, load_rgb2;
	
	generate
		if (RGB_outputs == 1)
		begin
			assign load_rgb1 = phase_reg[0] & first_cycle_finished & module_is_busy;
		end
		else
		begin
			assign load_rgb1 = phase_reg[3] & module_is_busy;
			assign load_rgb2 = phase_reg[0] & module_is_busy;
		end
	endgenerate
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
		begin
			rgb_out1 <= 0;
			rgb_out2 <= 0;
		end
		else
		begin
			if (load_rgb1)
				rgb_out1 <= rgb_tmp;
			if (load_rgb2)
				rgb_out2 <= rgb_tmp;
		end
				
	wire last_re_phase;
	generate
		if (RGB_outputs == 1)
			assign last_re_phase = (pixel_counter == (PIXEL_COUNT - 2)) & phase_reg[2];
		else
			assign last_re_phase = (pixel_counter == (PIXEL_COUNT - 2)) & phase_reg[5];
	endgenerate
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			al422_re <= 1'b1;
		else
			if (local_reset)
				al422_re <= 1'b0;
			else
				if (last_re_phase)
					al422_re <= 1'b1;
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			al422_nrst <= 1'b1;
		else
			al422_nrst <= !(local_reset & from_zero_address);

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			module_is_busy <= 1'b0;
		else
			if (local_reset)
				module_is_busy <= 1'b1;
			else
				if (last_phase & last_pixel)
					module_is_busy <= 1'b0;
				
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			row_data_ready <= 1'b0;
		else
			if (local_reset)
				row_data_ready <= 1'b0;
			else
				if (last_phase & last_pixel)
					row_data_ready <= 1'b1;
endmodule
