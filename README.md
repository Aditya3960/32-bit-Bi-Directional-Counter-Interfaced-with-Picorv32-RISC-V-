# 🔁 Bi-Directional Counter SoC using PicoRV32

This project implements a simple System-on-Chip (SoC) design using the [PicoRV32](https://github.com/cliffordwolf/picorv32) RISC-V soft-core processor. The SoC includes a **bi-directional counter** (up/down) that can be controlled via memory-mapped I/O through a small C firmware.
 
---

## 📌 Project Overview

The project consists of three primary components:

1. **Hardware Design (Verilog)**:
   - A bi-directional counter module (`bi_counter.v`)
   - A SoC wrapper integrating the counter and PicoRV32 processor (`soc_top_bi_counter1.v`)
   - A testbench to simulate the design (`tb_soc_bi_counter.v`)

2. **Firmware (C)**:
   - A simple RISC-V program (`bi_counter.c`) that writes to the counter mode register and reads the current count value.

3. **Memory Initialization**:
   - The C firmware is compiled into a `.hex` file (`firmware.hex`) that is loaded into the simulated memory.

---

## 📂 File Structure

| File | Description |
|------|-------------|
| `bi_counter.v` | RTL module for a 32-bit up/down counter with mode control |
| `soc_top_bi_counter1.v` | SoC wrapper integrating PicoRV32, RAM, and the counter |
| `tb_soc_bi_counter.v` | Testbench for simulating the SoC |
| `bi_counter.c` | RISC-V firmware to configure and read the counter |
| `linker1.ld` | Linker script for firmware memory layout |
| `firmware.hex` | Pre-generated hex file loaded into RAM at simulation time |

---

## ⚙️ How It Works

### 🧠 Concept

- The **bi-directional counter** counts either up or down based on a 2-bit mode signal:
  - `00`: Idle (no change)
  - `01`: Count up
  - `10`: Count down
- The PicoRV32 processor communicates with the counter via memory-mapped addresses.

### 📫 Memory Map

| Address | Purpose |
|---------|---------|
| `0x40000000` | Read-only: Counter current value |
| `0x40000004` | Write-only: Set counter mode (1 = up, 2 = down) |

---

## 🚀 Getting Started

### 🧰 Requirements

Make sure the following tools are installed:
-WSL-Ubutno
-Picorv32(https://github.com/cliffordwolf/picorv32)
- [Icarus Verilog (iverilog)](http://iverilog.icarus.com/)
- [GTKWave](http://gtkwave.sourceforge.net/) (for waveform viewing)
- [RISC-V GCC Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) (only needed if you want to rebuild `firmware.hex`)

---

### 🔧 Compile the Design

Run this command to compile the c file and make Hex file:

```bash
riscv32-unknown-elf-gcc -Os -ffreestanding -nostdlib \
  -Wl,-Bstatic,-Tlinker.ld,--strip-debug \
  -o firmware.elf bi_counter.c
 riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 firmware.elf firmware.hex

```

Run this command to compile the testbench and modules:

```bash
iverilog -o soc_tb tb_soc_bi_counter.v soc_top_bi_counter.v bi_counter.v
vvp soc_tb
```
