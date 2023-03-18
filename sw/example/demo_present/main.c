#include <neorv32.h>

#define BAUD_RATE 19200

int main() {
  neorv32_rte_setup();
  neorv32_uart0_setup(BAUD_RATE, 0);
  neorv32_rte_check_isa(0); // silent = 0 -> show message if isa mismatch

  /* ======================================================================================== */
  /* ====================================== KEY / PLAINTEXT VARIABLES ======================= */
  /* ======================================================================================== */
  // 80-bit key
  uint32_t key[3] = {0xFFFFFFFF, 0xFFFFFFFF, 0xFFFF0000};
  // 64-bit plaintext
	uint32_t state_high = 0x0, state_low = 0x0;
  uint32_t round_keys[32][2];

  /* ======================================================================================== */
  /* ====================================== KEY GENERATION ================================== */
  /* ======================================================================================== */

	// load 80-bit key register
  neorv32_cfu_r4_instr(3, key[0], key[1], key[2]);

  // generate round keys
  round_keys[0][0] = key[0];
  round_keys[0][1] = key[1];
  for (uint32_t i = 1; i < 32; i++) {
    round_keys[i][0] = neorv32_cfu_r3_instr(0b1000100, 0, 0x0, i);   // get round key msb
    round_keys[i][1] = neorv32_cfu_r3_instr(0b0000101, 0, 0x0, 0x0); // get round key lsb
  }

  neorv32_uart0_printf("key gen done\n");

  /* ======================================================================================== */
  /* ====================================== ENCRYPTION ====================================== */
  /* ======================================================================================== */

	for (uint32_t i = 0; i < 31; i++) {  
    // xor with round key
    state_high ^= round_keys[i][0];
    state_low ^= round_keys[i][1];

    // pass through present sp layer
    uint32_t temp = neorv32_cfu_r3_instr(0b0000000, 0, state_high, state_low);
    state_low = neorv32_cfu_r3_instr(0b0000001, 0, state_high, state_low);
    state_high= temp;
  }

  state_high ^= round_keys[31][0];
  state_low ^= round_keys[31][1];

  neorv32_uart0_printf("Encryption ... ciphertext = 0x%x %x\n", state_high, state_low);
  
  /* ======================================================================================== */
  /* ====================================== DECRYPTION ====================================== */
  /* ======================================================================================== */

  for (uint32_t i = 0; i < 31; i++) {
    // xor with round key
    state_high ^= round_keys[31-i][0];
    state_low ^= round_keys[31-i][1];

    // pass through present inv sp layer
    uint32_t temp = neorv32_cfu_r3_instr(0b0000010, 0, state_high, state_low);
    state_low = neorv32_cfu_r3_instr(0b0000011, 0, state_high, state_low);
    state_high = temp;
  }  

  state_high ^= round_keys[0][0];
  state_low ^= round_keys[0][1];

  neorv32_uart0_printf("Decryption ... plaintext = 0x%x %x\n", state_high, state_low);

  return 0;
}
