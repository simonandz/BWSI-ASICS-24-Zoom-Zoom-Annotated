# Repository Guide - x3q16 CPU with Keccak Accelerator

## Quick Navigation

### 🚀 **Want to see it work?**
1. Run: `bash run_all_tests.sh` (or `run_all_tests.bat` on Windows)
2. View waveforms: `gtkwave test/functional_cpu_keccak_tb.vcd`
3. Read: [Proof of Functionality](docs/proof/PROOF_OF_FUNCTIONALITY.md)

### 📖 **Want to understand the design?**
- Start with: [System Architecture](docs/info.md)
- Then read: [Functional Test Report](docs/proof/FUNCTIONAL_TEST_REPORT.md)

### 🔧 **Want to modify or extend?**
- Review: [Testing Guide](docs/TESTING_GUIDE.md)
- Understand: [Test Results](docs/TEST_RESULTS.md)

---

## Directory Structure

```
x3q16-cpu-keccak/
│
├── 📄 README.md                    # Start here - Project overview
├── 🔧 run_all_tests.sh            # Run all tests (Linux/Mac)
├── 🔧 run_all_tests.bat           # Run all tests (Windows)
├── ⚙️  .gitignore                  # Git ignore rules
│
├── 📁 src/                         # 🔴 CORE HDL SOURCE FILES
│   ├── tt_um_zoom_zoom.v          # Top-level Tiny Tapeout wrapper
│   ├── x3q16.v                    # ⭐ CPU core (main processor)
│   ├── x3q16alu.v                 # Arithmetic Logic Unit
│   ├── keccakf1600_statepermutate.v  # ⭐ Keccak crypto accelerator
│   ├── memory_controller_arduino.v    # External memory interface
│   ├── uart_rx.v                  # UART receiver
│   ├── uart_tx.v                  # UART transmitter
│   ├── spi_memory_interface.v     # SPI memory (alternative, not in default)
│   ├── atan.v                     # Atan accelerator (not in default)
│   └── ram_16bit.v                # RAM model (simulation only)
│
├── 📁 test/                        # 🟢 VERIFICATION & PROOF
│   │
│   ├── 🎬 functional_cpu_keccak_tb.vcd    # ⭐ PROOF: CPU execution
│   ├── 🎬 keccak_functional_tb.vcd        # ⭐ PROOF: Keccak operations
│   ├── 🎬 integration_test_tb.vcd         # ⭐ PROOF: System stability
│   │
│   ├── functional_cpu_keccak_tb.v         # CPU functional test source
│   ├── keccak_functional_tb.v             # Keccak test source
│   ├── integration_test_tb.v              # Integration test source
│   │
│   ├── 📁 uart_rx/                # UART RX module tests
│   │   ├── uart_rx_tb.v           # Testbench
│   │   └── uart_rx_tb.tv          # Test vectors
│   │
│   ├── 📁 uart_tx/                # UART TX module tests
│   │   ├── uart_tx_tb.v
│   │   └── uart_tx_tb.tv
│   │
│   ├── 📁 x3q16alu/               # ALU tests
│   │   ├── x3q16alu_tb.v
│   │   └── x3q16alu_tb.tv
│   │
│   ├── 📁 spi_memory_interface/   # SPI tests
│   │   ├── spi_memory_interface_tb.v
│   │   └── spi_memory_interface_tb.tv
│   │
│   ├── 📁 memory_control/         # Memory controller tests
│   │   ├── memory_control_tb.v
│   │   └── memory_control_tb.tv
│   │
│   ├── 📁 x3q16/                  # CPU core tests
│   │   ├── x3q16_tb.v
│   │   ├── program.bin
│   │   └── programs/              # Test programs
│   │
│   ├── 📁 keccak_test/            # Keccak module tests
│   │   ├── keccak_test_tb.v
│   │   └── programs/
│   │
│   ├── keccakf1600_statepermutate_tb.v   # Keccak permutation test
│   └── README.md                  # Test directory info
│
├── 📁 docs/                        # 🔵 DOCUMENTATION
│   ├── info.md                    # ⭐ System architecture & ISA
│   ├── TESTING_GUIDE.md           # How to run tests
│   ├── TEST_RESULTS.md            # Test results summary
│   │
│   └── 📁 proof/                  # ✅ VERIFICATION EVIDENCE
│       ├── PROOF_OF_FUNCTIONALITY.md      # ⭐ Executive summary + proof
│       ├── FUNCTIONAL_TEST_REPORT.md      # Detailed analysis
│       └── WAVEFORM_GUIDE.md              # How to interpret waveforms
│
└── 📁 asm/                         # Assembly/binary programs
    └── test.bin                   # Sample program
```

