library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sha256_package.all;

entity sha256_ops is
    port (
        data1_i, data2_i, data3_i : in std_ulogic_vector(31 downto 0);
        rtype                     : in std_ulogic_vector(1 downto 0);
        funct7_msb                : in std_ulogic;
        funct3_lsb                : in std_ulogic;
        data_o                    : out std_ulogic_vector(31 downto 0)
    );
end entity;

architecture sha256_ops_rtl of sha256_ops is
    signal add1, add2 : std_ulogic_vector(31 downto 0);
begin
    process (rtype, data1_i, data2_i, data3_i, funct7_msb, funct3_lsb)
    begin
        case rtype is
            -- r3 type instruction
            when "00" =>
                if (funct7_msb = '0') then 
                    add1 <= sig0(data1_i);
                else 
                    add1 <= sig1(data1_i);
                end if;
                add2 <= data2_i;
            -- r4 type instruction
            when others =>
                if (funct3_lsb = '0') then 
                    add1 <= sum0(data1_i);
                    add2 <= Maj(data1_i, data2_i, data3_i);
                else 
                    add1 <= sum1(data1_i);
                    add2 <= Ch(data1_i, data2_i, data3_i);
                end if;
        end case;
    end process;

    data_o <= std_ulogic_vector(unsigned(add1) + unsigned(add2));

end architecture;