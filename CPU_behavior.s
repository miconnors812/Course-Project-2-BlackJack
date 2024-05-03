base:
    db 0xff
chances:
    db [0x00, 3] ;chances in the order:
                 ;bet/stand, draw/hit, fold

cpu_action:
start:
    ;CALL rand_int ;assume rand in ax
    mov ax, 0x0189 ;TEMP
    mov bx, 0x64
    div bx ;rolled percent in dl
    mov bp, offset chances
    mov di, 0x00
compare_bet:
    mov dh, byte [bp, di] ;bet chance section
    cmp dl, dh
    jle cpu_bet
compare_draw:
    inc di
    mov ch, byte [bp, di] ;draw chance section
    add dh, ch
    cmp dl, dh
    jle cpu_draw
    ;otherwise jump to fold
cpu_bet:
    ;stand and bet
cpu_draw:
    ;CALL draw_card
cpu_fold
    ;fold, player wins the round