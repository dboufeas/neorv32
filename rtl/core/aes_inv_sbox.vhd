library ieee;
use ieee.std_logic_1164.all;

entity aes_inv_sbox is
    port (
        data_i : in std_ulogic_vector(7 downto 0);
        data_o : out std_ulogic_vector(7 downto 0)
    );
end entity;

architecture aes_inv_sbox_rtl of aes_inv_sbox is
begin
    with data_i select data_o <=
        x"52" when x"00",
        x"09" when x"01",
        x"6a" when x"02",
        x"d5" when x"03",
        x"30" when x"04",
        x"36" when x"05",
        x"a5" when x"06",
        x"38" when x"07",
        x"bf" when x"08",
        x"40" when x"09",
        x"a3" when x"0a",
        x"9e" when x"0b",
        x"81" when x"0c",
        x"f3" when x"0d",
        x"d7" when x"0e",
        x"fb" when x"0f",
        x"7c" when x"10",
        x"e3" when x"11",
        x"39" when x"12",
        x"82" when x"13",
        x"9b" when x"14",
        x"2f" when x"15",
        x"ff" when x"16",
        x"87" when x"17",
        x"34" when x"18",
        x"8e" when x"19",
        x"43" when x"1a",
        x"44" when x"1b",
        x"c4" when x"1c",
        x"de" when x"1d",
        x"e9" when x"1e",
        x"cb" when x"1f",
        x"54" when x"20",
        x"7b" when x"21",
        x"94" when x"22",
        x"32" when x"23",
        x"a6" when x"24",
        x"c2" when x"25",
        x"23" when x"26",
        x"3d" when x"27",
        x"ee" when x"28",
        x"4c" when x"29",
        x"95" when x"2a",
        x"0b" when x"2b",
        x"42" when x"2c",
        x"fa" when x"2d",
        x"c3" when x"2e",
        x"4e" when x"2f",
        x"08" when x"30",
        x"2e" when x"31",
        x"a1" when x"32",
        x"66" when x"33",
        x"28" when x"34",
        x"d9" when x"35",
        x"24" when x"36",
        x"b2" when x"37",
        x"76" when x"38",
        x"5b" when x"39",
        x"a2" when x"3a",
        x"49" when x"3b",
        x"6d" when x"3c",
        x"8b" when x"3d",
        x"d1" when x"3e",
        x"25" when x"3f",
        x"72" when x"40",
        x"f8" when x"41",
        x"f6" when x"42",
        x"64" when x"43",
        x"86" when x"44",
        x"68" when x"45",
        x"98" when x"46",
        x"16" when x"47",
        x"d4" when x"48",
        x"a4" when x"49",
        x"5c" when x"4a",
        x"cc" when x"4b",
        x"5d" when x"4c",
        x"65" when x"4d",
        x"b6" when x"4e",
        x"92" when x"4f",
        x"6c" when x"50",
        x"70" when x"51",
        x"48" when x"52",
        x"50" when x"53",
        x"fd" when x"54",
        x"ed" when x"55",
        x"b9" when x"56",
        x"da" when x"57",
        x"5e" when x"58",
        x"15" when x"59",
        x"46" when x"5a",
        x"57" when x"5b",
        x"a7" when x"5c",
        x"8d" when x"5d",
        x"9d" when x"5e",
        x"84" when x"5f",
        x"90" when x"60",
        x"d8" when x"61",
        x"ab" when x"62",
        x"00" when x"63",
        x"8c" when x"64",
        x"bc" when x"65",
        x"d3" when x"66",
        x"0a" when x"67",
        x"f7" when x"68",
        x"e4" when x"69",
        x"58" when x"6a",
        x"05" when x"6b",
        x"b8" when x"6c",
        x"b3" when x"6d",
        x"45" when x"6e",
        x"06" when x"6f",
        x"d0" when x"70",
        x"2c" when x"71",
        x"1e" when x"72",
        x"8f" when x"73",
        x"ca" when x"74",
        x"3f" when x"75",
        x"0f" when x"76",
        x"02" when x"77",
        x"c1" when x"78",
        x"af" when x"79",
        x"bd" when x"7a",
        x"03" when x"7b",
        x"01" when x"7c",
        x"13" when x"7d",
        x"8a" when x"7e",
        x"6b" when x"7f",
        x"3a" when x"80",
        x"91" when x"81",
        x"11" when x"82",
        x"41" when x"83",
        x"4f" when x"84",
        x"67" when x"85",
        x"dc" when x"86",
        x"ea" when x"87",
        x"97" when x"88",
        x"f2" when x"89",
        x"cf" when x"8a",
        x"ce" when x"8b",
        x"f0" when x"8c",
        x"b4" when x"8d",
        x"e6" when x"8e",
        x"73" when x"8f",
        x"96" when x"90",
        x"ac" when x"91",
        x"74" when x"92",
        x"22" when x"93",
        x"e7" when x"94",
        x"ad" when x"95",
        x"35" when x"96",
        x"85" when x"97",
        x"e2" when x"98",
        x"f9" when x"99",
        x"37" when x"9a",
        x"e8" when x"9b",
        x"1c" when x"9c",
        x"75" when x"9d",
        x"df" when x"9e",
        x"6e" when x"9f",
        x"47" when x"a0",
        x"f1" when x"a1",
        x"1a" when x"a2",
        x"71" when x"a3",
        x"1d" when x"a4",
        x"29" when x"a5",
        x"c5" when x"a6",
        x"89" when x"a7",
        x"6f" when x"a8",
        x"b7" when x"a9",
        x"62" when x"aa",
        x"0e" when x"ab",
        x"aa" when x"ac",
        x"18" when x"ad",
        x"be" when x"ae",
        x"1b" when x"af",
        x"fc" when x"b0",
        x"56" when x"b1",
        x"3e" when x"b2",
        x"4b" when x"b3",
        x"c6" when x"b4",
        x"d2" when x"b5",
        x"79" when x"b6",
        x"20" when x"b7",
        x"9a" when x"b8",
        x"db" when x"b9",
        x"c0" when x"ba",
        x"fe" when x"bb",
        x"78" when x"bc",
        x"cd" when x"bd",
        x"5a" when x"be",
        x"f4" when x"bf",
        x"1f" when x"c0",
        x"dd" when x"c1",
        x"a8" when x"c2",
        x"33" when x"c3",
        x"88" when x"c4",
        x"07" when x"c5",
        x"c7" when x"c6",
        x"31" when x"c7",
        x"b1" when x"c8",
        x"12" when x"c9",
        x"10" when x"ca",
        x"59" when x"cb",
        x"27" when x"cc",
        x"80" when x"cd",
        x"ec" when x"ce",
        x"5f" when x"cf",
        x"60" when x"d0",
        x"51" when x"d1",
        x"7f" when x"d2",
        x"a9" when x"d3",
        x"19" when x"d4",
        x"b5" when x"d5",
        x"4a" when x"d6",
        x"0d" when x"d7",
        x"2d" when x"d8",
        x"e5" when x"d9",
        x"7a" when x"da",
        x"9f" when x"db",
        x"93" when x"dc",
        x"c9" when x"dd",
        x"9c" when x"de",
        x"ef" when x"df",
        x"a0" when x"e0",
        x"e0" when x"e1",
        x"3b" when x"e2",
        x"4d" when x"e3",
        x"ae" when x"e4",
        x"2a" when x"e5",
        x"f5" when x"e6",
        x"b0" when x"e7",
        x"c8" when x"e8",
        x"eb" when x"e9",
        x"bb" when x"ea",
        x"3c" when x"eb",
        x"83" when x"ec",
        x"53" when x"ed",
        x"99" when x"ee",
        x"61" when x"ef",
        x"17" when x"f0",
        x"2b" when x"f1",
        x"04" when x"f2",
        x"7e" when x"f3",
        x"ba" when x"f4",
        x"77" when x"f5",
        x"d6" when x"f6",
        x"26" when x"f7",
        x"e1" when x"f8",
        x"69" when x"f9",
        x"14" when x"fa",
        x"63" when x"fb",
        x"55" when x"fc",
        x"21" when x"fd",
        x"0c" when x"fe",
        x"7d" when others;
end architecture;