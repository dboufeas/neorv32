#include <neorv32.h>

union LFSR {
	uint32_t u32[8];
	uint16_t u16[16];
};

union LFSR A;
union LFSR B;

uint32_t R1[4], R2[4], R3[4]; // 128-bit registers

inline void __attribute__ ((always_inline)) aes_round(uint32_t *new_state, uint32_t *state) {
	uint32_t tmp_state[4];

	// SubBytes + implicit ShiftRows
	tmp_state[0] = neorv32_cfu_r3_instr(0b0000000, 1, state[3], state[2]);
	tmp_state[1] = neorv32_cfu_r3_instr(0b0000000, 1, state[0], state[3]);
	tmp_state[2] = neorv32_cfu_r3_instr(0b0000000, 1, state[1], state[0]);
	tmp_state[3] = neorv32_cfu_r3_instr(0b0000000, 1, state[2], state[1]);

	// MixColumns + implicit ShiftRows
	new_state[0] = neorv32_cfu_r3_instr(0b1000001, 1, tmp_state[0], tmp_state[2]);
	new_state[1] = neorv32_cfu_r3_instr(0b1000001, 1, tmp_state[1], tmp_state[3]);
	new_state[2] = neorv32_cfu_r3_instr(0b1000001, 1, tmp_state[2], tmp_state[0]);
	new_state[3] = neorv32_cfu_r3_instr(0b1000001, 1, tmp_state[3], tmp_state[1]);
}

inline void __attribute__ ((always_inline)) snowv_keystream (uint32_t *z) {	
	neorv32_cpu_csr_write(CSR_MCYCLEH, 0);
	neorv32_cpu_csr_write(CSR_MCYCLE, 0); 

	z[3] = neorv32_cfu_r4_instr(3, R1[3], B.u32[7], R2[3]);  // (R1[3] + B[7]) ^ R2[3]; 
	z[2] = neorv32_cfu_r4_instr(3, R1[2], B.u32[6], R2[2]);  // (R1[2] + B[6]) ^ R2[2]; 
	z[1] = neorv32_cfu_r4_instr(3, R1[1], B.u32[5], R2[1]);  // (R1[1] + B[5]) ^ R2[1]; 
	z[0] = neorv32_cfu_r4_instr(3, R1[0], B.u32[4], R2[0]);  // (R1[0] + B[4]) ^ R2[0]; 

	// for (uint32_t i = 0; i < 4; i++)
	// 	neorv32_uart0_printf("%x ", z[i]);
	// neorv32_uart0_printf("\n");

	uint32_t tmp[4];
	tmp[3] = neorv32_cfu_r4_instr(4, R2[3], R3[3], A.u32[3]); // R2[3] + (R3[3] ^ A[3]);
	tmp[2] = neorv32_cfu_r4_instr(4, R2[2], R3[2], A.u32[2]); // R2[2] + (R3[2] ^ A[2]);
	tmp[1] = neorv32_cfu_r4_instr(4, R2[1], R3[1], A.u32[1]); // R2[1] + (R3[1] ^ A[1]);
	tmp[0] = neorv32_cfu_r4_instr(4, R2[0], R3[0], A.u32[0]); // R2[0] + (R3[0] ^ A[0]);
	
	aes_round(R3, R2);
	aes_round(R2, R1);

	// sigma permutation
	R1[3] = neorv32_cfu_r3_instr(0b1100001, 3, tmp[3], tmp[2]) ^ neorv32_cfu_r3_instr(0b1100000, 3, tmp[1], tmp[0]);
	R1[2] = neorv32_cfu_r3_instr(0b1000001, 3, tmp[3], tmp[2]) ^ neorv32_cfu_r3_instr(0b1000000, 3, tmp[1], tmp[0]);
	R1[1] = neorv32_cfu_r3_instr(0b0100001, 3, tmp[3], tmp[2]) ^ neorv32_cfu_r3_instr(0b0100000, 3, tmp[1], tmp[0]);
	R1[0] = neorv32_cfu_r3_instr(0b0000001, 3, tmp[3], tmp[2]) ^ neorv32_cfu_r3_instr(0b0000000, 3, tmp[1], tmp[0]);

	for (uint32_t i = 0; i < 8; i++) {
		uint16_t tmp_a = neorv32_cfu_r4_instr(5, A.u16[0], 0x990f, A.u16[1]) ^ neorv32_cfu_r4_instr(6, A.u16[8], 0xcc87, B.u16[0]);
		uint16_t tmp_b = neorv32_cfu_r4_instr(5, B.u16[0], 0xc963, B.u16[3]) ^ neorv32_cfu_r4_instr(6, B.u16[8], 0xe4b1, A.u16[0]);

		for (uint32_t j = 0; j < 15; j++) { 
			A.u16[j] = A.u16[j + 1]; 
			B.u16[j] = B.u16[j + 1]; 
		} 

		A.u16[15] = tmp_a;
		B.u16[15] = tmp_b;
	}

	uint32_t cycles_low = neorv32_cpu_csr_read(CSR_MCYCLE);
	uint32_t cycles_high = neorv32_cpu_csr_read(CSR_MCYCLEH);

	neorv32_uart0_printf("Clock Cycles = %u %u\n", cycles_high, cycles_low);
}
