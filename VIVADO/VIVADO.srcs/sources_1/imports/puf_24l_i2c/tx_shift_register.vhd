library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_shift_register is
generic (data_width : natural);
port (
    clk: in std_logic;
    scl: in std_logic;
    rst: in std_logic; -- active low
    shift_enable: in std_logic; --active high
    parallel_data: in std_logic_vector(data_width-1 downto 0);
    serial_data: out std_logic;
    irq: out std_logic
);
end;

architecture rtl of tx_shift_register is
    signal s_data, s_next_data: std_logic_vector(data_width-1 downto 0);
    signal counter_irq: std_logic;
    signal s_clk: std_logic;
begin
    --serial_data <= s_data(data_width-1);

    counter: entity work.generic_counter(rtl)
        generic map(8)
        port map(
            clk => scl,
            rst => shift_enable,
            preload => std_logic_vector(to_unsigned(data_width-1, 8)),
            o_cnt => counter_irq
        );
    
    process(clk, rst, shift_enable, counter_irq) is
    begin
        irq <= '0';
        if counter_irq = '1' then
            irq <= '1';
        end if;
    end process;

    process(clk, rst, shift_enable, counter_irq, s_data) is
    begin
        if shift_enable = '1' then
            serial_data <= s_data(data_width-1);
            s_next_data <= to_stdlogicvector(to_bitvector(s_data) sll 1);
            s_clk <= scl;
        else
            serial_data <= 'Z';
            s_next_data <= parallel_data;
            s_clk <= clk;
        end if;
    end process;
    
    process(s_clk, rst) is
    begin
        if rst = '0' then
            s_data <= (others => '0');
        elsif s_clk'event and s_clk = '1' then
            s_data <= s_next_data;
        end if;
    end process;
end;
