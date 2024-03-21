library ieee;
use ieee.std_logic_1164.all;
use work.i2c_pkg.all;

entity i2c is
    port(
        num_bytes_to_receive: in natural;
        data_bus: inout std_logic_vector(15 downto 0);--data bus
        addr_bus: in std_logic_vector(7 downto 0);   --address bus
        rw: in std_logic;                            --rw=1 - write request
        rst: in std_logic;                           --reset active low
        clk: in std_logic;                           --fpga clock
        as: in std_logic;                            --address on address bus is valid
        ds: in std_logic;                            --data is valid
        irq: out std_logic;                          --transmit/receive done active high
        scl: out std_logic;
        sda: inout std_logic 
    );
end;

architecture rtl of i2c is
    type T_STATE is (IDLE, HEADER, ACK_HEADER, RCV_DATA, ACK_DATA, XMIT_DATA, WAIT_ACK, STOP);
    signal clk_state: SCL_STATE;
    signal CURRENT_STATE, NEXT_STATE: T_STATE;
    signal detect_start, header_xmit_done: std_logic;
    signal header_reg_rw, data_reg_rw, receive_data_reg_rw: std_logic;
    signal gen_start, gen_stop: std_logic;
    signal data_rcv_done: std_logic;
    signal detect_stop, data_xmit_done: std_logic;
    signal s_scl, s_rw: std_logic;
begin

transmit_header_reg: entity work.tx_shift_register(rtl)
    generic map(data_width => 8)
    port map(
        clk => s_scl,
        rst => rst,
        shift_enable => header_reg_rw,
        parallel_data => data_bus(7 downto 0),
        irq => header_xmit_done,
        serial_data => sda
    );

transmit_data_reg: entity work.tx_shift_register(rtl)
    generic map(data_width => 8)
    port map(
        clk => s_scl,
        rst => rst,
        shift_enable =>  data_reg_rw,
        parallel_data => data_bus(7 downto 0),
        irq => data_xmit_done,
        serial_data => sda
    );

receive_data_reg: entity work.rx_shift_register(rtl)
    generic map(data_width => 16)
    port map(
        clk => s_scl,
        rst => rst,
        shift_enable =>  receive_data_reg_rw,
        parallel_data => data_bus,
        irq => data_rcv_done,
        serial_data => sda
    );

scl_gen: entity work.scl_gen(rtl)
    port map(
        fpga_clk => clk,
        rst => rst,
        gen_start => gen_start,
        gen_stop => gen_stop,
        o_scl => s_scl
    );

scl <= s_scl;
detect_start <= as and ds;
s_rw <= not rw;
process is
begin
    data_reg_rw <= '0';
    header_reg_rw <='0';
    receive_data_reg_rw <= '0';
    sda <= '1';
    case CURRENT_STATE is
        when IDLE =>
            if rst = '0' then
                NEXT_STATE <= CURRENT_STATE;
            elsif detect_start = '1' then
                NEXT_STATE <= HEADER;
                header_reg_rw <= '1';
            end if;

        when HEADER =>
            header_reg_rw <= '1';
            if header_xmit_done = '1' then
                NEXT_STATE <= ACK_HEADER;
            else
                NEXT_STATE <= CURRENT_STATE;
            end if;

        when ACK_HEADER => 
            sda <= s_rw;
            if s_rw = '1' then
                NEXT_STATE <= RCV_DATA;
            elsif s_rw = '0' then
                NEXT_STATE <= XMIT_DATA;
            elsif sda = '1' then
                NEXT_STATE <= STOP;
            end if;

        when RCV_DATA =>
            receive_data_reg_rw <= '1';
            if data_rcv_done = '1' then
                NEXT_STATE <= ACK_DATA;
            elsif detect_stop = '1' then
                NEXT_STATE <= STOP;
            end if;

        when XMIT_DATA =>
            data_reg_rw <= '1';
            if data_xmit_done = '1' then
                sda <= 'Z';
                NEXT_STATE <= WAIT_ACK;
            elsif detect_stop = '1' then
                NEXT_STATE <= STOP;
            end if;

        when ACK_DATA =>
            sda <= '0';
            NEXT_STATE <= RCV_DATA;
        
        when WAIT_ACK =>
            if sda = '0' then
                NEXT_STATE <= STOP;
            end if;

        when STOP =>
            NEXT_STATE <= IDLE;
        
        when others => null;
    end case;
end process;

ctrl_reg: 


process(s_scl, rst) is
begin
    if rst = '0' then
        CURRENT_STATE <= IDLE;
    elsif clk'event and clk = '1' then
        CURRENT_STATE <= NEXT_STATE;
    end if;
end process;

end;