; CS-274
; Michael Connors
;
; Lab 7: Random numbers

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


start:
    mov ax, 0x00
    ;check + remove card
    ;take in suite, value
    ;offset = suite(base idx 0) * 2
    ;check if >8, chose correct word
    ;set checkval 0x01, lshift to index correctly
    ;bitwise and to check if card is there
    ;if not, try again
    ;if it is, remove it by:
    ;bitwise and with bitwise NOT(checkval)