// To keep this in the first portion of the binary.
.section ".text.boot"
 
// Make _start global.
.globl _start
 
// Entry point for the kernel.
// r15 -> should begin execution at 0x00000000.
// r0 -> 0x00000000
// r1 -> 0x00000C42
// r2 -> 0x00000100 - start of ATAGS
// preserve these registers as argument for kernel_main
_start:
        b Reset_Handler
        b Undefined_Handler
        b SWI_Handler
        b Prefetch_Handler
        b Abort_Handler
        NOP                             // Reserved vector
        b IRQ_Handler
        b FIQ_Handler

Reset_Handler:        
    // Setup the stack.
    mov sp, #0x8000
 

    // Clear out bss.
    ldr r4, =__bss_start
    ldr r9, =__bss_end
    mov r5, #0
    mov r6, #0
    mov r7, #0
    mov r8, #0
    b       2f
 
1:
    // store multiple at r4.
    stmia r4!, {r5-r8}
 
    // If we are still below bss_end, loop.
2:
    cmp r4, r9
    blo 1b
 
    // Call kernel_main
    ldr r3, =kernel_main
    blx r3
 
// The following dummy handlers do not do anything useful in this example.
// They are set up here for completeness.

Undefined_Handler:
        B       Undefined_Handler
SWI_Handler:
        B       SWI_Handler
Prefetch_Handler:
        B       Prefetch_Handler
Abort_Handler:
        B       Abort_Handler
        
IRQ_Handler:
        B       IRQ_Handler


        
FIQ_Handler:
        B       FIQ_Handler

    // halt
halt:
    wfe
    b halt
