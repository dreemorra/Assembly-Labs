; NASM assembly x64, lab 4
;
; nasm -f elf64 lab4.asm && ld -o lab4 lab4.o
;
; read string from console, delete vowels and display result in console
;
%define BUFSIZE     4096

section .data

    string_input:         db                      'Please, enter text: ', 0
    string_res:           db                      'Result: ', 0
    nl:                   db                      10, 0
    letters:              db                      'aeiouyAEIOUY', 0

section .bss
    output              resb                    8
    input               resb                    BUFSIZE
    buffer   	        resb 	                BUFSIZE ; buffer for read operations

section .text
    global _start

    _start:

    mov     rsi, string_input
    call    print

    call    read

    mov     rsi, string_res
    call    print

    call    delete_letter

    mov     rsi, nl
    call    print

    mov     rsi, nl
    call    print

    xor     rbx, rbx
    mov     rax, 1
    int     80h


    strlen:
	mov 	rax, rsi

	.nextchar:
		cmp 	byte [rax], 0
		je 		strlen.finished
		inc 	rax
		jmp 	strlen.nextchar

	.finished:
		sub 	rax, rsi
		ret

    print:
	call	strlen

	mov       rdx, rax                 ; number of bytes
	mov       rax, 1                   ; system call for write
	mov       rdi, 1                   ; file handle 1 is stdout
    ;mov       rsi, message            ; address of string to output
    syscall     
	ret

    ; rax read(rdi) - reads from terminal at EDI, rax shows how many was read
    read:
	mov       rax, 0                  ; system call for read
	mov       rdi, 0                  ; file handle 0 is stdin
    mov       rsi, input              ; address of string to input
	mov       rdx, BUFSIZE            ; number of bytes
    syscall     
    mov 	byte [rsi + rax - 1], 0 ; remove linefeed
	ret

    ;delete letter from input string and store result in output string
    delete_letter:
    push    rcx
    push    rsi

    mov     rsi, input

    call strlen
    mov     rdx, rax
    .loo:                                       ; for( ; rsi != '\0'; inc rsi)
    cmp     rdx, 0
    je      .fin

    mov     rcx, 12
    mov     rdi, 0
    mov     rdi, letters
    .check:                                     ; for(rcx = 12; rcx > 0; dec rcx)
    mov     bl, byte [rdi]
    cmp     byte [rsi], bl                      ;   if([rsi] == letters[rcx]) {
    je      .delete                             ;       call delete
    inc     rdi                                 ;       break;}
    loop    .check                              ;   else continue
    mov     al, byte [rsi]
    mov     [output], al
    inc     rsi
    call    append
    .break:
    dec     rdx
    jmp     .loo

    .fin:
    pop     rsi
    pop     rcx
    ret

    ;delete letter shifting string left by 1
    .delete:
        push    rsi
        push    rbx
        push    rcx

        call    strlen
        mov     rcx, rax
        mov     rdi, buffer
        .loopy:
        mov     bl, byte [rsi+1]
        mov     byte [rsi], bl           ; shift left by 1
        movsb
        loop    .loopy
    
        .exit:
        
        mov     rsi, rdi

        pop     rcx
        pop     rbx
        pop     rsi
        jmp     .break

    ;void append - prints symbol
    append:
    push    rsi
    push    rdx
    push    rax
    push    rdi

    mov     rsi, output
    call    print
    
    pop     rdi
    pop     rax
    pop     rdx
    pop     rsi
    ret