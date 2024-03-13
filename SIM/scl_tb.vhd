library ieee;
use ieee.std_logic_1164.all;

entity scl_tb is
end;

architecture sim of scl_tb is
    signal fpga_clk, gen_start, rst, gen_stop, o_scl: std_logic;
begin
    process is
    begin
        fpga_clk <= '0';
        wait for 5 ns;
        fpga_clk <= '1';
        wait for 5 ns;
    end process;

    scl_0: entity work.scl_gen(rtl)
        port map(
            fpga_clk => fpga_clk,
            rst => rst,
            gen_start => gen_start,
            gen_stop => gen_stop,
            o_scl => o_scl
        );
        
    gen_start <= '0';
    rst <= '0';
    gen_stop <= '0';
    process is
    begin
        wait for 100 ns;
        gen_start <= '1';
        wait for 10 ns;
        rst <= '1';
        wait for 1 us;
        gen_stop <= '1';
        wait for 100 ns;
    end process;

end;