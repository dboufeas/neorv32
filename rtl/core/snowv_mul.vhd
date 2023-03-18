library ieee;
use ieee.std_logic_1164.all;

use work.snowv_package.all;

entity snowv_mul is
    port (
        data1_i, data2_i, data3_i : in std_ulogic_vector(31 downto 0);
        data_o                    : out std_ulogic_vector(31 downto 0)
    );
end entity;

architecture snowv_mul_rtl of snowv_mul is
    signal temp : std_ulogic_vector(15 downto 0);
begin
    temp <= mul_x(data1_i(15 downto 0), data2_i(15 downto 0));
    data_o <= (x"0000" & temp) xor data3_i;
end architecture;