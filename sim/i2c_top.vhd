library ieee;
use ieee.std_logic_1164.all;

entity top is
end entity;

architecture sim of top is
    signal s_rst, s_clk, s_sda, s_scl, s_btn, s_clk_master : std_logic;
    signal s_i2c_data : std_logic_vector (1 downto 0);
begin

    --s_sda <= 'H';
    --s_scl <= 'H';

    s_i2c_data(0) <= 'H';
    s_i2c_data(1) <= 'H'; 
    master: entity work.i2c(rtl)
    port map(
        --scl => s_scl,
        --sda => s_sda,
        i2c_data => s_i2c_data,
        clk => s_clk,
        btn => s_btn,
        rst => s_rst
    );

     slave: entity work.i2c_memory(sim)
     port map(
         rst => s_rst,
         clk => s_clk,                                 
         --scl => s_scl,
         --sda => s_sda
         i2c_data => s_i2c_data
     );

    clk_gen : process is begin
        s_clk <= '1';
        wait for 5 ns;
        s_clk <= '0';
        wait for 5 ns;
    end process;
    
    clk_gen_master : process is begin
        s_clk_master <= '1';
        wait for 83.33 ns;
        s_clk_master <= '0';
        wait for 83.33 ns;
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