---

## File Categories

### 🔴 **Core HDL Files** (Essential)
These are the actual hardware design files:
- `src/tt_um_zoom_zoom.v` - Top wrapper
- `src/x3q16.v` - CPU core
- `src/x3q16alu.v` - ALU
- `src/keccakf1600_statepermutate.v` - Keccak accelerator
- `src/memory_controller_arduino.v` - Memory interface
- `src/uart_rx.v`, `src/uart_tx.v` - UART

**Not included in default build:**
- `src/spi_memory_interface.v` - SPI (alternative memory)
- `src/atan.v` - Atan accelerator (size constraint)
- `src/ram_16bit.v` - Simulation only

### 🟢 **Test & Verification** (Proof)
**Main Proof Files (Essential):**
- `test/functional_cpu_keccak_tb.vcd` - CPU execution waveform (15 KB)
- `test/keccak_functional_tb.vcd` - Keccak waveform (28 KB)
- `test/integration_test_tb.vcd` - Integration waveform (90 KB)

**Test Source Files:**
- `test/functional_cpu_keccak_tb.v` - CPU test program
- `test/keccak_functional_tb.v` - Keccak test program
- `test/integration_test_tb.v` - Integration test

**Module-Specific Tests:**
- Individual directories for each module
- Test vectors (`.tv` files)
- Testbenches (`.v` files)

### 🔵 **Documentation** (Read These)
**Essential Reading:**
1. `README.md` - Start here
2. `docs/proof/PROOF_OF_FUNCTIONALITY.md` - Evidence it works
3. `docs/info.md` - Architecture details

**Reference Documentation:**
- `docs/TESTING_GUIDE.md` - How to test
- `docs/TEST_RESULTS.md` - Test results
- `docs/proof/FUNCTIONAL_TEST_REPORT.md` - Detailed analysis
- `docs/proof/WAVEFORM_GUIDE.md` - Waveform analysis

---

## What to Look At First

### For Reviewers/Judges
1. **[README.md](README.md)** - Project overview
2. **[docs/proof/PROOF_OF_FUNCTIONALITY.md](docs/proof/PROOF_OF_FUNCTIONALITY.md)** - Evidence
3. **Waveforms:** `gtkwave test/functional_cpu_keccak_tb.vcd`
4. **[docs/info.md](docs/info.md)** - Technical details

### For Developers
1. **[README.md](README.md)** - Overview
2. **[docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md)** - How to test
3. **[src/x3q16.v](src/x3q16.v)** - CPU implementation
4. **[test/functional_cpu_keccak_tb.v](test/functional_cpu_keccak_tb.v)** - Test examples

### For Synthesis/Fabrication
1. **[README.md](README.md)** - Pin configuration
2. **[src/tt_um_zoom_zoom.v](src/tt_um_zoom_zoom.v)** - Top-level
3. **[docs/info.md](docs/info.md)** - Architecture
4. **Source files in `src/`** (except simulation-only files)

---

## Key Proof Files

### 🎬 Waveform Files (Primary Evidence)

**1. functional_cpu_keccak_tb.vcd** (15 KB)
- **Proves:** CPU executes instructions correctly
- **Shows:** 14 instructions, ALU ops, memory I/O
- **View:** `gtkwave test/functional_cpu_keccak_tb.vcd`
- **Key Signals:**
  - `cpu.current_address` - Program counter
  - `cpu.registers[0-7]` - Register file
  - `cpu.alu_result` - ALU output

