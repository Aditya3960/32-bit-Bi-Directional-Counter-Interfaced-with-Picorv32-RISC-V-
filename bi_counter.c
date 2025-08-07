#include <stdint.h>

// Entry point of the program
void _start(void) {
    volatile uint32_t val;

    // Configure counter mode:
    // Write 1 to 0x40000004 for UP count
    // Write 2 to 0x40000004 for DOWN count
    *(volatile uint32_t*)0x40000004 = 2;  // Change to 1 for UP, 2 for DOWN

    // Infinite loop to read current counter value
    for (;;) {
        // Read counter value from memory-mapped address 0x40000000
        val = *(volatile uint32_t*)0x40000000;

        // Optional: Send value to UART if connected
        // *(volatile uint32_t*)0x20000008 = val & 0xFF;
    }
}
