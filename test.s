/******************************************************************************
***
File: Example11a.s
Author: Craig Eichelkraut
Purpose: Test the branch and linking and push /pop instructions of the ARM
processor.
History:
Use these commands to assemble, link, run and debug the program
as -o Example11a.o -g Example11a.s
gcc -o Example11a Example11a.o
./Example11a
gdb --args ./Example11a
******************************************************************************
*****/
.global main
main: @Must use this label where to start executing the code.
ADR r0, This + 1 @ Generate address of Thumb section
BX r0 @ Off we go branch and change to Thumb state
.thumb @ Assemble Thumb instructions
This:
/******************************************************************************
***
Use the C library call printf to print the results string. Details on
how to use this function is given in the .data section.
r0 - Must contain the starting address of the string to be printed.
******************************************************************************
*****/
LDR R0, =str_A @ Put address of string in r0
LDR R6, =A @ Put address of A in r6
LDR R1, [R6] @ Put the value of A in r1 for printf output
BL printf @ Make the call to printf
LDR R0, =str_B @ Put address of string in r0
LDR R7, =B @ Put the address of B in r7
LDR R1, [r7] @ Put the value of B in in r1 for printf output
BL printf @ Make the call to printf
LDR R1, [r6] @ Put the value of A in r2 for gcd
LDR R2, [r7] @ Put the value of B in r3 for gcd
BL lcm
MOV R1, r0 @ put results in r1 for printing
LDR R0, =str_C @ Put address of string in r0
BL printf @ Make the call to printf
@ Force the exit of this program and return command to OS.
MOV R7, #0X01
SVC 0
/******************************************************************************
***
Function lcm - Calculate Least Common Multiple
r0 - results
r1 - number 1 "a"
r2 - number 2 "b"
******************************************************************************
*****/
lcm:
PUSH {R2, R3, LR}
MOV R3, R2 @ put B in temp register for calculations
BL gcd @ call gcd(a, b)
MOV R2, R0
BL divide @ calculate a / gcd(a, b). results are left in r0
MUL R0,R3,R0 @ multiply; results = results * B
POP {R2, R3, PC} @ return
/******************************************************************************
***
Function gcd - Calculate Greatest Common Divisor using recursive
algorithm.
r0 - results
r1 - number 1 "a"
r2 - number 2 "b"
******************************************************************************
*****/
gcd:
PUSH {R1, R2, LR}
MOV R0, R1 @ results = A
CMP R2, #0 @ return if B == 0
BEQ done
BL modulus @ call modulus function r0 = r1 % r2
MOV R1, R2 @ GCD(b, a % b)
MOV R2, R0
BL gcd @ GCD results are left in r0
done: POP {R1, R2, PC} @ return
/******************************************************************************
***
Function modulus - calculate modulus using repeated subtract.
r0 - results
r1 - numerator
r2 - denominator
******************************************************************************
*****/
modulus:
PUSH {R1, LR}
loop: SUB R1,R1,R2 @ subtract R2 from R1 and store in R1.
CMP R1,#0 @ compare results.
BPL loop @ branch to start of loop on condition
@ Higher, i.e. R1 is still greater than R2.
BEQ zero @ if R1 != 0 then ADD else MOV.
ADD R1, R1, R2 @ if the result goes negative add R2 back.
zero: MOV R0, R1 @ Put results in R0
POP {R1, PC} @ return
/******************************************************************************
***
Function divide - use ARM divide function to perform division.
r0 - results
r1 - numerator
r2 - denominator
******************************************************************************
*****/
divide:
PUSH {R1-R3, LR}
MOV R0, R1 @ load R0 and R1 for divide routine.
MOV R1, R2
BL __aeabi_idiv @ calculate a / gcd(a, b). results are left in r0
POP {R1-R3, PC} @ return
@ Declare the strings
.data @ Lets the OS know it is OK to write to this area of memory.
.balign 4 @ Force a word boundary
str_A: .asciz "A = %d\n"
.balign 4 @ Force a word boundary
str_B: .asciz "B = %d\n"
.balign 4 @ Force a word boundary
str_C: .asciz "Results = %d\n"
.balign 4 @ Force a word boundary
A: .word 15
B: .word 20
.global printf
/******************************************************************************
***
To use printf:
r0 - Contains the starting address of the string to be printed. The string
must conform to the C coding standards.
r2,r3 - If the string contains an output parameter i.e., %f, etc. register
pair r2,r3 must contain the value to be printed.
When the call returns registers: r0, r1, r2, r3 and r12 are changed.
end of code and end of file. Leave a blank line after this.
******************************************************************************
*****/
