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
    db [0x00, 0x03] ; Array to hold 3 chance values 
                    ; First value: filler
                    ; Second value: number of bytes
end_chances:
    db 0xff
incorrect_input:
    db "Input a smaller value, risk level exceeded 100%."
                
len:
    db 0x00

start:
    mov di, OFFSET chances
    dec di          ;it's one off from the start for some reason

_take_input:        ; take a number from the user a possible risk level factor
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
    jge _sum_100       ; CHANGE OCCURED HERE SINCE LAST VERSION
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
 
_sum_100:
    mov si, OFFSET chances  ; 1 too large
    mov al, byte [bp, si]
    inc si
    add al, byte [bp, si]
    inc si
    add al, byte [bp, si]
    ; see if all 3 numbers add up to 100
    cmp al, 0x64
    jle _exit_input
    jmp _wrong_input
    
_wrong_input:
    
    ;print prompt here
    mov ax, 0
    MOV AH, 0x13	; move BIOS interrupt number
    MOV CX, 48	    ; move string length
    MOV BX, 0
    ;lea bx, word end_phrase		; move 0 to bx
    ;add bx, 0x2
    MOV ES, BX		; move segment to start of string
    MOV DX, OFFSET incorrect_input
    ;ADD DX, 2
    MOV BP, DX	;move start offset of string
    MOV DX, 0		;start writing from col 0
    int 0x10		; BIOS interrupt
    jmp _take_input ;ask for input again 

    
_exit_input:    ;change name to save_chance or smth 
    cmp al, 0x64
    jg _wrong_input
    mov byte [bp, di], al
    inc di
    cmp di, 0x0a
    jl _take_input
    

;_loop:
    
_exit_loop:
    ;print here
    mov ax, 0
    MOV AH, 0x13	; move BIOS interrupt number
    MOV CX, 60	    ; move string length
    MOV BX, 0
    ;lea bx, word end_phrase		; move 0 to bx
    ;add bx, 0x2
    MOV ES, BX		; move segment to start of string
    MOV DX, OFFSET chances
    ;ADD DX, 2
    MOV BP, DX	;move start offset of string
    MOV DX, 0		;start writing from col 0
    int 0x10		; BIOS interrupt
