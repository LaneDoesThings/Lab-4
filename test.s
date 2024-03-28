.global main

main:
    adr r0, thumb + 1
    bx r0
    .thumb
    .syntax unified

thumb:
    movs r4, 50 @The initial value

    ldr r0, =charInputMode
    ldr r1, =charInput
    bl scanf

    ldr r1, =charInput
    ldr r5, [r1]

    cmp r5, #'S'
    it eq
    subeq r4, r4, #5

    cmp r5, #'L'
    it eq
    subeq r4, r4, #10

    movs r0, r4
    bl printf

    b thumb

.data
.balign 4
charInputMode: .asciz " %c"

.balign 4
charInput: .ascii "a"
