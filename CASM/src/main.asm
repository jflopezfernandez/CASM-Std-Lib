
;==============================================================================
;
;                            CASM Standard Lib
;
;==============================================================================
;
; Author: Jose Fernando Lopez Fernandez
; Date:   11-May-2019
;
; Description:
;
;   This is a library implementing the functionality of the C Standard Library
;   in NASM assembly language for x86-64 computers running *nix systems.
;
;==============================================================================

    SECTION .data

str:    db "abcdef", 10, 0  ; Test string while I implement I/O functionality.

    SECTION .text

;==============================================================================
;
;                            Global Functions
;
;==============================================================================
;
; Description:
; 
;   The following functions are declared global, and are therefore visible
;   to other compilation units.
;
;==============================================================================

    global exit
    global _start

;==============================================================================
;
;                                 EXIT
;
;==============================================================================
;
; Author: Jose Fernando Lopez Fernandez
; Date:   11-May-2019
; 
; Description:
; 
;   This function assumes an regular exit code, and therefore returns an
;   exit code of 0, indicating successful execution.
;
;==============================================================================

exit:
    xor rdi, rdi
    mov rdi, rax        ; DEBUG: Temporarily replacing the usual exit code of 0
                        ; with the return value from the function last called,
                        ; which is stored in the RAX register, as per
                        ; convention.
    mov rax, 60

    syscall

;==============================================================================
;
;                                 STRLEN
;
;==============================================================================
;
; Author: Jose Fernando Lopez Fernandez
; Date:   11-May-2019
;
; Description:
; 
;   This is a reimplementation of the classic 'strlen' function in the C
;   standard library. The function takes a single argument, the address
;   of a null-terminated string, and it returns the length by incrementing
;   the RAX register until hitting the first null character.
;
;==============================================================================

strlen:
    xor rax, rax

.loop:
    cmp byte [rdi + rax], 0
    je .end
    inc rax
    jmp .loop

.end:
    ret

;==============================================================================
;
;                                 PUTS
;
;==============================================================================
;
; Author: Jose Fernando Lopez Fernandez
; Date:   11-May-2019
;
; Description:
;
;   This function is meant to replicate the functionality of the C Standard
;   library 'puts' function. Short for "put string," the function prints the
;   passed-in string to stdout.
;
;   On entering the function, the contents of RDI, namely the address of the
;   source string, is pushed on to the stack. It is not moved to the RSI
;   register where it will be needed eventually because we must first 
;   calculate the length of the passed-in string, and since RSI is a volatile
;   register, we have no guarantee that if we place it there strlen will not
;   modify the contents of RSI.
;
;   Alternatively, the contents of RDI could be preserved by using a
;   non-volatile register like R12-R15, like so:
;
;       mov r12, rdi
;       call strlen
;       mov rsi, r12
;
; C language equivalent:
;
;   void puts(const char* str) {
;       ...
;   }
;
;==============================================================================

puts:
    push rdi            ; Push instruction decrements the stack pointer and
                        ; stores the source operand on the top of the stack.
    call strlen
    pop rsi             ; Loads the value from the top of the stack to the 
                        ; location specified with the destination operand (or
                        ; explicit opcode) and then decrements the stack
                        ; pointer.
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    
    syscall
    ret

;==============================================================================
;
;                                 PUTCHAR
;
;==============================================================================
;
; Author: Jose Fernando Lopez Fernandez
; Date:   11-May-2019
;
; Description:
;
;   This is a re-implementation of the C Standard Library putchar function,
;   which prints the passed in argument of type 'char' and prints it to 
;   stdout.
;
; C Language Equivalent:
;
;   void putchar(char c) {
;       ...
;   }
;
;==============================================================================

putchar:
    xor rax, rax
    ret

;==============================================================================
;
;                                 MAIN
;
;==============================================================================
;
; Author: Jose Fernando Lopez Fernandez
; Date:   11-May-2019
;
; Description:
;
;   The _start function is the entry point of the application. The default
;   setting in ld is to look for a _start function, while gcc looks for
;   a function named 'main'. I chose to bypass gcc for now and work directly
;   through ld, so _start it is.
;
;==============================================================================
;
; Sample NASM Program
;
; _start:
;     mov rax, 1          ; 'write' syscall number
;     mov rdi, 1          ; stdout descriptor
;     mov rsi, msg        ; string address
;     mov rdx, 14         ; string length in bytes
;
;     syscall
;
;     mov rax, 60         ; 'exit' syscall number
;     xor rdi, rdi
;
;     syscall
;
;==============================================================================

_start:
    mov rdi, str
    
    ; call strlen
    call puts

    call exit
