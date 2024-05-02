base:
    db 0xff
decks:
    ;set decks to full
    db [0x1F] ;value of card in decending order
    db [0xFF] ;values over 13 ommitted
    db [0x1F] ;four suites
    db [0xFF]
    db [0x1F]
    db [0xFF]
    db [0x1F]
    db [0xFF]
curr_card:
    db [0xCC, 2] ;word for storing current card,
        ;suite followed by value (both base 0)

draw_card:
start:
    ;CALL randint
    
    ;assuming random int in ax
    ;leave suite, value to dh, dl
    ;TEMP INT FOR TESTING IN AL
    mov al, 0x49
    mov bl, 0x34
    ;end tmp
    div bl ;puts our card idx in dx
    mov al, ah
    mov dl, ah
    mov bl, 0x0D ;d13
    div bl ;convert to value and suite
        ;error on this div, overflow?
        ;suite val in al far too high
    mov dh, al ;suite in dh
    mov dl, ah ;val in dl
    ;save card to curr_card
    mov word [di], dx
    ;check + remove card
    mov dh, 0x00 ;FIXED VAL FOR TESTING
    ;offset = suite(base idx 0) * 2
    shl dh, 0x01
    mov dh, bl
    mov bh, 0x00
    mov di, bx
    
    ;check if val >7 (base 0)
    mov cl, 0x07
    cmp dl, cl
    jg skip_inc
    inc dh ;target next index if lower val,
            ;higher vals stored in first idx
    ;then correct for this adjustment
    sub dl, 0x08
skip_inc:
    mov bp, OFFSET decks
    ;set checkval at bl = 0x01, lshift to index correctly
    mov bl, 0x01
    mov cl, dl
    shl bl, cl
    ;load relevant deck byte to al
    mov al, dh
    mov ah, 0x00
    
    mov di, ax
    mov al, byte [bp, di]
    ;bitwise AND to check if card is there
    and al, bl
    cmp al, bl
    ;if not, try again
    jne draw_card
    
    ;if it is, remove it by:
    ;bitwise and with bitwise NOT(checkval)
    mov al, byte [bp, di]
    not bl
    and al, bl
    mov byte [bp, di], al
    