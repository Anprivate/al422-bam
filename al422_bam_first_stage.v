module al422_bam_first_stage(
	input wire in_nrst,
	input wire in_clk,
	input wire [7:0] in_data,
	input wire [2:0] bit_counter,
	input wire module_start,
	input wire from_zero_address,
	output reg [2:0] rgb_out1, rgb_out2,
	output reg led_clk,
	output reg al422_re,
	output reg al422_nrst,
	output reg module_is_busy,
	output reg row_data_ready
);

	parameter PIXEL_COUNT;
	parameter PIXEL_COUNTER_WIDTH = $clog2(PIXEL_COUNT);
	
	// 
	reg [7:0] in_data_buffer;
	//
	reg [1:0] phase_cntr;
	wire [2:0] phase_reg;
	wire last_phase;
	//
	reg local_en;
	reg data_in_data_buffer_valid;
	reg first_cycle_finished;
	reg out_data_valid;

	wire local_reset;
	assign local_reset = !module_is_busy & module_start;
	
	reg [PIXEL_COUNTER_WIDTH - 1:0] pixel_counter;

	reg [2:0] rgb_tmp;

	wire last_pixel;
	
	// in_data_buffer
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			in_data_buffer <= 8'h00;
		else
			in_data_buffer <= in_data;

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
				data_in_data_buffer_valid <= 1'b0;
		else
			if (local_reset) 
				data_in_data_buffer_valid <= 1'b0;
			else
				if (al422_nrst)
					data_in_data_buffer_valid <= 1'b1;
	
	assign phase_reg[0] = (phase_cntr == 2'h0);
	assign phase_reg[1] = (phase_cntr == 2'h1);
	assign phase_reg[2] = (phase_cntr == 2'h2);
	
	assign last_phase = phase_reg[2];
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			phase_cntr <= 0;
		else
			if (local_reset)
				phase_cntr <= 0;
			else
				if (data_in_data_buffer_valid & module_is_busy)
					if (last_phase)
						phase_cntr <= 0;
					else
						phase_cntr <= phase_cntr + 1;
	
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

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			led_clk <= 1'b0;
		else
			if (local_reset)
				led_clk <= 1'b0;
			else
				led_clk <= out_data_valid;

	// pixel counter
	assign last_pixel = (pixel_counter == (PIXEL_COUNT - 1));
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			pixel_counter <= 0;
		else
			if (local_reset)
				pixel_counter <= 0;
			else
				if (data_in_data_buffer_valid & led_clk)
					if (last_pixel)
						pixel_counter <= 0;
					else
						pixel_counter <= pixel_counter + 1;

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			rgb_tmp <= 0;
		else
			if (local_reset)
				rgb_tmp <= 0;
			else
				if (data_in_data_buffer_valid)
					rgb_tmp[phase_cntr] <= in_data_buffer[bit_counter];
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
		begin
			rgb_out1 <= 0;
			rgb_out2 <= 0;
			out_data_valid <= 1'b0;
		end
		else
			if (local_reset)
			begin
				rgb_out1 <= 0;
				rgb_out2 <= 0;
				out_data_valid <= 1'b0;
			end
			else
				if (data_in_data_buffer_valid & phase_reg[0] & first_cycle_finished & module_is_busy)
				begin
					rgb_out1 <= rgb_tmp;
					out_data_valid <= 1'b1;
				end
				else
					out_data_valid <= 1'b0;
				
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			al422_re <= 1'b1;
		else
			if (local_reset)
				al422_re <= 1'b0;
			else
				if ((pixel_counter == (PIXEL_COUNT - 2)) & phase_reg[1])
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
				if (data_in_data_buffer_valid & last_phase & last_pixel)
					module_is_busy <= 1'b0;
				
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			row_data_ready <= 1'b0;
		else
			if (local_reset)
				row_data_ready <= 1'b0;
			else
				if (data_in_data_buffer_valid & last_phase & last_pixel)
					row_data_ready <= 1'b1;
endmodule
