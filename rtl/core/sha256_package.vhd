library ieee;
use ieee.std_logic_1164.all;

package sha256_package is
    component sha256_ops
        port (
            data1_i, data2_i, data3_i : in std_ulogic_vector(31 downto 0);
            rtype                     : in std_ulogic_vector(1 downto 0);
            funct7_msb                : in std_ulogic;
            funct3_lsb                : in std_ulogic;
            data_o                    : out std_ulogic_vector(31 downto 0)
        );
    end component;

    function rotr(input : std_ulogic_vector(31 downto 0); n : integer range 0 to 31) return std_ulogic_vector;
    function Ch(x, y, z : std_ulogic_vector(31 downto 0)) return std_ulogic_vector;
    function Maj(x, y, z : std_ulogic_vector(31 downto 0)) return std_ulogic_vector;
    function sum0(input : std_ulogic_vector(31 downto 0)) return std_ulogic_vector;
    function sum1(input : std_ulogic_vector(31 downto 0)) return std_ulogic_vector;
    function sig0(input : std_ulogic_vector(31 downto 0)) return std_ulogic_vector;
    function sig1(input : std_ulogic_vector(31 downto 0)) return std_ulogic_vector;
end package;

package body sha256_package is
    function rotr(input : std_ulogic_vector(31 downto 0); n : integer range 0 to 31) return std_ulogic_vector is 
        variable output : std_ulogic_vector(31 downto 0);
    begin
        output := input(n-1 downto 0) & input(31 downto n);
        return output;
    end function;

    function Ch(x, y, z : std_ulogic_vector(31 downto 0)) return std_ulogic_vector is 
        variable output : std_ulogic_vector(31 downto 0);
    begin
        output := (x and y) xor ((not x) and z);
        return output;
    end function;

    function Maj(x, y, z : std_ulogic_vector(31 downto 0)) return std_ulogic_vector is
        variable output : std_ulogic_vector(31 downto 0);
    begin
        output := (x and y) xor (x and z) xor (y and z);
        return output;
    end function;

    function sum0(input : std_ulogic_vector(31 downto 0)) return std_ulogic_vector is
        variable output : std_ulogic_vector(31 downto 0);
    begin
        output := rotr(input, 2) xor rotr(input, 13) xor rotr(input, 22);
        return output;
    end function;

    function sum1(input : std_ulogic_vector(31 downto 0)) return std_ulogic_vector is
        variable output : std_ulogic_vector(31 downto 0);
    begin
        output := rotr(input, 6) xor rotr(input, 11) xor rotr(input, 25);
        return output;
    end function;

    function sig0(input : std_ulogic_vector(31 downto 0)) return std_ulogic_vector is
        variable output : std_ulogic_vector(31 downto 0);
    begin
        output := rotr(input, 7) xor rotr(input, 18) xor ("000" & input(31 downto 3));
        return output;
    end function;
    
    function sig1(input : std_ulogic_vector(31 downto 0)) return std_ulogic_vector is 
        variable output : std_ulogic_vector(31 downto 0);
    begin
        output := rotr(input, 17) xor rotr(input, 19) xor ("0000000000" & input(31 downto 10));
        return output;
    end function;
end package body;