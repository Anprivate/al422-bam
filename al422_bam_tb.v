`timescale 1 ps/ 1 ps
module al422_bam_vlg_tst();
// test vector input registers
reg in_clk;
reg [15:0] address;
reg [8:0] memory [0:8191];
reg in_nrst;
// wires                                               
wire al422_nrst;
wire al422_re;
wire cntr_nrst;
wire led_clk_out;
wire led_lat_out;
wire led_oe_out;
wire [4:0]  led_row;
wire [2:0]  rgb1;
wire [2:0]  rgb2;

wire [7:0] memory_out;

assign cntr_nrst = al422_nrst & in_nrst;
assign memory_out = memory[address];

al422_bam al422_bam (
// port map - connection between master ports and signals/registers   
	.al422_nrst_out(al422_nrst),
	.al422_re_out(al422_re),
	.in_clk(in_clk),
	.in_data(memory_out),
	.in_nrst(in_nrst),
	.led_clk_out(led_clk_out),
	.led_lat_out(led_lat_out),
	.led_oe_out(led_oe_out),
	.led_row(led_row),
	.rgb1(rgb1),
	.rgb2(rgb2)
);

integer j;

initial
begin
	for (j=0; j < 8192; j=j+1)
		memory[j] <= 8'h00; //reset array

	memory[0] <= 8'hFF;
	memory[1] <= 8'hFF;
	memory[2] <= 8'hFF;
	memory[6] <= 8'hFF;
	memory[7] <= 8'hFF;
	memory[8] <= 8'hFF;
	memory[21] <= 8'hFF;
	memory[22] <= 8'hFF;
	memory[23] <= 8'hFF;
	
	memory[27] <= 8'h02;
	memory[28] <= 8'h02;
	memory[29] <= 8'h02;

	in_nrst = 0;
	in_clk = 0;                                                       
	address = 0;
	#15 in_nrst = 1;
	#2000000 $stop;
end                                                    

always                                                 
  #10 in_clk = ~in_clk;
  
always @ (posedge in_clk)
	if (!al422_re)
	begin
		if (~cntr_nrst)
			address <= 16'h0;
		else
			address <= address + 16'h1;
	end

endmodule

