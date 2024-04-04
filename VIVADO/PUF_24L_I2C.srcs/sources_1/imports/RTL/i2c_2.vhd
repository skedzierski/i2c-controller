library ieee;
use ieee.std_logic_1164.all;
use work.i2c_2_pkg.all;
use work.i2c_pkg.all;

entity i2c_2 is
    port(
        addr_bus: in std_logic_vector(7 downto 0);
        as: in std_logic;
        ds: in std_logic;
        rw: in std_logic; -- 1 is read, 0 is write
        clk: in std_logic;
        rst: in std_logic;
        irq: out std_logic;
        data_bus: inout std_logic_vector(7 downto 0);
        scl: inout std_logic;
        sda: inout std_logic
    );
end entity;

architecture rtl of i2c_2 is
    signal gen_start, gen_stop: std_logic;
    signal scl_t: SCL_STATE;
    signal s_ctr: ctr_bits;
    signal s_sr: sr_bits;
    signal s_addr, s_dtr, s_drr: std_logic_vector(7 downto 0);
    signal begin_count, done_counting: std_logic;
    type T_STATE is (IDLE, ADDR_SHIFT, ADDRESS_ACK, RECEIVE_DATA, TRANSMIT_DATA, SEND_ACK, WAIT_ACK);
    signal current_state, next_state: T_STATE;
    signal falling_sda, rising_scl: std_logic;
    impure function start_detected return boolean is
    begin
        return falling_sda = '1' and scl = '1';
    end function;

    impure function stop_detected return boolean is
    begin
        return rising_scl = '1' and sda = '1';
    end function;

    impure function master_mode return boolean is
    begin
        return s_ctr.mode_sel = '1';
    end;

    impure function slave_mode return boolean is
    begin
        return s_ctr.mode_sel = '0';
    end;
    signal ack_receive: std_logic;
begin

    sda_detector: entity work.edge_detector(rtl)
    port map(
        clk => clk, 
        rst => rst,
        sig => sda,
        o_falling_edge => falling_sda
    );

    scl_detector: entity work.edge_detector(rtl)
    port map(
        clk => clk,
        rst => rst,
        sig => scl,
        o_rising_edge => rising_scl
    );

    scl_gen_0: entity work.scl_gen(rtl)
    port map(
        fpga_clk => clk,
        rst => rst,
        gen_start => gen_start,
        gen_stop => gen_stop,
        o_scl => scl,
        o_state => scl_t
    );

    bus_0: entity work.reg_map(rtl)
    port map(
        i_addr => addr_bus,
        data => data_bus,
        as => as,
        ds => ds,
        rw => rw,
        rst => rst,
        clk => clk,
        ctr => s_ctr,
        sr => s_sr,
        o_addr_reg => s_addr,
        dtr => s_dtr,
        drr => s_drr
    );
    
    master_slave_fsm_0: entity work.master_slave_fsm(rtl)
    port map(
        clk => clk,
        rst => rst,
        scl => scl,
        sda => sda,
        control_reg => s_ctr,
        addr_reg => s_addr,
        data_transmit_reg => s_dtr,
        data_receive_reg => s_drr,
        ack_receive => ack_receive
    );

    bit_counter: entity work.generic_counter(rtl)
    generic map (
        4
    )
    port map(
        clk => scl,
        rst => begin_count,
        preload => X"8",
        o_cnt => done_counting
    );

    process(
        addr_bus,
        as,
        ds,
        rw,
        clk,
        rst,
        data_bus,
        scl,
        sda
    ) is
    begin
        gen_start <= '0';
        gen_stop <= '0';
        begin_count <= '0';
        next_state <= IDLE;
        if rising_edge(s_ctr.mode_sel) then
            gen_start <= '1';
        end if;

        if falling_edge(s_ctr.mode_sel) then
            gen_stop <= '1';
        end if;

        case current_state is
            when IDLE =>
                if start_detected then
                    next_state <= ADDR_SHIFT;
                else
                    next_state <= IDLE;
                end if;

            when ADDR_SHIFT =>
                begin_count <= '1';
                if done_counting = '1' then
                    begin_count <= '0';
                    next_state <= ADDRESS_ACK;
                elsif stop_detected then
                    next_state <= IDLE;
                else
                    next_state <= ADDR_SHIFT;
                end if;

            when ADDRESS_ACK =>
                if stop_detected then
                    next_state <= IDLE;
                elsif ack_receive = '1' and master_mode and s_ctr.transmit_dir = '0' then
                    next_state <= RECEIVE_DATA;
                elsif ack_receive = '1'and master_mode and s_ctr.transmit_dir = '1' then
                    next_state <= TRANSMIT_DATA;
                elsif ack_receive = '1' and slave_mode and s_ctr.transmit_dir = '0' then
                    next_state <= RECEIVE_DATA;
                elsif ack_receive = '1' and slave_mode and s_ctr.transmit_dir = '1' then
                    next_state <= TRANSMIT_DATA;
                elsif not (ack_receive = '1') then
                    next_state <= IDLE;
                end if;

            when RECEIVE_DATA =>
                begin_count <= '1';
                if done_counting = '1' then
                    next_state <= SEND_ACK;
                    begin_count <= '0';
                elsif stop_detected then
                    next_state <= IDLE;
                else
                    next_state <= RECEIVE_DATA;
                end if;

            when TRANSMIT_DATA =>
                begin_count <= '1';
                if done_counting = '1' then
                    next_state <= WAIT_ACK;
                    begin_count <= '0';
                elsif stop_detected then
                    next_state <= IDLE;
                else
                    next_state <= TRANSMIT_DATA;
                end if;

            when SEND_ACK => 
                if stop_detected then
                    next_state <= IDLE;
                else
                    next_state <= RECEIVE_DATA;
                end if;
            
            when WAIT_ACK =>
                if stop_detected then
                    next_state <= IDLE;
                elsif ack_receive = '1' then
                    next_state <= TRANSMIT_DATA;
                elsif ack_receive = '0' then
                    next_state <= IDLE;
                else
                    next_state <= WAIT_ACK;
                end if;
        end case;
    end process;

    state_reg: process (scl, rst) is
    begin
        if rst = '0' then
            current_state <= IDLE;
        elsif falling_edge(scl) then
            current_state <= next_state;
        end if;
    end process;

end architecture;
