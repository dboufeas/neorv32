library ieee;
use ieee.std_logic_1164.all;

entity present_sbox is
    port (
        data_i : in std_ulogic_vector(3 downto 0);
        data_o : out std_ulogic_vector(3 downto 0)
    );
end entity;

architecture present_sbox_rtl of present_sbox is
begin
    with data_i select data_o <=
        x"C" when x"0",
        x"5" when x"1",
        x"6" when x"2",
        x"B" when x"3",
        x"9" when x"4",
        x"0" when x"5",
        x"A" when x"6",
        x"D" when x"7",
        x"3" when x"8",
        x"E" when x"9",
        x"F" when x"A",
        x"8" when x"B",
        x"4" when x"C",
        x"7" when x"D",
        x"1" when x"E",
        x"2" when others;
end architecture;