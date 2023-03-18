# NEORV32 Crypto Extension

This is a fork of NEORV32 repository that extends NEORV32 ISA to implement AES-128, PRESENT-80, SHA-256 and SNOW-V cryptographic primitives.

## Additional files

Hardware modules:
```
neorv32_top.vhd
└neorv32_cpu.vhd
 └neorv32_cpu_cp_cfu.vhd	- Modified CFU to execute new instructions
  │
  ├aes_package.vhd
  ├aes_slayer.vhd
  ├aes_sbox.vhd
  ├aes_inv_slayer.vhd
  ├aes_inv_sbox.vhd
  ├aes_mixcols.vhd
  ├aes_inv_mixcols.vhd
  │
  ├present_package.vhd
  ├present_sp.vhd
  ├present_sbox.vhd
  ├present_inv_sp.vhd
  ├present_inv_sbox.vhd
  ├present_ks.vhd
  │
  ├sha256_package.vhd
  ├sha256_ops.vhd
  │
  ├snowv_package.vhd
  ├snowv_op0.vhd
  ├snowv_op1.vhd
  ├snowv_mul.vhd
  ├snowv_inv_mul.vhd
  └snowv_perm.vhd
```

Software:
```
neorv32/sw/example/demo_aes
neorv32/sw/example/demo_present
neorv32/sw/example/demo_sha256
neorv32/sw/example/demo_snowv
```

## Using RISC-V CSRs to measure Clock Cycles & Instructions

Clock Cycles count:
```C
neorv32_cpu_csr_write(CSR_MCYCLEH, 0);
neorv32_cpu_csr_write(CSR_MCYCLE, 0);

// code to measure goes here

uint32_t cycles_low = neorv32_cpu_csr_read(CSR_MCYCLE);
uint32_t cycles_high = neorv32_cpu_csr_read(CSR_MCYCLEH);
```
Instructions count:
```C
neorv32_cpu_csr_write(CSR_MINSTRETH, 0);
neorv32_cpu_csr_write(CSR_MINSTRET, 0);

// code to measure goes here

uint32_t cycles_low = neorv32_cpu_csr_read(CSR_MINSTRET);
uint32_t cycles_high = neorv32_cpu_csr_read(CSR_MINSTRETH);
```
