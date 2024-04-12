use work.i2c_2_pkg.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.floor;
use ieee.math_real.uniform;
use ieee.numeric_std.all;

entity i2c_tb_top is
end entity;

architecture sim of i2c_tb_top is

    signal s_sda, s_scl, s_rst : std_logic;

begin

master: entity work.i2c_tb(sim)
port map(
    rst => s_rst,
    sda => s_sda,
    scl => s_scl
);

slave: entity work.i2c_memory(sim)
port map(
    rst => s_rst,
    sda => s_sda,
    scl => s_scl
);

    process is begin
        s_rst <= '1';
        wait for 10 ns;
        s_rst <= '0';
        wait for 1 us;
        s_rst <= '1';
        wait;
    end process;
end architecture;