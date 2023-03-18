library ieee;
use ieee.std_logic_1164.all;

use work.aes_package.all;

entity aes_slayer is
    port (
        data1_i, data2_i : in std_ulogic_vector(31 downto 0);
        opt_rot          : in std_ulogic;
        data_o           : out std_ulogic_vector(31 downto 0)
    );
end entity;

architecture aes_slayer_rtl of aes_slayer is
    signal data_sub : std_ulogic_vector(31 downto 0);
    signal data_rot : std_ulogic_vector(31 downto 0);
begin
    aes_sbox3_i: aes_sbox port map (
        data_i => data1_i(31 downto 24),
        data_o => data_sub(31 downto 24)
    );

    aes_sbox2_i: aes_sbox port map (
        data_i => data2_i(23 downto 16),
        data_o => data_sub(23 downto 16)
    );

    aes_sbox1_i: aes_sbox port map (
        data_i => data1_i(15 downto 8),
        data_o => data_sub(15 downto 8)
    );

    aes_sbox0_i: aes_sbox port map (
        data_i => data2_i(7 downto 0),
        data_o => data_sub(7 downto 0)
    );

    data_rot <= data_sub(23 downto 0) & data_sub(31 downto 24);

    with opt_rot select data_o <=
        data_sub when '0',
        data_rot when others;
end architecture;