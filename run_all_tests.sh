#!/bin/bash

# Comprehensive test runner for BWSI-ASICS-24-Zoom-Zoom
# This script compiles and runs all individual module tests and integration tests

echo "========================================"
echo "BWSI ASICS 24 Zoom Zoom - Test Suite"
echo "========================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test
run_test() {
    local test_name=$1
    local test_dir=$2
    local test_file=$3
    local sources=$4

    echo "----------------------------------------"
    echo "Running: $test_name"
    echo "----------------------------------------"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    cd "$test_dir" || return 1

    # Compile
    echo "Compiling..."
    if iverilog -o test.vvp -I ../../src $test_file $sources 2>&1 | grep -i error; then
        echo -e "${RED}FAILED${NC}: Compilation error"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        cd - > /dev/null
        return 1
    fi

    # Run
    echo "Running simulation..."
    if vvp test.vvp 2>&1 | tee test_output.txt | tail -20; then
        if grep -qi "error" test_output.txt && ! grep -qi "0 errors" test_output.txt; then
            echo -e "${RED}FAILED${NC}: Runtime errors detected"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            cd - > /dev/null
            return 1
        else
            echo -e "${GREEN}PASSED${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            cd - > /dev/null
            return 0
        fi
    else
        echo -e "${RED}FAILED${NC}: Simulation error"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        cd - > /dev/null
        return 1
    fi
}

# Get the base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BASE_DIR"

echo "Base directory: $BASE_DIR"
echo ""

# Test 1: UART RX
run_test "UART RX Module" \
    "$BASE_DIR/test/uart_rx" \
    "uart_rx_tb.v" \
    ""

# Test 2: UART TX
run_test "UART TX Module" \
    "$BASE_DIR/test/uart_tx" \
    "uart_tx_tb.v" \
    ""

# Test 3: x3q16 ALU
run_test "x3q16 ALU Module" \
    "$BASE_DIR/test/x3q16alu" \
    "x3q16alu_tb.v" \
    ""

# Test 4: SPI Memory Interface
run_test "SPI Memory Interface" \
    "$BASE_DIR/test/spi_memory_interface" \
    "spi_memory_interface_tb.v" \
    ""

# Test 5: Integration Test
echo "----------------------------------------"
echo "Running: System Integration Test"
echo "----------------------------------------"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
cd "$BASE_DIR/test"
echo "Compiling integration test..."
if iverilog -o integration_test_tb.vvp -s integration_test_tb \
    integration_test_tb.v \
    ../src/tt_um_zoom_zoom.v \
    ../src/x3q16.v \
    ../src/memory_controller_arduino.v \
    ../src/uart_rx.v \
    ../src/uart_tx.v \
    ../src/x3q16alu.v \
    ../src/keccakf1600_statepermutate.v 2>&1 | grep -i "error:"; then
    echo -e "${RED}FAILED${NC}: Compilation error"
    FAILED_TESTS=$((FAILED_TESTS + 1))
else
    echo "Running integration test..."
    if vvp integration_test_tb.vvp 2>&1 | tee integration_output.txt; then
        if grep -q "ALL TESTS PASSED" integration_output.txt; then
            echo -e "${GREEN}PASSED${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "${RED}FAILED${NC}: Some integration tests failed"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo -e "${RED}FAILED${NC}: Simulation error"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
fi

cd "$BASE_DIR"

# Final summary
echo ""
echo "========================================"
echo "Test Suite Summary"
echo "========================================"
echo "Total Tests:  $TOTAL_TESTS"
echo -e "Passed:       ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:       ${RED}$FAILED_TESTS${NC}"
echo "========================================"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}ALL TESTS PASSED!${NC}"
    exit 0
else
    echo -e "${RED}SOME TESTS FAILED!${NC}"
    exit 1
fi
