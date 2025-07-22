# LC-3 Palindrome Checker

**Tech Stack**: LC-3 Assembly Language | Stack Data Structure | ASCII Character Processing | Interactive Loop System

A comprehensive palindrome detection system implemented in LC-3 assembly language featuring automatic character case conversion, continuous user interaction, and robust error handling mechanisms.

## Technology Stack

### Core Technologies
- **Assembly Language**: LC-3 instruction set architecture
- **Data Structure**: Manual stack implementation using BLKW memory allocation
- **Memory Management**: Register-based stack pointer manipulation and preservation
- **I/O Operations**: GETC, PUTS, OUT instructions for interactive character processing

### Programming Techniques
- **Modular Design**: Subroutine-based architecture with JSR/RET calling conventions
- **ASCII Processing**: Character validation, case conversion, and comparison algorithms
- **Stack Operations**: LIFO data structure with overflow detection and boundary checking
- **Interactive Control Flow**: Loop-based user interface with input validation

## System Architecture

### Character Processing and Case Conversion

**Automatic Case Normalization:**
```assembly
TO_UPPERCASE:
    ST      R1, SAVE_R1         ; Preserve register state
    AND     R1, R1, #0          ; Clear working register
    
    LD      R1, ASCII_a         ; Load 'a' ASCII value (0x0061)
    NOT     R1, R1              ; Two's complement preparation
    ADD     R1, R1, #1
    ADD     R1, R0, R1          ; Check if input >= 'a'
    BRn     NOT_LOWERCASE       ; Skip conversion if not lowercase
    
    LD      R1, ASCII_z         ; Load 'z' ASCII value (0x007A)
    NOT     R1, R1
    ADD     R1, R1, #1
    ADD     R1, R0, R1          ; Check if input <= 'z'
    BRp     NOT_LOWERCASE       ; Skip conversion if not lowercase
    
    LD      R2, ASCII_FORMULA   ; Load conversion factor (-0x0020)
    ADD     R0, R0, R2          ; Convert lowercase to uppercase
    
NOT_LOWERCASE:
    LD      R1, SAVE_R1         ; Restore register state
    RET

; Character processing constants
ASCII_a         .FILL   x0061   ; Lowercase 'a'
ASCII_z         .FILL   x007A   ; Lowercase 'z'  
ASCII_FORMULA   .FILL   xFFE0   ; Conversion factor (-32)
```

### Stack-Based Data Management

**Memory Allocation and Structure:**
```assembly
; Memory layout for palindrome processing
STACK           .BLKW   7       ; 7-character stack buffer
STACK_BOTTOM    .BLKW   1       ; Stack bottom boundary marker
SAVE_PTR        .BLKW   1       ; Stack pointer backup storage
SAVE_R1         .BLKW   1       ; Register preservation
SAVE_UPPERCASE  .BLKW   1       ; Additional storage for processing
```

**Stack Push Operation with Bounds Checking:**
```assembly
PUSH:
    ST      R1, SAVE_R1         ; Save current register state
    AND     R5, R5, #0          ; Initialize overflow flag
    
    LEA     R1, STACK           ; Load stack base address
    NOT     R1, R1              ; Calculate two's complement
    ADD     R1, R1, #1
    ADD     R1, R1, R6          ; Check stack pointer bounds
    BRz     PUSH_FAIL           ; Branch if stack overflow detected
    
    ADD     R6, R6, #-1         ; Decrement stack pointer
    STR     R0, R6, #0          ; Store character at current position
    LD      R1, SAVE_R1         ; Restore register state
    RET

PUSH_FAIL:
    ADD     R5, R5, #1          ; Set overflow indicator flag
    LD      R1, SAVE_R1         ; Restore register state
    RET
```

### Input Processing and Validation

