-- #################################################################################################
-- # << NEORV32 - CPU Co-Processor: Custom (Instructions) Functions Unit >>                        #
-- # ********************************************************************************************* #
-- # For user-defined custom RISC-V instructions (R3-type, R4-type and R5-type formats).           #
-- # See the CPU's documentation for more information.                                             #
-- #                                                                                               #
-- # NOTE: Take a look at the "software-counterpart" of this CFU example in 'sw/example/demo_cfu'. #
-- # ********************************************************************************************* #
-- # BSD 3-Clause License                                                                          #
-- #                                                                                               #
-- # Copyright (c) 2023, Stephan Nolting. All rights reserved.                                     #
-- #                                                                                               #
-- # Redistribution and use in source and binary forms, with or without modification, are          #
-- # permitted provided that the following conditions are met:                                     #
-- #                                                                                               #
-- # 1. Redistributions of source code must retain the above copyright notice, this list of        #
-- #    conditions and the following disclaimer.                                                   #
-- #                                                                                               #
-- # 2. Redistributions in binary form must reproduce the above copyright notice, this list of     #
-- #    conditions and the following disclaimer in the documentation and/or other materials        #
-- #    provided with the distribution.                                                            #
-- #                                                                                               #
-- # 3. Neither the name of the copyright holder nor the names of its contributors may be used to  #
-- #    endorse or promote products derived from this software without specific prior written      #
-- #    permission.                                                                                #
-- #                                                                                               #
-- # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS   #
-- # OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF               #
-- # MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE    #
-- # COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     #
-- # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE #
-- # GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED    #
-- # AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     #
-- # NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED  #
-- # OF THE POSSIBILITY OF SUCH DAMAGE.                                                            #
-- # ********************************************************************************************* #
-- # The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32       (c) Stephan Nolting #
-- #################################################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

-- cryptographic libraries
use work.present_package.all;
use work.aes_package.all;
use work.sha256_package.all;
use work.snowv_package.all;

entity neorv32_cpu_cp_cfu is
  generic (
            XLEN : natural -- data path width
          );
  port (
    -- global control --
         clk_i   : in  std_ulogic; -- global clock, rising edge
         rstn_i  : in  std_ulogic; -- global reset, low-active, async
         ctrl_i  : in  ctrl_bus_t; -- main control bus
         start_i : in  std_ulogic; -- trigger operation
                                   -- data input --
         rs1_i   : in  std_ulogic_vector(XLEN-1 downto 0); -- rf source 1
         rs2_i   : in  std_ulogic_vector(XLEN-1 downto 0); -- rf source 2
         rs3_i   : in  std_ulogic_vector(XLEN-1 downto 0); -- rf source 3
         rs4_i   : in  std_ulogic_vector(XLEN-1 downto 0); -- rf source 4
                                                           -- result and status --
         res_o   : out std_ulogic_vector(XLEN-1 downto 0); -- operation result
         valid_o : out std_ulogic -- data output valid
       );
end neorv32_cpu_cp_cfu;

architecture neorv32_cpu_cp_cfu_rtl of neorv32_cpu_cp_cfu is

  -- CFU controll - do not modify! ---------------------------
  -- ------------------------------------------------------------

type control_t is record
  busy   : std_ulogic; -- CFU is busy
  done   : std_ulogic; -- set to '1' when processing is done
  result : std_ulogic_vector(XLEN-1 downto 0); -- user's processing result (for write-back to register file)
  rtype  : std_ulogic_vector(1 downto 0); -- instruction type, see constants below
  funct3 : std_ulogic_vector(2 downto 0); -- "funct3" bit-field from custom instruction
  funct7 : std_ulogic_vector(6 downto 0); -- "funct7" bit-field from custom instruction
end record;
signal control : control_t;

  -- instruction format types --
