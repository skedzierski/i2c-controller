library ieee;
use ieee.std_logic_1164.all;

use work.i2c_pkg.all;

entity i2c_3 is
    port(
        scl: inout std_logic;
        sda: inout std_logic;
        clk: in std_logic;
        btn: in std_logic;
        rst: in std_logic
    );
end entity;

architecture rtl of i2c_3 is
    signal s_gen_start, s_gen_stop: std_logic;
    type T_STATE is (IDLE, START, WRITE_DATA, CHECK_ACK, RECEIVE_TMP, SEND_ACK, SEND_NACK, STOP);
    signal current_state, next_state: T_STATE;
    signal scl_state : SCL_STATE;
    signal scl_rising, scl_falling : std_logic;
    
    signal s_shift_enable_write, send_done, s_shift_enable_read, read_done, received_msb  : std_logic;
    signal s_next_data_to_write, s_data_to_write, s_data_to_read : std_logic_vector(7 downto 0);
                        
    constant tmp3_addr_read : std_logic_vector(7 downto 0) := "10010000";
    constant tmp3_addr_write : std_logic_vector(7 downto 0) := "10010001";
    constant tmp3_ta_pointer : std_logic_vector(7 downto 0) := X"00";
    type rom is array (0 to 2) of std_logic_vector (7 downto 0);
    constant a_rom : rom := (tmp3_addr_write, tmp3_ta_pointer, tmp3_addr_read);
    signal rom_index, next_rom_index : natural;
    signal edge_counter, next_edge_counter : natural;
begin

    scl_gen: entity work.scl_gen(rtl)
    port map(
    fpga_clk => clk,
    rst => rst,
    gen_start => s_gen_start,
    gen_stop => s_gen_stop,
    o_scl => scl,
    o_state => scl_state
    );

    scl_edge_detector: entity work.edge_detector(rtl)
    port map(
        clk => clk,
        rst => rst,
        sig => scl,
        o_rising_edge => scl_rising,
        o_falling_edge => scl_falling
    );

    tx_reg: entity work.tx_shift_register(rtl)
    generic map(8)
    port map(
    clk => clk,
    scl => scl,
    rst => rst,
    shift_enable => s_shift_enable_write,
    parallel_data => s_data_to_write,
    serial_data => sda,
    irq => send_done
    );

    rx_reg: entity work.rx_shift_register(rtl)
    generic map(8)
    port map(
    clk => scl,
    rst => rst,
    shift_enable => s_shift_enable_read,
    parallel_data => s_data_to_read,
    serial_data => sda,
    irq => read_done
    );


    --send start (sda low)
    --start the scl
    --send address + write bit
    --check for ack
    --send 8bit Ta pointer to tmp3
    --check for ack

--Receive:
    --send start (sda low)
    --send address + read bit
    --check for ack
    --receive msb of temperature
    --SEND ACK
    --receive lsb of tempertature
    --SEND NACK (sda high)
    --goto receive
    
    --stop condition?


        process(clk, send_done, btn, current_state, scl_falling, edge_counter)
        is begin
        
            s_shift_enable_write <= '0';
            s_shift_enable_read <= '0';
            received_msb <= '0';
            sda <= 'W';
            s_gen_start <= '0';
            s_next_data_to_write <= s_data_to_write;
            next_state <= IDLE;
            next_rom_index <= rom_index;
            next_edge_counter <= edge_counter;
            case (current_state) is
                when IDLE =>
                    if btn = '1' then
                        next_state <= START;
                        s_next_data_to_write <= a_rom(rom_index);
                    else
                        next_state <= IDLE;
                    end if;
                when START =>
                    sda <= '0';
                    s_gen_start <= '1';
                    next_state <= WRITE_DATA;
                when WRITE_DATA =>
                    s_shift_enable_write <= '1';
                    if send_done = '1' then
                        next_state <= CHECK_ACK;
                        next_rom_index <= rom_index + 1;
                    else
                        next_state <= WRITE_DATA;
                    end if;
                    next_edge_counter <= 0;
                when CHECK_ACK =>
                    next_state <= CHECK_ACK;

                    if rom_index = 2 and scl_falling = '1' then
                        next_state <= RECEIVE_TMP;
                        next_rom_index <= 0;
                    elsif scl_falling = '1' then
                        next_state <= WRITE_DATA;
                    end if;
                when RECEIVE_TMP =>
                    s_shift_enable_read <= '1';
                    if read_done = '1' then
                        if received_msb = '0' then
                            next_state <= SEND_ACK;
                        else
                            next_state <= SEND_NACK;
                        end if;
                    else
                        next_state <= RECEIVE_TMP;
                    end if;
                when SEND_ACK =>
                    if scl_rising = '1' then
                        sda <= '0';
                    end if;
                    if scl_falling = '1' then 
                        next_state <= RECEIVE_TMP;
                        received_msb <= '1';
                    end if;
                when SEND_NACK =>
                    if scl_rising = '1' then
                        sda <= '1';
                    end if;
                    if scl_falling = '1' then
                        next_state <= START;
                    end if;
                when STOP => null;
            end case;
            
            
        
        end process;

   state_register: process(clk, rst) is begin
        if rst = '0' then
            current_state <= IDLE;
            edge_counter <= 0;
            rom_index <= 0;
            s_data_to_write <= X"00";
        elsif rising_edge(clk) then
            current_state <= next_state;
            edge_counter <= next_edge_counter;
            rom_index <= next_rom_index;
            s_data_to_write <= s_next_data_to_write;
        end if;
   end process;

end architecture;