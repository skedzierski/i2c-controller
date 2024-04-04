use work.i2c_2_pkg.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.floor;
use ieee.math_real.uniform;
use ieee.numeric_std.all;

entity registers_test is
end entity;

architecture sim of registers_test is
    signal s_addr,  
           s_data_to_write,
           s_data_to_read,
           s_data,
           s_addr_reg,
           s_dtr,
           s_drr: std_logic_vector(7 downto 0);
    signal s_ctr: ctr_bits;
    signal s_sr: sr_bits;
    signal s_as, s_ds, s_rw, s_rst, clk: std_logic;
    type sample_data is array (0 to 5) of integer range 0 to 255;
begin

regs: entity work.reg_map(rtl)
port map (
    i_addr => s_addr,
    data => s_data,
    as => s_as,
    ds => s_ds,
    rw => s_rw,
    rst => s_rst,
    clk => clk,
    ctr => s_ctr,
    sr => s_sr,
    o_addr_reg => s_addr_reg,
    dtr => s_dtr,
    drr => s_drr
);

process is begin
    clk <= '0';
    wait for 100 ps;
    clk <= '1';
    wait for 100 ps;
end process;

process(s_addr, 
s_data, 
s_data_to_read,
s_data,
s_addr_reg,
s_dtr,
s_drr,
s_ctr,
s_sr,
s_as, s_ds, s_rw, s_rst, clk) is
begin
    if s_rw = '0' then
        s_data_to_write <= s_data;
    else
        s_data_to_read <= s_data;
    end if;
end process;

process is 
    variable seed1, seed2: positive;
    variable x : real;
    variable some_junk: sample_data;
begin
    s_as <= '0';
    s_sr <= stlv_to_sr_bits(X"FF");
    s_drr <= X"AE";
    s_ds <= '0';
    s_rw <= '0';
    s_rst <= '1';
    s_addr <= X"00";
    s_data_to_write <= X"BE";
    wait for 100 ns;
    s_rst <= '0';
    wait for 10 ns;
    s_rst <= '1';
    wait for 1 us;
    s_addr <= X"AA";
    s_data_to_write <= X"69";
    wait for 10 ns;
    s_as <= '1';
    wait for 10 ns;
    s_ds <= '1';
    wait for 5 ns;
    s_as <= '1';
    s_ds <= '1';
    wait for 100 ns;
    
    seed1 := 1;
    seed2 := 1;
    for i in 0 to 5 loop
        uniform(seed1, seed2, x);
        some_junk(i) := integer(floor(x * 255.0));
    end loop;

    s_rw <= '0';
    writing_data: for i in 0 to 5 loop
        s_addr <= std_logic_vector(to_unsigned(i, s_addr'length));
        s_as <= '1';
        wait for 10 ns;
        s_data_to_write <= std_logic_vector(to_unsigned(some_junk(i), s_data_to_write'length));
        s_ds <= '1';
        wait for 10 ns;
        s_as <= '0';
        s_ds <= '0';
        wait for 3 ns;
    end loop;

    s_rw <= '1';
    s_ds <= '0';
    reading_data: for i in 0 to 5 loop
        s_addr <= std_logic_vector(to_unsigned(i, s_addr'length));
        s_as <= '1';
        wait for 10 ns;
        s_as <= '0';
        wait for 3 ns;
    end loop;
end process;

end architecture;