; CS-274
; Michael Connors
;
; CP 2: User interface
base:
    db 0xff
;   I want to keep all strings under 32 characters to save memory space
;   but I think we have like a million spaces in memory (1 MB) so idk ill play it safe
welcome:
    db "Welcome to Blackjack!"
invalid_input:
    db "Invalid input, try again"
invalid_risk:
    db "Risk exceeded 100%, it must be less than or equal to 100. Try again"
ask_starting_cash:
    db "Input Starting Cash ($10-1000):"
ask_num_decks:
    db "How many card decks? (1-3):"    
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
specify_conserve:
    db "(Type 2 for Conservative)"
specify_normal:
    db "(Type 1 for Normal)"
specify_aggro:
    db "(Type 3 for Aggressive)"
ask_difficulty:
    db "Choose a Difficulty:"
specify_easy:
    db "(Type 2 for Easy)"
specify_hard:
    db "(Type 3 for Hard)"
funds:              ;a full word per human & cpu funds
    dw [0xffff, 2]  
num_decks:          ; number 1-3 to describe # of decks
    db 0xff         
difficulty:         ; number 1-3 to describe difficulty
    db 0xff         ; 1 = normal, 2 = easy (computer start $ div by 2), 3 = hard (computer start $ mul by 2)
betting_mode:       ; number 1-3 to describe betting mode (1=normal, 2=easy, 3=hard)
    db 0xff         ; bet amount = user bet + (betting_mode * (user_bet / 10))
                    ; except its addition for hard and subtraction for easy
                    
int_buffer:    ;*********** go to start address 250 to view this easily in memory ********
    db 0x05     ; Maximum amount of characters to read
    db 0x00     ; Actual value read after INT
    db [0x00, 0x05] ; Buffer of the right size  
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

    
def string_print {
    ; bp and cx should already be set to offset and length respectively
    mov ah, 0x13	; move BIOS interrupt number
    mov bx, 0		; move 0 to bx
    mov es, bx		; move segment to start of string
    mov dl, 0		;start writing from col 0
    int 0x10		; BIOS interrupt
    ret
    }  
    
def new_line {
    ; print a blank line in order to separate text and made it easier to read
    ;mov bp, 0
    mov cx, 0
    mov ah, 0x13	; move BIOS interrupt number
    mov bx, 0		; move 0 to bx
    mov es, bx		; move segment to start of string
    mov dl, 0		;start writing from col 0
    int 0x10		; BIOS interrupt
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

    ; reset the 5-char buffer and the length obtained from user input
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
    inc si
    mov byte [bp,si], 0x00
    
    ret
}


def input_int {     
    ; get 5-char long user input string, convert to integer
    ; useful for when the user has to input a number that could reach high like an amount of money
    
    ; use a buffer so they can input a number
    mov ah, 0x0a    ;for buffer
	lea dx, word int_buffer
	int 0x21
	; getting the end of the string to di
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

def char_to_int {     ;  single char  user input converted to integer
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

def get_starting_money {

    ; ask them to declare the starting $$$
    mov bp, OFFSET ask_starting_cash
    mov cx, 31 ;0x15
    call string_print
    
    call input_int ; take user inputted string through a buffer and turn it into an int value
    
    cmp ax, 0x3E8  ;compare to 1000
    jg _invalid_cash
    cmp ax, 0x0a   ;compare to 10
    jl _invalid_cash
    
    ; set di to the location of funds in order to save in memory
    add di, OFFSET funds    ; before equation, di = 0 is for human, di = 1 is for computer
    mov word [di], ax  ; save value in funds if it meets above conditions
    ; using di here could cause problems later so return here if theres issues with di
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
    
    ; tell them 1 = conservative
    mov bp, OFFSET specify_conserve
    mov cx, 25 ;string length
    call string_print
    
    ; tell them 2 = normal
    mov bp, OFFSET specify_normal
    mov cx, 19 ;length
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
    
    ; tell them 1 = easy
    mov bp, OFFSET specify_easy
    mov cx, 17 ;string length
    call string_print
    
    ; tell them 2 = normal
    mov bp, OFFSET specify_normal
    mov cx, 19 ;length
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
    


start:
  
    call user_config
    ;call turn_loop
    
    ;def(?) _turn_loop:
    ; check turn requirements
    ; call user_turn
    ; go through various prompts and get user input throughout their turn
    ; user says no more or win/loss, jmp _exit_turn_loop
    
    jmp _end

    
_skip:
    ; skip past non-integer values in the _to_integer procedure
    inc si
    cmp si, bx          ; dont loop if si is at the end of the string
    jl _call_get_int
    ret
   
_call_get_int:
    ; this is necessary because you can't return based on a compare, so you need
    ; too loop the procedure until the compare stops allowing the jump and the original
    ; procedure can end
    call _to_integer
    ret
    
; these are all the same except each one returns to a different procedure 
_invalid_cash:
    mov bp, OFFSET invalid_input
    mov cx, 24 
    call string_print       ; print incorrect input phrase
    call get_starting_money ; try starting $$$ procedure again
    ;ret
    
_invalid_bet:
    call new_line
    mov bp, OFFSET invalid_input
    mov cx, 24 
    call string_print       ; print incorrect input phrase
    call get_bet_mode   ; try bet mode procedure again
    ;ret
    
_invalid_diff:
    call new_line
    mov bp, OFFSET invalid_input
    mov cx, 24 
    call string_print       ; print incorrect input phrase
    call get_difficulty   ; try difficulty procedure again
    ;ret
    
_invalid_deck:
    mov bp, OFFSET invalid_input
    mov cx, 24 
    call string_print       ; print incorrect input phrase
    call get_num_decks ; try num deck procedure again
    ;ret
    
_invalid_risk:
    call new_line
    mov bp, OFFSET invalid_risk
    mov cx, 67
    call string_print       ; print incorrect input phrase
    call get_risk_level ; try risk procedure again
    ;ret
    
_end: