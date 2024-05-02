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
ask_starting_cash:
    db "Input Starting Cash (10-1000):"
ask_num_decks:
    db "How many card decks? (1-3):"    
ask_betting_mode:
    db "Choose a computer betting mode:"
specify_conserve:
    db "(Type 1 for Conservative)"
specify_normal_bet:
    db "(Type 2 for Normal)"
specify_aggro:
    db "(Type 3 for Aggressive)"
ask_difficulty:
    db "Choose a Difficulty:"
specify_easy:
    db "(Type 1 for Easy)"
specify_normal_diff:
    db "(Type 2 for Normal)"
specify_hard:
    db "(Type 3 for Hard)"
starting_cash:
    dw 0xffff
num_decks:
    db 0xff
difficulty:
    db 0xff
betting_mode:
    db 0xff
cash_buffer:    ;*********** go to start address 100 to view this in memory on 2nd line ********
    db 0xff     ; Maximum value to read
    db 0x00     ; Actual value read after INT
    db [0x00, 0x04] ; Buffer of the right size  
                    ; First value: filler
                    ; Second value: number of bytes
end_cash_buffer:
    db 0xff

    
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
    ; converts a 4-digit long user inputted string into a single hexadecimal value.
    ; universal, can be used with any string as long as...
    ; bp points to buffer of choice (lea bp, word BUFFER_HERE)
    ; bx = the length of the string 

    mov cl, byte [bp, si] ; load byte at index si in bp into cl
    cmp cl, 0x30    
    jl _skip        ; ignore ASCII values lower than 30, which is the number 0
    cmp cl, 0x40
    jge _skip        ; ignore ASCII values greater than 39, which is the number 9
    sub cl, 0x30      ; convert ASCII to hexadecimal int
    mul dx          ; value so far in ax * 10  (ax is initially 0)
    add al, cl      ; add most recent digit taken from input
    inc si          ; move to next element in buffer
    mov dx, 0x0a    ; move 10 to get ready for next 10s place in number
    cmp si, bx              ; end of string reached?
    jl _call_get_int
    ret     
}

; ================================================================
; these need to be above other procedures since they are universal,
; the rest are mainly one off procedures for progressing the game
; ================================================================    

def get_starting_money {

    ; ask them to declare the starting $$$
    mov bp, OFFSET ask_starting_cash
    mov cx, 30 ;0x15
    call string_print
    
    ; use a buffer so they can input a number
    mov ah, 0x0a    ;for buffer
	lea dx, word cash_buffer
	int 0x21
	; getting the end of the string to di
    lea bp, word cash_buffer
    inc bp  ;move past the 0xff that is only there to declare maximum read value
    lea bx, word end_cash_buffer     ;get the end of the string
    mov cx, bp      ; move start of string to cx
    sub bx, cx      ; subtract start of string from end of string (EX: len = 117 - 114 = 3)
    mov ch, 0x0a       ; reseting cx for later equations
    mov ax, 0 
    mov si, 1   ; set as 1 because 1st character is string length so we can ignore that
    
    call _to_integer    ; string input --> integer
    
    cmp ax, 0x3E8  ;compare to 1,000
    jg _invalid_cash
    cmp ax, 0x0a   ;compare to 10
    jl _invalid_cash
    
    mov word starting_cash, ax  ; save value if it meets above conditions
    
    ret
}



def user_config {
    ; welcome the player to the game
    mov bp, OFFSET welcome
    mov cx, 21 ;0x15
    call string_print
    call new_line
    
    
    call get_starting_money ;needs its own procedure because a wrong input causes it to repeat
    
    ; TODO:
    ; continue here with asking the user for other config stuff and converting
    ; inputs into integers and putting them in mem
    
    ret
    }
    


start:
  
    call user_config
    ;jmp turn_loop
    
    ;_turn_loop:
    ; check turn requirements
    ; call user_turn
    ; go through various prompts and get user input throughout their turn
    ; user says no more or win/loss, jmp _exit_turn_loop
    
    jmp _end

    
_skip:
    ; skip past non-integer values
    inc si
    ;jmp cash_to_integer
    ret
   
_call_get_int:
    ; this is necessary because you can't return based on a compare, so you need
    ; too loop the procedure until the compare stops allowing the jump and the original
    ; procedure can end
    call _to_integer
    ret
    
    
_invalid_cash:
    mov bp, OFFSET invalid_input
    mov cx, 24 
    call string_print
    call get_starting_money
    ret
    
_end: