library ieee;
use ieee.std_logic_1164.all;

use work.aes_package.all;

entity aes_mixcols is
    port (
        data1_i, data2_i : in std_ulogic_vector(31 downto 0);
        byte_endianness  : in std_ulogic; 
        data_o           : out std_ulogic_vector(31 downto 0)
    );
end entity;

architecture aes_mixcols_rtl of aes_mixcols is
    signal t0, t1, t2, t3 : std_ulogic_vector(7 downto 0);
    signal res0, res1, res2, res3 : std_ulogic_vector(7 downto 0);
begin
    t0 <= data1_i(31 downto 24) when byte_endianness = '0' else data2_i(7 downto 0);
    t1 <= data1_i(23 downto 16) when byte_endianness = '0' else data2_i(15 downto 8);
    t2 <= data2_i(15 downto 8)  when byte_endianness = '0' else data1_i(23 downto 16);
    t3 <= data2_i(7 downto 0)   when byte_endianness = '0' else data1_i(31 downto 24);

    res0 <= gf_mul2(t0) xor gf_mul3(t1) xor t2 xor t3;
    res1 <= t0 xor gf_mul2(t1) xor gf_mul3(t2) xor t3;
    res2 <= t0 xor t1 xor gf_mul2(t2) xor gf_mul3(t3);
    res3 <= gf_mul3(t0) xor t1 xor t2 xor gf_mul2(t3);

	data_o(31 downto 24) <= res0 when byte_endianness = '0' else res3;
	data_o(23 downto 16) <= res1 when byte_endianness = '0' else res2;
	data_o(15 downto 8)  <= res2 when byte_endianness = '0' else res1;
	data_o(7 downto 0)   <= res3 when byte_endianness = '0' else res0;
end architecture;
