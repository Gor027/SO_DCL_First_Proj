        global _start

; Limit on 8288
BUF_SIZE: equ 8100
SPAN: equ 42
BCHAR: equ '1'


section .text

        %define checked rsi            ; Stores pointer to checked permutation
        %define reverse rbx            ; Stores pointer to reversed perm
        %define char rcx
        %define index rdx
        %define temp r11               ; on syscall r11 is modified

_check_normalize:
        xor rdi, rdi                   ; checking uniqueness of chars
        mov rdi, 0xffffffffffffffff
        shl rdi, SPAN                  ; 22 1's and 42 0's should be there

        xor index, index
.whiling:
        sub [checked + index], BYTE BCHAR
        mov cl, BYTE [checked + index] ; cl is 8-bit of char
        mov BYTE [reverse + char], dl  ; 8-bit of index

        jb exit_err                    ; comparision flags set in sub

        cmp char, SPAN
        jge exit_err

; There is not any syscall, so
; as temp var, r11 is used
        xor temp, temp
        mov temp, 1
        shl temp, cl

        or rdi, temp

        inc index
        cmp index, SPAN
        jne .whiling

        cmp BYTE [checked + index], 0
        jne exit_err

        cmp rdi, -1
        jne exit_err
        ret



        %define rState r15
        %define lState r14

key_checking:
; Key is in rsi
; First L perm
        movzx lState, BYTE [rsi]
        sub lState, BYTE BCHAR
        jl exit_err

        cmp lState, SPAN
        jge exit_err

; The same for R perm
        movzx rState, BYTE [rsi + 1]
        sub rState, BYTE BCHAR
        jl exit_err

        cmp rState, SPAN
        jge exit_err

        cmp BYTE [rsi + 2], 0
        jne exit_err
        ret

        %define T r10
        %define char rax
        %define index rbx


transpose_checking:
        xor char, char
        mov ebx, SPAN - 1              ; Loop from end
.whiling:
        mov al, BYTE [T + index]       ; al is 8 bit of char
        cmp al, bl                     ; char and index shouldn't be equal
        je exit_err

; only 2-length cycles in transpose
        cmp BYTE [T + char], bl
        jne exit_err

        dec index
        jns .whiling

        ret



        %define R r9
        %define R_rev r8
        %define L r13
        %define L_rev r12
        %define T r10

        %define rState r15
        %define lState r14

        %define size rbx               ; length for syscall is kept
        %define index rax
        %define char rcx

; For applying permutations macros are used in ecryption

        %macro PERMUTATE 1
        mov cl, BYTE [%1 + char]       ; cl is 8-bit of char
        %endmacro

        %macro Q 1
        xor edi, edi
        add cl, %1
        cmp cl, SPAN
        cmovge edi, esi
        sub cl, dil
        %endmacro

        %macro Q_INV 1
        xor edi, edi
        sub cl, %1
        cmovb edi, esi                 ; if carry flag is set
        add cl, dil
        %endmacro

        %macro add_in_range 2
        xor edi, edi
        add %1, 1
        cmp %1, %2
        cmovge edi, esi                ; if greater or equal then copy value
        sub %1, dil
        %endmacro



encrypting:
        xor index, index
        xor char, char
        mov esi, SPAN
.enc_whiling:
        add_in_range r15b, SPAN        ; 8-bit of rState

        cmp rState, 'L' - BCHAR
        je .inc_left
        cmp rState, 'R' - BCHAR
        je .inc_left
        cmp rState, 'T' - BCHAR
        je .inc_left

        jmp .jump_over
.inc_left:
        add_in_range r14b, SPAN

.jump_over:

        mov cl, BYTE [buf + index]
        sub cl, BYTE BCHAR
        js exit_err
        cmp char, SPAN
        jge exit_err

        Q r15b
        PERMUTATE R
        Q_INV r15b
        Q r14b
        PERMUTATE L
        Q_INV r14b
        PERMUTATE T
        Q r14b
        PERMUTATE L_rev
        Q_INV r14b
        Q r15b
        PERMUTATE R_rev
        Q_INV r15b

        add cl, BCHAR
        mov BYTE [buf + index], cl

        inc index
        cmp index, size
        jne .enc_whiling
        jmp finished_enc



        %define read_into rsi
_start:
        cmp QWORD [rsp], 5             ; checking argcount
        jne exit_err

        mov read_into, [rsp + 2*8]     ; Miss the first arg (path)
        lea rbx, [rel Left_bar]
        call _check_normalize
        mov L, read_into
        mov L_rev, rbx

        mov read_into, [rsp + 3*8]
        lea rbx, [rel Right_bar]
        call _check_normalize
        mov R, read_into
        mov R_rev, rbx

        mov read_into, [rsp + 4*8]
        add rbx, SPAN
        call _check_normalize
        mov T, read_into               ; reverse of transposition is not necessary
        call transpose_checking

        mov read_into, [rsp + 5*8]
        call key_checking

.input_whiling:
; Get input
        xor eax, eax
        call _getInput

        cmp rax, 0                     ; syscall checking
        mov size, rax
        jg encrypting                  ; based on flags in cmp
        js exit_err                    ; less than 0 is error
        jmp exit_0                     ; EOF reached

finished_enc:

; Print result
        xor eax, eax
        call _printRes

        cmp rax, 0                     ; syscall checking
        js exit_err
        jmp _start.input_whiling



_getInput:
        mov rax, 0                     ; 0 is the id of SYS_READ
        mov rdi, 0                     ; STDIN file_descriptor is 0
        mov rsi, buf
        mov rdx, BUF_SIZE              ; holding the length for syscall
        syscall
        ret

_printRes:
        mov rax, 1                     ; 1 is the id of SYS_WRITE
        mov rdi, 1                     ; STDOUT file_descriptor is 1
        mov rsi, buf
        mov rdx, size                  ; Holds the length for syscall to print
        syscall
        ret

exit_err:
        xor eax, eax
        mov edi, 1                     ; Return code is 1
        mov eax, 60                    ; SYS_EXIT id is 60
        syscall

exit_0:
        xor eax, eax
        mov edi, 0                     ; Return code is 0
        mov eax, 60
        syscall


section .bss
Left_bar: resb 42
Right_bar: resb 42
buf: resb BUF_SIZE
