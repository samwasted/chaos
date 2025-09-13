org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
    jmp main

;
; Prints a string to the screen
; Params:
;   - ds:si points to string
;
puts:
    push si
    push ax
    push bx

.loop:
    lodsb               ; AL = [DS:SI], SI++
    or al, al
    jz .done

    mov ah, 0x0E        ; teletype BIOS
    mov bh, 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret

main:
    ; setup data segments
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; setup stack (leave some room so pushes don't clobber code)
    mov ss, ax
    mov sp, 0x7A00      ; safer: stack at 0x0000:0x7A00 (leaves 0x200 bytes)

    ; print hello world message
    mov si, msg_hello
    call puts

    cli
    hlt

.halt:
    cli
.halt_loop:
    hlt
    jmp .halt_loop

msg_hello: db 'Hello world!', ENDL, 0

times 510-($-$$) db 0
dw 0AA55h
