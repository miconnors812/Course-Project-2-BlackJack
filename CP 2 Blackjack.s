; CS-274
; Michael Connors & Breeze Tucker
;
; CP 2: Blackjack against a Computer Opponent
base:
    db 0xff
; next four are for random number generation
a:
    dw 0xCDE7
m: 
    dw 0xfff1
Xk:
    dw 0xff00  ; The initial seed to change for different results
Xk2:
    dw 0x0000
welcome:
    db "Welcome to Blackjack!"
begin:
    db "Let's Begin!"
invalid_input:
    db "Invalid input, try again"
praise:
    db "Nice job!"
scold:
    db "Tough luck!"
invalid_risk:
    db "Risk exceeded 100%, it must be less than or equal to 100. Try again"
all_in:
    db "You went all in!"
kept_hand:
    db "You kept your hand!"
add_hand:
    db "You drew another card!"
forfeit_hand:
    db "You forfeited your turn!"
cpu_kept:
    db "Computer kept their hand!"
cpu_add:
    db "Computer drew another card!"
cpu_forfeit:
    db "Computer forfeited their turn!"
hand:
    db "Your hand:"
comp_hand:
    db "Computer's hand:"
ai_bet:
    db "Computer's bet:"
ask_starting_cash:
    db "Input Starting Cash (10-1000):"
ask_num_decks:
    db "How many card decks? (1-3):"  
ask_bet:
    db "How much would you like to bet?" 
ask_betting_mode:
    db "Choose a computer betting mode:"
ask_risk:
    db "Input two numbers that must not exceed 100% for the computer risk level..."
ask_keep:
    db "Input the % chance for the computer to keep their current hand:"
ask_add:
    db "Input the % chance for the computer to add another card to their hand:"
display_forfeit:
    db "The remaining percent has been put into forfeit hand chance"
display_funds:
    db "Your remaining funds are..."
display_comp_funds:
    db "Computer's remaining funds are..."
specify_conserve:
    db "(Type 2 for Conservative)"
specify_normal:
    db "(Type 1 for Normal)"
specify_aggro:
    db "(Type 3 for Aggressive)"
display_choice:
    db "Choose one of the following actions..."
specify_keep:
    db "(Type 1 to keep your hand)"
specify_add:
    db "(Type 2 to add another card)"
specify_forfeit:
    db "(Type 3 to lose the current turn)"
ask_difficulty:
    db "Choose a Difficulty:"
specify_easy:
    db "(Type 2 for Easy)"
specify_hard:
    db "(Type 3 for Hard)"
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
win_msg:
    db "YOU WON!!!"
lose_msg:
    db "YOU LOST!!"
funds:              ;a full word per human & cpu funds
    dw [0xffff, 2]  
stake:
    dw 0x0000 ;bet for current hand
comp_stake:
    dw 0x0000 ;bet for computer hand
your_sum:
    db 0x00     ; your current hand's total value
comp_sum:
    db 0x00     ; computer's current hand total value
curr_card:
    db [0xCC, 2] ;word for storing current card,
        ;suite followed by value (both base 0)
num_decks:          ; number 1-3 to describe # of decks
    db 0xff         
difficulty:         ; number 1-3 to describe difficulty
    db 0xff         ; 1 = normal, 2 = easy (computer start $ div by 2), 3 = hard (computer start $ mul by 2)
betting_mode:       ; number 1-3 to describe betting mode (1=normal, 2=conservative, 3=aggressive)
    db 0xff         ; bet amount = user bet + (betting_mode * (user_bet / 10))
                    ; except its addition for hard and subtraction for easy
ascii_print:        ;printable version of an int, useful for user funds
    db [0x00, 4]
ascii_end:          ; end of ascii array
    db 0xff
                    
int_buffer:    ;*********** go to start address 3F0 to view this easily in memory ********
    db 0x04     ; Maximum amount of characters to read
    db 0x00     ; Actual value read after INT
    db [0x00, 0x04] ; Buffer of the right size  
                    ; First value: filler
                    ; Second value: number of bytes
end_int_buffer:
    db 0xff
char_buffer:    
    db 0x01     ; Maximum amount of characters to read
    db 0x00     ; Actual value read after INT
    db [0x00, 0x01] ; Buffer of the right size  
                    ; First value: filler
                    ; Second value: number of bytes
end_char_buffer:
    db 0xff
chances:
    db [0x00, 0x03] ; Array to hold 3 chance values that add up to 100%
                    ; First value: keep
                    ; Second value: add
                    ; Third value: forfeit
;decks:
    ;set decks to full
    ;db [0x1F] ;value of card in decending order
    ;db [0xFF] ;values over 13 ommitted
    ;db [0x1F] ;four suites
    ;db [0xFF]
    ;db [0x1F]
    ;db [0xFF]
    ;db [0x1F]
    ;db [0xFF]

