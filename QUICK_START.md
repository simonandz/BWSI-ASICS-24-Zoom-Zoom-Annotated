# Quick Start Guide

## 🚀 Want to See It Work? (30 seconds)

```bash
# 1. Run all tests
bash run_all_tests.sh

# Expected output:
# Total Tests:  5
# Passed:       5
# Failed:       0
# ALL TESTS PASSED!
```

That's it! The system works.

---

## 🎬 Want to See Proof? (2 minutes)

```bash
# 2. View the execution waveform
cd test
gtkwave functional_cpu_keccak_tb.vcd
```

**What you'll see:**
- CPU executing 14 instructions
- ALU doing math (ADD, SUB, NAND)
- Memory read/write operations
- Keccak accelerator working

**Key signals to view:**
- `cpu.current_address` - Program counter
- `cpu.registers[4]` - See result 0x0400 from addition
- `cpu.alu_result` - ALU calculations

---

## 📖 Want to Understand It? (5 minutes)

Read in this order:
1. [README.md](README.md) - Project overview
2. [docs/proof/PROOF_OF_FUNCTIONALITY.md](docs/proof/PROOF_OF_FUNCTIONALITY.md) - Evidence it works

---

## 🔧 Want to Modify It? (10 minutes)

1. Read: [REPOSITORY_GUIDE.md](REPOSITORY_GUIDE.md) - Navigation
2. Read: [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md) - How to test
3. Look at: [src/x3q16.v](src/x3q16.v) - CPU core
4. Look at: [test/functional_cpu_keccak_tb.v](test/functional_cpu_keccak_tb.v) - Test example

---

## 📚 Complete Documentation

| Document | Purpose | Time |
|----------|---------|------|
| [README.md](README.md) | Project overview | 3 min |
| [REPOSITORY_GUIDE.md](REPOSITORY_GUIDE.md) | Navigation | 2 min |
| [docs/info.md](docs/info.md) | Architecture | 10 min |
| [docs/proof/PROOF_OF_FUNCTIONALITY.md](docs/proof/PROOF_OF_FUNCTIONALITY.md) | Evidence | 5 min |
| [docs/proof/FUNCTIONAL_TEST_REPORT.md](docs/proof/FUNCTIONAL_TEST_REPORT.md) | Detailed analysis | 15 min |
| [docs/proof/WAVEFORM_GUIDE.md](docs/proof/WAVEFORM_GUIDE.md) | Waveform help | 10 min |
| [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md) | How to test | 5 min |
| [docs/TEST_RESULTS.md](docs/TEST_RESULTS.md) | Test results | 5 min |

---

## ✅ What Works (Verified)

- CPU executes all instruction types ✅
- ALU: ADD, SUB, MUL, NAND ✅
- Memory: Read/Write ✅
- Keccak accelerator integrated ✅
- 1000+ cycles stable ✅
- All tests passing ✅

**See waveforms for proof!**

---

## 💡 Need Help?

- **Can't run tests?** See [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md)
- **Don't understand a file?** See [REPOSITORY_GUIDE.md](REPOSITORY_GUIDE.md)
- **Want technical details?** See [docs/info.md](docs/info.md)
- **Need proof?** See [docs/proof/PROOF_OF_FUNCTIONALITY.md](docs/proof/PROOF_OF_FUNCTIONALITY.md)

---

**Status:** ✅ Everything works, fully tested, ready to go!
