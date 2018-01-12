library verilog;
use verilog.vl_types.all;
entity al422_bam is
    generic(
        BIT_COUNTER_WIDTH: integer := 3;
        led_row_preload : vl_logic_vector(0 to 2) := (Hi1, Hi1, Hi1)
    );
    port(
        in_clk          : in     vl_logic;
        in_nrst         : in     vl_logic;
        in_data         : in     vl_logic_vector(7 downto 0);
        al422_nrst_out  : out    vl_logic;
        al422_re_out    : out    vl_logic;
        led_clk_out     : out    vl_logic;
        led_oe_out      : out    vl_logic;
        led_lat_out     : out    vl_logic;
        led_row         : out    vl_logic_vector(4 downto 0);
        rgb1            : out    vl_logic_vector(2 downto 0);
        rgb2            : out    vl_logic_vector(2 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of BIT_COUNTER_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of led_row_preload : constant is 1;
end al422_bam;
