/*
File: Lab4.s
Author: Lane Wright

To Run:
as -o Lab4.o Lab4.s -g
gcc -o Lab4 Lab4.o -g
./Lab4

To Dubug after compiled:
gdb ./Lab4
 */

.global main

@r4: The value the user input
@r5: The total money input
@r6: Amount of Coke
@r7: Amount of Sprite
@stack: Amount of Dr. Pepper
@stack: Amount of Coke Zero

main:
    adr r0, thumb + 1
    bx r0
    .thumb
    .syntax unified
thumb:
    @Set the initial values
    movs r4, #0
    movs r5, #0
    movs r6, #2
    movs r7, #2
    movs r0, #2
    movs r1, #2
    push {r0, r1} 

    @Welcome the user
    ldr r0, =strWelcomeMessage
    bl printf

input:

    @Check if the machine is empty and if it is exit the program
    bl checkEmpty
    cmp r0, #4
    beq exit

    @Get the money input from the user
    ldr r0, =strMoneyMessage
    bl printf
    ldr r0, =charInputMode
    ldr r1, =charInput
    bl scanf
    cmp r0, #0
    it eq
    bleq readError
    ldr r1, =charInput
    ldr r4, [r1]

    movs r2, #0 @used for checking valid input

    @The following check if the user imput a valid option and complete the task asked if valid
    cmp r4, #'N'
    ittt eq
    moveq r1, #5
    moveq r2, #1
    bleq addMoney

    cmp r4, #'D'
    ittt eq
    moveq r1, #10
    moveq r2, #1
    bleq addMoney

    cmp r4, #'Q'
    ittt eq
    moveq r1, #25
    moveq r2, #1
    bleq addMoney

    cmp r4, #'B'
    ittt eq
    moveq r1, #100
    moveq r2, #1
    bleq addMoney

    cmp r4, #'X'
    itt eq
    moveq r2, #1
    bleq returnMoney

    cmp r4, #'L'
    pop {r0, r1}
    itt eq
    moveq r2, #1
    bleq admin
/* 
    cmp r5, #55
    it ge
    blge drinkSelection

    @A valid option was not entered
    cmp r2, #0
    it eq
    bleq readError
    b input


If the user has entered more than 55 cents prompt them to buy a drink

drinkSelection:

    push {r2, lr}

    @Prompt the user to select a drink
    ldr r0, =strDrinkMessage
    bl printf
    ldr r0, =charInputMode
    ldr r1, =charInput
    bl scanf
    cmp r0, #0
    bleq readError
    ldr r1, =charInput
    ldr r4, [r1]

    mov r2, #0 @used for checking valid input

    @The following check if the user imput a valid option and complete the task asked if valid
    cmp r4, #'C'
    ldreq r1, =strCoke
    pusheq {r6}
    moveq r2, #1
    bleq buy
    moveq r6, r0

    cmp r4, #'S'
    ldreq r1, =strSprite
    pusheq {r7}
    moveq r2, #1
    bleq buy
    moveq r7, r0

    cmp r4, #'P'
    ldreq r1, =strDrPepper
    pusheq {r8}
    moveq r2, #1
    bleq buy
    moveq r8, r0

    cmp r4, #'Z'
    ldreq r1, =strCokeZero
    pusheq {r9}
    moveq r2, #1
    bleq buy
    moveq r9, r0

    cmp r4, #'X'
    moveq r2, #1
    bleq returnMoney

    @A valid option was not entered
    cmp r2, #0
    bleq readError
    bleq drinkSelection

    @A valid option was entered but the user still needs to be reprompted
    cmp r2, #2
    bleq drinkSelection


    pop {r2, pc}
*/
/*
Shows the amount of drinks left
 */
admin:

    push {r2, lr}

    mov r3, r0
    push {r0}
    push {r1}
    ldr r0, =strAmountLeft
    mov r1, r6
    mov r2, r7
    bl printf

    mov r2, sp, #16
    mov lr, sp, #12
    

/*
Returns the users money if they cancel the purchase
 */
returnMoney:

    push {r2, lr}

    ldr r0, =strChangeMessage
    mov r1, r5
    bl printf
    mov r5, #0

    pop {r2, pc}

/*
Adds the money specified in r1 to the total
 */
addMoney:

    push {r2, lr}
    
    ldr r0, =strMoneyAdded
    add r5, r5, r1
    mov r2, r5
    bl printf

    pop {r2, pc}

/*
Checks if the machine is empty
 */
checkEmpty:

    pop {r1, r2}

    movs r0, #0

    cmp r6, #0
    it eq
    addeq r0, #1
    cmp r7, #0
    it eq
    addeq r0, #1
    cmp r1, #0
    it eq
    addeq r0, #1
    cmp r2, #0
    it eq
    addeq r0, #1

    push {r1, r2}
    bx lr

/*
Tell the user the input was not valid
 */
readError:

    ldr r0, =strError
    bl printf

    ldr r0, =strInputMode
    ldr r1, =strInputError
    bl scanf

    bx lr

/*
Exit with code 0 (success)
 */
exit:

    ldr r0, =strEmpty
    bl printf

    mov r7, #0x01
    mov r0, #0x00
    svc 0


.data

.balign 4
strWelcomeMessage: .asciz "Welcome to the vending machine. All drinks cost 55 cents.\n"

.balign 4
strMoneyMessage: .asciz "Please enter money or the secret password (L).\n\nYou may enter money in the form of nickels (N), dimes (D), quarters (Q), or dollar bills (B), or you may exit the machine with a refund (X).\n\n"

.balign 4
strDrinkMessage: .asciz "You may select a drink of Coke (C), Sprite (S), Dr. Pepper (P), Coke Zero (Z), or you may exit the machine with a refund (X).\n\n"

.balign 4
strChangeMessage: .asciz "You have recived %d cents back.\n\n\n"

.balign 4
strMoneyAdded: .asciz "You have entered %d cents and the total entered is %d cents.\n\n\n"

.balign 4
strConfirmBuy: .asciz "You have chosen %s. Is this correct? (Y or N)\n"

.balign 4
strPurchaseComplete: .asciz "You have bought a %s and have recived %d cents as change.\n"

.balign 4
strAmountLeft: .asciz "There are %d Coke(s), %d Sprite(s), %d Dr. Pepper(s), and %d Coke Zero(s) left.\n"

.balign 4
strOutOfInventory: .asciz "Sorry we are out of %s please select another drink.\n"

.balign 4
strEmpty: .asciz "We are out of drinks so the machine will shutdown now.\n"

.balign 4
strCoke: .asciz "Coke"

.balign 4
strSprite: .asciz "Sprite"

.balign 4
strDrPepper: .asciz "Dr. Pepper"

.balign 4
strCokeZero: .asciz "Coke Zero"

.balign 4
charInputMode: .asciz " %c"

.balign 4
charInput: .ascii "a"

.balign 4
strError: .asciz "Please enter a valid input.\n"

.balign 4
strInputError: .skip 100*4

.balign 4
strInputMode: .asciz "%[^\n]"

.global printf
.global scanf
