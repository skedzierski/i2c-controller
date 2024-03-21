library ieee;
use ieee.std_logic_1164.all;

entity rx_tb is
end entity;

architecture sim of rx_tb is
signal s_clk, s_reset, s_shift_enable, s_irq, sda: std_logic;
signal s_data: std_logic_vector(15 downto 0);
begin

process is
begin
    s_clk <= '1';
    wait for 10 ns;
    s_clk <= '0';
    wait for 10 ns;
end process;

receive_data_reg: entity work.rx_shift_register(rtl)
    generic map(data_width => 16)
    port map(
        clk => s_clk,
        rst => s_reset,
        shift_enable =>  s_shift_enable,
        parallel_data => s_data,
        irq => s_irq,
        serial_data => sda
    );

process is
begin
    s_reset <= '0';
    s_shift_enable <= '0'; 
    sda <= '0';
    wait for 100 ns;
    s_reset <= '1';
    s_shift_enable <= '1'; 

    for i in 0 to 15 loop
        sda <= '1';
        wait for 20 ns;
        sda <= '0';
        wait for 20 ns;
    end loop;
end process;

end architecture;