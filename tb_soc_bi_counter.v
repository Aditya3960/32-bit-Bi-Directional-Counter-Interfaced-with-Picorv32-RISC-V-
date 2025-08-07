// ============================================================================
// Testbench    : tb_soc_counter
// Description  : Testbench for the top-level SoC with bi-directional counter.
//                Simulates clock, reset, and prints counter values
// ============================================================================
module tb_soc_counter;

    // ---------------- Clock and Reset ----------------
    reg clk = 0;           // Clock signal
    reg reset = 1;         // Active-high reset

    // ---------------- Debug Wire ----------------
    wire [31:0] dbg_counter_value; // Output from DUT (for monitoring)

    // ---------------- Clock Generation ----------------
    always #5 clk = ~clk; // 100MHz clock (10ns period)

    // ---------------- DUT Instantiation ----------------
    soc_top_bi_counter uut (
        .clk(clk),
        .reset(reset),
        .dbg_counter_value(dbg_counter_value)
    );

    // ---------------- Simulation Initialization ----------------
    initial begin
        $dumpfile("soc_wave.vcd");        // VCD waveform output
        $dumpvars(0, tb_soc_counter);     // Dump all signals in module
        #100 reset = 0;                   // Deassert reset after 100ns
        #1000;                            // Run for 1000ns after reset
        $finish;                          // End simulation
    end

    // ---------------- Print Counter Value ----------------
    always @(posedge clk) begin
        if (!reset)
            $display("Time: %0dns, Counter Value: %0d", $time, dbg_counter_value);
    end

endmodule
