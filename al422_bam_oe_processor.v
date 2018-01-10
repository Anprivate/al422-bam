module al422_bam_oe_processor(
	input wire in_nrst,
	input wire in_clk,
	input wire module_start,
	input wire [7:0] oe_duration,
	output reg module_is_busy,
	output wire led_oe
);

	parameter OE_PRESCALER;
	parameter OE_PREDELAY;
	parameter OE_POSTDELAY;
	
	parameter PRESCALER_COUNTER_WIDTH = $clog2(OE_PRESCALER);
	parameter PREDELAY_COUNTER_WIDTH = $clog2(OE_PREDELAY);
	parameter POSTDELAY_COUNTER_WIDTH = $clog2(OE_POSTDELAY);
	
	reg [7:0] main_counter;
	reg [PRESCALER_COUNTER_WIDTH - 1:0] prescaler_counter;
	reg [PREDELAY_COUNTER_WIDTH - 1:0] predelay_counter;
	reg [POSTDELAY_COUNTER_WIDTH - 1:0] postdelay_counter;
	
	reg [1:0] phase_cntr;
	
	wire [3:0] phase_reg;
	assign phase_reg[0] = (phase_cntr == 2'h0);
	assign phase_reg[1] = (phase_cntr == 2'h1);
	assign phase_reg[2] = (phase_cntr == 2'h2);
	assign phase_reg[3] = (phase_cntr == 2'h3);
	
	assign led_oe = phase_reg[1];
	
	wire local_reset;
	assign local_reset = !module_is_busy & module_start;

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			phase_cntr <= 2'b0;
		else
			if (local_reset)
				phase_cntr <= 2'b0;
			else
				if ((phase_reg[0] & (predelay_counter == 0)) |
					(phase_reg[1] & (main_counter == 1) & (prescaler_counter == 0)) |
					(phase_reg[2] & (postdelay_counter == 0)))
					phase_cntr <= phase_cntr + 1;

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			predelay_counter <= OE_PREDELAY - 1;
		else
			if (local_reset)
				predelay_counter <= OE_PREDELAY - 1;
			else
				if (module_is_busy & phase_reg[0])
					predelay_counter <= predelay_counter - 1;
				
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			prescaler_counter <= OE_PRESCALER - 1;
		else
			if (local_reset)
				prescaler_counter <= OE_PRESCALER - 1;
			else
				if (module_is_busy & phase_reg[1])
					if (prescaler_counter == 0)
						prescaler_counter <= OE_PRESCALER - 1;
					else
						prescaler_counter <= prescaler_counter - 1;

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			main_counter <= 8'hFF;
		else
			if (local_reset)
				main_counter <= oe_duration;
			else
				if (module_is_busy & phase_reg[1] & (prescaler_counter == 0))
					main_counter <= main_counter - 1;

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			postdelay_counter <= OE_POSTDELAY - 1;
		else
			if (local_reset)
				postdelay_counter <= OE_POSTDELAY - 1;
			else
				if (module_is_busy & phase_reg[2])
					postdelay_counter <= postdelay_counter - 1;

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			module_is_busy <= 1'b0;
		else
			if (local_reset)
				module_is_busy <= 1'b1;
			else
				if (phase_reg[3])
					module_is_busy <= 1'b0;
	
endmodule
