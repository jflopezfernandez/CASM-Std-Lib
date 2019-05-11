
;==============================================================================
;
;                                 STR
;
;==============================================================================
;
; Author: Jose Fernando Lopez Fernandez
; Date:   11-May-2019
;
; Description:
;
;   This is a library implementing various string-related functions in NASM
;   assembly language for x86-64 computers running *nix systems.
;
;==============================================================================

    SECTION .data

str:    db "abcdef", 0

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
; C language equivalent:
;
;   void puts(const char* str) {
;       ...
;   }
;
;==============================================================================

puts:
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

_start:
    mov rdi, str
    call strlen

    call exit
