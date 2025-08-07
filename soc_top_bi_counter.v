`timescale 1ns / 1ps
`include "picorv32.v"

// ============================================================================
// Module      : soc_top_bi_counter
// Description : Top-level SoC module with PicoRV32 processor and a
//               bi-directional counter peripheral. Processor can read the
//               counter value and change its counting mode (UP/DOWN).
// ============================================================================
module soc_top_bi_counter (
    input wire clk,                    // System clock
    input wire reset,                  // Active-high reset
    output wire [31:0] dbg_counter_value // Debug output: current counter value
);

    // ---------------- PicoRV32 Memory Interface ----------------
    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    reg  [31:0] mem_rdata;

    // ---------------- Instantiate PicoRV32 CPU ----------------
    picorv32 cpu (
        .clk         (clk),
        .resetn      (~reset),       // Active-low reset for PicoRV32
        .mem_valid   (mem_valid),
        .mem_instr   (mem_instr),
        .mem_ready   (mem_ready),
        .mem_addr    (mem_addr),
        .mem_wdata   (mem_wdata),
        .mem_wstrb   (mem_wstrb),
        .mem_rdata   (mem_rdata),
        .mem_la_read (),
        .mem_la_write(),
        .mem_la_addr (),
        .mem_la_wdata(),
        .mem_la_wstrb()
    );

    // ---------------- Memory Declaration (4KB RAM) ----------------
    reg [31:0] memory [0:1023]; // 1024 words = 4KB

    initial begin
        $readmemh("firmware.hex", memory); // Load firmware into memory
    end

    reg mem_ready_reg;
    assign mem_ready = mem_ready_reg;

    // ---------------- Bi-directional Counter Interface ----------------
    wire [31:0] counter_value;
    reg  [1:0]  counter_mode = 2'd0; // 1 = UP, 2 = DOWN (default 0)

    // ---------------- Memory-Mapped I/O Address Mapping ----------------
    // Memory-mapped address decoding (word-aligned, 0x40000000 and 0x40000004)
    wire counter_selected = mem_valid && (mem_addr[31:2] == 30'h10000000); // 0x40000000
    wire mode_selected    = mem_valid && (mem_addr[31:2] == 30'h10000001); // 0x40000004

    // ---------------- Instantiate Counter Peripheral ----------------
    bi_counter u_counter (
        .clk(clk),
        .reset(reset),
        .mode(counter_mode),
        .count(counter_value)
    );

    // ---------------- Memory Access and Peripheral Logic ----------------
    always @(posedge clk) begin
        mem_ready_reg <= 0; // Default no response

        if (mem_valid && !counter_selected && !mode_selected) begin
            // Regular memory access (not counter or mode)
            mem_ready_reg <= 1;
            if (mem_wstrb != 0) begin
                // Byte-wise write support
                if (mem_wstrb[0]) memory[mem_addr[11:2]][7:0]   <= mem_wdata[7:0];
                if (mem_wstrb[1]) memory[mem_addr[11:2]][15:8]  <= mem_wdata[15:8];
                if (mem_wstrb[2]) memory[mem_addr[11:2]][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) memory[mem_addr[11:2]][31:24] <= mem_wdata[31:24];
            end
            mem_rdata <= memory[mem_addr[11:2]]; // Return data
        end
        else if (counter_selected) begin
            // Reading from counter
            mem_ready_reg <= 1;
            mem_rdata <= counter_value;
        end
        else if (mode_selected) begin
            // Writing to counter mode register
            mem_ready_reg <= 1;
            if (mem_wstrb != 0) begin
                counter_mode <= mem_wdata[1:0]; // Set new mode (1 or 2)
            end
        end
    end

    // ---------------- Debug Output ----------------
    assign dbg_counter_value = counter_value;

endmodule
