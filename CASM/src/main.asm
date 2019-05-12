
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
; Note:
;
;   I modified the original function to use the RBP and RSP registers, 
;   to demonstrate how to use the stack and base pointer registers. I 
;   prefer to compile with the '-fomit-frame-pointer' option on gcc, but this
;   is just for illustrative purposes.
;
;==============================================================================

strlen:
    push rbp
    mov rbp, rsp

    xor rax, rax

.loop:
    cmp byte [rdi + rax], 0
    je .end
    inc rax
    jmp .loop

.end:
    pop rbp
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
;   Like the puts function, putchar pushes the RDI register onto the stack
;   to preserve the parameter's value, as the call to puts means that the
;   contents of the RDI register are not guaranteed to be preserved. The
;   function then sets the RDI register to the contents of the stack pointer,
;   RSP, which allows the puts function to access the putchar function's
;   parameter.
;
;   The reason for this seemingly roundabout method of passing the argument
;   to the puts function is that the calling convention requires the stack
;   to be preserved between function calls. This means that while the RDI
;   register where the argument initially resided was volatile and could
;   be modified by the called function, putting the argument on the stack
;   guaranteed the argument would be unchanged but would still be accessible
;   to the puts function.
;
;   Upon returning from the puts function, the putchar function must pop the
;   previously-allocated contents off the stack to also comply with the
;   stack-preservation convention.
;
; C Language Equivalent:
;
;   void putchar(char c) {
;       ...
;   }
;
;==============================================================================

putchar:
    push rdi
    mov rdi, rsp
    call puts
    pop rdi
    ret

;==============================================================================
;
;                                 PRINT_NEWLINE
;
;==============================================================================
;
; Author: Igor Zhirkov
; 
; Description:
; 
;   This is a utility function that results in a newline character
;   being printed to stdout. It is implemented by simply loading the newline
;   ASCII value (10) into the RDI register and jumping directly to the
;   putchar function. The putchar function then reads its first and only
;   argument from the RDI register, as per the x86-64 *nix calling convention,
;   after which the putchar function's ret instruction passes execution
;   control directly to the main function.
;
;   The function could have been similarly implemented as follows:
;
;       print_newline:
;           mov rdi, 10
;           call putchar
;           ret
;
;   The single jmp instruction foregoes the need to create a new stack frame,
;   which must be set up then disassembled. Instead, the current implementation
;   results in a more direct execution path, where the print_newline function
;   is semantically nothing more than loading a newline into the RDI register,
;   but adds no further overhead.
;
;==============================================================================

print_newline:
    mov rdi, 10
    jmp putchar

; TODO: Implement print_uint
print_uint:
    xor rax, rax
    ret

; TODO: Implement print_int
print_int:
    xor rax, rax
    ret

;==============================================================================
;
;                                 READ_CHAR
;
;==============================================================================
;
; Author: Igor Zhirkov
;
; Description:
;
;   ...
;
;==============================================================================

read_char:
    push 0
    xor rax, rax    ; Load system call id 0 into RAX, indicating an I/O read.
    xor rdi, rdi    ; Load file descriptor id 0 (stdin) into the RDI register.
    mov rsi, rsp    ; The string buffer is the stack-allocated space we just created.
    mov rdx, 1      ; String length to read set to 1, passed through the RDX register.

    syscall

    ; DEBUG: Test read_char function by immediately printing the input.
    ; mov rdi, [rsp]
    ; call putchar
    ; call print_newline

    pop rax
    ret

; TODO: Implement read_word
read_word:
    xor rax, rax
    ret

; TODO: Implement parse_uint
parse_uint:
    xor rax, rax
    ret

; TODO: Implement parse_int
parse_int:
    xor rax, rax
    ret

; TODO: Implement string_equals
string_equals:
    xor rax, rax
    ret

; TODO: Implement string_copy
string_copy:
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
    mov rdi, 'a'
    
    ; call strlen
    ; call puts
    ; call putchar
    ; call print_newline
    call read_char

    call exit