def rand_num {
    ; generates a random number 0-51
    
    mov dx, word Xk2
    mov ax, word Xk 
    mov cx, word m
    ;mov bx, word a
    div cx                  ; dx:ax (0:Xk) / cx (m) --> Xk / M
    mov cx, dx              ; remainder to mult spot
    mov ax, word a          ; a to be multiplied
    mul cx                  ; cx (the remainder) * ax (a) = dx:ax (Xk+1)
    mov word Xk, ax         ; changing Xk to be the rightmost half Xk+1
    mov word Xk2, dx        ; changing Xk2 to be the leftmost half of Xk+1
    ;mov cx, 0x0034          ; 0x0034 = 52
    ;div cx                  ; dx:ax (which is Xk+1) / cx (which is 52)
    ;mov ax, word Xk         ; procedure leaves ax as Xk
    ;dx:ax is the randomized number
    ret
}
    
def string_print {
    ; bp and cx should already be set to offset and length respectively
    mov ah, 0x13	; move BIOS interrupt number
    mov bx, 0		; move 0 to bx
    mov es, bx		; move segment to start of string
    mov dl, 0		;start writing from col 0
    int 0x10		; BIOS interrupt
    ret
    }  
    
def int_print {
    ; print out whatever number the user put in the integer buffer
    
    mov bp, OFFSET int_buffer 
    add bp, 2       ;add 2 to bp to skip values that aren't from the user
    mov cx, 4
    mov ah, 0x13	; move BIOS interrupt number
    mov bx, 0		
    mov es, bx		; move segment to start of string
    mov dl, 0		;start writing from col 0
    int 0x10		; BIOS interrupt
    ret
    }
    
def new_line {
    ; print a blank line in order to separate text and made it easier to read
    ;mov cx, 0
    ;mov ah, 0x13	; move BIOS interrupt number
    ;mov bx, 0		; move 0 to bx
    ;mov es, bx		; move segment to start of string
    ;mov dl, 0		;start writing from col 0
    ;int 0x10		; BIOS interrupt
    
    mov dl, 0x0    ; otherwise, convert to ascii
    mov ah, 0x2
    int 0x21        ; print number
    
    ret
}

def ascii_reset {
    ; an input thats shorter than the previous one will automatically take on
    ; the last few digits of the old input, so we need to reset after each use

    ; reset the 4-char ascii code 
    lea bp, word ascii_print ; move to buffer
    mov si, 0
    mov byte [bp,si], 0x00  ; set it back to 0
    inc si                  ; next element in buffer
    mov byte [bp,si], 0x00  ; repeat until buffer is all 00s again
    inc si
    mov byte [bp,si], 0x00
    inc si
    mov byte [bp,si], 0x00
    
    ret
}
    
def int_to_ascii {
    ; ax is already set to the int to convert
    ; mov si, OFFSET ascii_end      was also done beforehand
    dec si          ; next digit since we start from end
    mov dx, 0       ; we don't want values messing up dx:ax in division
    mov cx, 0x0a
    div cx          ; dx = remainder, ax = rest of number
    add dl, 0x30    ; convert to ascii
    mov byte [si], dl    ; save ascii value

    cmp ax, 0x09
    jg _printable_int   ; loop if > 10
    
    dec si
    add al, 0x30 
    mov byte [si], al    ; save ascii value
    
    mov bp, OFFSET ascii_print
    add bp, 0       ;add 2 to bp to skip values that aren't from the user
    mov cx, 4
    mov ah, 0x13	; move BIOS interrupt number
    mov bx, 0		
    mov es, bx		; move segment to start of string
    mov dl, 0		;start writing from col 0
    int 0x10		; BIOS interrupt
    
    call ascii_reset
    ret
    
}
    
    
def _to_integer {
    ; converts a user inputted string into a single hexadecimal value.
    ; universal, can be used with any string as long as...
    ; bp points to buffer of choice (lea bp, word BUFFER_HERE)
    ; bx = the length of the string 
    
    
    mov cl, byte [bp, si] ; load byte at index si in bp into cl
    cmp cl, 0x30    
    jl _skip        ; ignore ASCII values lower than 30, which is the number 0
    cmp cl, 0x40
    jge _skip        ; ignore ASCII values greater than 39, which is the number 9
    sub cl, 0x30      ; convert ASCII to hexadecimal int
    mul dl         ; value so far in ax * 10  (ax is initially 0)
    add al, cl      ; add most recent digit taken from input
    inc si          ; move to next element in buffer
    mov dx, 0x0a    ; move 10 to get ready for next 10s place in number
    cmp si, bx              ; end of string reached?
    jl _call_get_int
    ret     
}

