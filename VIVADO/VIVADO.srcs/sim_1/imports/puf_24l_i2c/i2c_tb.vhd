use work.i2c_2_pkg.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.floor;
use ieee.math_real.uniform;
use ieee.numeric_std.all;

entity i2c_tb is
  port(
        rst: in std_logic;                                            
        scl: out std_logic;
        sda: inout std_logic 
    );
end entity;

architecture sim of i2c_tb is
    signal  s_as,
            s_ds,
            s_rw,
            s_irq,
            s_clk,
            s_rst: std_logic;
    -- signal  s_sda,
    --         s_scl: std_logic;
    signal  s_addr,
            s_data_to_write,
            s_data_to_read,
            s_data: std_logic_vector(7 downto 0);

    signal temperature : std_logic_vector(7 downto 0) := X"00";
    signal tmp3_addr : std_logic_vector(7 downto 0) := "10010000";
    signal dtr_reg : std_logic_vector(7 downto 0) := "00001110";
    signal status_reg : std_logic_vector(7 downto 0) := "00001000";
    signal control_reg : std_logic_vector(7 downto 0) := "00000100";
    signal drr_reg : std_logic_vector(7 downto 0) := "00000000";

    -- impure function wait_and_reset return boolean is
    -- begin
    --     wait for 100 ps;
    --     s_as <= '0';
    --     s_ds <= '0';
    --     wait for 100 ps;
    --     return 0;
    -- end function;

    -- impure function wait_for_tip return boolean is
    -- begin
    --     s_rw <= '1';
    --     s_addr <= status_reg;
    --     s_as <= '1';
    --     wait for s_data_to_read(7) = '1'; --wait for setting TIP flag in status register
    --     s_as <= '0';
    --     return 0;
    -- end function;

    -- type T_STATE is (RESET, INIT_SEND, SEND_ADDR, SEND_DATA, INIT_RECEIVE, RECEIVE_DATA, STOP);
    -- signal CURRENT_STATE : T_STATE := RESET;
    -- signal NEXT_STATE: T_STATE := RESET;
            

begin
    dut: entity work.i2c_2(rtl)
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
        s_clk <= '0';
        wait for 100 ps;
        s_clk <= '1';
        wait for 100 ps;
    end process;

    process is begin
        s_rst <= '1';
        wait for 10 ns;
        s_rst <= '0';
        wait for 1 us;
        s_rst <= '1';

    --Init temperature read:
        --Write i2c device address and write bit to core dtr register
        --Write mode select, en bit and configuration to core control register
        --Wait for TIP flag in core status register
        --Write data to send (temperature register pointer) to core dtr register
        --Write HALT flag to core control register
        --Wait for TIP flag in core status register
        --Write i2c device address and read bit to core dtr register
        --Write HALT and REP_START flags to core control register
    --Read temperature:
        --Wait for TIP flag in core status register
        --Write HALT flag and set master receive in core control register
        --Wait for TIP flag in core status register
        --Read data from drr register (MSB of read temperature)
        --Write HALT flag to core control register
        --Wait for TIP flag in core status register
        --Read data from drr register (LSB of read temperature)
        --Write HALT flag and set master transmit in core control register
    --Goto "Read temperature"

--IMPLEMENTATNION
    --Init temperature read:
        --Write i2c device address and write bit to core dtr register
        s_rw <= '0';
        s_addr <= dtr_reg;
        s_as <= '1';
        s_data_to_write <= tmp3_addr OR X"01";
        s_ds <= '1';
        wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
        --Write mode select, en bit and configuration to core control register
        s_rw <= '0';
        s_addr <= control_reg;
        s_as <= '1';
        s_data_to_write <= "00110000";
        s_ds <= '1';
        wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
        --Wait for TIP flag in core status register
        s_rw <= '1';
        s_addr <= status_reg;
        s_as <= '1';
        wait until s_data_to_read(7) = '1'; --wait for setting TIP flag in status register
        s_as <= '0';
        --Write data to send (temperature register pointer) to core dtr register
        s_rw <= '0';
        s_addr <= dtr_reg;
        s_as <= '1';
        s_data_to_write <= "00000000";
        s_ds <= '1';
        wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
        --Write HALT flag to core control register
        s_rw <= '0';
        s_addr <= control_reg;
        s_as <= '1';
        s_data_to_write <= "00110001";
        s_ds <= '1';
        wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
        --Wait for TIP flag in core status register
        s_rw <= '1';
        s_addr <= status_reg;
        s_as <= '1';
        wait until s_data_to_read(7) = '1'; --wait for setting TIP flag in status register
        s_as <= '0';
        --Write i2c device address and read bit to core dtr register
        s_rw <= '0';
        s_addr <= dtr_reg;
        s_as <= '1';
        s_data_to_write <= tmp3_addr AND X"00";
        s_ds <= '1';
        wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
        --Write HALT and REP_START flags to core control register
        s_rw <= '0';
        s_addr <= control_reg;
        s_as <= '1';
        s_data_to_write <= "00110101";
        s_ds <= '1';
        wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
    --Read temperature:
        --Wait for TIP flag in core status register
        s_rw <= '1';
        s_addr <= status_reg;
        s_as <= '1';
        wait until s_data_to_read(7) = '1'; --wait for setting TIP flag in status register
        s_as <= '0';
        --Write HALT flag and set master receive in core control register
        s_rw <= '0';
        s_addr <= control_reg;
        s_as <= '1';
        s_data_to_write <= "00100101";
        s_ds <= '1';
        wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
        --Wait for TIP flag in core status register
        s_rw <= '1';
        s_addr <= status_reg;
        s_as <= '1';
        wait until s_data_to_read(7) = '1'; --wait for setting TIP flag in status register
        s_as <= '0';
        --Read data from drr register (MSB of read temperature)
        s_rw <= '1';
        s_addr <= drr_reg;
        s_as <= '1';
        temperature <= std_logic_vector(shift_left(unsigned(s_data_to_read), 8));
        wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
        --Write HALT flag to core control register
        s_rw <= '0';
        s_addr <= control_reg;
        s_as <= '1';
        s_data_to_write <= "00100101";
        s_ds <= '1';
        wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
        --Wait for TIP flag in core status register
        s_rw <= '1';
        s_addr <= status_reg;
        s_as <= '1';
        wait until s_data_to_read(7) = '1'; --wait for setting TIP flag in status register
        s_as <= '0';
        --Read data from drr register (LSB of read temperature)
        s_rw <= '1';
        s_addr <= drr_reg;
        s_as <= '1';
        temperature <= temperature AND s_data_to_read;
        wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
        --Write HALT flag and set master transmit in core control register
        s_rw <= '0';
        s_addr <= control_reg;
        s_as <= '1';
        s_data_to_write <= "00110101";
        s_ds <= '1';
        wait for 100 ps;
        s_as <= '0';
        s_ds <= '0';
        wait for 100 ps;
    --Goto "Read temperature"
        --TODO Add while(true) loop or something

    end process;
end;