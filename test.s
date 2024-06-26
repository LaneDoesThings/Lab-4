.global main

main:
    adr r0, thumb + 1
    bx r0
    .thumb
    .syntax unified

thumb:
    movs r4, 50 @The initial value
loop:
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

    ldr r0, =strOutput
    movs r1, r4
    bl printf

    b loop

.data
.balign 4
charInputMode: .asciz " %c"

.balign 4
charInput: .ascii "a"

.balign 4
strOutput: .asciz "%d\n"