constant r3type_c  : std_ulogic_vector(1 downto 0) := "00"; -- R3-type instructions (custom-0 opcode)
constant r4type_c  : std_ulogic_vector(1 downto 0) := "01"; -- R4-type instructions (custom-1 opcode)
constant r5typeA_c : std_ulogic_vector(1 downto 0) := "10"; -- R5-type instruction A (custom-2 opcode)
constant r5typeB_c : std_ulogic_vector(1 downto 0) := "11"; -- R5-type instruction B (custom-3 opcode)

  -- User Logic ----------------------------------------------
  -- ------------------------------------------------------------

  -- PRESENT
type present_out_t is record
  sp_high, sp_low         : std_ulogic_vector(31 downto 0);
  inv_sp_high, inv_sp_low : std_ulogic_vector(31 downto 0);
  rk_high, rk_low         : std_ulogic_vector(31 downto 0);
  ks_done                 : std_ulogic;
end record;
signal present_out : present_out_t;

  -- AES
type aes_out_t is record
  sub_bytes     : std_ulogic_vector(31 downto 0);
  mix_cols      : std_ulogic_vector(31 downto 0);
  inv_sub_bytes : std_ulogic_vector(31 downto 0);
  inv_mix_cols  : std_ulogic_vector(31 downto 0);
  ks_round      : std_ulogic_vector(31 downto 0);
end record;
signal aes_out : aes_out_t;

  -- SHA256
signal sha256_out : std_ulogic_vector(31 downto 0);

  -- SNOW-V
type snowv_out_t is record
  op0, op1 : std_ulogic_vector(31 downto 0);
  perm     : std_ulogic_vector(31 downto 0);
  mul      : std_ulogic_vector(31 downto 0);
  inv_mul  : std_ulogic_vector(31 downto 0);
end record;
signal snowv_out : snowv_out_t;