**Interactive Input Loop:**
```assembly
INPUT_LOOP:
    GETC                        ; Read character from keyboard
    OUT                         ; Echo character to display
    ADD     R0, R0, #-10        ; Check for newline terminator
    BRz     DONE_INPUT          ; Exit input loop if newline detected
    
    JSR     TO_UPPERCASE        ; Convert character to uppercase
    JSR     PUSH                ; Store processed character in stack
    
    ADD     R5, R5, #0          ; Check overflow status flag
    BRp     STACK_FULL          ; Handle stack overflow condition
    BR      INPUT_LOOP          ; Continue input processing

DONE_INPUT:
    LEA     R5, STACK_BOTTOM    ; Load stack bottom address
    NOT     R5, R5              ; Calculate negative address
    ADD     R5, R5, #1
    ADD     R5, R6, R5          ; Compare current pointer with bottom
    BRz     EMPTY_INPUT         ; Handle empty input case
    
    ST      R6, SAVE_PTR        ; Store current stack pointer
    JSR     IS_PALINDROME       ; Begin palindrome analysis
```

### Palindrome Detection Algorithm

**Dual-Pointer Comparison Method:**
```assembly
IS_PALINDROME:
    LD      R3, SAVE_PTR        ; Load end pointer (last character)
    LEA     R6, STACK_BOTTOM    ; Reset start pointer to bottom
    ADD     R6, R6, #-1         ; Adjust for proper indexing

NEXT_CHAR:
    LEA     R4, STACK_BOTTOM    ; Calculate stack bottom address
    NOT     R4, R4              ; Two's complement conversion
    ADD     R4, R4, #1
    ADD     R4, R3, R4          ; Check if pointers have converged
    BRz     TRUE                ; Palindrome confirmed if pointers meet
    
    LDR     R1, R3, #0          ; Load character from end position
    ADD     R3, R3, #1          ; Move end pointer toward center
    LDR     R2, R6, #0          ; Load character from start position
    ADD     R6, R6, #-1         ; Move start pointer toward center
    
    ; Character comparison using arithmetic subtraction
    NOT     R2, R2              ; Negate second character
    ADD     R2, R2, #1          ; Complete two's complement
    ADD     R1, R1, R2          ; Perform subtraction: R1 - R2
    BRz     NEXT_CHAR           ; Continue if characters match
    BRnp    FALSE               ; Branch to FALSE if mismatch detected

TRUE:
    LEA     R0, TRUE_PROMPT     ; Load success message
    PUTS                        ; Display result
    BR      CHOICE              ; Continue to user choice menu

FALSE:
    LEA     R0, FALSE_PROMPT    ; Load failure message
    PUTS                        ; Display result
    BR      CHOICE              ; Continue to user choice menu
```

### Interactive Control System

**Continuous Operation Loop:**
```assembly
CHOICE:
    LEA     R0, END_PROMPT      ; Display continuation prompt
    PUTS                        ; "Continue? 0 for yes, 1 for exit."
    
    GETC                        ; Read user choice
    OUT                         ; Echo choice to display
    LD      R1, ASCII_ZERO      ; Load negative ASCII '0' (-0x0030)
    ADD     R0, R0, R1          ; Convert ASCII to numeric value
    BRz     BEGIN               ; Restart program if user enters '0'
    
    ADD     R0, R0, #-1         ; Check if user entered '1'
    BRz     DONE                ; Exit program if user enters '1'
    
    LEA     R0, ERROR_PROMPT    ; Display error for invalid input
    PUTS                        ; "Illegal input, please try again:"
    BRnzp   CHOICE              ; Return to choice menu

; Program control constants
ASCII_ZERO      .FILL   xFFD0   ; Negative ASCII '0' for conversion
```

### Error Handling and Edge Cases

**Comprehensive Error Management:**
```assembly
; Stack overflow handling
STACK_FULL:
    LEA     R0, FULL_PROMPT     ; Load overflow message
    PUTS                        ; Display "Overflow"
    BR      DONE                ; Terminate program

; Empty input validation
EMPTY_INPUT:
    LEA     R0, EMPTY_PROMPT    ; Load empty input message
    PUTS                        ; Display "Input is empty"
    BR      DONE                ; Terminate program

; Program termination
DONE:
    HALT                        ; End program execution
```