def int_buffer_reset {
    ; an input thats shorter than the previous one will automatically take on
    ; the last few digits of the old input, so we need to reset after each use

    ; reset the 4-char buffer and the length obtained from user input
    lea bp, word int_buffer ; move to buffer
    mov si, 1               ; start of buffer
    mov byte [bp,si], 0x00  ; set it back to 0
    inc si                  ; next element in buffer
    mov byte [bp,si], 0x00  ; repeat until buffer is all 00s again
    inc si
    mov byte [bp,si], 0x00
    inc si
    mov byte [bp,si], 0x00
    inc si
    mov byte [bp,si], 0x00
    
    ret
}



def input_int {     
    ; get 4-char long user input string, convert to integer
    ; useful for when the user has to input a number that could reach high like an amount of money
    
    ; use a buffer so they can input a number
    mov ah, 0x0a    ;for buffer
	lea dx, word int_buffer
	int 0x21
	; getting the end of the string to di
	
	;call int_print  ;remind the user what they inputted
	
    lea bp, word int_buffer
    inc bp  ;move past the 0xff that is only there to declare maximum read value
    lea bx, word end_int_buffer     ;get the end of the string
    mov cx, bp      ; move start of string to cx
    sub bx, cx      ; subtract start of string from end of string (EX: len = 117 - 114 = 3)
    mov ch, 0x0a       ; reseting cx for later equations
    mov ax, 0       ;reset previous values yhat might mess up equations
    mov si, 1   ; set as 1 because 1st character is string length so we can ignore that
    
    call _to_integer        ; string input --> integer
    
    
    call int_buffer_reset   ; set the buffer back to all 00s for the next use
    ;result is left in ax
    ret
}

def char_to_int {     
    ;  single char  user input converted to integer
    ; useful for when the user has to input a number that will never exceed 9
    ; saves time for decisions where the input correlates to certain events rather than integer values
    
    ; use a buffer so they can input a number
    mov ah, 0x0a    ;for buffer
	lea dx, word char_buffer
	int 0x21
	; getting the end of the string to di
    lea bp, word char_buffer
    inc bp  ;move past the 0xff that is only there to declare maximum read value
    lea bx, word end_char_buffer     ;get the end of the string
    mov cx, bp      ; move start of string to cx
    sub bx, cx      ; subtract start of string from end of string (EX: len = 117 - 114 = 3)
    mov ch, 0x0a       ; reseting cx for later equations
    mov ax, 0       ;reset previous values yhat might mess up equations
    mov si, 1   ; set as 1 because 1st character is string length so we can ignore that
    
    call _to_integer    ; string input --> integer
    
    ;result is left in ax
    ret
}



; =============================================================================
; these higher ones need to be above other procedures since they are universal,
; the rest are mainly one off procedures for progressing the game
; =============================================================================  


