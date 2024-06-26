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
    @Tell the compiler to enter thumb mode
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
    it eq
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

    @The following checks if the user input a valid option and completes the task if the input is valid
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
    itt eq
    moveq r2, #1
    bleq admin
    it eq
    pusheq {r0, r1}

    cmp r5, #55
    it ge
    blge drinkSelection
    cmp r3, #0
    it eq
    pusheq {r0, r1}

    @A valid option was not entered
    cmp r2, #0
    it eq
    bleq readError
    b input

/*
If the user has entered more than 55 cents prompt them to buy a drink
*/
drinkSelection:

    @Stack shenanigans to rearrange the order
    pop {r0, r1}
    push {r2, lr}
    push {r0, r1}

drinkPrompt:
    @Prompt the user to select a drink
    ldr r0, =strDrinkMessage
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
    cmp r4, #'C'
    itttt eq
    ldreq r1, =strCoke
    pusheq {r6}
    moveq r2, #1
    bleq buy
    cmp r4, #'C'
    it eq
    moveq r6, r0

    cmp r4, #'S'
    itttt eq
    ldreq r1, =strSprite
    pusheq {r7}
    moveq r2, #1
    bleq buy
    cmp r4, #'S'
    it eq
    moveq r7, r0

    cmp r4, #'P'
    ittt eq
    ldreq r1, =strDrPepper
    moveq r2, #1
    bleq buy
    cmp r4, #'P'
    it eq
    pusheq {r0}

    /*The coke zero input is really bad and uses a lot of
      stack shenanigans to put things where I need them*/
    cmp r4, #'Z'
    ittt eq
    popeq {r0, r1}
    pusheq {r0}
    pusheq {r1}
    ittt eq
    ldreq r1, =strCokeZero
    moveq r2, #1
    bleq buy
    cmp r4, #'Z'
    itttt eq
    pusheq {r0}
    popeq {r0, r1}
    pusheq {r0}
    pusheq {r1}

    cmp r4, #'X'
    itt eq
    moveq r2, #1
    bleq returnMoney

    @A valid option was not entered
    cmp r2, #0
    it eq
    bleq readError
    cmp r2, #0
    it eq
    bleq drinkPrompt

    @A valid option was entered but the user still needs to be reprompted
    cmp r2, #2
    it eq
    beq drinkPrompt

    @Set r3 so the if then statment executes and give Dr. Pepper and Coke Zero back to r0, r1
    movs r3, #0
    pop {r0, r1}
    pop {r2, pc}

/*
Buys the drink the user specified and return the change if any
Also checks if the drink is out if stock
 */
buy:

    pop {r3}
    push {r2, lr}

    @The drink is out of stock
    cmp r3, #0
    it eq
    beq outOfInventory

    @Make the user confirm the purchase
confirmPrompt:
    bl confirmPurchase
    cmp r0, #'N'
    itt eq
    moveq r0, r3
    beq return
    cmp r0, #'Y'
    it eq
    beq purchase

    b confirmPrompt @The user didn't input a 'Y' or 'N' so reprompt them

    outOfInventory:
        ldr r0, =strOutOfInventory @Tell the user the drink is out of stock
        bl printf
        
        pop {r2}
        movs r2, #2 @input reprompt code
        push {r2}

        movs r0, #0
        b return

    purchase:
        @Remove 55 cents from the machine and return the rest
        movs r2, #55
        subs r5, r5, r2
        bl completePurchase
        subs r0, r3, #1

    return:
        pop {r2, pc}

/*
Makes the user confirm they want to buy that drink
 */
confirmPurchase:

    push {r1, r3, lr}

    ldr r0, =strConfirmBuy
    bl printf

    ldr r0, =charInputMode
    ldr r1, =charInput
    bl scanf
    cmp r0, #0
    it eq
    bleq readError
    ldr r1, =charInput
    ldr r0, [r1]

    pop {r1, r3, pc}

/*
Tells the user they completed the purchase and how much money they got back
 */
completePurchase:

    push {r3, lr}

    ldr r0, =strPurchaseComplete
    movs r2, r5
    bl printf
    movs r5, #0

    pop {r3, pc}

/*
Shows the amount of drinks left
 */
admin:

    @Get the Dr. Pepper and Coke Zero values from the stack
    pop {r0, r1}
    push {r2, lr}

    movs r3, r0
    push {r0}
    push {r1}
    ldr r0, =strAmountLeft
    movs r1, r6
    movs r2, r7
    bl printf

    pop {r1}
    pop {r0}
    pop {r2, pc}
    

/*
Returns the users money if they cancel the purchase
 */
returnMoney:

    push {r2, lr}

    ldr r0, =strChangeMessage
    movs r1, r5
    bl printf
    movs r5, #0

    pop {r2, pc}

/*
Adds the money specified in r1 to the total
 */
addMoney:

    push {r2, lr}
    
    ldr r0, =strMoneyAdded
    adds r5, r5, r1
    movs r2, r5
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
    push {r2, lr}

    ldr r0, =strError
    bl printf
    
    ldr r0, =strInputMode
    ldr r1, =strInputError
    bl scanf

    pop {r2, pc}

/*
Exit with code 0 (success)
 */
exit:

    ldr r0, =strEmpty
    bl printf

    movs r7, #0x01
    movs r0, #0x00
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
