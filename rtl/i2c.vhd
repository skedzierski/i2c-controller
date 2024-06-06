library ieee;
use ieee.std_logic_1164.all;

use work.i2c_pkg.all;

entity i2c is
    port(
        --scl_vec: inout std_logic_vector(0 to 0);
        --sda_vec: inout std_logic_vector(0 to 0);
        scl_o : out std_logic;
        sda_o : out std_logic;
        scl_i : in std_logic;
        sda_i : in std_logic;
        --i2c_ila : out std_logic_vector (1 downto 0);
        clk: in std_logic;
        btn: in std_logic;
        rst: in std_logic;
        
        dbg1 : out std_logic; --dbg
        dbg2 : out std_logic; --dbg
        dbg3 : out std_logic; --dbg
        dbg4 : out std_logic; --dbg
        pio : out std_logic_vector (7 downto 0)
    );
end entity;

architecture rtl of i2c is
    signal s_gen_start, s_gen_stop, s_rep_start, s_clk100khz, s_stretch_low : std_logic;
    signal s_scl_rising, s_scl_falling : std_logic;
    signal s_tx_oe : std_logic;
    
    signal s_shift_enable_write, s_send_done, s_shift_enable_read, s_read_done  : std_logic;
    signal s_data_to_write, s_data_to_read : std_logic_vector(7 downto 0);
                        
    signal s_clk100khz_falling, s_clk100khz_rising : std_logic;
    signal scl, sda, sda_tx, i_sda, sda_fsm : std_logic;
    
--    -- ATTRIBUTE DECLARATION --
--ATTRIBUTE MARK_DEBUG : STRING;
--ATTRIBUTE MARK_DEBUG OF scl : SIGNAL IS "true";
--ATTRIBUTE MARK_DEBUG OF sda : SIGNAL IS "true";
    
begin

    sda_o <= sda_tx when s_tx_oe = '1' else sda_fsm;
    scl_o <= scl;
    
--    process(all) is begin
--    if scl_i = '1' then
--        dbg1 <= '1';
--    else
--        dbg1 <= '0';
--    end if;
--    end process;
    
    -- if s_tx_oe = '1' then
    --     sda_o <= sda_tx;
    -- else
    --     sda_o <= sda_fsm;
    -- end if;
    
    scl_gen: entity work.scl_gen(rtl)
    port map(
    fpga_clk => clk,
    rst => rst,
    gen_start => s_gen_start,
    rep_start => s_rep_start,
    gen_stop => s_gen_stop,
    o_scl => scl,
    clk100khz => s_clk100khz,
    stretch_low => s_stretch_low
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
    serial_data => sda_tx,
    irq => s_send_done
    );

    rx_reg: entity work.rx_shift_register(rtl)
    generic map(8)
    port map(
    clk => s_clk100khz,
    rst => rst,
    shift_enable => s_shift_enable_read,
    parallel_data => pio,
    serial_data => sda_i,
    irq => s_read_done
    );
    
    i2c_fsm: entity work.i2c_fsm(rtl)
    port map(
        scl => scl,
        sda => sda_fsm,
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
        clk100khz_rising => s_clk100khz_rising,
        dbg_state1 => dbg1,
        dbg_state2 => dbg2,
        dbg_state3 => dbg3,
        dbg_state4 => dbg4
    );


end architecture;
