#include <neorv32.h>

#define BAUD_RATE 19200

const uint32_t Rcon[10] = {0x01000000, 0x02000000, 0x04000000, 0x08000000, 0x10000000, 0x20000000, 0x40000000, 0x80000000, 0x1B000000, 0x36000000};

int main() {
  neorv32_rte_setup();
  neorv32_uart0_setup(BAUD_RATE, PARITY_NONE, FLOW_CONTROL_NONE);
  neorv32_rte_check_isa(0); // silent = 0 -> show message if isa mismatch

  /* ======================================================================================== */
  /* ====================================== KEY / PLAINTEXT VARIABLES ======================= */
  /* ======================================================================================== */
  uint32_t key[4] = {0x2b7e1516, 0x28aed2a6, 0xabf71588, 0x09cf4f3c};
  uint32_t state[4] = {0x3243f6a8, 0x885a308d, 0x313198a2, 0xe0370734};
  uint32_t round_keys[44];

  /* ======================================================================================== */
  /* ====================================== KEY GENERATION ================================== */
  /* ======================================================================================== */
  // RoundKey(0)
  round_keys[0] = key[0];
  round_keys[1] = key[1];
  round_keys[2] = key[2];
  round_keys[3] = key[3];

  // RoundKey(1-43)
  for (uint32_t i = 4; i < 44; i++) {
    neorv32_cpu_csr_write(CSR_MCYCLEH, 0);
    neorv32_cpu_csr_write(CSR_MCYCLE, 0);

    uint32_t temp = round_keys[i-1];

    if (i % 4 == 0) 
      temp = neorv32_cfu_r3_instr(0b1000000, 1, temp, temp) ^ Rcon[i/4-1];

    round_keys[i] = round_keys[i-4] ^ temp;

    uint32_t cycles_low = neorv32_cpu_csr_read(CSR_MCYCLE);
    uint32_t cycles_high = neorv32_cpu_csr_read(CSR_MCYCLEH);

    neorv32_uart0_printf("Clock Cycles = %u %u\n", cycles_high, cycles_low);
  } 

  neorv32_uart0_printf("Key gen done\n");

  /* ======================================================================================== */
  /* ====================================== ENCRYPTION ====================================== */
  /* ======================================================================================== */
  uint32_t new_state[4];

  // AddRoundKey(0)
  state[0] ^= round_keys[0];
  state[1] ^= round_keys[1];
  state[2] ^= round_keys[2];
  state[3] ^= round_keys[3];

  for (uint32_t round = 1; round < 10; round++) {
    neorv32_cpu_csr_write(CSR_MCYCLEH, 0);
    neorv32_cpu_csr_write(CSR_MCYCLE, 0);

    // SubBytes + implicit ShiftRows
    new_state[0] = neorv32_cfu_r3_instr(0b0000000, 1, state[0], state[1]);
    new_state[1] = neorv32_cfu_r3_instr(0b0000000, 1, state[1], state[2]);
    new_state[2] = neorv32_cfu_r3_instr(0b0000000, 1, state[2], state[3]);
    new_state[3] = neorv32_cfu_r3_instr(0b0000000, 1, state[3], state[0]);

    // MixColumns + implicit ShiftRows
    state[0] = neorv32_cfu_r3_instr(0b0000001, 1, new_state[0], new_state[2]);
    state[1] = neorv32_cfu_r3_instr(0b0000001, 1, new_state[1], new_state[3]);
    state[2] = neorv32_cfu_r3_instr(0b0000001, 1, new_state[2], new_state[0]);
    state[3] = neorv32_cfu_r3_instr(0b0000001, 1, new_state[3], new_state[1]);

    state[0] ^= round_keys[4*round];
    state[1] ^= round_keys[4*round+1];
    state[2] ^= round_keys[4*round+2];
    state[3] ^= round_keys[4*round+3];

    uint32_t cycles_low = neorv32_cpu_csr_read(CSR_MCYCLE);
    uint32_t cycles_high = neorv32_cpu_csr_read(CSR_MCYCLEH);

    neorv32_uart0_printf("Clock Cycles = %u %u\n", cycles_high, cycles_low);
  }

  // SubBytes
  new_state[0] = neorv32_cfu_r3_instr(0b0000000, 1, state[0], state[0]);
  new_state[1] = neorv32_cfu_r3_instr(0b0000000, 1, state[1], state[1]);
  new_state[2] = neorv32_cfu_r3_instr(0b0000000, 1, state[2], state[2]);
  new_state[3] = neorv32_cfu_r3_instr(0b0000000, 1, state[3], state[3]);

  // Explicit ShiftRows
  state[0] = (new_state[0] & 0xFF000000) ^ (new_state[1] & 0x00FF0000) ^ (new_state[2] & 0x0000FF00) ^ (new_state[3] & 0x000000FF);
  state[1] = (new_state[1] & 0xFF000000) ^ (new_state[2] & 0x00FF0000) ^ (new_state[3] & 0x0000FF00) ^ (new_state[0] & 0x000000FF);
  state[2] = (new_state[2] & 0xFF000000) ^ (new_state[3] & 0x00FF0000) ^ (new_state[0] & 0x0000FF00) ^ (new_state[1] & 0x000000FF);
  state[3] = (new_state[3] & 0xFF000000) ^ (new_state[0] & 0x00FF0000) ^ (new_state[1] & 0x0000FF00) ^ (new_state[2] & 0x000000FF);

  // AddRoundKey(10)
  state[0] ^= round_keys[40];
  state[1] ^= round_keys[41];
  state[2] ^= round_keys[42];
  state[3] ^= round_keys[43];

  neorv32_uart0_printf("Encryption ... ciphertext = %x %x %x %x\n", state[0], state[1], state[2], state[3]);

  /* ======================================================================================== */
  /* ====================================== DECRYPTION ====================================== */
  /* ======================================================================================== */
  // AddRoundKey(10)
  state[0] ^= round_keys[40];
  state[1] ^= round_keys[41];
  state[2] ^= round_keys[42];
  state[3] ^= round_keys[43];

  // explicit InvShiftRows
  new_state[0] = (state[0] & 0xFF000000) ^ (state[3] & 0x00FF0000) ^ (state[2] & 0x0000FF00) ^ (state[1] & 0x000000FF);
  new_state[1] = (state[1] & 0xFF000000) ^ (state[0] & 0x00FF0000) ^ (state[3] & 0x0000FF00) ^ (state[2] & 0x000000FF);
  new_state[2] = (state[2] & 0xFF000000) ^ (state[1] & 0x00FF0000) ^ (state[0] & 0x0000FF00) ^ (state[3] & 0x000000FF);
  new_state[3] = (state[3] & 0xFF000000) ^ (state[2] & 0x00FF0000) ^ (state[1] & 0x0000FF00) ^ (state[0] & 0x000000FF);

  // InvSubBytes
  state[0] = neorv32_cfu_r3_instr(0b0000010, 1, new_state[0], new_state[0]);
  state[1] = neorv32_cfu_r3_instr(0b0000010, 1, new_state[1], new_state[1]);
  state[2] = neorv32_cfu_r3_instr(0b0000010, 1, new_state[2], new_state[2]);
  state[3] = neorv32_cfu_r3_instr(0b0000010, 1, new_state[3], new_state[3]);

  for (uint32_t round = 0; round < 9; round++) {
    neorv32_cpu_csr_write(CSR_MCYCLEH, 0);
    neorv32_cpu_csr_write(CSR_MCYCLE, 0);

    // AddRoundKey(9)
    state[0] ^= round_keys[36 - 4*round];
    state[1] ^= round_keys[36 - 4*round+1];
    state[2] ^= round_keys[36 - 4*round+2];
    state[3] ^= round_keys[36 - 4*round+3];

    // InvMixCols + implicit InvShiftRows
    new_state[0] = neorv32_cfu_r3_instr(0b0000011, 1, state[0], state[2]);
    new_state[1] = neorv32_cfu_r3_instr(0b0000011, 1, state[1], state[3]);
    new_state[2] = neorv32_cfu_r3_instr(0b0000011, 1, state[2], state[0]);
    new_state[3] = neorv32_cfu_r3_instr(0b0000011, 1, state[3], state[1]);

    // InvSubBytes + implicit InvShiftRows
    state[0] = neorv32_cfu_r3_instr(0b0000010, 1, new_state[0], new_state[3]);
    state[1] = neorv32_cfu_r3_instr(0b0000010, 1, new_state[1], new_state[0]);
    state[2] = neorv32_cfu_r3_instr(0b0000010, 1, new_state[2], new_state[1]);
    state[3] = neorv32_cfu_r3_instr(0b0000010, 1, new_state[3], new_state[2]);
  
    uint32_t cycles_low = neorv32_cpu_csr_read(CSR_MCYCLE);
    uint32_t cycles_high = neorv32_cpu_csr_read(CSR_MCYCLEH);

    neorv32_uart0_printf("Clock Cycles = %u %u\n", cycles_high, cycles_low);
  }

  // AddRoundKey(0)
  state[0] ^= round_keys[0];
  state[1] ^= round_keys[1];
  state[2] ^= round_keys[2];
  state[3] ^= round_keys[3];

  neorv32_uart0_printf("Decryption ... plaintext = %x %x %x %x\n", state[0], state[1], state[2], state[3]);

  return 0;
}