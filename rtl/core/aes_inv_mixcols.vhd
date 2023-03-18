library ieee;
use ieee.std_logic_1164.all;

use work.aes_package.all;

entity aes_inv_mixcols is
    port (
        data1_i, data2_i : in std_ulogic_vector(31 downto 0);
        data_o           : out std_ulogic_vector(31 downto 0)
    );
end entity;

architecture aes_inv_mixcols_rtl of aes_inv_mixcols is
    signal t1_0, t1_1, t1_2, t1_3 : std_ulogic_vector(7 downto 0);
    signal t2_0, t2_1, t2_2, t2_3 : std_ulogic_vector(7 downto 0);
begin
    t1_0 <= data1_i(31 downto 24);
    t1_1 <= data1_i(23 downto 16);
    t1_2 <= data1_i(15 downto 8);
    t1_3 <= data1_i(7 downto 0);

    t2_0 <= data2_i(31 downto 24);
    t2_1 <= data2_i(23 downto 16);
    t2_2 <= data2_i(15 downto 8);
    t2_3 <= data2_i(7 downto 0);

    data_o(31 downto 24) <= gf_mule(t1_0) xor gf_mulb(t1_1) xor gf_muld(t1_2) xor gf_mul9(t1_3);
    data_o(23 downto 16) <= gf_mul9(t1_0) xor gf_mule(t1_1) xor gf_mulb(t1_2) xor gf_muld(t1_3);
    data_o(15 downto 8) <= gf_muld(t2_0) xor gf_mul9(t2_1) xor gf_mule(t2_2) xor gf_mulb(t2_3);
    data_o(7 downto 0) <= gf_mulb(t2_0) xor gf_muld(t2_1) xor gf_mul9(t2_2) xor gf_mule(t2_3);

end architecture;
