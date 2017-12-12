.data
.equ UART0_BASE, 0x3F201000
 
FIQMsg:
.asciz "FIQ triggered"
IRQMsg:
.asciz "IRQ triggered"
SWIMsg:
.asciz "SWI triggered"
UndefinedMsg:
.asciz "Undefined triggered"
PrefetchMsg:
.asciz "Prefetch triggered"
AbortMsg:
.asciz "Abort triggered"

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
    ldr pc,=Reset_Handler
    ldr pc,=Undefined_Handler
    ldr pc,=SWI_Handler
    ldr pc,=Prefetch_Handler
    ldr pc,=Abort_Handler
    NOP                             // Reserved vector
    ldr pc,=IRQ_Handler
    //FIQ handler should ideally be here so that can be serviced quicker avoiding an extra jump
FIQ_Handler:
    //print out message
    ldr r6, FIQMsgAddr
    STMFD R13!,{R14}
    bl PrintMsg
    LDMFD R13!,{r14}
    SUBS PC, R14, #4 //return

//prints the message poined by r6 to null termination
PrintMsg:
    ldr r5, =UART0_BASE
morechar:
    mov r7, #0
    ldrb r7, [r6], #1
    strb r7, [r5]
    cmp r7, #0
    beq lastchar
waitchar:
    ldr r7, [r5, #0x18]
    and r7, #0x40
    beq waitchar
    b   morechar
lastchar:
    mov pc, lr
    

Reset_Handler:        
    // Setup the stack.
    mov sp, #0x8000

    // Zero out bss.
    ldr r4, =__bss_start
    ldr r9, =__bss_end
    mov r5, #0
    mov r6, #0
    mov r7, #0
    mov r8, #0
    b   done
 
clear:
    // store multiple at r4.
    stmia r4!, {r5-r8}
 
    // If we are still below bss_end, loop.
done:
    cmp r4, r9
    blo clear
 
    // Call kernel_main
    ldr r3, =kernel_main
    blx r3
 
// The following dummy handlers do not do anything useful in this example.
// They are set up here for completeness.

Undefined_Handler:
    //print out message
    ldr r6, UndefinedMsgAddr
    STMFD R13!,{R14}
    bl PrintMsg
    LDMFD R13!,{r14}
    MOVS PC,R14

SWI_Handler:
    //print out message
    ldr r6, SWIMsgAddr
    STMFD R13!,{R14}
    bl PrintMsg
    LDMFD R13!,{r14}
/*  
    //use this to jump to your swi handler routine, r0 take the argument to the swi call
    mov r0, #0x21
    blx sw_irq
*/
    MOVS PC,R14 //return

Prefetch_Handler:
    //print out message
    ldr r6, PrefetchMsgAddr
    STMFD R13!,{R14}
    bl PrintMsg
    LDMFD R13!,{r14}
    SUBS PC,R14,#4

Abort_Handler:
    //print out message
    ldr r6, AbortMsgAddr
    STMFD R13!,{R14}
    bl PrintMsg
    LDMFD R13!,{r14}
    SUBS PC,R14,#4 //if abort instruction does not need re-executing
    SUBS PC,R14,#8 //if abort instruction needs re-executing

IRQ_Handler:
    //print out message
    ldr r6, IRQMsgAddr
    STMFD R13!,{R14}
    bl PrintMsg
    LDMFD R13!,{r14}
    SUBS PC, R14, #4 //return

    // halt
halt:
    wfe
    b halt

IRQMsgAddr : .word IRQMsg
SWIMsgAddr : .word SWIMsg
FIQMsgAddr : .word FIQMsg
PrefetchMsgAddr : .word PrefetchMsg
UndefinedMsgAddr : .word UndefinedMsg
AbortMsgAddr : .word AbortMsg

.end
