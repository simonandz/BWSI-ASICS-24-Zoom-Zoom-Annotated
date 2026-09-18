@echo off
REM Comprehensive test runner for BWSI-ASICS-24-Zoom-Zoom (Windows)
REM This script compiles and runs all individual module tests and integration tests

echo ========================================
echo BWSI ASICS 24 Zoom Zoom - Test Suite
echo ========================================
echo.

set TOTAL_TESTS=0
set PASSED_TESTS=0
set FAILED_TESTS=0

REM Test 1: UART RX
echo ----------------------------------------
echo Running: UART RX Module
echo ----------------------------------------
set /a TOTAL_TESTS+=1
cd test\uart_rx
iverilog -o test.vvp -I ..\..\src uart_rx_tb.v 2>&1 | findstr /i "error" >nul
if %errorlevel% equ 0 (
    echo FAILED: Compilation error
    set /a FAILED_TESTS+=1
) else (
    vvp test.vvp >test_output.txt 2>&1
    type test_output.txt | findstr /i "error" | findstr /v "0 errors" >nul
    if %errorlevel% equ 0 (
        echo FAILED: Runtime errors detected
        set /a FAILED_TESTS+=1
    ) else (
        echo PASSED
        set /a PASSED_TESTS+=1
    )
)
cd ..\..

REM Test 2: UART TX
echo ----------------------------------------
echo Running: UART TX Module
echo ----------------------------------------
set /a TOTAL_TESTS+=1
cd test\uart_tx
iverilog -o test.vvp -I ..\..\src uart_tx_tb.v 2>&1 | findstr /i "error" >nul
if %errorlevel% equ 0 (
    echo FAILED: Compilation error
    set /a FAILED_TESTS+=1
) else (
    vvp test.vvp >test_output.txt 2>&1
    type test_output.txt | findstr /i "error" | findstr /v "0 errors" >nul
    if %errorlevel% equ 0 (
        echo FAILED: Runtime errors detected
        set /a FAILED_TESTS+=1
    ) else (
        echo PASSED
        set /a PASSED_TESTS+=1
    )
)
cd ..\..

REM Test 3: x3q16 ALU
echo ----------------------------------------
echo Running: x3q16 ALU Module
echo ----------------------------------------
set /a TOTAL_TESTS+=1
cd test\x3q16alu
iverilog -o test.vvp -I ..\..\src x3q16alu_tb.v 2>&1 | findstr /i "error" >nul
if %errorlevel% equ 0 (
    echo FAILED: Compilation error
    set /a FAILED_TESTS+=1
) else (
    vvp test.vvp >test_output.txt 2>&1
    type test_output.txt | findstr /i "error" | findstr /v "0 errors" >nul
    if %errorlevel% equ 0 (
        echo FAILED: Runtime errors detected
        set /a FAILED_TESTS+=1
    ) else (
        echo PASSED
        set /a PASSED_TESTS+=1
    )
)
cd ..\..

REM Test 4: SPI Memory Interface
echo ----------------------------------------
echo Running: SPI Memory Interface
echo ----------------------------------------
set /a TOTAL_TESTS+=1
cd test\spi_memory_interface
iverilog -o test.vvp -I ..\..\src spi_memory_interface_tb.v 2>&1 | findstr /i "error" >nul
if %errorlevel% equ 0 (
    echo FAILED: Compilation error
    set /a FAILED_TESTS+=1
) else (
    vvp test.vvp >test_output.txt 2>&1
    type test_output.txt | findstr /i "error" | findstr /v "0 errors" >nul
    if %errorlevel% equ 0 (
        echo FAILED: Runtime errors detected
        set /a FAILED_TESTS+=1
    ) else (
        echo PASSED
        set /a PASSED_TESTS+=1
    )
)
cd ..\..

REM Test 5: Integration Test
echo ----------------------------------------
echo Running: System Integration Test
echo ----------------------------------------
set /a TOTAL_TESTS+=1
cd test
iverilog -o integration_test_tb.vvp -s integration_test_tb integration_test_tb.v ..\src\tt_um_zoom_zoom.v ..\src\x3q16.v ..\src\memory_controller_arduino.v ..\src\uart_rx.v ..\src\uart_tx.v ..\src\x3q16alu.v ..\src\keccakf1600_statepermutate.v 2>&1 | findstr /i "error:" >nul
if %errorlevel% equ 0 (
    echo FAILED: Compilation error
    set /a FAILED_TESTS+=1
) else (
    vvp integration_test_tb.vvp >integration_output.txt 2>&1
    type integration_output.txt | findstr "ALL TESTS PASSED" >nul
    if %errorlevel% equ 0 (
        echo PASSED
        set /a PASSED_TESTS+=1
    ) else (
        echo FAILED: Some integration tests failed
        set /a FAILED_TESTS+=1
    )
)
cd ..

REM Final summary
echo.
echo ========================================
echo Test Suite Summary
echo ========================================
echo Total Tests:  %TOTAL_TESTS%
echo Passed:       %PASSED_TESTS%
echo Failed:       %FAILED_TESTS%
echo ========================================

if %FAILED_TESTS% equ 0 (
    echo ALL TESTS PASSED!
    exit /b 0
) else (
    echo SOME TESTS FAILED!
    exit /b 1
)
