library ieee;
use ieee.std_logic_1164.all;
use work.i2c_pkg.all;

entity i2c is
    port(
        clk: in std_logic;
        ja: inout std_logic_vector(1 downto 0)
    );
end entity;

architecture rtl of i2c is
    signal s_gen_start, s_gen_stop, s_rep_start, s_clk100khz : std_logic;
    signal s_scl_rising, s_scl_falling : std_logic;
    signal s_tx_oe : std_logic;
    
    signal s_shift_enable_write, s_send_done, s_shift_enable_read, s_read_done  : std_logic;
    signal s_data_to_write, s_data_to_read : std_logic_vector(7 downto 0);
                        
    signal s_clk100khz_falling, s_clk100khz_rising : std_logic;

    signal scl, sda, sda_fsm, sda_tx : std_logic;
    signal clk_100mhz : std_logic;
    signal rst : std_logic;
    
    signal btn, resetn, next_ja0, next_ja1 : std_logic;
    signal ctrl : std_logic_vector(1 downto 0);
    
    component clk_wiz_0
    port
     (-- Clock in ports
      -- Clock out ports
      clk          : out    std_logic;
      -- Status and control signals
      resetn             : in     std_logic;
      locked            : out    std_logic;
      clk_in1           : in     std_logic
     );
    end component;
    
    COMPONENT ila_0

    PORT (
        clk : IN STD_LOGIC;    
        probe0 : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
    END COMPONENT  ;
    
    COMPONENT vio_0
    PORT (
    clk : IN STD_LOGIC;
    probe_out0 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
    END COMPONENT;

begin
    scl <= next_ja1;
    sda <= next_ja0;

    btn <= ctrl(0);
    resetn <= ctrl(1);

    process(s_tx_oe, clk_100mhz, sda_tx, sda_fsm) is begin
        if s_tx_oe = '1' then
            next_ja0 <= sda_tx;
        else
            next_ja0 <= sda_fsm;
        end if;
    end process;
    
    process(clk_100mhz, rst) is begin
        if rising_edge(clk_100mhz) then
            ja(0) <= next_ja0;
            ja(1) <= next_ja1;
        end if;
        if rst = '1' then
            ja(0) <= 'Z';
            ja(1) <= 'Z';
        end if;
    end process;
    
    ila : ila_0
    PORT MAP (
        clk => clk_100mhz,
        probe0 => ja
    );
    
    vio : vio_0
    PORT MAP (
    clk => clk_100mhz,
    probe_out0 => ctrl
    );
        
    system_clock : clk_wiz_0
    port map ( 
    -- Clock out ports  
    clk => clk_100mhz,
    -- Status and control signals                
    resetn => resetn,
    locked => rst,
    -- Clock in ports
    clk_in1 => clk
    );
    
    scl_gen: entity work.scl_gen(rtl)
    port map(
    fpga_clk => clk_100mhz,
    rst => rst,
    gen_start => s_gen_start,
    rep_start => s_rep_start,
    gen_stop => s_gen_stop,
    o_scl => scl,
    clk100khz => s_clk100khz
    );

    scl_edge_detector: entity work.edge_detector(rtl)
    port map(
        clk => clk_100mhz,
        rst => rst,
        sig => scl,
        o_rising_edge => s_scl_rising,
        o_falling_edge => s_scl_falling
    );

    clk100khz_detector: entity work.edge_detector(rtl)
    port map(
        clk => clk_100mhz,
        rst => rst,
        sig => s_clk100khz,
        o_falling_edge => s_clk100khz_falling,
        o_rising_edge => s_clk100khz_rising
    );

    tx_reg: entity work.tx_shift_register(rtl)
    generic map(8)
    port map(
    clk => clk_100mhz,
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
    parallel_data => s_data_to_read,
    serial_data => sda,
    irq => s_read_done
    );
    
    i2c_fsm: entity work.i2c_fsm(rtl)
    port map(
        scl => scl,
        sda => sda_fsm,
        clk => clk_100mhz,
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
