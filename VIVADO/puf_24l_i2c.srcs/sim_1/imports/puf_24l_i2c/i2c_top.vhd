library ieee;
use ieee.std_logic_1164.all;

entity top is
end entity;

architecture sim of top is
    signal s_rst, s_clk, s_sda, s_scl, s_btn, s_clk_12mhz : std_logic;
    signal s_ja : std_logic_vector(1 downto 0);
begin
    
    s_sda <= s_ja(1);
    s_scl <= s_ja(0);
    s_ja(1 downto 0) <= "HH";

--    master: entity work.i2c(rtl)
--    port map(
--        scl => s_scl,
--        sda => s_sda,
--        sys_clk_pin => s_clk,
--        btn => s_btn,
--        rst => s_rst
--    );

    master: entity work.i2c(rtl)
    port map(
        clk => s_clk_12mhz,
        ja => s_ja
    );

     slave: entity work.i2c_memory(sim)
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
    
    clk_gen_12mhz : process is begin
        wait for 83.33 ns;
        while true loop
            s_clk_12mhz <= '1';
            wait for 41.66 ns;
            s_clk_12mhz <= '0';
            wait for 41.66 ns;
        end loop;
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