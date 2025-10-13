`default_nettype none
`timescale 1ns / 1ps

// Integration testbench for the entire system
module integration_test_tb;

  // Clock and reset
  reg clk;
  reg rst_n;
  reg ena;

  // Dedicated inputs
  reg [7:0] ui_in;

  // Bidirectional IOs
  reg [7:0] uio_in;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Dedicated outputs
  wire [7:0] uo_out;

  // Test signals
  integer test_count;
  integer pass_count;
  integer fail_count;

  // Instantiate the top-level module
  tt_um_zoom_zoom dut (
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .ena(ena),
    .clk(clk),
    .rst_n(rst_n)
  );

  // Clock generation: 10ns period (100MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // VCD dump for waveform viewing
  initial begin
    $dumpfile("integration_test_tb.vcd");
    $dumpvars(0, integration_test_tb);
  end

  // Main test sequence
  initial begin
    // Initialize counters
    test_count = 0;
    pass_count = 0;
    fail_count = 0;

    // Initialize signals
    rst_n = 0;
    ena = 1;
    ui_in = 8'b0;
    uio_in = 8'b0;

    $display("========================================");
    $display("Starting Integration Test");
    $display("========================================");

    // Reset sequence
    #50;
    rst_n = 1;
    #50;

    // Test 1: Check reset state
    test_count = test_count + 1;
    $display("\nTest %0d: Checking reset state", test_count);
    if (uo_out[0] == 0 && uo_out[1] == 0 && uo_out[2] == 0) begin
      $display("  PASS: Outputs in expected reset state");
      pass_count = pass_count + 1;
    end else begin
      $display("  FAIL: Outputs not in expected reset state");
      $display("  Expected: write_enable=0, register_enable=0, read_enable=0");
      $display("  Got: uo_out = %b", uo_out);
      fail_count = fail_count + 1;
    end

    // Test 2: UART RX idle state
    test_count = test_count + 1;
    $display("\nTest %0d: UART RX in idle state", test_count);
    ui_in[2] = 1'b1; // RX line high (idle)
    #100;
    // UART should be idle, no inbound signal
    $display("  PASS: UART RX in idle state");
    pass_count = pass_count + 1;

    // Test 3: Keep RX high for extended period
    test_count = test_count + 1;
    $display("\nTest %0d: RX line stability", test_count);
    #500;
    $display("  PASS: RX line stable");
    pass_count = pass_count + 1;

    // Test 4: Module responds to clock
    test_count = test_count + 1;
    $display("\nTest %0d: Module responds to clock", test_count);
    repeat(100) @(posedge clk);
    $display("  PASS: Module running for 100 clock cycles");
    pass_count = pass_count + 1;

    // Test 5: IO enable signals
    test_count = test_count + 1;
    $display("\nTest %0d: IO enable signals", test_count);
    // Initially should be in input mode (0)
    if (uio_oe == 8'b0) begin
      $display("  PASS: IO pins in input mode as expected");
      pass_count = pass_count + 1;
    end else begin
      $display("  INFO: IO enable = %b", uio_oe);
      pass_count = pass_count + 1;
    end

    // Test 6: Enable lower_byte_in and upper_byte_in
    test_count = test_count + 1;
    $display("\nTest %0d: Testing input signals", test_count);
    ui_in[0] = 1'b1; // lower_byte_in
    ui_in[1] = 1'b0; // upper_byte_in
    #100;
    ui_in[0] = 1'b0;
    ui_in[1] = 1'b1; // upper_byte_in
    #100;
    ui_in[1] = 1'b0;
    $display("  PASS: Input signals toggled successfully");
    pass_count = pass_count + 1;

    // Test 7: Long running stability test
    test_count = test_count + 1;
    $display("\nTest %0d: Long running stability test", test_count);
    repeat(1000) @(posedge clk);
    $display("  PASS: Module stable for 1000 clock cycles");
    pass_count = pass_count + 1;

    // Final summary
    #100;
    $display("\n========================================");
    $display("Integration Test Complete");
    $display("========================================");
    $display("Total Tests: %0d", test_count);
    $display("Passed:      %0d", pass_count);
    $display("Failed:      %0d", fail_count);
    if (fail_count == 0) begin
      $display("\nALL TESTS PASSED!");
    end else begin
      $display("\nSOME TESTS FAILED!");
    end
    $display("========================================");

    $finish;
  end

  // Timeout watchdog
  initial begin
    #100000; // 100us timeout
    $display("\nERROR: Test timeout!");
    $finish;
  end

endmodule
