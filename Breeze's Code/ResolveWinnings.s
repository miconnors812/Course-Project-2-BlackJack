base:
    db 0xff
funds:
    dw [0x00a0, 2] ;full word for human, cpu funds
stake:
    dw [0x0000] ;bet for current hand
win_msg:
    db "you won :) "
lose_msg:
    db "you lost :("

resolve_hand:
start:
    
    mov ax, 0x02
    mov bx, 0x03
    sub ax, bx
    ;compare hands and distribute winnings
    ;after both players are done drawing cards
    ;assume ah = player hand, al = cpu hand
    ;assume busts over 21 are caught previously
    mov ax, 0x0a09  ;TMP
    cmp ah, al
    je endturn ;skip funds if tied
    ;load player funds to bx, cpu to cx, bet to dx
    mov di, offset funds
    mov bx, word [di] 
    inc di
    mov cx, word [di]
    mov di, offset stake
    jl cpu_win
player_win:
    ;add stake to player at bx, sub from cpu at cx
    add bx, dx
    sub cx, dx
    jmp checkfunds
cpu_win:
    ;add stake to cpu at cx, sub from player at bx
    add cx, dx
    sub bx, dx
checkfunds:
    jns endturn ;if no player below 0, next turn
end_round:
    ;player that won this hand wins
    cmp ah, al
    jl cpu_victor
player_victor:
    mov bp, offset win_msg
    jmp print_msg
cpu_victor:
    mov bp, offset lose_msg
print_msg:
    mov di, 0x00
    mov ah, 0x02
    mov cx, 0x000b
print_loop:
    mov dl, byte [bp, di]
    int 0x21
    inc di
    cmp di, cx
    jge end_print
    jmp print_loop
end_print:

endturn:
    ;goto next hand/return
end_game:
    ;terminate program
