library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity snowv_op1 is
    port (
        data1_i, data2_i, data3_i : in std_ulogic_vector(31 downto 0);
        data_o                    : out std_ulogic_vector(31 downto 0)
    );
end entity;

architecture snowv_op1_rtl of snowv_op1 is
    signal temp : std_ulogic_vector(31 downto 0);
begin
    temp <= data2_i xor data3_i;
    data_o <= std_ulogic_vector(unsigned(data1_i) + unsigned(temp));
end architecture;