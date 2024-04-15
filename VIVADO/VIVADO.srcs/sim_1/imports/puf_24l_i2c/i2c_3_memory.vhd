library ieee;
use ieee.std_logic_1164.all;

entity i2c_3_memory is
    port(
        clk: in std_logic;
        rst: in std_logic;                                            
        scl: inout std_logic;
        sda: inout std_logic 
    );
end entity;

architecture sim of i2c_3_memory is

    signal s_shift_enable_write, send_done, s_shift_enable_read, read_done, sda_i, sda_o  : std_logic;
    signal s_data_to_write, s_data_to_read : std_logic_vector(7 downto 0);

begin
    rx: entity work.rx_shift_register(rtl)
    generic map (
        8
    )
    port map(
        clk => scl,
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
        scl => scl,
        rst => rst,
        shift_enable => s_shift_enable_write,
        parallel_data => s_data_to_write,
        serial_data => sda_o,
        irq => send_done
    );
    
    process is begin
        s_shift_enable_write <= '0';
        s_shift_enable_read <= '0';
        sda <= sda_i;
    --wait for start
        wait until scl = '1' and falling_edge(sda);
    --read address
        s_shift_enable_read <= '1';
        wait until read_done = '1';
        s_shift_enable_read <= '0';
    --send ack
        s_shift_enable_read <= '0';
        wait until rising_edge(scl);
        sda <= '0';
        wait until falling_edge(scl);
        sda <= 'Z';
    --read pointer
        sda <= sda_i;
        s_shift_enable_read <= '1';
        wait until read_done = '1';
        s_shift_enable_read <= '0';
    --send ack
        s_shift_enable_read <= '0';
        wait until rising_edge(scl);
        sda <= '0';
        wait until falling_edge(scl);
        sda <= 'Z';
--Send:
    --wait for start
        sda <= sda_i;
        wait until scl = '1' and falling_edge(sda);
        s_data_to_write <= X"DA";
    --read address
        s_shift_enable_read <= '1';
        wait until read_done = '1';
        s_shift_enable_read <= '0';
    --send ack
        wait until rising_edge(scl);
        sda <= '0';
        wait until falling_edge(scl);
        sda <= 'Z';
    --send msb data
        sda <= sda_o;
        s_shift_enable_write <= '1';
        wait until send_done = '1';
    --wait for ack
        s_shift_enable_write <= '0';
        s_data_to_write <= X"FC";
        wait until falling_edge(scl);
    --send lsb data
        s_shift_enable_write <= '1';
        wait until send_done = '1';
    --wait for nack
        s_shift_enable_write <= '0';
        wait until falling_edge(scl);
    --goto send

    end process;

end architecture;