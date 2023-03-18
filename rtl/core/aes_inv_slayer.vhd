library ieee;
use ieee.std_logic_1164.all;

use work.aes_package.all;

entity aes_inv_slayer is
    port (
        data1_i, data2_i : in std_ulogic_vector(31 downto 0);
        data_o           : out std_ulogic_vector(31 downto 0)
    );
end entity;

architecture aes_inv_slayer_rtl of aes_inv_slayer is
begin
    aes_sbox3_i: aes_inv_sbox port map (
        data_i => data1_i(31 downto 24),
        data_o => data_o(31 downto 24)
    );

    aes_sbox2_i: aes_inv_sbox port map (
        data_i => data2_i(23 downto 16),
        data_o => data_o(23 downto 16)
    );

    aes_sbox1_i: aes_inv_sbox port map (
        data_i => data1_i(15 downto 8),
        data_o => data_o(15 downto 8)
    );

    aes_sbox0_i: aes_inv_sbox port map (
        data_i => data2_i(7 downto 0),
        data_o => data_o(7 downto 0)
    );
end architecture;