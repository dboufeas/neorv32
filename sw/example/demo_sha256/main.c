#include <neorv32.h>

#define BAUD_RATE 19200

#define N 1

const uint32_t K[64] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
};

int main() {
  neorv32_rte_setup();
  neorv32_uart0_setup(BAUD_RATE, PARITY_NONE, FLOW_CONTROL_NONE);
  neorv32_rte_check_isa(0); // silent = 0 -> show message if isa mismatch

  /* ======================================================================================== */
  /* ====================================== PADDED MESSAGE ================================== */
  /* ======================================================================================== */
  // padded message (N-blocks) / message = "abc" (8-bit ASCII)
  uint32_t M[N][16] = {{0x61626380, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x18}};
  uint32_t H[8];
  
  /* ======================================================================================== */
  /* ====================================== CALCULATE HASH ================================== */
  /* ======================================================================================== */

  // set initial hash value
	H[0] = 0x6a09e667;
	H[1] = 0xbb67ae85;
	H[2] = 0x3c6ef372;
	H[3] = 0xa54ff53a;
	H[4] = 0x510e527f;
	H[5] = 0x9b05688c;
	H[6] = 0x1f83d9ab;
	H[7] = 0x5be0cd19;

  for (uint32_t i = 0; i < N; i++) {
    neorv32_cpu_csr_write(CSR_MCYCLEH, 0);
    neorv32_cpu_csr_write(CSR_MCYCLE, 0);
    
    uint32_t W[64];
    
    // 1.
    for (uint32_t t = 0; t < 16; t++)
      W[t] = M[i][t];
    for (uint32_t t = 16; t < 64; t++)
      W[t] = neorv32_cfu_r3_instr(0b1000000, 2, W[t-2], W[t-7]) + neorv32_cfu_r3_instr(0b0000000, 2, W[t-15], W[t-16]);

    // 2. init a, b, c, d, e, f, g, h
    uint32_t a = H[0];
    uint32_t b = H[1];
    uint32_t c = H[2];
    uint32_t d = H[3];
    uint32_t e = H[4];
    uint32_t f = H[5];
    uint32_t g = H[6];
    uint32_t h = H[7];

    // 3.
    uint32_t T1, T2;
    for (uint32_t t = 0; t < 64; t++) {
      T1 = h + neorv32_cfu_r4_instr(1, e, f, g) + K[t] + W[t];
      T2 = neorv32_cfu_r4_instr(0, a, b, c);

      h = g;
      g = f;
      f = e;
      e = d + T1;
      d = c;
      c = b;
      b = a;
      a = T1 + T2;
    }

    // 4. compute i-th intermediate hash value H(i)
    H[0] += a;
    H[1] += b;
    H[2] += c;
    H[3] += d;
    H[4] += e;
    H[5] += f;
    H[6] += g;
    H[7] += h;
    
    uint32_t cycles_low = neorv32_cpu_csr_read(CSR_MCYCLE);
    uint32_t cycles_high = neorv32_cpu_csr_read(CSR_MCYCLEH);

    neorv32_uart0_printf("Clock Cycles = %u %u\n", cycles_high, cycles_low);
  }


  neorv32_uart0_printf("Message digest = 0x%x %x %x %x %x %x %x %x\n", H[0], H[1], H[2], H[3], H[4], H[5], H[6], H[7]);

  return 0;
}
