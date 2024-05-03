; CS-274
; Michael Connors
;
; Lab 7: Random numbers

base:
    db 0xff
X0:
    dw 0xff01  ; The seed to change for different results
    ;dw 0x0002
a:
    dw 0xCDE7
    ;dw 0x0004
m: 
    dw 0xfff1
    ;dw 0x0007
Xk:
    dw 0x0000
    ;dw 0x0017
Xk2:
    dw 0x0000

def _rand_num {
    ;lea bx, word Xk
    ;lea cx, word a
    ;lea dx, word m
    ;mov ax ;Xk mod m
    ;div cx
    
    mov dx, word Xk2
    mov ax, word Xk 
    mov cx, word m
    mov bx, word a
    div cx ;dx:ax (0:Xk) / cx (m) --> Xk / M
    mov cx, dx ;remainder to mult spot
    mov ax, word a ;a to be multiplied
    mul cx ;cx (remainder) * ax (a) = dx:ax (Xk+1)
    mov word Xk, ax ;changing Xk to be the rightmost half Xk+1
    mov word Xk2, dx  ;changing Xk2 to be the leftmost half of Xk+1
    mov cx, 0x0034 ; 0x0034 = 52
    div cx ; dx:ax (Xk+1) / cx (52)
    mov ax, word Xk ;procedure leaves ax as Xk
    ret
}



start:
    mov ax, word X0
    mov word Xk, ax
    call _rand_num
    ;mov ax, cx
    
    ;mov cx, 0x0034
    ;div cx
    
    mov bh, 0x30
    add dl, bh
    ;mov dl, 0x33
    mov ah, 0x02
    int 0x21
    
    ; I know I could've used a loop here but whatever
    call _rand_num
    mov bh, 0x30
    add dl, bh
    mov ah, 0x02
    int 0x21
    
    call _rand_num
    mov bh, 0x30
    add dl, bh
    mov ah, 0x02
    int 0x21

    

