library ieee;
use ieee.std_logic_1164.all;

use work.i2c_2_pkg.all;
entity reg_map is
    port(
        i_addr: in std_logic_vector(7 downto 0);
        data: inout std_logic_vector(7 downto 0);
        as: in std_logic;
        ds: in std_logic;
        rw: in std_logic;
        rst: in std_logic;
        clk: in std_logic;
        ctr: inout ctr_bits;
        sr: in sr_bits;
        o_addr_reg: out std_logic_vector(7 downto 0);
        dtr: out std_logic_vector(7 downto 0);
        drr: in std_logic_vector(7 downto 0)
    );

end entity;

architecture rtl of reg_map is
    signal control, next_control: ctr_bits;
    signal status, next_status: sr_bits;
    signal addr, next_addr, next_data: std_logic_vector (7 downto 0);
    signal data_transmit, next_data_transmit: std_logic_vector (7 downto 0);
    signal data_receive, next_data_receive: std_logic_vector (7 downto 0);
    signal control_enable, addr_enable, data_transmit_enable: std_logic;
begin

    process(i_addr,
            data,
            as,
            ds,
            rw,
            rst,
            clk,
            sr,
            drr,
            data_transmit,
            control,
            addr,
            status,
            data_receive)
    is 
    begin
        next_control <= stlv_to_ctr_bits(X"00");
        next_addr <= X"00";
        next_data_transmit <= X"00";
        next_status <= sr;
        dtr <= data_transmit;
        next_data_receive <= drr;
        o_addr_reg <= addr;
        control_enable <= '0';
        addr_enable <= '0';
        data_transmit_enable <= '0';
        next_data <= X"00";
        ctr <= stlv_to_ctr_bits(X"00");
        if rw = '0' and ds = '1' and as = '1' then
            ctr <= next_control;
            case i_addr is
            when X"04" => 
                control_enable <= '1';
                next_control <= stlv_to_ctr_bits(data);
            when X"0B" => 
                addr_enable <= '1';
                next_addr <= data;
            when X"0E" => 
                data_transmit_enable <= '1';
                next_data_transmit <= data;
            when others => null;
        end case;
        elsif rw = '1' and as = '1' then
            control <= ctr;
            case i_addr is
                when X"04" => next_data <= ctr_bits_to_stlv(control);
                when X"08" => next_data <= sr_bits_to_stlv(status);
                when X"0E" => next_data <= data_transmit;
                when X"00" => next_data <= data_receive;
                when others => null;
            end case;
         end if;
    end process;

    process(clk, rst) is
    begin
        if rst = '0' then
             control <= stlv_to_ctr_bits(X"00");
             status <= stlv_to_sr_bits(X"00");
             addr <= X"00";
             data_transmit <= X"00";
             data_receive <= X"00";
             data <= "ZZZZZZZZ";
        elsif rising_edge(clk) then
             if control_enable = '1' then
                 control <= next_control;
             end if;

             status <= next_status;
            
             if addr_enable = '1' then
                 addr <= next_addr;
             end if;
             if data_transmit_enable = '1' then
                 data_transmit <= next_data_transmit;
             end if;

            data_receive <= next_data_receive;
            if rw = '1' and as = '1' then
                data <= next_data;
            end if;
        end if;
    end process;
end architecture;
