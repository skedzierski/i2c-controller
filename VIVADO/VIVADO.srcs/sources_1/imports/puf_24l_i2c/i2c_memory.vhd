library ieee;
use ieee.std_logic_1164.all;

entity i2c_memory is
    port(
        rst: in std_logic;                                            
        scl: out std_logic;
        sda: inout std_logic 
    );
end;

architecture sim of i2c_memory is
    type ram is array (0 to 10) of std_logic_vector(15 downto 0);
    signal memory: ram;
    signal address, counter_reg: std_logic_vector(7 downto 0);
    signal data: std_logic_vector(15 downto 0);
    signal rw: std_logic;
    constant device_addr: std_logic_vector(6 downto 0) = X"0";
    signal clk, as, ds, done: std_logic;
begin
    process is
    begin
        clk <= not clk;
        wait for 1 ns;
    end process;

    process(rst, scl) is
    begin
        if rst = 0 then
            counter_reg <= X"00";
            exit;
        end if;
        counter_reg <= counter_reg + 1;

        if counter_reg <= X"08" then
            done <= '1';
        else
            done <= '0';
        end if;
    end process;
    i2c_0: entity work.i2c(rtl)
    port map(
        clk => clk,
        data_bus => data,
        rw => rw,
        rst => rst
        scl => scl,
        sda => sda,
        as => as,
        ds => ds,
        num_bytes_to_receive => 2
    );

    process is
    begin
        wait on done;
        if not data(7 downto 1) = device_addr then
            exit;
        end if;
        rw <= data(0);
        if rw = '1' then
            wait on done;
            address <= data(7 downto 0);
            data <= memory(address);
            wait on done;
        else
            wait on done;
            address <= data(7 downto 0);
            wait on done;
            memory(address) <= data;
        end if;
    end process;
end architecture;