library ieee;
use ieee.std_logic_1164.all;

entity present_inv_sbox is
    port (
        data_i : in std_ulogic_vector(3 downto 0);
        data_o : out std_ulogic_vector(3 downto 0)  
    );
end entity;

architecture present_inv_sbox_rtl of present_inv_sbox is
begin
    with data_i select data_o <=
        x"5" when x"0",
        x"E" when x"1",
        x"F" when x"2",
        x"8" when x"3",
        x"C" when x"4",
        x"1" when x"5",
        x"2" when x"6",
        x"D" when x"7",
        x"B" when x"8",
        x"4" when x"9",
        x"6" when x"A",
        x"3" when x"B",
        x"0" when x"C",
        x"7" when x"D",
        x"9" when x"E",
        x"A" when others;
end architecture;