; NASM assembly x64, lab 3 (lab 2 with signs)
;
; nasm -f elf64 lab3.asm && ld -o lab3 lab3.o
;
%define STDIN	    dword 0
%define STDOUT	    dword 1
%define BUFSIZE     256

section .data

    string_one:         db                      '1-st number: ', 0
	string_two:         db                      '2-nd number: ', 0
    string_three:       db                      '3-rd number: ', 0
	string_four:        db                      '4-th number: ', 0
    string_res:         db                      'result: ', 0
    string_error:       db                      'Invalid number, try again: ', 0
    string_overflow:    db                      'Integer number too large, please, enter another num(s): ', 0
    ten: 		        dw 	                	10
    nl:                 db                      10, 0

    
section .bss
    var_one             resb                    256
    var_two             resb                    256
    var_three           resb                    256
    var_four            resb                    256
    output_buffer       resb                    1
    readbuf 	        resb 	                BUFSIZE ; buffer for read operations

section .text
    global _start

    _start:

    mov     rsi, string_one
    call    print

    ; reads first num
    call    readint
    mov     [var_one], rax
    
    mov     rsi, string_two
    call    print

    ; reads second num 
    call    readint
    mov     [var_two], rax 

    mov     rsi, string_three
    call    print

    ; reads third num
    call    readint
    mov     [var_three], rax 

    mov     rsi, string_four
    call    print

    ; reads fourth num
    call    readint
    mov     [var_four], rax 

    call    calculate

    call    output

    ; exit 
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
    
    ; rax checknumber(rsi) - 1 if number in ESI, 0 if not
    checknumber:
	push 	rsi

	mov 	rax, rsi

	cmp 	byte [rsi], '-'
	jne 	checknumber.checkplus

		inc 	rsi
		inc 	rax

        jmp checknumber.loopy

    .checkplus:
    cmp 	byte [rsi], '+'
	jne 	.loopy

		inc 	rsi
		inc 	rax
    

	.loopy:
		cmp 	byte [rax], 0 ; if met end
		je 		checknumber.exityes

		 cmp 	byte [rax], 0xA ; if met newline
		 je 		checknumber.exityes

		cmp 	byte [rax], '0'
		jl 		checknumber.exitno

		cmp 	byte [rax], '9'
		jg 		checknumber.exitno

		inc 	rax
		jmp 	checknumber.loopy

	.exityes:
		cmp 	rax, rsi
		mov 	rax, 1
		jne 	checknumber.exit

	.exitno:
		mov 	rax, 0

	.exit:
	pop 	rsi
	ret

    ; void print(rsi) - prints buffer at ESI
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
    mov       rsi, readbuf            ; address of string to input
	mov       rdx, BUFSIZE            ; number of bytes
    syscall     
	ret

    ; rax calculate(var_one, var_two, var_three , var_four) - calculates expression (see description)
    calculate:

    mov     ax, [var_one]
    mov     cx, [var_three]

    imul    cx        ;ax = a*c
    mov     bx, ax   ;bx = a*c

    mov     ax, [var_two]
    mov     cx, [var_four]
    
    imul    cx        ;ax = b*d
    add     bx, ax   ;bx = a*c + b*d
    push    bx
    mov     ax, [var_one]
    
    imul    cx        ;ax = a*d
    mov     bx, ax   ;DX = a*d
    mov     ax, [var_two]
    mov     cx, [var_three]
    imul    cx        ;ax=b*c
    add     bx, ax   ;DX = a*d + b*c
    mov     ax, [var_one]
    mov     cx, bx
    pop     bx

    cmp     bx, cx   ;if (a*c + b*d == a*d + b*c)
    jnz     else1        ;if they are not equal, go to label else1
        mov     bx, [var_two]
        cmp     ax, bx
        jng     else2     ;if a < b, go to label else2
            imul    ax ;print a^2    
            ret
        else2:
            mov     cx, [var_three]
            cmp     ax, cx
            jng     else3 ;if a < c, go to label else3
                ;print ((c AND b) + min (a, b, c)/(a^2-c))
                call findmin
                push    ax
                mov     ax, [var_one]
                imul    ax
                sub     ax, cx          ;ax = a^2-c
                and     cx, bx          ;cx = c and b
                mov     bx, ax
                pop     ax              ;min(a,b,c)
                cwd
                idiv    bx
                add     ax, cx
                ret
            else3:
                or      bx, cx
                sub     ax, bx ;a-(b or c)
                ret
    else1:
    
        mov     ax, [var_one]
        mov     cx, [var_four]

        ;mov     rdx, 0
        cwd
        ;mov ah, 0
        ;mov dl, 0

        idiv     cx                       ;a/d
        ret
    
    ; rax findmin(a, b, c) - finds minimal num
    findmin:
        cmp     ax, bx
        jg      findmin.comp_b_c         ;if a > b, go to label comp_b_c
            cmp     ax, cx
            jg      findmin.min_c        ;if a > c, go to min_c
            ret
        .comp_b_c:
            cmp     bx, cx
            jg      findmin.min_c        ;if b > c go to min_c
            mov     ax, bx
            ret
        .min_c:
            mov     ax, cx
            ret


    ; void output(rax) - prints result
    output:
    jo      output.fail
    mov     [output_buffer], rax

    ; result
    mov     rsi, string_res
    call    print

    mov     rax, [output_buffer]
    mov     rdi, readbuf
    call    itoa
    mov     rsi, rdi
    call    print
    mov     rsi, nl
    call    print
    ret

    .fail:
    mov     rsi, string_overflow
    call print
    mov     rsi, nl
    call    print
    jmp _start


    ; rax atoi(esi) - converts string at ESI to number at EAX
    atoi:
    push 	rsi
	push 	rcx
	push 	rbx
	push 	rdx

	call 	strlen
	mov 	rcx, rax

	mov 	rdx, 0 ; is negative
	mov 	rax, 0
	mov 	rbx, 0
    
	cmp 	byte [rsi], '-'
	jne 	.checkplus

		inc 	rsi
		dec 	rcx

		mov 	rdx, 1

        jmp .loopy

    .checkplus:
    cmp 	byte [rsi], '+'
	jne 	.loopy

		inc 	rsi
		dec 	rcx

	.loopy:
		movzx 	rcx, byte [esi] ; get a character
		inc 	esi ; ready for next one
		cmp 	rcx, '0' ; valid?
		jb 		.continue
		cmp 	rcx, '9'
		ja 		.continue
		sub 	rcx, '0' ; "convert" character to number
		imul 	rax, 10 ; multiply "result so far" by ten
		add 	rax, rcx ; add in current digit
		loop 	.loopy

    .continue:
	cmp 	rdx, 0
	je  	.finish
    neg     rax

	.finish:
	pop 	rdx
	pop 	rbx
	pop 	rcx
	pop 	rsi
	ret
	

    ; rdi itoa(rax) - convert number from EAX and store it to EDI
    itoa:
	push 	rdi
	push 	rdx
	push 	rcx
	push 	rbx
	push 	rax

	mov 	rcx, 0
	mov 	rbx, 0 ; is negative

	test 	ax, ax
	jns  	.loopy
        neg     rax
		inc 	rcx
        mov     rbx, 1

	.loopy:
		inc 	rcx
		mov 	rdx, 0
		idiv 	word [ten]
		add 	rdx, '0'
		push 	rdx
		cmp 	rax, 0
		jg  	.loopy

	cmp 	rbx, 0
	je  	.loopo

	push     '-'

	.loopo:
		pop 	rax
		mov 	[rdi], al
		inc 	rdi
		loop 	.loopo

	mov 	[rdi], byte 0;

	pop 	rax
	pop 	rbx
	pop 	rcx
	pop 	rdx
	pop 	rdi
	ret 

    readint:
		;mov 	rdi, readbuf
		;mov 	rax, BUFSIZE
		call 	read

		mov 	rsi, readbuf
		call 	checknumber

		cmp 	rax, 0
		jne 	.success

		mov 	rsi, string_error
		call 	print

		jmp 	readint

	.success:
	mov 	rsi, readbuf
	call 	atoi
    cmp     rax, 0
    jz      .zero_fail
    cmp     rax, 0xFFFF
    jg      .overflow
	ret

    .overflow:
    mov     rsi, string_overflow
    call print
    mov     rsi, nl
    call    print
    jmp readint

    .zero_fail:
    mov     rsi, string_error
    call    print
    mov     rsi, nl
    call    print
    jmp readint