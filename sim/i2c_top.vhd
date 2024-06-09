library ieee;
use ieee.std_logic_1164.all;

entity top is
end entity;

architecture sim of top is
    signal s_rst, s_clk, s_btn, s_clk_master : std_logic;
    signal s_scl_o, s_scl_i, s_sda_o, s_sda_i : std_logic;
begin

    --s_sda <= 'H';
    --s_scl <= 'H';

    master: entity work.i2c(rtl)
    port map(
        scl_o => s_scl_o,
        sda_o => s_sda_o,
        scl_i => s_scl_i,
        sda_i => s_sda_i,
        clk => s_clk,
        btn => s_btn,
        rst => s_rst
    );

     slave: entity work.i2c_memory(sim)
     port map(
         rst => s_rst,
         clk => s_clk,                                 
         scl_o => s_scl_i,
         sda_o => s_sda_i,
         scl_i => s_scl_o,
         sda_i => s_sda_o
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
        wait for 11 ns;
        s_rst <= '0';
        wait for 1 us;
        s_rst <= '1';
        wait for 11 ns;
        
        s_btn <= '1';
        wait for 100 ms;
    end process;
end architecture;