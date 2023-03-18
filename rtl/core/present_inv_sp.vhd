library ieee;
use ieee.std_logic_1164.all;

use work.present_package.all;

entity present_inv_sp is
    port (
        data_high_i, data_low_i : in std_ulogic_vector(31 downto 0);
        data_high_o, data_low_o : out std_ulogic_vector(31 downto 0)
    );
end entity;

architecture present_inv_sp_rtl of present_inv_sp is
    signal data_i, data_o, data_perm : std_ulogic_vector(63 downto 0);
begin
    data_i <= data_high_i & data_low_i;

    data_perm(0)    <= data_i(0);
    data_perm(4)    <= data_i(1);
    data_perm(8)    <= data_i(2);
    data_perm(12)   <= data_i(3);
    data_perm(16)   <= data_i(4);
    data_perm(20)   <= data_i(5);
    data_perm(24)   <= data_i(6);
    data_perm(28)   <= data_i(7);
    data_perm(32)   <= data_i(8);
    data_perm(36)   <= data_i(9);
    data_perm(40)   <= data_i(10);
    data_perm(44)   <= data_i(11);
    data_perm(48)   <= data_i(12);
    data_perm(52)   <= data_i(13);
    data_perm(56)   <= data_i(14);
    data_perm(60)   <= data_i(15);
    data_perm(1)    <= data_i(16);
    data_perm(5)    <= data_i(17);
    data_perm(9)    <= data_i(18);
    data_perm(13)   <= data_i(19);
    data_perm(17)   <= data_i(20);
    data_perm(21)   <= data_i(21);
    data_perm(25)   <= data_i(22);
    data_perm(29)   <= data_i(23);
    data_perm(33)   <= data_i(24);
    data_perm(37)   <= data_i(25);
    data_perm(41)   <= data_i(26);
    data_perm(45)   <= data_i(27);
    data_perm(49)   <= data_i(28);
    data_perm(53)   <= data_i(29);
    data_perm(57)   <= data_i(30);
    data_perm(61)   <= data_i(31);
    data_perm(2)    <= data_i(32);
    data_perm(6)    <= data_i(33);
    data_perm(10)   <= data_i(34);
    data_perm(14)   <= data_i(35);
    data_perm(18)   <= data_i(36);
    data_perm(22)   <= data_i(37);
    data_perm(26)   <= data_i(38);
    data_perm(30)   <= data_i(39);
    data_perm(34)   <= data_i(40);
    data_perm(38)   <= data_i(41);
    data_perm(42)   <= data_i(42);
    data_perm(46)   <= data_i(43);
    data_perm(50)   <= data_i(44);
    data_perm(54)   <= data_i(45);
    data_perm(58)   <= data_i(46);
    data_perm(62)   <= data_i(47);
    data_perm(3)    <= data_i(48);
    data_perm(7)    <= data_i(49);
    data_perm(11)   <= data_i(50);
    data_perm(15)   <= data_i(51);
    data_perm(19)   <= data_i(52);
    data_perm(23)   <= data_i(53);
    data_perm(27)   <= data_i(54);
    data_perm(31)   <= data_i(55);
    data_perm(35)   <= data_i(56);
    data_perm(39)   <= data_i(57);
    data_perm(43)   <= data_i(58);
    data_perm(47)   <= data_i(59);
    data_perm(51)   <= data_i(60);
    data_perm(55)   <= data_i(61);
    data_perm(59)   <= data_i(62);
    data_perm(63)   <= data_i(63);

    gen_inv_slayer: for i in 0 to 15 generate
        inv_slayer_i: present_inv_sbox port map (
            data_i => data_perm(4*i+3 downto 4*i),
            data_o => data_o(4*i+3 downto 4*i)
        );
    end generate;

    data_high_o <= data_o(63 downto 32);
    data_low_o <= data_o(31 downto 0);
end architecture;