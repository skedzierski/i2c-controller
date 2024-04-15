library ieee;
use ieee.std_logic_1164.all;

entity top is
end entity;

architecture sim of top is
    signal s_rst, s_clk, s_sda, s_scl, s_btn : std_logic;
begin

    master: entity work.i2c_3(rtl)
    port map(
        scl => s_scl,
        sda => s_sda,
        clk => s_clk,
        btn => s_btn,
        rst => s_rst
    );

    slave: entity work.i2c_3_memory(sim)
    port map(
        rst => s_rst,
        clk => s_clk,                                 
        scl => s_scl,
        sda => s_sda
    );

    clk_gen : process is begin
        s_clk <= '1';
        wait for 5 ns;
        s_clk <= '0';
        wait for 5 ns;
    end process;

    process is begin
        s_btn <= '0';
        s_rst <= '1';
        wait for 10 ns;
        s_rst <= '0';
        wait for 1 us;
        s_rst <= '1';
        wait for 10 ns;
        
        s_btn <= '1';
        wait for 100 ms;
    end process;
end architecture;