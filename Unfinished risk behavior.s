; CS-274
; Michael Connors
;
; CP 2: Computer Risk Behavior
base:
    db 0xff
phrase1:
    db 0xff     ; Maximum value to read
    db 0x00     ; Actual value read after INT
    db [0x00, 0x03] ; Buffer of the right size  
                    ; First value: filler
                    ; Second value: number of bytes
end_phrase:
    db 0xff
chances:
    db [0xaa, 0x03] ; Array to hold 3 chance values 
                    ; First value: filler
                    ; Second value: number of bytes
end_chances:
    db 0xff                 
                
len:
    db 0x00

start:
    mov di, OFFSET chances
    dec di          ;it's one off from the start for some reason

_take_input:
    ; initializing the buffer
    mov ah, 0x0a
	lea dx, word phrase1
	int 0x21
	
	lea bp, word phrase1
    ;lea bx, word end_phrase
    mov si, 1       ; length of string at index si in bp
    ;mov ax, 0
    ;mov bl, byte [bp, si]
    ;add bl, 2
    ;inc bl
    mov bl, 5
    inc si
    mov dx, 0
    jmp _get_integer
    
_get_integer:
    cmp si, bx
    jge _exit_input
    mov cl, byte [bp, si] 
    cmp cl, 0x30
    jl _skip        ; ignore ASCII values lower than 30, which is the number 0
    cmp cl, 0x40
    jge _skip        ; ignore ASCII values greater than 39, which is the number 9
    sub cl, 0x30      ; convert ASCII to hexadecimal int
    ;sub si, 2       ; temporary pointer conversion for equation
    mul dx
    add ax, cx
    inc si
    mov dx, 0x0a
    jmp _get_integer
    
_skip:

    ; skip past non-integer values
    inc si
    jmp _get_integer
    
_exit_input:
    mov byte [bp, di], al
    inc di
    cmp di, 0x0a
    jl _take_input
    

    

;_loop:
    
_exit_loop:
    ;print here
    mov ax, 0
    MOV AH, 0x13	; move BIOS interrupt number
    MOV CX, 3	    ; move string length
    MOV BX, 0
    ;lea bx, word end_phrase		; move 0 to bx
    ;add bx, 0x2
    MOV ES, BX		; move segment to start of string
    MOV DX, OFFSET chances
    ;ADD DX, 2
    MOV BP, DX	;move start offset of string
    MOV DX, 0		;start writing from col 0
    int 0x10		; BIOS interrupt
