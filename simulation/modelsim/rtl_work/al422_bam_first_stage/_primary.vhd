library verilog;
use verilog.vl_types.all;
entity al422_bam_first_stage is
    generic(
        PIXEL_COUNT     : vl_notype;
        PIXEL_COUNTER_WIDTH: vl_notype
    );
    port(
        in_nrst         : in     vl_logic;
        in_clk          : in     vl_logic;
        in_data         : in     vl_logic_vector(7 downto 0);
        bit_counter     : in     vl_logic_vector(2 downto 0);
        module_start    : in     vl_logic;
        from_zero_address: in     vl_logic;
        rgb_out1        : out    vl_logic_vector(2 downto 0);
        rgb_out2        : out    vl_logic_vector(2 downto 0);
        led_clk         : out    vl_logic;
        al422_re        : out    vl_logic;
        al422_nrst      : out    vl_logic;
        module_is_busy  : out    vl_logic;
        row_data_ready  : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PIXEL_COUNT : constant is 5;
    attribute mti_svvh_generic_type of PIXEL_COUNTER_WIDTH : constant is 3;
end al422_bam_first_stage;
