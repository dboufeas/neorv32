library ieee;
use ieee.std_logic_1164.all;

use work.present_package.all;

entity present_sp is
    port (
        data_high_i, data_low_i : in std_ulogic_vector(31 downto 0);
        data_high_o, data_low_o : out std_ulogic_vector(31 downto 0)
    );
end entity;

architecture present_sp_rtl of present_sp is
    signal data_i, data_o, data_sub : std_ulogic_vector(63 downto 0);
begin
    data_i <= data_high_i & data_low_i;

    gen_slayer: for i in 0 to 15 generate
        sbox_i: present_sbox port map (
            data_i => data_i(4*i+3 downto 4*i),
            data_o => data_sub(4*i+3 downto 4*i)
        );
    end generate;

    data_o(0)   <= data_sub(0);
    data_o(16)  <= data_sub(1);
    data_o(32)  <= data_sub(2);
    data_o(48)  <= data_sub(3);
    data_o(1)   <= data_sub(4);
    data_o(17)  <= data_sub(5);
    data_o(33)  <= data_sub(6);
    data_o(49)  <= data_sub(7);
    data_o(2)   <= data_sub(8);
    data_o(18)  <= data_sub(9);
    data_o(34)  <= data_sub(10);
    data_o(50)  <= data_sub(11);
    data_o(3)   <= data_sub(12);
    data_o(19)  <= data_sub(13);
    data_o(35)  <= data_sub(14);
    data_o(51)  <= data_sub(15);
    data_o(4)   <= data_sub(16);
    data_o(20)  <= data_sub(17);
    data_o(36)  <= data_sub(18);
    data_o(52)  <= data_sub(19);
    data_o(5)   <= data_sub(20);
    data_o(21)  <= data_sub(21);
    data_o(37)  <= data_sub(22);
    data_o(53)  <= data_sub(23);
    data_o(6)   <= data_sub(24);
    data_o(22)  <= data_sub(25);
    data_o(38)  <= data_sub(26);
    data_o(54)  <= data_sub(27);
    data_o(7)   <= data_sub(28);
    data_o(23)  <= data_sub(29);
    data_o(39)  <= data_sub(30);
    data_o(55)  <= data_sub(31);
    data_o(8)   <= data_sub(32);
    data_o(24)  <= data_sub(33);
    data_o(40)  <= data_sub(34);
    data_o(56)  <= data_sub(35);
    data_o(9)   <= data_sub(36);
    data_o(25)  <= data_sub(37);
    data_o(41)  <= data_sub(38);
    data_o(57)  <= data_sub(39);
    data_o(10)  <= data_sub(40);
    data_o(26)  <= data_sub(41);
    data_o(42)  <= data_sub(42);
    data_o(58)  <= data_sub(43);
    data_o(11)  <= data_sub(44);
    data_o(27)  <= data_sub(45);
    data_o(43)  <= data_sub(46);
    data_o(59)  <= data_sub(47);
    data_o(12)  <= data_sub(48);
    data_o(28)  <= data_sub(49);
    data_o(44)  <= data_sub(50);
    data_o(60)  <= data_sub(51);
    data_o(13)  <= data_sub(52);
    data_o(29)  <= data_sub(53);
    data_o(45)  <= data_sub(54);
    data_o(61)  <= data_sub(55);
    data_o(14)  <= data_sub(56);
    data_o(30)  <= data_sub(57);
    data_o(46)  <= data_sub(58);
    data_o(62)  <= data_sub(59);
    data_o(15)  <= data_sub(60);
    data_o(31)  <= data_sub(61);
    data_o(47)  <= data_sub(62);
    data_o(63)  <= data_sub(63);

    data_high_o <= data_o(63 downto 32);
    data_low_o <= data_o(31 downto 0);
end architecture;