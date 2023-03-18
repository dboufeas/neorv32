library ieee;
use ieee.std_logic_1164.all;

package present_package is
    component present_sbox
        port (
            data_i : in std_ulogic_vector(3 downto 0);
            data_o : out std_ulogic_vector(3 downto 0)
        );
    end component;

    component present_inv_sbox
        port (
            data_i : in std_ulogic_vector(3 downto 0);
            data_o : out std_ulogic_vector(3 downto 0)  
        );
    end component;

    component present_sp
        port (
            data_high_i, data_low_i : in std_ulogic_vector(31 downto 0);
            data_high_o, data_low_o : out std_ulogic_vector(31 downto 0)
        );
    end component;

    component present_inv_sp
        port (
            data_high_i, data_low_i : in std_ulogic_vector(31 downto 0);
            data_high_o, data_low_o : out std_ulogic_vector(31 downto 0)
        );
    end component;

    component present_ks
        port (
            clk_i, rstn_i          : in std_ulogic;
            busy_i, start_i        : in std_ulogic;
            load_key_i             : in std_ulogic; -- if '1' load key else nothing
            update_key_i           : in std_ulogic; -- if '1' update key else nothing
            key1_i, key2_i, key3_i : in std_ulogic_vector(31 downto 0);
            rk_high_o, rk_low_o    : out std_ulogic_vector(31 downto 0);
            done_o                 : out std_ulogic
        );
    end component;
end package;