; NASM assembly x64, lab 1
;
; nasm -f elf64 lab1.asm && ld -o lab1 lab1.o
;
; if (a*c + b*d = a*d + b*c)
;   if (a > b)
;       result = a^2
;   else if (a > c)
;       result = (c && b) + min(a, b, c)/(a^2 - c)
;        else result = a - (b OR c)
; else result = a/d
        

section .data

    ;result = (c && b) + min(a, b, c)/(a^2 -c)
    a:                  dw                      10
    b:                  dw                      11
    c:                  dw                      9
    d:                  dw                      9

    ;result = a^2
    ;a:                  dw                      8
    ;b:                  dw                      7
    ;c:                  dw                      4
    ;d:                  dw                      4

    ;result = a - (b OR c)
    ;a:                  dw                      7
    ;b:                  dw                      9
    ;c:                  dw                      8
    ;d:                  dw                      8
    
    ;result = a/d
    ;a:                  dw                      8
    ;b:                  dw                      6
    ;c:                  dw                      4
    ;d:                  dw                      2

section .text
    global _start

    _start:

    mov     ax, [a]
    mov     cx, [c]

    mul     cx        ;ax = a*c
    mov     bx, ax   ;bx = a*c

    mov     ax, [b]
    mov     cx, [d]
    mul     cx        ;ax = b*d
    add     bx, ax   ;bx = a*c + b*d
    push    bx
    mov     ax, [a]
    
    mul     cx        ;ax = a*d
    mov     bx, ax   ;DX = a*d
    mov     ax, [b]
    mov     cx, [c]
    mul     cx        ;ax=b*c
    add     bx, ax   ;DX = a*d + b*c
    mov     ax, [a]
    mov     cx, bx
    pop     bx

    cmp     bx, cx   ;if (a*c + b*d == a*d + b*c)
    jnz     else1        ;if they are not equal, go to label else1
        mov     bx, [b]
        cmp     ax, bx
        jng     else2     ;if a < b, go to label else2
            imul     ax ;print a^2    
            jmp     end
        else2:
            mov     cx, [c]
            cmp     ax, cx
            jng     else3                 ;if a < c, go to label else3
                ;print ((c AND b) + min (a, b, c)/(a^2-c))
                call    findmin
                push    ax
                mov     ax, [a]
                mul     ax
                sub     ax, cx          ;ax = a^2-c
                and     cx, bx          ;cx = c and b
                mov     bx, ax
                pop     ax              ;findmin
                div     bx
                add     ax, cx
                jmp     end
            else3:
                or      bx, cx
                sub     ax, bx ;a-(b or c)
                jmp     end
    else1:
        mov     ax, [a]
        mov     cx, [d]
        div     cx     ;a/d
        jmp     end
    

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
                

    end:
    mov eax, 1      
    xor ebx, ebx    
    int 80h         