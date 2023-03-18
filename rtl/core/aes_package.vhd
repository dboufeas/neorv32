library ieee;
use ieee.std_logic_1164.all;

package aes_package is
    function gf_mul2(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector;
    function gf_mul3(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector;
    function gf_mul4(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector;
    function gf_mul8(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector;
    function gf_mul9(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector;
    function gf_mulb(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector;
    function gf_muld(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector;
    function gf_mule(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector;
    
    component aes_sbox
        port (
            data_i : in std_ulogic_vector(7 downto 0);
            data_o : out std_ulogic_vector(7 downto 0)
        );
    end component;

    component aes_inv_sbox
        port (
            data_i : in std_ulogic_vector(7 downto 0);
            data_o : out std_ulogic_vector(7 downto 0)
        );
    end component;

    component aes_slayer
        port (
            data1_i, data2_i : in std_ulogic_vector(31 downto 0);
            opt_rot          : in std_ulogic;
            data_o           : out std_ulogic_vector(31 downto 0)
        );
    end component;

    component aes_inv_slayer
        port (
            data1_i, data2_i : in std_ulogic_vector(31 downto 0);
            data_o           : out std_ulogic_vector(31 downto 0)
        );
    end component;

    component aes_mixcols
        port (
            data1_i, data2_i : in std_ulogic_vector(31 downto 0);
            byte_endianness  : in std_ulogic; 
            data_o           : out std_ulogic_vector(31 downto 0)
        );
    end component;

    component aes_inv_mixcols
        port (
            data1_i, data2_i : in std_ulogic_vector(31 downto 0);
            data_o           : out std_ulogic_vector(31 downto 0)
        );
    end component;
end package;

package body aes_package is
    function gf_mul2(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector is
        variable output : std_ulogic_vector(7 downto 0);
    begin
        output := input(6 downto 4) & (input(3) xor input(7)) & (input(2) xor input(7)) & input(1) & (input(0) xor input(7)) & input(7);
        return output;
    end function;

    function gf_mul3(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector is
        variable output : std_ulogic_vector(7 downto 0);
    begin
        output := gf_mul2(input) xor input;
        return output;
    end function;

    function gf_mul4(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector is
        variable output : std_ulogic_vector(7 downto 0);
    begin
        output := gf_mul2(gf_mul2(input));
        return output;
    end function;

    function gf_mul8(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector is
        variable output : std_ulogic_vector(7 downto 0);
    begin
        output := gf_mul2(gf_mul2(gf_mul2(input)));
        return output;
    end function;

    function gf_mul9(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector is
        variable output : std_ulogic_vector(7 downto 0);
    begin
        output := gf_mul8(input) xor input;
        return output;
    end function;

    function gf_mulb(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector is
        variable output : std_ulogic_vector(7 downto 0);
    begin
        output := gf_mul8(input) xor gf_mul2(input) xor input;
        return output;        
    end function;

    function gf_muld(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector is
        variable output : std_ulogic_vector(7 downto 0);
    begin
        output := gf_mul8(input) xor gf_mul4(input) xor input;
        return output;
    end function;

    function gf_mule(input : std_ulogic_vector(7 downto 0)) return std_ulogic_vector is
        variable output : std_ulogic_vector(7 downto 0);
    begin
        output := gf_mul2(input) xor gf_mul4(input) xor gf_mul8(input);
        return output;
    end function;
end package body;