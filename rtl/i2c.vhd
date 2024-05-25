library ieee;
use ieee.std_logic_1164.all;

use work.i2c_pkg.all;

entity i2c is
    port(
        --scl_vec: inout std_logic_vector(0 to 0);
        --sda_vec: inout std_logic_vector(0 to 0);
        i2c_data : inout std_logic_vector (1 downto 0);
        i2c_ila : out std_logic_vector (1 downto 0);
        clk: in std_logic;
        btn: in std_logic;
        rst: in std_logic
    );
end entity;

architecture rtl of i2c is
    signal s_gen_start, s_gen_stop, s_rep_start, s_clk100khz : std_logic;
    signal s_scl_rising, s_scl_falling : std_logic;
    signal s_tx_oe : std_logic;
    
    signal s_shift_enable_write, s_send_done, s_shift_enable_read, s_read_done  : std_logic;
    signal s_data_to_write, s_data_to_read : std_logic_vector(7 downto 0);
                        
    signal s_clk100khz_falling, s_clk100khz_rising : std_logic;
    signal scl, sda : std_logic;
begin

    scl <= i2c_data(0);
    sda <= i2c_data(1);
    
    i2c_ila(0) <= scl;
    i2c_ila(1) <= sda;
    
    scl_gen: entity work.scl_gen(rtl)
    port map(
    fpga_clk => clk,
    rst => rst,
    gen_start => s_gen_start,
    rep_start => s_rep_start,
    gen_stop => s_gen_stop,
    o_scl => scl,
    clk100khz => s_clk100khz
    );

    scl_edge_detector: entity work.edge_detector(rtl)
    port map(
        clk => clk,
        rst => rst,
        sig => scl,
        o_rising_edge => s_scl_rising,
        o_falling_edge => s_scl_falling
    );

    clk100khz_detector: entity work.edge_detector(rtl)
    port map(
        clk => clk,
        rst => rst,
        sig => s_clk100khz,
        o_falling_edge => s_clk100khz_falling,
        o_rising_edge => s_clk100khz_rising
    );

    tx_reg: entity work.tx_shift_register(rtl)
    generic map(8)
    port map(
    clk => clk,
    scl => s_clk100khz,
    rst => rst,
    shift_enable => s_shift_enable_write,
    oe => s_tx_oe,
    parallel_data => s_data_to_write,
    serial_data => sda,
    irq => s_send_done
    );

    rx_reg: entity work.rx_shift_register(rtl)
    generic map(8)
    port map(
    clk => s_clk100khz,
    rst => rst,
    shift_enable => s_shift_enable_read,
    parallel_data => s_data_to_read,
    serial_data => sda,
    irq => s_read_done
    );
    
    i2c_fsm: entity work.i2c_fsm(rtl)
    port map(
        scl => scl,
        sda => sda,
        clk => clk,
        btn => btn,
        rst => rst,
        gen_start => s_gen_start,
        rep_start => s_rep_start,
        gen_stop => s_gen_stop,
        scl_rising => s_scl_rising,
        scl_falling => s_scl_falling,
        data_to_write => s_data_to_write,
        shift_enable_write => s_shift_enable_write,
        send_done => s_send_done,
        shift_enable_read => s_shift_enable_read,
        read_done => s_read_done,
        tx_oe => s_tx_oe,
        clk100khz_falling => s_clk100khz_falling,
        clk100khz_rising => s_clk100khz_rising
    );


end architecture;
