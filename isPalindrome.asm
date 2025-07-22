                .ORIG       x3000
                
BEGIN           AND         R1, R1, #0
                AND         R2, R2, #0
                AND         R3, R3, #0
                AND         R4, R4, #0
                AND         R5, R5, #0
                AND         R6, R6, #0
                AND         R7, R7, #0
                
;-----------------------------------------------

                LEA         R0, PROMPT
                PUTS
                
                LEA         R6, STACK_BOTTOM
                
INPUT_LOOP      GETC                            ;Input
                OUT
                ADD         R0, R0, #-10
                BRz         DONE_INPUT
                
                JSR         TO_UPPERCASE
                
STORE_INPUT     JSR         PUSH                ;Send input to stack
                
                ADD         R5, R5, #0          ;Check if overflow
                BRp         STACK_FULL
                
                BR          INPUT_LOOP
                
DONE_INPUT      LEA         R5, STACK_BOTTOM    ;Check if input is empty
                NOT         R5, R5
                ADD         R5, R5, #1
                
                ADD         R5, R6, R5
                BRz         EMPTY_INPUT
                
                ST          R6, SAVE_PTR        ;Store the size of input
                
                JSR         IS_PALINDROME  
                
STACK_FULL      LEA         R0, FULL_PROMPT
                PUTS
                
                BR          DONE
                
EMPTY_INPUT     LEA         R0, EMPTY_PROMPT
                PUTS
                
                BR          DONE                
;-----------------------------------------------

TO_UPPERCASE    ST          R1, SAVE_R1
                AND         R1, R1, #0
                
                
                LD          R1, ASCII_a         ;Check if input >= a
                NOT         R1, R1
                ADD         R1, R1, #1
                
                ADD         R1, R0, R1
                BRn         NOT_LOWERCASE       
                
                LD          R1, ASCII_z         ;Check if input <= z
                NOT         R1, R1
                ADD         R1, R1, #1
                
                ADD         R1, R0, R1
                BRp         NOT_LOWERCASE
                
                LD          R2, ASCII_FORMULA
                ADD         R0, R0, R1
                
                LD          R1, SAVE_R1
                RET
                
NOT_LOWERCASE   LD          R1, SAVE_R1
                RET
                
;-----------------------------------------------

PUSH            ST          R1, SAVE_R1
                
                AND         R5, R5, #0          ;Assume no overflow
                
                LEA         R1, STACK
                NOT         R1, R1
                ADD         R1, R1, #1
                
                ADD         R1, R1, R6          ;Check whether R6 is at top
                BRz         PUSH_FAIL
                
                ADD         R6, R6, #-1         ;If no overflow, then get data
                STR         R0, R6, #0          ;Move stack pointer
                
                LD          R1, SAVE_R1
                RET

PUSH_FAIL       ADD         R5, R5, #1          ;Set R5 to indicate overflow
                LD          R1, SAVE_R1
                RET

;-----------------------------------------------

IS_PALINDROME   LD          R3, SAVE_PTR        ;Adress of last digit
                LEA         R6, STACK_BOTTOM
                ADD         R6, R6, #-1
                
NEXT_CHAR       LEA         R4, STACK_BOTTOM    ;Negative of bottom adress
                NOT         R4, R4
                ADD         R4, R4, #1          
                
                ADD         R4, R3, R4          ;Check if R3 is at bottom
                BRz         TRUE                ;If yes, then it means input is the palindrome number
                
                LDR         R1, R3, #0          ;R1 gets characters one by one from the last digit to the first digit
                ADD         R3, R3, #1          ;Move pointer of reversed input
                LDR         R2, R6, #0          ;R2, from first digit to last digit
                ADD         R6, R6, #-1         ;Move the pointer of input
                
                NOT         R2, R2
                ADD         R2, R2, #1
                
                ADD         R1, R1, R2          ;Check if R1 == R2
                BRz         NEXT_CHAR
                BRnp        FALSE
                
TRUE            LEA         R0, TRUE_PROMPT
                PUTS
                BR          CHOICE

FALSE           LEA         R0, FALSE_PROMPT
                PUTS
                BR          CHOICE

;-----------------------------------------------

CHOICE          LEA         R0, END_PROMPT
                PUTS
                
                GETC
                OUT
                LD          R1, ASCII_ZERO
                ADD         R0, R0, R1
                BRz         BEGIN
                
                ADD         R0, R0, #-1
                BRz         DONE
                
                LEA         R0, ERROR_PROMPT
                PUTS
                BRnzp       CHOICE

PROMPT          .STRINGZ    "\nType Here (Max 7 Digit):"
FULL_PROMPT     .STRINGZ    "\nOverflow"
EMPTY_PROMPT    .STRINGZ    "\nInput is empty"
TRUE_PROMPT     .STRINGZ    "TRUE"
FALSE_PROMPT    .STRINGZ    "FALSE"
END_PROMPT      .STRINGZ    "\nContinue? 0 for yes, 1 for exit."
ERROR_PROMPT    .STRINGZ    "\nIllegal input, please try again:"

ASCII_ZERO      .FILL       xFFD0               ;Negative of ASCII "0", i.e. -x0030
ASCII_FORMULA   .FILL       xFFCE               ;Negative of x0020
ASCII_a         .FILL       x0061               
ASCII_Z         .FILL       x007A              

SAVE_R1         .BLKW       1
SAVE_PTR        .BLKW       1
SAVE_UPPERCASE  .BLKW       1

STACK           .BLKW       7                   ;STACK
STACK_BOTTOM    .BLKW       1
DONE            HALT
                .END