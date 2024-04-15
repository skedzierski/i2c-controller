library ieee;
use ieee.std_logic_1164.all;

entity i2c_3_tb is
end entity;


architecture sim of i2c_3_tb is
    signal s_scl, s_sda, s_clk, s_rst, s_btn: std_logic;
begin
    clk_gen : process is begin
        s_clk <= '1';
        wait for 5 ns;
        s_clk <= '0';
        wait for 5 ns;
    end process;
    i2c_3: entity work.i2c_3(rtl)
    port map(
        scl => s_scl,
        sda => s_sda,
        clk => s_clk,
        btn => s_btn,
        rst => s_rst
    );

    process is begin
        s_rst <= '1';
        s_btn <= '0';
        wait for 10 ns;
        s_rst <= '0';
        wait for 1 us;
        s_rst <= '1';
        wait for 10 ns;

        s_btn <= '1';
        wait for 100 ms;


    end process;

end architecture;