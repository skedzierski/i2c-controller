library ieee;
use ieee.std_logic_1164.all;

use work.i2c_pkg.all;

entity i2c_fsm is
    port(
        scl: in std_logic;
        sda: inout std_logic;
        clk: in std_logic;
        btn: in std_logic;
        rst: in std_logic;
        gen_start: out std_logic;
        rep_start: out std_logic;
        gen_stop: out std_logic;
        scl_rising: in std_logic;
        scl_falling: in std_logic;
        data_to_write: out std_logic_vector(7 downto 0);
        shift_enable_write: out std_logic;
        send_done: in std_logic;
        shift_enable_read: out std_logic;
        read_done: in std_logic;
        tx_oe: out std_logic;
        clk100khz_falling: in std_logic;
        clk100khz_rising: in std_logic;
        
        dbg_state1 : out std_logic; --dbg
        dbg_state2 : out std_logic; --dbg
        dbg_state3 : out std_logic; --dbg
        dbg_state4 : out std_logic
    );
end entity;

architecture rtl of i2c_fsm is
    type T_STATE is (IDLE, START, S_REP_START, WRITE_DATA, CHECK_ACK, RECEIVE_TMP, SEND_ACK, SEND_NACK, STOP);
    signal current_state, next_state: T_STATE;
    signal next_sda : std_logic;
    signal received_msb, next_received_msb, scl_was_falling, next_scl_was_falling  : std_logic;
    signal s_clk100khz_falling, next_clk100khz_falling : std_logic;
    signal s_next_data_to_write : std_logic_vector(7 downto 0);

    constant tmp3_addr_read : std_logic_vector(7 downto 0) := "10010001";
    constant tmp3_addr_write : std_logic_vector(7 downto 0) := "10010000";
    constant tmp3_ta_pointer : std_logic_vector(7 downto 0) := X"00";
    type rom is array (0 to 3) of std_logic_vector (7 downto 0);
    constant a_rom : rom := (tmp3_addr_write, tmp3_ta_pointer, tmp3_addr_read, "ZZZZZZZZ");
    signal rom_index, next_rom_index : natural;
    signal edge_counter, next_edge_counter : natural;

    signal scl_was_rising, next_scl_was_rising, start_triggered, next_start_triggered : std_logic;
    signal stop_triggered, next_stop_triggered : std_logic;
    
begin

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

    shift_enable_write <= '0';
    shift_enable_read <= '0';
    next_received_msb <= received_msb;
    sda <= 'Z';
    gen_start <= '0';
    rep_start <= '0';
    tx_oe <= '0';
    next_start_triggered <= start_triggered;
    next_stop_triggered <= stop_triggered;
    next_state <= IDLE;
    s_next_data_to_write <= a_rom(rom_index);
    next_rom_index <= rom_index;
    next_edge_counter <= edge_counter;
    next_scl_was_falling <= scl_was_falling;
    next_scl_was_rising <= scl_was_rising;
    next_sda <= sda;
    next_clk100khz_falling <= s_clk100khz_falling;
    case (current_state) is
        when IDLE =>
            if btn = '1' then
                next_state <= START;
            else
                next_state <= IDLE;
            end if;
        when START =>
            rep_start <= '1';
            next_state <= START;
            sda <= next_sda;
            if scl = '1' and start_triggered = '0' then
                gen_start <= '1';
                next_sda <= '0';
                next_start_triggered <= '1';
            elsif scl = '0' and clk100khz_rising = '1' and start_triggered = '1' then
                gen_start <= '1';
                next_state <= WRITE_DATA;
                next_start_triggered <= '0';
            end if;
        when S_REP_START =>
            rep_start <= '1';
            next_state <= S_REP_START;
            sda <= next_sda;
            if scl = '1' and clk100khz_falling = '1' and start_triggered = '0' then
                gen_start <= '1';
                next_sda <= '0';
                next_start_triggered <= '1';
            elsif scl = '0' and clk100khz_rising = '1' and start_triggered = '1' then
                gen_start <= '1';
                next_state <= WRITE_DATA;
                next_start_triggered <= '0';
            end if;
        when WRITE_DATA =>
            shift_enable_write <= '1';
            tx_oe <= '1';
            if send_done = '1' then
                next_state <= CHECK_ACK;
                next_rom_index <= rom_index + 1;
            else
                next_state <= WRITE_DATA;
            end if;
            next_edge_counter <= 0;
        when CHECK_ACK =>
            next_state <= CHECK_ACK;
            if clk100khz_falling = '1' then 
                next_clk100khz_falling <= '1';
            end if;
            if rom_index = 3 and s_clk100khz_falling = '1' and clk100khz_rising = '1' then
                next_state <= RECEIVE_TMP;
                next_rom_index <= 0;
                next_scl_was_falling <= '0';
                next_clk100khz_falling <= '0';
            elsif rom_index = 2 and s_clk100khz_falling = '1' and clk100khz_rising = '1' then
                rep_start <= '1';
                next_state <= S_REP_START;
                next_sda <= 'Z';
                sda <= 'Z';
                next_scl_was_falling <= '0';
                next_clk100khz_falling <= '0';
            elsif s_clk100khz_falling = '1' and clk100khz_rising = '1' then
                next_state <= WRITE_DATA;
                next_scl_was_falling <= '0';
                next_clk100khz_falling <= '0';
            end if;
        when RECEIVE_TMP =>
            shift_enable_read <= '1';
            if read_done = '1' then
                if received_msb = '0' then
                    next_state <= SEND_ACK;
                    next_received_msb <= '1';
                else
                    next_state <= SEND_NACK;
                    next_received_msb <= '0';
                end if;
            else
                next_state <= RECEIVE_TMP;
            end if;
        when SEND_ACK =>
            next_state <= SEND_ACK;
            sda <= next_sda;
            if scl_rising = '1' then
                next_scl_was_rising <= '1';
            end if;
            if clk100khz_rising = '1' then
                next_sda <= '0';
            end if;
            if scl_rising = '1' then
                next_sda <= 'Z';
            end if;
            if clk100khz_rising = '1' and scl_was_rising = '1' then
                next_state <= RECEIVE_TMP;
                next_scl_was_rising <= '0';
            end if;
        when SEND_NACK =>
            next_state <= SEND_NACK;
            next_received_msb <= '0';
            if clk100khz_falling = '1' then
                next_clk100khz_falling <= '1';
            end if;

            if scl_falling = '1' then
                next_scl_was_falling <= '1';
            end if;

            if scl_falling = '1' and scl_was_falling = '1' then
                next_state <= STOP;
                next_clk100khz_falling <= '0';
                next_scl_was_falling <= '0';
            end if;
        when STOP => 
            sda <= next_sda;
            next_state <= STOP;
            if scl_falling = '1' then
                next_scl_was_falling <= '1';
            end if;
            
            if clk100khz_rising = '1' and stop_triggered = '0' then
                next_sda <= '0';
            end if;
            
            if clk100khz_falling = '1' then
                next_sda <= 'Z';
                next_stop_triggered <= '1';
            end if;

            if scl_falling = '1' and scl_was_falling = '1' then
                next_state <= START;
                next_scl_was_falling <= '0';
                next_stop_triggered <= '0';
            end if;

    end case;
