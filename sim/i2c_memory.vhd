library ieee;
use ieee.std_logic_1164.all;

entity i2c_memory is
    port(
        clk: in std_logic;
        rst: in std_logic;                                            
        scl_o : out std_logic;
        sda_o : out std_logic;
        scl_i : in std_logic;
        sda_i : in std_logic
    );
end entity;

architecture sim of i2c_memory is

    signal s_shift_enable_write, send_done, s_shift_enable_read, read_done : std_logic;
    signal s_data_to_write, s_data_to_read : std_logic_vector(7 downto 0);
    signal shifted_scl, s_oe, s_sda, tx_sda : std_logic;

    procedure send_ack(signal sda: out std_logic) is
    begin
        sda <= '0';
        wait until rising_edge(scl_i);
        sda <= '1';
        wait until falling_edge(scl_i);
    end procedure;

begin

    process is 
    begin
        wait until falling_edge(scl_i);
        wait for 2.5 us;
        shifted_scl <= '1';
        wait until rising_edge(scl_i);
        wait for 2.5 us;
        shifted_scl <= '0';
    end process;
    rx: entity work.rx_shift_register(rtl)
    generic map (
        8
    )
    port map(
        clk => shifted_scl,
        rst => rst,
        shift_enable => s_shift_enable_read,
        parallel_data => s_data_to_read,
        serial_data => sda_i,
        irq => read_done
    );

    tx: entity work.tx_shift_register(rtl)
    generic map (
        8
    )
    port map(
        clk => clk,
        scl => shifted_scl,
        rst => rst,
        shift_enable => s_shift_enable_write,
        oe => s_oe,
        parallel_data => s_data_to_write,
        serial_data => tx_sda,
        irq => send_done
    );
    sda_o <= tx_sda when s_oe = '1' else s_sda;
    
    process is begin
        s_sda <= '1';
        s_oe <= '0';
        s_shift_enable_write <= '0';
        s_shift_enable_read <= '0';
    --wait for start
        wait for 100 ns;
        wait until scl_i = '1' and sda_i = '0';
    --read address
        s_shift_enable_read <= '1';
        wait until read_done = '1';
        s_shift_enable_read <= '0';
    --send ack
        wait for 5 us;
        send_ack(s_sda);
    --read pointer
        s_shift_enable_read <= '1';
        wait until read_done = '1';
        s_shift_enable_read <= '0';
    --send ack
        wait for 5 us;
        send_ack(s_sda);
--Send:
    --wait for start
        wait until scl_i = '1' and falling_edge(sda_i);
        s_data_to_write <= X"BE";
    --read address
        s_shift_enable_read <= '1';
        wait until read_done = '1';
        s_shift_enable_read <= '0';
    --send ack
        wait for 5 us;
        send_ack(s_sda);
    --send msb data
        s_oe <= '1';
        wait for 10 us;
        s_shift_enable_write <= '1';
        wait until send_done = '1';
        --wait for 5 us;
    --wait for ack
        s_oe <= '0';
        s_shift_enable_write <= '0';
        wait for 2.5 us;
        s_sda <= '0';
        s_data_to_write <= X"EF";
        wait for 7.5 us;
        s_sda <= '1';
    --send lsb data
        s_oe <= '1';
        wait for 10 us;
        s_shift_enable_write <= '1';
        wait until send_done = '1';
    --wait for nack
        s_oe <= '0';
        s_shift_enable_write <= '0';
        wait until falling_edge(scl_i);
        wait until rising_edge(scl_i);
    --goto send

    end process;

end architecture;