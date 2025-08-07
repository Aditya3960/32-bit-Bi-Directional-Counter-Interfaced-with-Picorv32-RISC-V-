// ============================================================================
// Module      : bi_counter
// Description : 32-bit bi-directional counter with dynamic mode switching
//               Mode 1 = Up Counter (starts from 0)
//               Mode 2 = Down Counter (starts from 0xFFFFFFFF)
//               Resets counter when mode changes
// ============================================================================
module bi_counter (
    input wire clk,              // System clock
    input wire reset,            // Active-high reset
    input wire [1:0] mode,       // 2-bit mode: 1 = UP, 2 = DOWN
    output reg [31:0] count      // 32-bit counter output
);

    reg [1:0] prev_mode;         // Holds previous mode for change detection

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // On reset, initialize counter based on current mode
            prev_mode <= 2'd0;
            if (mode == 2)
                count <= 32'hFFFFFFFF;   // Start from max if DOWN mode
            else
                count <= 32'd0;          // Default to 0 for UP or invalid mode
        end else begin
            // On mode change, reset count accordingly
            if (mode != prev_mode) begin
                case (mode)
                    2'd1: count <= 32'd0;         // UP mode: start from 0
                    2'd2: count <= 32'hFFFFFFFF;  // DOWN mode: start from max
                    default: count <= count;      // No change for invalid mode
                endcase
                prev_mode <= mode;  // Update previous mode
            end else begin
                // Normal operation: count up or down
                case (mode)
                    2'd1: count <= count + 1;     // UP
                    2'd2: count <= count - 1;     // DOWN
                    default: count <= count;      // Hold value on invalid mode
                endcase
            end
        end
    end

endmodule
