library ieee;
use ieee.std_logic_1164.all;

package snowv_package is
    function mul_x(inp : std_ulogic_vector(15 downto 0); val : std_ulogic_vector(15 downto 0)) return std_ulogic_vector;
    function mul_x_inv(inp : std_ulogic_vector(15 downto 0); val : std_ulogic_vector(15 downto 0)) return std_ulogic_vector;

    component snowv_op0
        port (
            data1_i, data2_i, data3_i : in std_ulogic_vector(31 downto 0);
            data_o                    : out std_ulogic_vector(31 downto 0)
        );
    end component;

    component snowv_op1
        port (
            data1_i, data2_i, data3_i : in std_ulogic_vector(31 downto 0);
            data_o                    : out std_ulogic_vector(31 downto 0)
        );
    end component;

    component snowv_perm
        port (
            data1_i, data2_i : in std_ulogic_vector(31 downto 0);
            bytes2perm       : in std_ulogic_vector(1 downto 0);
            op               : in std_ulogic;                       -- 0->load low / 1->load high
            data_o           : out std_ulogic_vector(31 downto 0)
        );
    end component;

    component snowv_mul
        port (
            data1_i, data2_i, data3_i : in std_ulogic_vector(31 downto 0);
            data_o                    : out std_ulogic_vector(31 downto 0)
        );
    end component;

    component snowv_inv_mul
        port (
            data1_i, data2_i, data3_i : in std_ulogic_vector(31 downto 0);
            data_o                    : out std_ulogic_vector(31 downto 0)
        );
    end component;
end package;

package body snowv_package is
    function mul_x(inp : std_ulogic_vector(15 downto 0); val : std_ulogic_vector(15 downto 0)) return std_ulogic_vector is
        variable outp : std_ulogic_vector(15 downto 0);
    begin
        if (inp(15) = '1') then
            outp := (inp(14 downto 0) & '0') xor val;
        else
            outp := inp(14 downto 0) & '0';
        end if;

        return outp;
    end function;

    function mul_x_inv(inp : std_ulogic_vector(15 downto 0); val : std_ulogic_vector(15 downto 0)) return std_ulogic_vector is
        variable outp : std_ulogic_vector(15 downto 0);
    begin
        if (inp(0) = '1') then
            outp := ('0' & inp(15 downto 1)) xor val;
        else
            outp := '0' & inp(15 downto 1);
        end if;

        return outp;
    end function;
end package body;