### User Interface Messages

**Interactive Prompts and Feedback:**
```assembly
; User interface text strings
PROMPT          .STRINGZ    "\nType Here (Max 7 Digit):"
FULL_PROMPT     .STRINGZ    "\nOverflow"
EMPTY_PROMPT    .STRINGZ    "\nInput is empty"
TRUE_PROMPT     .STRINGZ    "TRUE"
FALSE_PROMPT    .STRINGZ    "FALSE"
END_PROMPT      .STRINGZ    "\nContinue? 0 for yes, 1 for exit."
ERROR_PROMPT    .STRINGZ    "\nIllegal input, please try again:"
```

## Program Flow and Main Logic

### Complete Program Structure
```assembly
.ORIG   x3000

BEGIN:
    ; Initialize all registers to zero state
    AND     R1, R1, #0
    AND     R2, R2, #0
    AND     R3, R3, #3
    AND     R4, R4, #0
    AND     R5, R5, #0
    AND     R6, R6, #0
    AND     R7, R7, #0

    ; Display user prompt and initialize stack
    LEA     R0, PROMPT
    PUTS
    LEA     R6, STACK_BOTTOM    ; Initialize stack pointer

    ; Begin interactive input processing
    BR      INPUT_LOOP

.END
```

## Installation and Testing

### Prerequisites
- LC-3 Simulator (LC-3Edit, LC-3 Tools, or compatible simulator)
- Understanding of LC-3 instruction set architecture
- Text editor for assembly code modification

### Running the Program
```bash
# Load program into LC-3 simulator
# Set program counter to x3000
# Execute program

# Interactive Test Session:
# Input: "racecar" → Output: TRUE
# Choice: 0 (continue)
# Input: "hello" → Output: FALSE  
# Choice: 0 (continue)
# Input: "Level" → Output: TRUE
# Choice: 1 (exit)
```

### Test Cases and Expected Behavior
```
Input Examples:
- "aba" → TRUE
- "AbA" → TRUE
- "racecar" → TRUE
- "RaceCar" → TRUE
- "hello" → FALSE
- "12321" → TRUE
- "" → Input is empty
- "verylongstring" → Overflow
```

## Project Structure
```
LC3-Palindrome-Checker/
├── isPalindrome.asm          # Complete interactive palindrome checker
├── test_scenarios.txt        # Comprehensive test cases
├── documentation.md          # Technical documentation
└── README.md                # Project overview and usage guide
```

## Algorithm Analysis and Performance

### Computational Complexity
- **Time Complexity**: O(n) for input processing + O(n/2) for palindrome check = O(n)
- **Space Complexity**: O(n) where n ≤ 7 characters (fixed stack size)
- **Memory Efficiency**: Constant memory allocation with overflow protection

### Technical Optimizations
- **Register Utilization**: Efficient use of limited LC-3 register set
- **Memory Access**: Minimized memory operations through register optimization  
- **Control Flow**: Streamlined branching logic for optimal execution path

## Project Results and Technical Achievements

This LC-3 palindrome checker demonstrates:

**Advanced Assembly Programming**: Complete implementation using low-level LC-3 instructions with manual memory management, register optimization, and explicit control flow design.

**Sophisticated Data Structure Implementation**: Custom stack data structure with LIFO operations, boundary checking, overflow detection, and efficient pointer manipulation.

**Character Processing Mastery**: ASCII character analysis, automatic case conversion algorithms, and robust input validation with comprehensive error handling.

**Interactive System Design**: Multi-stage user interface with continuous operation capability, input validation, error recovery, and graceful program termination.

**Modular Software Architecture**: Well-structured subroutine design with proper calling conventions, register preservation, and code reusability principles.

**Computer Architecture Understanding**: Direct manipulation of memory addresses, instruction-level programming, and efficient utilization of hardware constraints within the LC-3 environment.

The project showcases comprehensive understanding of computer organization principles, assembly language programming techniques, and algorithm implementation at the machine level without reliance on high-level language abstractions.
