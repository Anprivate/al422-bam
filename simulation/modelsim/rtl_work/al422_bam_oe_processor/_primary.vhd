library verilog;
use verilog.vl_types.all;
entity al422_bam_oe_processor is
    generic(
        OE_PRESCALER    : vl_notype;
        OE_PREDELAY     : vl_notype;
        OE_POSTDELAY    : vl_notype;
        BITS_IN_COUNTER : vl_notype;
        PRESCALER_COUNTER_WIDTH: vl_notype;
        PREDELAY_COUNTER_WIDTH: vl_notype;
        POSTDELAY_COUNTER_WIDTH: vl_notype;
        MAIN_COUNTER_WIDTH: vl_notype;
        prescaler_preload: vl_notype
    );
    port(
        in_nrst         : in     vl_logic;
        in_clk          : in     vl_logic;
        module_start    : in     vl_logic;
        bit_counter     : in     vl_logic_vector;
        module_is_busy  : out    vl_logic;
        led_oe          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of OE_PRESCALER : constant is 5;
    attribute mti_svvh_generic_type of OE_PREDELAY : constant is 5;
    attribute mti_svvh_generic_type of OE_POSTDELAY : constant is 5;
    attribute mti_svvh_generic_type of BITS_IN_COUNTER : constant is 5;
    attribute mti_svvh_generic_type of PRESCALER_COUNTER_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of PREDELAY_COUNTER_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of POSTDELAY_COUNTER_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of MAIN_COUNTER_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of prescaler_preload : constant is 3;
end al422_bam_oe_processor;
