#include <neorv32.h>
#include <snowv.h>

#define BAUD_RATE 19200

int main() {
  neorv32_rte_setup();
  neorv32_uart0_setup(BAUD_RATE, PARITY_NONE, FLOW_CONTROL_NONE);
  neorv32_rte_check_isa(0); // silent = 0 -> show message if isa mismatch

  /* ======================================================================================== */
  /* ====================================== KEY / IV ======================================== */
  /* ======================================================================================== */
  // initial key / iv test vectors
  const uint32_t key[8] = {0x53525150, 0x57565554, 0x5b5a5958, 0x5f5e5d5c, 0x3a2a1a0a, 0x7a6a5a4a, 0xbaaa9a8a, 0xfaeadaca};
  const uint32_t iv[4] = {0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476};
	uint32_t z[4];

  /* ======================================================================================== */
  /* ====================================== INIT ============================================ */
  /* ======================================================================================== */
	neorv32_uart0_printf("Initialization phase, z = \n");
  A.u32[7] = key[3];    B.u32[7] = key[7];        R1[3] = 0x00000000; R2[3] = 0x00000000; R3[3] = 0x00000000;
  A.u32[6] = key[2];    B.u32[6] = key[6];        R1[2] = 0x00000000; R2[2] = 0x00000000; R3[2] = 0x00000000;
  A.u32[5] = key[1];    B.u32[5] = key[5];        R1[1] = 0x00000000; R2[1] = 0x00000000; R3[1] = 0x00000000;
  A.u32[4] = key[0];    B.u32[4] = key[4];        R1[0] = 0x00000000; R2[0] = 0x00000000; R3[0] = 0x00000000;
  A.u32[3] = iv[3];     B.u32[3] = 0x00000000;
  A.u32[2] = iv[2];     B.u32[2] = 0x00000000;
  A.u32[1] = iv[1];     B.u32[1] = 0x00000000;
  A.u32[0] = iv[0];     B.u32[0] = 0x00000000;

  for (uint32_t t = 0; t < 16; t++) {
    // neorv32_cpu_csr_write(CSR_MCYCLEH, 0);
    // neorv32_cpu_csr_write(CSR_MCYCLE, 0);

		snowv_keystream(z);

    A.u32[7] ^= z[3];
    A.u32[6] ^= z[2];
    A.u32[5] ^= z[1];
    A.u32[4] ^= z[0];

    if (t == 14) {
      R1[3] ^= key[3];
      R1[2] ^= key[2];
      R1[1] ^= key[1];
      R1[0] ^= key[0];
    }

    if (t == 15) {
      R1[3] ^= key[7];
      R1[2] ^= key[6];
      R1[1] ^= key[5];
      R1[0] ^= key[4];
    }

    // uint32_t cycles_low = neorv32_cpu_csr_read(CSR_MCYCLE);
    // uint32_t cycles_high = neorv32_cpu_csr_read(CSR_MCYCLEH);

    // neorv32_uart0_printf("Clock Cycles = %u %u\n", cycles_high, cycles_low);
  }

  /* ======================================================================================== */
  /* ====================================== KEYSTREAM ======================================= */
  /* ======================================================================================== */
	neorv32_uart0_printf("Keystream phase, z = \n");
	for (uint32_t i = 0; i < 8; i++) {
		snowv_keystream(z);
	}

  return 0;
}