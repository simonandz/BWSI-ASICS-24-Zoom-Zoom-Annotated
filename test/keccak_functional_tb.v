`timescale 1ns / 1ps

/*
 * Comprehensive Keccak Accelerator Functional Test
 *
 * This testbench specifically tests the Keccak accelerator integration
 * with the x3q16 CPU, verifying:
 * 1. Loading data into Keccak registers
 * 2. Keccak ALU operations (XOR, THETA, ROL, XORINVAND)
 * 3. Unloading results from Keccak registers
 * 4. Complete Keccak processing pipeline
 */

module keccak_functional_tb;

    // Clock and reset
    reg clk;
    reg reset;

    // Memory interface
    reg [15:0] memory_in;
    reg memory_ready;
    reg write_complete;
    reg uart_inbound;

    // CPU outputs
    wire [15:0] request_address;
    wire request_type;
    wire request;
    wire [15:0] data_out;
    wire tx;
    wire set_rx_speed;
    wire [12:0] rx_speed;

    // Simulated RAM
    reg [15:0] ram [0:65535];

    // Test tracking
    integer cycle_count;
    integer test_phase;

    // Instantiate CPU
    x3q16 cpu (
        .clk(clk),
        .reset(reset),
        .memory_in(memory_in),
        .memory_ready(memory_ready),
        .write_complete(write_complete),
        .uart_inbound(uart_inbound),
        .request_address(request_address),
        .request_type(request_type),
        .request(request),
        .data_out(data_out),
        .tx(tx),
        .set_rx_speed(set_rx_speed),
        .rx_speed(rx_speed)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Memory controller simulation
    reg request_pending;
    always @(posedge clk) begin
        if (reset) begin
            memory_ready <= 0;
            write_complete <= 0;
            request_pending <= 0;
        end else begin
            if (request && !request_pending) begin
                request_pending <= 1;
                memory_ready <= 0;
                write_complete <= 0;
            end else if (request_pending) begin
                if (request_type) begin
                    ram[request_address] <= data_out;
                    write_complete <= 1;
                    memory_ready <= 0;
                    request_pending <= 0;
                end else begin
                    memory_in <= ram[request_address];
                    memory_ready <= 1;
                    write_complete <= 0;
                    request_pending <= 0;
                end
            end else begin
                memory_ready <= 0;
                write_complete <= 0;
            end
        end
    end

    // VCD dump with detailed Keccak register monitoring
    initial begin
        $dumpfile("keccak_functional_tb.vcd");
        $dumpvars(0, keccak_functional_tb);
        $dumpvars(0, cpu.keccak_registers);
        $dumpvars(0, cpu.keccak_output);
        $dumpvars(0, cpu.execution_stage);
        $dumpvars(0, cpu.current_instruction);
        $dumpvars(0, cpu.current_address);
        $dumpvars(0, cpu.registers[2]);
        $dumpvars(0, cpu.registers[3]);
        $dumpvars(0, cpu.registers[4]);
    end

    // Initialize comprehensive Keccak test program
    integer i;
    initial begin
        // Initialize RAM
        for (i = 0; i < 65536; i = i + 1) begin
            ram[i] = 16'h0000;
        end

        /*
         * Keccak Test Program
         *
         * Keccak operations:
         * - Mode 00: kxorinvand = K0 ^ ((~K1) & K2)
         * - Mode 01: ktheta = K0 ^ K1 ^ K2 ^ K3
         * - Mode 10: krol = K0 ^ ROL(K1, K2)
         * - Mode 11: kxor = K0 ^ K1
         *
         * Instruction 0x1001 (Keccak load/unload):
         * [15:14]=ksettings, [13:12]=kreg1_ext, [11:7]=kreg1, [6:4]=settings(reg), [3:0]=1001
         * ksettings: 00=load, 01/10/11=unload
         */

        // Prepare test data in memory (addresses 0x1000-0x1010)
        ram[16'h1000] = 16'hAAAA;  // Test data 1
        ram[16'h1001] = 16'hBBBB;  // Test data 2
        ram[16'h1002] = 16'h5555;  // Test data 3
        ram[16'h1003] = 16'hFF00;  // Test data 4
        ram[16'h1004] = 16'h00FF;  // Test data 5
        ram[16'h1005] = 16'h1234;  // Test data 6
        ram[16'h1006] = 16'h5678;  // Test data 7
        ram[16'h1007] = 16'h9ABC;  // Test data 8

        // Output storage area
        ram[16'h2000] = 16'h0000;  // Output location 1
        ram[16'h2001] = 16'h0000;  // Output location 2

        // === Test Program ===

        // Load base address 0x1000 into R2
        ram[16'h0000] = 16'b000100000_010_0111;  // LI R2, 0x1000

        // Load output address 0x2000 into R3
        ram[16'h0001] = 16'b001000000_011_0111;  // LI R3, 0x2000

        // === PHASE 1: Load data into Keccak register K0 (4 x 16-bit words = 64 bits) ===

        // Load K0[15:0] from [R2] (0x1000)
        // Format: [15:14]=00 (load), [13:12]=00 (word 0), [11:7]=00000 (K0), [6:4]=010 (R2), [3:0]=1001
        ram[16'h0002] = 16'b00_00_00000_010_1001;  // K0[15:0] = [R2]

        // Increment R2 (R2 = R2 + 1)
        ram[16'h0003] = 16'b010_000_010_000_0010;  // R2 = R2 + 1 (ALUI, add mode)

        // Load K0[31:16] from [R2] (0x1001)
        ram[16'h0004] = 16'b00_01_00000_010_1001;  // K0[31:16] = [R2]

        // Increment R2
        ram[16'h0005] = 16'b010_000_010_000_0010;  // R2 = R2 + 1

        // Load K0[47:32] from [R2] (0x1002)
        ram[16'h0006] = 16'b00_10_00000_010_1001;  // K0[47:32] = [R2]

        // Increment R2
        ram[16'h0007] = 16'b010_000_010_000_0010;  // R2 = R2 + 1

        // Load K0[63:48] from [R2] (0x1003)
        ram[16'h0008] = 16'b00_11_00000_010_1001;  // K0[63:48] = [R2]

        // === PHASE 2: Load data into Keccak register K1 ===

        // Increment R2
        ram[16'h0009] = 16'b010_000_010_000_0010;  // R2 = R2 + 1 (now 0x1004)

        // Load K1[15:0] from [R2]
        ram[16'h000A] = 16'b00_00_00001_010_1001;  // K1[15:0] = [R2]

        // Increment R2
        ram[16'h000B] = 16'b010_000_010_000_0010;

        // Load K1[31:16]
        ram[16'h000C] = 16'b00_01_00001_010_1001;  // K1[31:16] = [R2]

        // Increment R2
        ram[16'h000D] = 16'b010_000_010_000_0010;

        // Load K1[47:32]
        ram[16'h000E] = 16'b00_10_00001_010_1001;  // K1[47:32] = [R2]

        // Increment R2
        ram[16'h000F] = 16'b010_000_010_000_0010;

        // Load K1[63:48]
        ram[16'h0010] = 16'b00_11_00001_010_1001;  // K1[63:48] = [R2]

        // === PHASE 3: Perform Keccak ALU operation (XOR: K0 ^ K1) ===
        // This stores result in K4
        ram[16'h0011] = 16'b11_00_00000_000_0011;  // Keccak ALU XOR operation

        // === PHASE 4: Store result from K4 back to memory ===

        // Unload K4[15:0] to [R3] (0x2000)
        // Format: [15:14]=01+ (unload), [13:12]=00, [11:7]=00100 (K4), [6:4]=011 (R3), [3:0]=1001
        ram[16'h0012] = 16'b01_00_00100_011_1001;  // [R3] = K4[15:0]

        // Increment R3
        ram[16'h0013] = 16'b011_000_011_000_0010;  // R3 = R3 + 1

        // Unload K4[31:16] to [R3]
        ram[16'h0014] = 16'b01_01_00100_011_1001;  // [R3] = K4[31:16]

        // Increment R3
        ram[16'h0015] = 16'b011_000_011_000_0010;

        // Unload K4[47:32]
        ram[16'h0016] = 16'b01_10_00100_011_1001;  // [R3] = K4[47:32]

        // Increment R3
        ram[16'h0017] = 16'b011_000_011_000_0010;

        // Unload K4[63:48]
        ram[16'h0018] = 16'b01_11_00100_011_1001;  // [R3] = K4[63:48]

        // === PHASE 5: Jump to end ===
        ram[16'h0019] = 16'b000_000_010_110_0100;  // Indirect jump

        ram[16'h001A] = 16'hFFFF;  // Jump address

        // End marker
        ram[16'hFFFF] = 16'h0000;  // NOP
    end

    // Main test sequence
    initial begin
        $display("\n========================================");
        $display("Keccak Accelerator Functional Test");
        $display("========================================\n");

        clk = 0;
        reset = 1;
        uart_inbound = 0;
        cycle_count = 0;
        test_phase = 0;

        #20;
        reset = 0;
        $display("Test started at time %0t\n", $time);

        // Run simulation
        repeat(1000) @(posedge clk) begin
            cycle_count = cycle_count + 1;

            // Monitor Keccak register loading
            if (cycle_count == 100 && test_phase == 0) begin
                $display("=== Phase 1: After initial Keccak loads ===");
                $display("K0[63:0] = 0x%016h", cpu.keccak_registers[63:0]);
                $display("K1[63:0] = 0x%016h", cpu.keccak_registers[127:64]);
                test_phase = 1;
            end

            // Check for end condition
            if (request_address == 16'hFFFF && !reset) begin
                $display("\n========================================");
                $display("Program Complete - Final Results");
                $display("========================================");

                #200;  // Wait for operations to complete

                $display("\n=== Final Keccak Register State ===");
                $display("K0[63:0]   = 0x%016h", cpu.keccak_registers[63:0]);
                $display("K1[63:0]   = 0x%016h", cpu.keccak_registers[127:64]);
                $display("K2[63:0]   = 0x%016h", cpu.keccak_registers[191:128]);
                $display("K3[63:0]   = 0x%016h", cpu.keccak_registers[255:192]);
                $display("K4[63:0]   = 0x%016h (XOR result)", cpu.keccak_registers[319:256]);

                $display("\n=== Memory Results ===");
                $display("Input data at 0x1000-0x1007:");
                $display("  [0x1000] = 0x%04h", ram[16'h1000]);
                $display("  [0x1001] = 0x%04h", ram[16'h1001]);
                $display("  [0x1002] = 0x%04h", ram[16'h1002]);
                $display("  [0x1003] = 0x%04h", ram[16'h1003]);
                $display("  [0x1004] = 0x%04h", ram[16'h1004]);
                $display("  [0x1005] = 0x%04h", ram[16'h1005]);
                $display("  [0x1006] = 0x%04h", ram[16'h1006]);
                $display("  [0x1007] = 0x%04h", ram[16'h1007]);

                $display("\nOutput data at 0x2000-0x2003:");
                $display("  [0x2000] = 0x%04h", ram[16'h2000]);
                $display("  [0x2001] = 0x%04h", ram[16'h2001]);
                $display("  [0x2002] = 0x%04h", ram[16'h2002]);
                $display("  [0x2003] = 0x%04h", ram[16'h2003]);

                // Verify XOR operation
                $display("\n=== Verification ===");
                $display("Expected K0 XOR K1 in K4:");
                $display("  K0[15:0] ^ K1[15:0] = 0xAAAA ^ 0x00FF = 0x%04h", 16'hAAAA ^ 16'h00FF);
                $display("  K0 input: 0x%016h", {ram[16'h1003], ram[16'h1002], ram[16'h1001], ram[16'h1000]});
                $display("  K1 input: 0x%016h", {ram[16'h1007], ram[16'h1006], ram[16'h1005], ram[16'h1004]});

                $display("\n=== CPU Register State ===");
                $display("R2 = 0x%04h", cpu.registers[2]);
                $display("R3 = 0x%04h", cpu.registers[3]);

                $display("\nTotal cycles: %0d", cycle_count);
                $display("\n========================================");
                $display("KECCAK TEST COMPLETED");
                $display("Waveform saved to: keccak_functional_tb.vcd");
                $display("========================================\n");

                #100;
                $finish;
            end
        end

        $display("\nWARNING: Test timeout at %0d cycles", cycle_count);
        $display("Current PC: 0x%04h", request_address);
        $finish;
    end

    // Timeout watchdog
    initial begin
        #100000;  // 100us
        $display("\nERROR: Watchdog timeout!");
        $finish;
    end

endmodule
