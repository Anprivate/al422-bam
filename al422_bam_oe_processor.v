module al422_bam_oe_processor(
	in_nrst, in_clk, module_start, bit_counter, module_is_busy, led_oe
);

	parameter OE_PRESCALER;
	parameter OE_PREDELAY;
	parameter OE_POSTDELAY;
	parameter BITS_IN_COUNTER;
	
	input wire in_nrst;
	input wire in_clk;
	input wire module_start;
	input wire [BITS_IN_COUNTER - 1:0] bit_counter;
	output wire module_is_busy;
	output wire led_oe;
	
	parameter PRESCALER_COUNTER_WIDTH = (OE_PRESCALER > 1) ? $clog2(OE_PRESCALER) : 1;
	parameter PREDELAY_COUNTER_WIDTH = $clog2(OE_PREDELAY);
	parameter POSTDELAY_COUNTER_WIDTH = $clog2(OE_POSTDELAY);
	parameter tmpmax1 = (PRESCALER_COUNTER_WIDTH > PREDELAY_COUNTER_WIDTH) ? PRESCALER_COUNTER_WIDTH : PREDELAY_COUNTER_WIDTH;
	parameter FS_COUNTER_WIDTH = (tmpmax1 > POSTDELAY_COUNTER_WIDTH) ? tmpmax1 : POSTDELAY_COUNTER_WIDTH;
	
	parameter MAIN_COUNTER_WIDTH = (1 << BITS_IN_COUNTER);
	
	reg [MAIN_COUNTER_WIDTH - 1:0] main_counter;
	reg [FS_COUNTER_WIDTH - 1:0] fs_counter;
	
	reg [1:0] phase_cntr;
	
	wire phase_idle, phase_pre, phase_main;
	assign phase_idle = (phase_cntr == 2'h0);
	assign phase_pre = (phase_cntr == 2'h1);
	assign phase_main = (phase_cntr == 2'h2);
	
	assign led_oe = phase_main;
	assign module_is_busy = !phase_idle;
	
	wire local_reset;
	assign local_reset = !module_is_busy & module_start;
	
	wire fs_counter_is_zero;
	assign fs_counter_is_zero = (fs_counter == 0);
	
	wire main_counter_is_one;
	assign main_counter_is_one = (main_counter == 1);

	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			phase_cntr <= 2'b0;
		else
			if (local_reset)
				phase_cntr <= 2'b1;
			else
				if ((fs_counter_is_zero & !phase_idle & (main_counter_is_one | !phase_main)))
					phase_cntr <= phase_cntr + 1'b1;

	parameter predelay_preload = OE_PREDELAY - 1'b1;
	parameter prescaler_preload = OE_PRESCALER - 1'b1; 
	parameter postdelay_preload = OE_POSTDELAY - 1'b1;
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			fs_counter <= predelay_preload[FS_COUNTER_WIDTH - 1:0];
		else
			if (local_reset)
				fs_counter <= predelay_preload[FS_COUNTER_WIDTH - 1:0];
			else
				if (fs_counter_is_zero)
					if (phase_pre | (phase_main & !main_counter_is_one))
						fs_counter <= prescaler_preload[FS_COUNTER_WIDTH - 1:0];
					else
						fs_counter <= postdelay_preload[FS_COUNTER_WIDTH - 1:0];
				else
					if (module_is_busy & !phase_idle)
						fs_counter <= fs_counter - 1'b1;
	
	wire [MAIN_COUNTER_WIDTH - 1:0] oe_duration;
	assign oe_duration = (1'b1 << bit_counter);
	
	always @(posedge in_clk or negedge in_nrst)
		if (~in_nrst)
			main_counter <= 8'hFF;
		else
			if (local_reset)
				main_counter <= oe_duration;
			else
				if (module_is_busy & phase_main & fs_counter_is_zero)
					main_counter <= main_counter - 1'b1;

endmodule
