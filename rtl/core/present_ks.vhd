library ieee;
use ieee.std_logic_1164.all;

use work.present_package.all;

entity present_ks is
    port (
        clk_i, rstn_i          : in std_ulogic;
        busy_i, start_i        : in std_ulogic;
        load_key_i             : in std_ulogic; -- if '1' load key else nothing
        update_key_i           : in std_ulogic; -- if '1' update key else nothing
        key1_i, key2_i, key3_i : in std_ulogic_vector(31 downto 0);
        rk_high_o, rk_low_o    : out std_ulogic_vector(31 downto 0);
        done_o                 : out std_ulogic
    );
end entity;

architecture present_ks_rtl of present_ks is
    signal key_reg : std_ulogic_vector(79 downto 0); -- 80-bit key register
    
    signal key_rot, key_update : std_ulogic_vector(79 downto 0);
    signal key_sub : std_ulogic_vector(3 downto 0);
    signal key_xor : std_ulogic_vector(4 downto 0);
begin
    process (clk_i, rstn_i)
    begin
        if (rstn_i = '0') then
            key_reg <= (others => '0');
            done_o <= '0';
        elsif rising_edge(clk_i) then
            if (busy_i = '0' and start_i = '1') then -- if CFU is idle (ready for next operation) and actually triggered by a custom instruction word
                if (load_key_i = '1') then
                    key_reg <= key1_i & key2_i & key3_i(31 downto 16);
                elsif (update_key_i = '1') then
                    key_reg <= key_update;
                end if;

                done_o <= '1';
            else
                done_o <= '0';
            end if;
        end if;
    end process;


    key_rot <= key_reg(18 downto 0) & key_reg(79 downto 19);

    ks_sbox_i: present_sbox port map (
        data_i => key_rot(79 downto 76),
        data_o => key_sub
    );

    key_xor <= key_rot(19 downto 15) xor key2_i(4 downto 0);

    key_update <= key_sub & key_rot(75 downto 20) & key_xor & key_rot(14 downto 0);

    rk_high_o <= key_reg(79 downto 48);
    rk_low_o <= key_reg(47 downto 16);
end architecture;