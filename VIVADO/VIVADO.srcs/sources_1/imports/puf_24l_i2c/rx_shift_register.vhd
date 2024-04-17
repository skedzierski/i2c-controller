library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_shift_register is
generic (data_width : natural);
port (
    clk: in std_logic;
    rst: in std_logic; -- active low
    shift_enable: in std_logic; --active high
    parallel_data: out std_logic_vector(data_width-1 downto 0);
    serial_data: in std_logic;
    irq: out std_logic
);
end;

architecture rtl of rx_shift_register is
    signal s_data, s_next_data: std_logic_vector(data_width-1 downto 0);
    signal counter_irq: std_logic;
begin
    parallel_data <= s_data;
    counter: entity work.generic_counter(rtl)
        generic map(8)
        port map(
            clk => clk,
            rst => shift_enable,
            preload => std_logic_vector(to_unsigned(data_width-1, 8)),
            o_cnt => counter_irq
        );
    
    process(all) is
    begin
        irq <= '0';
        if counter_irq = '1' then
            irq <= '1';
        end if;
    end process;

    process(all) is
    begin
        if shift_enable = '1' then
            s_next_data <= to_stdlogicvector(to_bitvector(s_data) srl 1);
            s_next_data(data_width-1) <= serial_data;
        else
            s_next_data <= s_data;
        end if;
    end process;
    
    process(clk, rst) is
    begin
        if rst = '0' then
            s_data <= (others => '0');
        elsif clk'event and clk = '0' then
            s_data <= s_next_data;
        end if;
    end process;
end;
