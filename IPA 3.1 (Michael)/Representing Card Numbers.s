; CS-274
; Michael Connors
;
; CP 2: Representing Cards Onscreen
base:
    db 0xff
spade:
    db "Spades"
heart:
    db "Hearts"
diamond:
    db "Diamonds"
club:
    db "Clubs"
of:
    db "of"
ace:
    db "Ace"
jack:
    db "Jack"
queen:
    db "Queen"
king:
    db "King"
;your:
;    db "Your"
;opponents:
;    db "Computer's"
;deck:
;    db "Deck:"
    
def card_cont { 
    
    ;print the word of
    mov ah, 0x13	; move BIOS interrupt number
    mov cx, 2		; move string length
    mov bx, 0		; move 0 to bx
    mov es, bx		; move segment to start of string
    mov bp, OFFSET of	;move start offset of string
    mov dl, 0		;start writing from col 0
    int 0x10		; BIOS interrupt

    
    cmp dh, 0x0
    je _spade
    
    cmp dh, 0x1
    je _heart
    
    cmp dh, 0x2
    je _diamond
    
    cmp dh, 0x3
    jge _club
   
    ret
    }
    
def print_card {
    cmp dl, 0x0
    je _ace         ; print word for ace
    
    cmp dl, 0x0b
    je _jack        ; print word for jack
    
    cmp dl, 0x0c
    je _queen       ; print word for queen

    cmp dl, 0x0d
    jge _king        ; print word for king
    
    ;mov dl, bh
    add dl, 0x30    ; otherwise, convert to ascii
    mov ah, 0x2
    int 0x21        ; print number
    call card_cont  
    ret
    }
    
;def show_decks {
    
    ;print "your"
    ;print "deck"
    ;get card deck from memroy???
    ;call print_card
    ;print "computer's"
    ;print "deck"
    ;also pull from computer's own deck in memory
    
;}

def string_print {
    ; bp and cx should already be set to offset and length respectively
    mov ah, 0x13	; move BIOS interrupt number
    mov bx, 0		; move 0 to bx
    mov es, bx		; move segment to start of string
    mov dl, 0		;start writing from col 0
    int 0x10		; BIOS interrupt
    ret
    }
    
start:
    ;bring in 2 random numbers, one ranging from 0-3 and another ranging from 0-12.
    mov dh, 0x01     ;dh determines suit    0 = spade, 1 = heart, 2 = diamond, 3 = club
    mov dl, 0x0b    ; dl determines card #
    call print_card
    
    mov dh, 0x00     ;dh determines suit
    mov dl, 0x07    ; dl determines card #
    call print_card
    
    mov dh, 0x04     ;dh determines suit
    mov dl, 0x00    ; dl determines card #
    call print_card
    
    jmp _exit_loop
    
; these just set bp to the respective string and set cx to its length
_ace:
    mov bp, OFFSET ace
    mov cx, 3
    call string_print
    call card_cont
    ret
    
_jack:
    mov bp, OFFSET jack
    mov cx, 4
    call string_print
    call card_cont
    ret
    
_queen:
    mov bp, OFFSET queen
    mov cx, 5
    call string_print
    call card_cont
    ret
    
_king:
    mov bp, OFFSET king
    mov cx, 4
    call string_print
    call card_cont
    ret
    
_spade:
    mov bp, OFFSET spade
    mov cx, 6
    call string_print
    ;jmp _exit_loop
    ret
    
_heart:
    mov bp, OFFSET heart
    mov cx, 6
    call string_print
    ;jmp _exit_loop
    ret
    
_diamond:
    mov bp, OFFSET diamond
    mov cx, 8
    call string_print
    ;jmp _exit_loop
    ret
    
_club:
    mov bp, OFFSET club
    mov cx, 5
    call string_print
    ;jmp _exit_loop 
    ret

_exit_loop:
    ;ret