def card_cont {
    ;after printing the number, we need to print the card suit
    
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
    ; prints out the card suit and number in a easy to read way for the user
    ; this specific procedure prints the number then chains into the procedure to print the suit
    
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

def get_starting_money {

    ; ask them to declare the starting $$$
    mov bp, OFFSET ask_starting_cash
    mov cx, 30 ;0x15
    call string_print
    
    call input_int ; take user inputted string through a buffer and turn it into an int value
    
    cmp ax, 0x3E8  ;compare to 1000
    jg _invalid_cash
    cmp ax, 0x0a   ;compare to 10
    jl _invalid_cash
    
    ; set si to the location of funds in order to save in memory
    mov bp, OFFSET funds
    ; before equation, di = 0 is for human, di = 2 is for computer
    mov word [bp, di], ax  ; save value in funds if it meets above conditions
    ; using di here could cause problems later so return here if theres issues with di
    
    
    mov si, OFFSET ascii_end ; move to end of ascii string
    call int_to_ascii        ; convert hex to readable user cash amount
    ; It might seem inefficient to convert back to ascii when we already have the 
    ; user input, but later we will also need to print numbers that are hex values 
    
    
    ret
}

def get_num_decks {

    ; ask them to declare the # of decks
    mov bp, OFFSET ask_num_decks
    mov cx, 27
    call string_print
    
    call char_to_int ; take user inputted string through a buffer and turn it into an int value
    
    cmp al, 0x3  ;compare to 3
    jg _invalid_deck
    cmp al, 0x1   ;compare to 1
    jl _invalid_deck
    
    mov byte num_decks, al  ; save value in difficulty if it meets above conditions
  
    ; print out the input for user to see their own answer
    mov dl, al      ; move al into the spot for the interrupt
    add dl, 0x30    ; convert to ascii
    mov ah, 0x2     ; interrupt number
    int 0x21        ; print char

    ret
}

def get_bet_mode {

    ; ask them to declare the bet mode
    mov bp, OFFSET ask_betting_mode
    mov cx, 31 ;string length
    call string_print
    
    ; tell them 1 = normal
    mov bp, OFFSET specify_normal
    mov cx, 19 ;length
    call string_print
    
    ; tell them 2 = conservative
    mov bp, OFFSET specify_conserve
    mov cx, 25 ;string length
    call string_print

    
    ; tell them 3 = aggressive
    mov bp, OFFSET specify_aggro
    mov cx, 23 ;length
    call string_print
    
    call char_to_int ; take user inputted string through a buffer and turn it into an int value
    
    cmp al, 0x3  ;compare to 3
    jg _invalid_bet
    cmp al, 0x1   ;compare to 1
    jl _invalid_bet
    
    mov byte betting_mode, al  ; save value in bet mode if it meets above conditions
   
    ; print out the input for user to see their own answer
    mov dl, al      ; move al into the spot for the interrupt
    add dl, 0x30    ; convert to ascii
    mov ah, 0x2     ; interrupt number
    int 0x21        ; print char

    ret
}

def get_difficulty {

    ; ask them to declare the difficulty
    mov bp, OFFSET ask_difficulty
    mov cx, 20 ;string length
    call string_print
    
    ; tell them 1 = normal
    mov bp, OFFSET specify_normal
    mov cx, 19 ;length
    call string_print
    
    ; tell them 2 = easy
    mov bp, OFFSET specify_easy
    mov cx, 17 ;string length
    call string_print
    
    ; tell them 3 = hard
    mov bp, OFFSET specify_hard
    mov cx, 17 ;length
    call string_print
    
    call char_to_int ; take user inputted string through a buffer and turn it into an int value
    
    cmp al, 0x3  ;compare to 3
    jg _invalid_diff
    cmp al, 0x1   ;compare to 1
    jl _invalid_diff
    
    mov byte difficulty, al  ; save value in difficulty if it meets above conditions

    ; print out the input for user to see their own answer
    mov dl, al      ; move al into the spot for the interrupt
    add dl, 0x30    ; convert to ascii
    mov ah, 0x2     ; interrupt number
    int 0x21        ; print char

    ret
}

def get_risk_level {
    
    ; relay the entire prompt
    mov bp, OFFSET ask_risk
    mov cx, 74  ;long string length 
    call string_print
    
    
    
    ; Ask how much % chance to choose keep
    mov bp, OFFSET ask_keep
    mov cx, 63  ;long string length 
    call string_print
    
    call input_int ; turn it into an integer
    
    ; since we only have keep so far, we only need to compare one value
    cmp al, 0x65            ; compare keep chance to 100
    jge _invalid_risk        ; retry procedure if too big
    mov si, OFFSET chances  ; si at 1st slot in chances array
    mov byte [si], al       ; save keep %


    
    ; Ask how much % chance to choose add
    mov bp, OFFSET ask_add
    mov cx, 70  ;long string length 
    call string_print
    
    call input_int  ; turn it into an integer
    
    ; add up 2 values of chances, then check if they exceed 100
    mov si, OFFSET chances  ; go to 1st value in chances array
    mov bl, byte [si]       ; move 1st value to bx
    inc si                  ; move si to 2nd value
    add bl, al              ; add 2nd value to 1st in bx
    cmp bl, 0x65            ; compare result to 100
    jge _invalid_risk        ; retry procedure if too big
    mov byte [si], al       ; save 2nd value which is still in al
    
    
    
    ;calculate 3rd value and save 3rd values
    inc si                  ; move si to 3rd value
    mov al, 0x64            ; move al to 100 for remaining %
    sub al, bl              ; calculate 3rd value
    mov byte [si], al       ; automatically save 3rd value
    
    ; Tell them the rest is in forfeit
    mov bp, OFFSET display_forfeit
    mov cx, 59  ;long string length 
    call string_print
    
    
    ret
}

def user_config {
    ; welcome the player to the game
    mov bp, OFFSET welcome
    mov cx, 21 ;0x15
    call string_print  
    call new_line
    
    ; These next parts need their own procedure because a wrong input causes it to repeat the section
    ; comment any calls for quicker testing but make sure to uncomment later
    
    call get_starting_money
    call new_line
    
    call get_num_decks
    call new_line
    
    call get_bet_mode
    call new_line
    
    call get_risk_level
    call new_line
    
    call get_difficulty
    call new_line
    
    ret
    }
    
def draw_card {
    ; comments are kinda messy as our codes intertwine but generate a card and print it

    ; ax = random number
    call rand_num
    mov si, OFFSET curr_card
    ;assuming random int in ax
    ;leave suite, value to dh, dl
    ;TEMP INT FOR TESTING IN AL
    ;mov al, 0x49
    mov bl, 0x0d    ; 13
    ;end tmp
    div bx ;puts our card idx in dx
    ;mov al, ah
    ;mov dl, ah
    
    mov cl, dl  ; save num less than 13 for later
    
    mov bl, 0x04 ; 4
    div bx ;convert to value and suite
        ;error on this div, overflow?
        ;suite val in al far too high
    
    mov ch, dl ; save num less than 4 for later
    ;add cl, 255
    xchg cx, dx     ; move card # to dx
    ;mov dh, al ;suite in dh
    ;mov dl, ah ;val in dl
    ;save card to curr_card
    mov word [si], dx       ; dh = suit, dl = card num
    
    ; !!!!! the deck tracking part isn't working so it's commented out !!!!!!
    ;check + remove card
    ;mov dh, 0x00 ;FIXED VAL FOR TESTING
    ;offset = suite(base idx 0) * 2
    ;shl dh, 0x01
    ;mov dh, bl
    ;mov bh, 0x00
    ;mov si, bx
    
    ;check if val >7 (base 0)
    ;mov cl, 0x07
    ;cmp dl, cl
    ;jg skip_inc
    ;inc dh ;target next index if lower val,
            ;higher vals stored in first idx
    ;then correct for this adjustment
    ;sub dl, 0x08
    ;jmp skip_inc
    ret
}

def computer_cash {
    ; determine computer's funds based on difficulty and user inputted funds
    ; 1 = normal (computer matches your start, so do nothing)
    ; 2 = easy (computer start $ div by 2) 
    ; 3 = hard (computer start $ mul by 2)
    
    cmp byte difficulty, 0x2    ; make sure nothing sneaky happens
    jl _normal_funds
    
    cmp byte difficulty, 0x2
    je _easy_funds
    
    cmp byte difficulty, 0x2    ; make sure nothing sneaky happens
    jg _hard_funds
    
    ret
}

start:

    ;=========================
    ; START                  |
    ;=========================
  
    ;call draw_card         ; TESTING GAMEFLOW, COMMENT THESE LATER
    ;mov word stake, 0x64
    ;mov byte betting_mode, 0x2
    ;jmp _computer_bet

    mov di, 0   ; for determining turns, 0 = human & 2 = computer
    call user_config
    
    ;mov si, OFFSET funds        ; TESTING GAMEFLOW
    ;mov word [si], 0x3E8        ; COMMENT THESE LATER
    ;mov byte difficulty, 0x2
    ;mov byte betting_mode, 0x3
    ;jmp _deal_cards
    
    
    
    call computer_cash  ; get computer starting money
    
    ;call turn_loop
    
    ;def(?) _turn_loop:
    ; check turn requirements
    ; call user_turn
    ; go through various prompts and get user input throughout their turn
    ; user says no more or win/loss, jmp _exit_turn_loop
    
    ;jmp _end
    
    
    mov bp, OFFSET begin
    mov cx, 12 ;string length
    call string_print
    
    jmp _start_turn
    
_start_turn:
    ; show user funds
    mov bp, OFFSET display_funds
    mov cx, 27 ;string length
    call string_print
    
    ; print your fund number
    mov si, OFFSET funds
    mov ax, word [si]
    mov si, OFFSET ascii_end
    call int_to_ascii
    
    ; show computer funds
    mov bp, OFFSET display_comp_funds
    mov cx, 33 ;string length
    call string_print
    
    ;print comp funds
    mov bp, OFFSET funds
    mov di, 2
    mov ax, word [bp, di]
    mov si, OFFSET ascii_end
    call int_to_ascii
    mov di, 0
    
    call new_line
    
    ;ask how much they would like to bet
    mov bp, OFFSET ask_bet
    mov cx, 31 ;string length
    call string_print
    
    call input_int
    mov si, OFFSET funds
    mov word stake, ax  ; save input as their stake
    cmp ax, word [si]   ; compare user input to remaining funds
    jge _all_in          ; if user uses a big number or the last of their money, tell them it's the last of their money   
    jmp _computer_bet      ; computer bets based on yours
    
_all_in:
    ; tell the user that they are using the last of their funds
    mov bp, OFFSET all_in
    mov cx, 16
    call string_print       ; print incorrect input phrase
    mov bp, OFFSET funds
    mov ax, word [si]       ; making sure any super large numbers will set down to ur max funds
    mov word stake, ax      ; correct stake from large number to max possible bet
    jmp _computer_bet
    
_computer_bet:
    ; first, show the user their bet
    mov si, OFFSET stake
    mov ax, word [si]
    mov si, OFFSET ascii_end
    call int_to_ascii
    
    ; computer decides how much to bet against the player based on their bet and betting mode
    ; bet amount = user bet + (betting_mode * (user_bet / 10))
    
    mov ax, word stake          ; redundant but will weed out errors later
    
    ; jump to normal early because the computer matches the user's bet
    cmp byte betting_mode, 0x02 ; 1 = normal, so less than 2 will give normal
    jl  _normal_bet
    
    ; the rest ain't so easy
    mov dx, 0                   ; weeds out errors
    mov cx, 0x0a                ; 10 to cx
    div cx                      ; ax =  10% of user input
    mov cl, byte betting_mode   ; 2 = conservative, 3 = aggressive
    mul cx                      ; make ax into 20% of input for conservative, 30% for agressive       
    mov cx, word stake          ; prepare user stake for upcoming jumps
    
    cmp byte betting_mode, 0x02 ; 2 = conservative
    je  _conserve_bet
    
    cmp byte betting_mode, 0x02 ; 3 = aggressive, so greater than 2 will give normal
    jg  _aggro_bet
    
    jmp _deal_cards
    
_deal_cards:
    ; finish up printing from computer bet
    mov bp, OFFSET ai_bet
    mov cx, 15 ;0x15
    call string_print 
    ; print comp bet number
    mov si, OFFSET comp_stake
    mov ax, word [si]
    mov si, OFFSET ascii_end
    call int_to_ascii
    call new_line

    ;di = 0
    mov byte your_sum, 0
    mov byte comp_sum, 0    ; reset both hands for this turn
    
    ; let user know whose hand is being dealt
    mov bp, OFFSET hand
    mov cx, 10 ;string length
    call string_print

    ; draw ur first card
    call new_line
    call draw_card 
    ;sub dl, 0x30            ; return from ascii value of printing
    mov al, dl
    add al, byte your_sum   ; 0 (inital value) + 1st rand num 0-12
    mov byte your_sum, al
    ;sub dl, byte your_sum   ; return back to random number 0-12
    call print_card
    
    ; draw ur 2nd card
    call new_line
    call draw_card 
    ;sub dl, 0x30            ; return from ascii value of printing
    mov al, dl
    add al, byte your_sum   ; 0 (inital value) + 1st rand num 0-12
    mov byte your_sum, al
    ;sub dl, byte your_sum   ; return back to random number 0-12
    call print_card
    
    ; now computer's turn to be dealt
    call new_line
    mov bp, OFFSET comp_hand
    mov cx, 16 ;string length
    call string_print
    call new_line
    
    ; draw comp's first card
    call new_line
    call draw_card 
    ;sub dl, 0x30            ; return from ascii value of printing
    mov al, dl
    add al, byte comp_sum   ; 0 (inital value) + 1st rand num 0-12
    mov byte comp_sum, al
    ;sub dl, byte comp_sum   ; return back to random number 0-12
    call print_card
    
    ; draw comp's 2nd card
    call new_line
    call draw_card 
    ;sub dl, 0x30            ; return from ascii value of printing
    mov al, dl
    add al, byte comp_sum   ; 0 (inital value) + 1st rand num 0-12
    mov byte comp_sum, al
    ;sub dl, byte comp_sum   ; return back to random number 0-12
    call print_card
    
    jmp _player_choice
    
    
_player_choice:
    ; let user know their options
    mov bp, OFFSET display_choice
    mov cx, 38 ;string length
    call string_print
    
    ; choice 1: keep
    mov bp, OFFSET specify_keep
    mov cx, 26 ;string length
    call string_print
    
    ; choice 2: add
    mov bp, OFFSET specify_add
    mov cx, 28 ;string length
    call string_print
    
    ; choice 3: forfeit
    mov bp, OFFSET specify_forfeit
    mov cx, 33 ;string length
    call string_print
    
    call new_line
    
    call char_to_int    ; user input
    
    cmp al, 0x3  ;compare to 3
    jg _invalid_option
    je _forfeit
    cmp al, 0x1   ;compare to 1
    jl _invalid_option
    je _keep
    jmp _add
    
_keep:
    ;tell them their option
    mov bp, OFFSET kept_hand
    mov cx, 19 ;string length
    call string_print
    call new_line
    jmp cpu_action
_add:
    ;tell them their option
    mov bp, OFFSET add_hand
    mov cx, 22 ;string length
    call string_print
    
    ; draw a card
    call new_line
    call draw_card 
    mov al, dl
    add al, byte your_sum   ; current sum + rand num 0-12
    mov byte your_sum, al
    call print_card
    call new_line
    
    cmp byte your_sum, 0x15
    jge cpu_win
    jmp _player_choice   ;ask again

_forfeit:
    ;tell them their option
    mov bp, OFFSET forfeit_hand
    mov cx, 24 ;string length
    call string_print
    call new_line
    
    mov bp, offset funds
    mov di, 0
    mov bx, word [bp, di] 
    mov di, 2
    mov cx, word [bp, di]
    mov di, 0
    jmp cpu_win


cpu_action:
    ;CALL rand_int ;assume rand in ax
    ;mov ax, 0x0189 ;TEMP
    call rand_num
    mov bx, 0x64
    div bx ;rolled percent in dl
    mov bp, offset chances
    mov si, 0x00
compare_bet:
    mov dh, byte [bp, si] ;bet chance section
    cmp dl, dh
    jle cpu_bet
compare_draw:
    inc di
    mov ch, byte [bp, si] ;draw chance section
    add dh, ch
    cmp dl, dh
    jle cpu_draw
    ;otherwise jump to fold
    jmp cpu_fold
cpu_bet:
    ;tell user that computer will stand and bet
    mov bp, OFFSET cpu_kept
    mov cx, 25 ;string length
    call string_print
    call new_line
    
    
    jmp cmp_21

cpu_draw:
    ;tell user that computer will draw
    mov bp, OFFSET cpu_add
    mov cx, 27 ;string length
    call string_print
    call new_line
    
    ; draw a card
    call new_line
    call draw_card 
    mov al, dl
    add al, byte comp_sum   ; current sum + rand num 0-12
    mov byte comp_sum, al
    call print_card
    call new_line
    
    jmp cpu_action
    
cpu_fold:
    ;tell user that computer will forfeit
    mov bp, OFFSET cpu_forfeit
    mov cx, 30 ;string length
    call string_print
    call new_line
    ;fold, player wins the round
    mov bp, offset funds
    mov di, 0
    mov bx, word [bp, di] 
    mov di, 2
    mov cx, word [bp, di]
    mov di, 0
    jmp player_win
cmp_21:
    mov bp, offset funds
    mov di, 0
    mov bx, word [bp, di] 
    mov di, 2
    mov cx, word [bp, di]
    mov di, 0
    ; player at/over 21?
    cmp word your_sum,  0x15
    jg cpu_win
    je player_win
    
    ; computer at/over 21?
    cmp word comp_sum,  0x15
    jg player_win
    je cpu_win
    
    jmp resolve_hand


;skip_inc:
    ; !!!!!!! this also does not work due to the lack of deck tracking !!!!!!!!

    ;mov bp, OFFSET decks
    ;set checkval at bl = 0x01, lshift to index correctly
    ;mov bl, 0x01
    ;mov cl, dl
    ;shl bl, cl
    ;load relevant deck byte to al
    ;mov al, dh
    ;mov ah, 0x00
    
    ;mov si, ax
    ;mov al, byte [bp, si]
    ;bitwise AND to check if card is there
    ;and al, bl
    ;cmp al, bl
    ;if not, try again
    ;jne _card_again
    
    ;if it is, remove it by:
    ;bitwise and with bitwise NOT(checkval)
    ;mov al, byte [bp, di]
    ;not bl
    ;and al, bl
    ;mov byte [bp, di], al
    ;ret
    
_skip:
    ; skip past non-integer values in the _to_integer procedure
    inc si
    cmp si, bx          ; dont loop if si is at the end of the string
    jl _call_get_int
    ret
   
   
; these procedures act as conditional calls for other procedures
_card_again:
    call draw_card
    ret

_call_get_int:
    ; this is necessary because you can't return based on a compare, so you need
    ; too loop the procedure until the compare stops allowing the jump and the original
    ; procedure can end
    call _to_integer
    ret
    
_printable_int:
    ; another conditional call
    call int_to_ascii
    ret
    
; these are all the same except each one returns to a different procedure 
_invalid_cash:
    mov bp, OFFSET invalid_input
    mov cx, 24 
    call string_print       ; print incorrect input phrase
    call get_starting_money ; try starting $$$ procedure again
    ret
    
_invalid_bet:
    call new_line
    mov bp, OFFSET invalid_input
    mov cx, 24 
    call string_print       ; print incorrect input phrase
    call get_bet_mode   ; try bet mode procedure again
    ret
    
_invalid_diff:
    call new_line
    mov bp, OFFSET invalid_input
    mov cx, 24 
    call string_print       ; print incorrect input phrase
    call get_difficulty   ; try difficulty procedure again
    ret
    
_invalid_deck:
    mov bp, OFFSET invalid_input
    mov cx, 24 
    call string_print       ; print incorrect input phrase
    call get_num_decks ; try num deck procedure again
    ret
    
_invalid_risk:
    call new_line
    mov bp, OFFSET invalid_risk
    mov cx, 67
    call string_print       ; print incorrect input phrase
    call get_risk_level ; try risk procedure again
    ret
    
_invalid_option:
    mov bp, OFFSET invalid_input
    mov cx, 24 
    call string_print       ; print incorrect input phrase
    jmp _player_choice

; these next 8 just set bp to the respective string and set cx to its length for card visualization
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

; for determining computer starting funds
_normal_funds:
    ; 1 = normal (computer matches your start)
    mov bp, OFFSET funds    ; computer matches user fund in the first slot of array funds
    mov ax, word [bp]            ; leave ax for procedure
    
    ; save result
    mov di, 2               ;set focus to computer temporarily
    ;mov word [bp, di], 0x0000   ; clean out old values that might mess with smaller numbers
    mov word [bp, di], ax   ; save value in funds if it meets above conditions
    mov di, 0 
    
    ret

; different computer funds based on difficulty
_easy_funds:
    ; 2 = easy (computer start $ div by 2) 
    ; bit shift could've worked here and in hard one but oh well
    mov bp, OFFSET funds    ; computer first matches user fund in the first slot of array funds
    mov ax, word [bp]            ; ready ax for modification
    mov dx, 0               ; just in case dx would mess up division
    mov cx, 2               ; half
    div cx                  
    
    ; save result
    mov di, 2               ;set focus to computer temporarily
    ;mov word [bp, di], 0x0000   ; clean out old values that might mess with smaller numbers
    mov word [bp, di], ax   ; save value in funds if it meets above conditions
    mov di, 0 
    
    ret ;ax = comp bet
    
_hard_funds:
    ; 3 = hard (computer start 50% more)
    mov bp, OFFSET funds    ; computer first matches user fund in the first slot of array funds
    mov ax, word [bp]            ; ready ax for modification
    mov dx, 0               ; just in case dx would mess up division
    mov cx, 2               ; half
    div cx
    mov cx, word [bp]
    add ax, cx
    
    ; save result
    mov di, 2               ;set focus to computer temporarily
    ;mov word [bp, di], 0x0000   ; clean out old values that might mess with smaller numbers
    mov word [bp, di], ax   ; save value in funds if it meets above conditions
    mov di, 0               ; return focus to player for their turn
    
    ret ;ax = comp bet
    
; different bets based on betting mode
_normal_bet:
    mov word comp_stake, ax
    jmp _deal_cards

_conserve_bet:
    ; this one requires subtraction
    sub cx, ax      ; user bet - 20% of user bet
    xchg cx, ax
    mov word comp_stake, ax
    jmp _deal_cards

    
_aggro_bet:
    ; this one requires addition
    add ax, cx      ; user bet + 30% of user bet
    mov word comp_stake, ax
    jmp _deal_cards

    
resolve_hand:
    mov ah, byte your_sum
    mov al, byte comp_sum
    ;now ah = player sum for hand & al = computer sum for hand
    ;mov ax, 0x02
    ;mov bx, 0x03
    ;sub ax, bx
    ;compare hands and distribute winnings
    ;after both players are done drawing cards
    ;assume ah = player hand, al = cpu hand
    ;assume busts over 21 are caught previously
    ;mov ax, 0x0a09  ;TMP
    cmp ah, al
    je endturn ;skip funds if tied
    ;load player funds to bx, cpu to cx, bet to dx
    mov bp, offset funds
    mov bx, word [bp, di] 
    mov di, 2
    mov cx, word [bp, di]
    ;mov si, offset stake
    cmp ah, al
    jl cpu_win
player_win:
    ;add stake to player at bx, sub from cpu at cx
    mov dx, word comp_stake
    add bx, dx
    sub cx, dx
    
    mov bp, OFFSET praise
    mov cx, 9 ;string length
    call string_print
    call new_line
    
    jmp checkfunds
cpu_win:
    ;add stake to cpu at cx, sub from player at bx
    mov dx, word stake
    add cx, dx
    sub bx, dx
    
    mov bp, OFFSET scold
    mov cx, 11 ;string length
    call string_print
    call new_line
    
checkfunds:
    mov word [bp, di], cx  ; save comp funds
    mov di, 0
    mov word [bp, di], bx   ; save player funds
    cmp bx, 0
    jg endturn ;if no player below 0, next turn
    cmp cx, 0
    jg endturn ;if no player below 0, next turn
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
    mov si, 0x00
    mov ah, 0x02
    mov cx, 0x000a
print_loop:
    mov dl, byte [bp, si]
    int 0x21
    inc si
    cmp si, cx
    jge end_game
    jmp print_loop
endturn:
    ;goto next hand/return
    jmp _start_turn
end_game:
    ;terminate program