begin

  -- ****************************************************************************************************************************
  -- This controller is required to handle the CPU/pipeline interface. Do not modify!
  -- ****************************************************************************************************************************

  -- CFU Controller -------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------
  cfu_control: process(rstn_i, clk_i)
  begin
    if (rstn_i = '0') then
      res_o        <= (others => '0');
      control.busy <= '0';
    elsif rising_edge(clk_i) then
      res_o <= (others => '0'); -- default; all CPU co-processor outputs are logically OR-ed
      if (control.busy = '0') then -- idle
        if (start_i = '1') then
          control.busy <= '1';
        end if;
      else -- busy
        if (control.done = '1') or (ctrl_i.cpu_trap = '1') then -- processing done? abort if trap (exception)
          res_o        <= control.result; -- output result for just one cycle, CFU output has to be all-zero otherwise
          control.busy <= '0';
        end if;
      end if;
    end if;
  end process cfu_control;

  -- CPU feedback --
  valid_o <= control.busy and control.done; -- set one cycle before result data

  -- pack user-defined instruction type/function bits --
  control.rtype  <= ctrl_i.ir_opcode(6 downto 5);
  control.funct3 <= ctrl_i.ir_funct3;
  control.funct7 <= ctrl_i.ir_funct12(11 downto 5);

  -- ****************************************************************************************************************************
  -- Actual CFU User Logic Example - replace this with your custom logic
  -- ****************************************************************************************************************************

  -- Cryptographic components instantiation
  -- PRESENT
  present_sp_inst: present_sp port map (rs1_i, rs2_i, present_out.sp_high, present_out.sp_low);
                                        present_inv_sp_inst: present_inv_sp port map (rs1_i, rs2_i, present_out.inv_sp_high, present_out.inv_sp_low);
                                                                                      present_ks_inst: present_ks port map (
                                                                                                                             clk_i        => clk_i,
                                                                                                                             rstn_i       => rstn_i,
                                                                                                                             busy_i       => control.busy,
                                                                                                                             start_i      => start_i,
                                                                                                                             load_key_i   => control.rtype(0),
                                                                                                                             update_key_i => control.funct7(6),
                                                                                                                             key1_i       => rs1_i,
                                                                                                                             key2_i       => rs2_i,
                                                                                                                             key3_i       => rs3_i,
                                                                                                                             rk_high_o    => present_out.rk_high,
                                                                                                                             rk_low_o     => present_out.rk_low,
                                                                                                                             done_o       => present_out.ks_done
                                                                                                                           );

  -- AES
                                                                                      aes_slayer_inst: aes_slayer port map (
                                                                                                                             data1_i => rs1_i,
                                                                                                                             data2_i => rs2_i,
                                                                                                                             opt_rot => control.funct7(6),
                                                                                                                             data_o  => aes_out.sub_bytes
                                                                                                                           );
                                                                                      aes_mixcols_inst: aes_mixcols port map (
                                                                                                                               data1_i         => rs1_i,
                                                                                                                               data2_i         => rs2_i,
                                                                                                                               byte_endianness => control.funct7(6),
                                                                                                                               data_o          => aes_out.mix_cols
                                                                                                                             );
                                                                                      aes_inv_slayer_inst: aes_inv_slayer port map (rs1_i, rs2_i, aes_out.inv_sub_bytes);
                                                                                                                                    aes_inv_mixcols_inst: aes_inv_mixcols port map (rs1_i, rs2_i, aes_out.inv_mix_cols);

  -- SHA-256
                                                                                                                                                                                    sha256_ops_inst: sha256_ops port map (
                                                                                                                                                                                                                           data1_i    => rs1_i,
                                                                                                                                                                                                                           data2_i    => rs2_i,
                                                                                                                                                                                                                           data3_i    => rs3_i,
                                                                                                                                                                                                                           rtype      => control.rtype,
                                                                                                                                                                                                                           funct7_msb => control.funct7(6),
                                                                                                                                                                                                                           funct3_lsb => control.funct3(0),
                                                                                                                                                                                                                           data_o     => sha256_out
                                                                                                                                                                                                                         );

  -- SNOW-V
                                                                                                                                                                                    snowv_op0_inst: snowv_op0 port map (rs1_i, rs2_i, rs3_i, snowv_out.op0);
                                                                                                                                                                                                                        snowv_op1_inst: snowv_op1 port map (rs1_i, rs2_i, rs3_i, snowv_out.op1);
                                                                                                                                                                                                                                                            snowv_perm_inst: snowv_perm port map (
                                                                                                                                                                                                                                                                                                   data1_i    => rs1_i,
                                                                                                                                                                                                                                                                                                   data2_i    => rs2_i,
                                                                                                                                                                                                                                                                                                   bytes2perm => control.funct7(6 downto 5),
                                                                                                                                                                                                                                                                                                   op         => control.funct7(0),
                                                                                                                                                                                                                                                                                                   data_o     => snowv_out.perm
                                                                                                                                                                                                                                                                                                 );
                                                                                                                                                                                                                                                            snowv_mul_inst: snowv_mul port map (rs1_i, rs2_i, rs3_i, snowv_out.mul);
                                                                                                                                                                                                                                                                                                snowv_inv_mul_inst: snowv_inv_mul port map (rs1_i, rs2_i, rs3_i, snowv_out.inv_mul);
  -- end cryptographic components instantiation

                                                                                                                                                                                                                                                            process (control, present_out, aes_out)
                                                                                                                                                                                                                                                            begin
                                                                                                                                                                                                                                                              case control.rtype is
      -- --------------------------------------------------------
                                                                                                                                                                                                                                                                when r3type_c => -- R3-type instructions
                                                                                                                                                                                                                                                                                 -- --------------------------------------------------------
                                                                                                                                                                                                                                                                  case control.funct3 is
          -- PRESENT
                                                                                                                                                                                                                                                                    when "000" => 
                                                                                                                                                                                                                                                                      case control.funct7(2 downto 0) is
                                                                                                                                                                                                                                                                        when "000"  => control.result <= present_out.sp_high;     control.done <= '1';                 -- encryption MSB bits
                                                                                                                                                                                                                                                                        when "001"  => control.result <= present_out.sp_low;      control.done <= '1';                 -- encryption LSB bits
                                                                                                                                                                                                                                                                        when "010"  => control.result <= present_out.inv_sp_high; control.done <= '1';                 -- decryption MSB bits
                                                                                                                                                                                                                                                                        when "011"  => control.result <= present_out.inv_sp_low;  control.done <= '1';                 -- decryption LSB bits
                                                                                                                                                                                                                                                                        when "100"  => control.result <= present_out.rk_high;     control.done <= present_out.ks_done; -- round key MSB bits
                                                                                                                                                                                                                                                                        when "101"  => control.result <= present_out.rk_low;      control.done <= '1';                 -- round key LSB bits
                                                                                                                                                                                                                                                                        when others => control.result <= (others => '0');         control.done <= '1';
                                                                                                                                                                                                                                                                      end case;
          -- end PRESENT
          -- AES
                                                                                                                                                                                                                                                                    when "001" =>
                                                                                                                                                                                                                                                                      case control.funct7(1 downto 0) is
                                                                                                                                                                                                                                                                        when "00"   => control.result <= aes_out.sub_bytes;     control.done <= '1';
                                                                                                                                                                                                                                                                        when "01"   => control.result <= aes_out.mix_cols;      control.done <= '1';
                                                                                                                                                                                                                                                                        when "10"   => control.result <= aes_out.inv_sub_bytes; control.done <= '1';
                                                                                                                                                                                                                                                                        when "11"   => control.result <= aes_out.inv_mix_cols;  control.done <= '1';
                                                                                                                                                                                                                                                                        when others => control.result <= (others => '0');       control.done <= '1';
                                                                                                                                                                                                                                                                      end case;
          -- end AES
          -- SHA-256
                                                                                                                                                                                                                                                                    when "010" =>
                                                                                                                                                                                                                                                                      control.result <= sha256_out; control.done <= '1';
          -- end SHA-256
          -- SNOW-V
                                                                                                                                                                                                                                                                    when "011" =>
                                                                                                                                                                                                                                                                      case control.funct7(0) is
                                                                                                                                                                                                                                                                        when '0'    => control.result <= snowv_out.perm;  control.done <= '1';
                                                                                                                                                                                                                                                                        when '1'    => control.result <= snowv_out.perm;  control.done <= '1';
                                                                                                                                                                                                                                                                        when others => control.result <= (others => '0'); control.done <= '1';
                                                                                                                                                                                                                                                                      end case;
          -- end SNOW-V
                                                                                                                                                                                                                                                                    when others => control.result <= (others => '0'); control.done <= '1';  
                                                                                                                                                                                                                                                                  end case;
      -- end R3-type instructions
      -- --------------------------------------------------------
                                                                                                                                                                                                                                                                when r4type_c => -- R4-type instructions
                                                                                                                                                                                                                                                                                 -- --------------------------------------------------------
                                                                                                                                                                                                                                                                  case control.funct3 is
          -- SHA-256
                                                                                                                                                                                                                                                                    when "000" => control.result <= sha256_out; control.done <= '1';
                                                                                                                                                                                                                                                                    when "001" => control.result <= sha256_out; control.done <= '1';
          -- end SHA-256
          -- PRESENT
                                                                                                                                                                                                                                                                    when "010" => control.result <= (others => '0'); control.done <= present_out.ks_done; -- load key for key generation
                                                                                                                                                                                                                                                                                                                                                          -- end PRESENT
                                                                                                                                                                                                                                                                                                                                                          -- SNOW-V
                                                                                                                                                                                                                                                                    when "011" => control.result <= snowv_out.op0;     control.done <= '1';
                                                                                                                                                                                                                                                                    when "100" => control.result <= snowv_out.op1;     control.done <= '1';
                                                                                                                                                                                                                                                                    when "101" => control.result <= snowv_out.mul;     control.done <= '1';
                                                                                                                                                                                                                                                                    when "110" => control.result <= snowv_out.inv_mul; control.done <= '1';
          -- end SNOW-V
                                                                                                                                                                                                                                                                    when others => control.result <= (others => '0'); control.done <= '1';
                                                                                                                                                                                                                                                                  end case;
      -- end R4-type instructions
                                                                                                                                                                                                                                                                when others => control.result <= (others => '0'); control.done <= '1';
                                                                                                                                                                                                                                                              end case;
                                                                                                                                                                                                                                                            end process;
                                                                                                                                                                                                                      end neorv32_cpu_cp_cfu_rtl;
