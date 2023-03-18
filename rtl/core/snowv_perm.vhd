library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity snowv_perm is
    port (
        data1_i, data2_i : in std_ulogic_vector(31 downto 0);
        bytes2perm       : in std_ulogic_vector(1 downto 0);
        op               : in std_ulogic;                       -- 0->load low / 1->load high
        data_o           : out std_ulogic_vector(31 downto 0)
    );
end entity;

architecture snowv_perm_rtl of snowv_perm is
    signal perm_bytes1, perm_bytes2 : std_ulogic_vector(7 downto 0);
    signal perm_out1, perm_out2 : std_ulogic_vector(31 downto 0);
begin
    perm_bytes1 <= data1_i(8*to_integer(unsigned(bytes2perm))+7 downto 8*to_integer(unsigned(bytes2perm)));
    perm_bytes2 <= data2_i(8*to_integer(unsigned(bytes2perm))+7 downto 8*to_integer(unsigned(bytes2perm)));

    perm_out1 <= x"0000" & perm_bytes1 & perm_bytes2;
    perm_out2 <= perm_bytes1 & perm_bytes2 & x"0000";

    with op select data_o <=
        perm_out1 when '0',
        perm_out2 when others;
end architecture;