library ieee;
use ieee.std_logic_1164.all;

entity i2c_memory is
    port(
        rst: in std_logic;                                            
        scl: inout std_logic;
        sda: inout std_logic 
    );
end entity;

architecture sim of i2c_memory is

    signal s_clk, s_as, s_ds, s_rw, s_irq, s_rst : std_logic; 
    signal s_addr, s_data, s_data_to_write, s_data_to_read : std_logic_vector(7 downto 0);
    signal s_received_data, s_memory : std_logic_vector(7 downto 0);
    signal s_addr_match : std_logic;

    signal addr_reg : std_logic_vector(7 downto 0) := "00001100";
    signal dtr_reg : std_logic_vector(7 downto 0) := "00001110";
    signal status_reg : std_logic_vector(7 downto 0) := "00001000";
    signal control_reg : std_logic_vector(7 downto 0) := "00000100";
    signal drr_reg : std_logic_vector(7 downto 0) := "00000000";

begin

    -- impure function wait_and_reset return boolean is
    -- begin
    --     wait for 100 ps;
    --     s_as = '0';
    --     s_ds = '0';
    --     wait for 100 ps;
    --     return 0;
    -- end function;

    -- impure function wait_for_tip return boolean is
    -- begin
    --     s_rw = '1';
    --     s_addr = status_reg;
    --     s_as = '1';
    --     wait until s_data_to_read(7) = '1'; --wait for setting TIP flag in status register
    --     s_as = '0';
    --     return 0;
    -- end function;

    process is
    begin
        s_clk <= not s_clk;
        wait for 100 ps;
    end process;

    i2c: entity work.i2c_2(rtl)
    port map(
        addr_bus => s_addr,
        as => s_as,
        ds => s_ds,
        rw => s_rw,
        clk => s_clk,
        rst => rst,
        irq => s_irq,
        data_bus => s_data,
        scl => scl,
        sda => sda
    );

    process(s_rw, s_data, s_data_to_write, s_data_to_read) is
    begin
    if s_rw = '0' then
        s_data <= s_data_to_write;
    else
        s_data <= "ZZZZZZZZ";
        s_data_to_read <= s_data;
    end if;
    end process;

    process is begin
        s_rst <= '1';
        wait for 10 ns;
        s_rst <= '0';
        wait for 1 us;
        s_rst <= '1';

    --Set i2c addr reg
    --Set control reg
    --Wait for addr_match flag in status register
    --Read drr register
--loop:
    --If drr=100100+write_bit
        -- --Write HALT flag to control reg
        --Wait for TIP flag in statur reg
        --Read data from DRR
        -- --Write HALT flag to control reg
    --If drr=100100+read_bit
        --Write data to DTR
        --Write HALT to control reg
    --GOTO loop

    --Set i2c addr reg
    s_rw <= '0';
    s_addr <= addr_reg;
    s_as <= '1';
    s_data_to_write <= "10010000";
    s_ds <= '1';
    wait for 100 ps;
    s_as <= '0';
    s_ds <= '0';
    wait for 100 ps;
    --Set control reg
    s_rw <= '0';
    s_addr <= control_reg;
    s_as <= '1';
    s_data_to_write <= "00000000";
    s_ds <= '1';
    wait for 100 ps;
    s_as <= '0';
    s_ds <= '0';
    wait for 100 ps;
    --Wait for addr_match flag in status register
    s_rw <= '1';
    s_addr <= status_reg;
    s_as <= '1';
    s_addr_match <= s_data_to_read(6);
    wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
    if s_addr_match = '1' then
        --Read drr register
        s_rw <= '1';
        s_addr <= drr_reg;
        s_as <= '1';
        s_received_data <= s_data_to_read;
        wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
    end if;
    --If drr=100100+write_bit
    if s_received_data = "10010001" then
        -- --Write HALT flag to control reg
        --Wait for TIP flag in statur reg
        s_rw <= '1';
        s_addr <= status_reg;
        s_as <= '1';
        wait until s_data_to_read(7) = '1'; --wait for setting TIP flag in status register
        s_as <= '0';
        --Read data from DRR
        s_rw <= '1';
        s_addr <= drr_reg;
        s_as <= '1';
        s_memory <= s_data_to_read;
        -- --Write HALT flag to control reg
    --If drr=100100+read_bit
    elsif s_received_data = "10010000" then
        --Write data to DTR
        s_rw <= '0';
        s_addr <= dtr_reg;
        s_as <= '1';
        s_data_to_write <= s_memory;
        s_ds <= '1';
        wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
        --Write HALT to control reg
    else
        s_received_data <= X"00";
    end if;
end process;
end architecture;