**2. keccak_functional_tb.vcd** (28 KB)
- **Proves:** Keccak accelerator works
- **Shows:** Register loading, crypto operations
- **View:** `gtkwave test/keccak_functional_tb.vcd`
- **Key Signals:**
  - `cpu.keccak_registers[319:0]` - All Keccak state
  - `cpu.keccak_output` - Keccak ALU result

**3. integration_test_tb.vcd** (90 KB)
- **Proves:** System stability
- **Shows:** 1000+ cycles, no errors
- **View:** `gtkwave test/integration_test_tb.vcd`

---

## Test Vector Files

Test vectors (`.tv` files) contain input/output pairs for module testing:
- Binary format: Each line is one test case
- Used by testbenches to verify module behavior
- Found in each module's test directory

---

## Building & Running

### Quick Test (Everything)
```bash
bash run_all_tests.sh    # Linux/Mac
run_all_tests.bat        # Windows
```

### Individual Module Test
```bash
cd test/uart_rx
iverilog -o test.vvp -I ../../src uart_rx_tb.v
vvp test.vvp
```

### Functional Test (CPU + Keccak)
```bash
cd test
iverilog -o functional_cpu_keccak_tb.vvp -s functional_cpu_keccak_tb \
    functional_cpu_keccak_tb.v \
    ../src/x3q16.v \
    ../src/x3q16alu.v \
    ../src/uart_tx.v \
    ../src/keccakf1600_statepermutate.v
vvp functional_cpu_keccak_tb.vvp
```

---

## File Size Summary

### Source Files (~50 KB total)
- Core CPU + Keccak: ~30 KB
- Memory controllers: ~10 KB
- UART: ~5 KB
- Support files: ~5 KB

### Proof Waveforms (133 KB total)
- functional_cpu_keccak_tb.vcd: 15 KB
- keccak_functional_tb.vcd: 28 KB
- integration_test_tb.vcd: 90 KB

### Documentation (~60 KB total)
- Proof documents: ~30 KB
- Test guides: ~20 KB
- Architecture docs: ~10 KB

---

## Git Workflow

### What's Tracked
- All source files (`src/*.v`)
- Test source files (`test/**/*.v`, `test/**/*.tv`)
- Documentation (`docs/**/*.md`)
- Proof waveforms (3 main `.vcd` files)
- Test scripts (`*.sh`, `*.bat`)

### What's Ignored (via .gitignore)
- Build artifacts (`*.vvp`)
- Temporary waveforms (except proof files)
- Log files
- Editor temp files

---

## Tiny Tapeout Files

If using Tiny Tapeout platform, these files are also important:
- `info.yaml` - Project metadata
- `docs/info.md` - Documentation for TT platform

---

## Support

### Questions About Files?
- Check this guide first
- Review README.md
- Look in relevant docs/ subdirectory

### Need to Reproduce Tests?
- See: [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md)

### Need to Understand Design?
- See: [docs/info.md](docs/info.md)
- See: [docs/proof/FUNCTIONAL_TEST_REPORT.md](docs/proof/FUNCTIONAL_TEST_REPORT.md)

---

## Summary

**Essential Files for Understanding the Project:**
1. README.md
2. docs/proof/PROOF_OF_FUNCTIONALITY.md
3. test/*.vcd (waveforms)
4. src/x3q16.v (CPU)
5. src/keccakf1600_statepermutate.v (Keccak)

**Essential Files for Building:**
- All files in `src/` (except simulation-only)
- Top-level: `src/tt_um_zoom_zoom.v`

**Essential Files for Verification:**
- Test source in `test/`
- Waveforms: `test/*.vcd`
- Documentation: `docs/proof/`

---

**Last Updated:** 2025-10-13
**Repository Status:** ✅ Clean and Ready for Publication