end process;

registers: process(clk, rst) is begin
        if rst = '0' then
            current_state <= IDLE;
            edge_counter <= 0;
            rom_index <= 0;
            received_msb <= '0';
            data_to_write <= X"00";
            scl_was_falling <= '0';
            scl_was_rising <= '0';
            s_clk100khz_falling <= '0';
            start_triggered <= '0';
            stop_triggered <= '0';
        elsif rising_edge(clk) then
            current_state <= next_state;
            received_msb <= next_received_msb;
            edge_counter <= next_edge_counter;
            rom_index <= next_rom_index;
            data_to_write <= s_next_data_to_write;
            scl_was_falling <= next_scl_was_falling;
            scl_was_rising <= next_scl_was_rising;
            s_clk100khz_falling <= next_clk100khz_falling;
            start_triggered <= next_start_triggered;
            stop_triggered <= next_stop_triggered;
            
        case (current_state) is
        when IDLE =>
        dbg_state1 <= '0';
        dbg_state2 <= '0';
        dbg_state3 <= '0';
        dbg_state4 <= '0';
        when START =>
        dbg_state1 <= '1';
        dbg_state2 <= '0';
        dbg_state3 <= '0';
        dbg_state4 <= '0';
        when WRITE_DATA =>
        dbg_state1 <= '0';
        dbg_state2 <= '1';
        dbg_state3 <= '0';
        dbg_state4 <= '0';
        when CHECK_ACK =>
        dbg_state1 <= '1';
        dbg_state2 <= '1';
        dbg_state3 <= '0';
        dbg_state4 <= '0';
        when RECEIVE_TMP =>
        dbg_state1 <= '0';
        dbg_state2 <= '0';
        dbg_state3 <= '1';
        dbg_state4 <= '0';
        when SEND_ACK =>
        dbg_state1 <= '1';
        dbg_state2 <= '0';
        dbg_state3 <= '1';
        dbg_state4 <= '0';
        when SEND_NACK =>
        dbg_state1 <= '0';
        dbg_state2 <= '1';
        dbg_state3 <= '1';
        dbg_state4 <= '0';
        when STOP => 
        dbg_state1 <= '1';
        dbg_state2 <= '1';
        dbg_state3 <= '1';
        dbg_state4 <= '0';
        when S_REP_START =>
        dbg_state1 <= '0';
        dbg_state2 <= '0';
        dbg_state3 <= '0';
        dbg_state4 <= '1';
        end case;
        
    
        end if;
end process;
end architecture;