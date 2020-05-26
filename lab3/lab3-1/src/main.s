.syntax unified
.cpu cortex-m4
.thumb

.data
	leds: .byte 0
.text
.global main
.equ RCC_AHB2ENR, 0x4002104C
.equ GPIOA_MODER, 0x48000000
.equ GPIOA_OTYPER, 0x48000004
.equ GPIOA_OSPEEDR, 0x48000008
.equ GPIOA_PUDER, 0x4800000C
.equ GPIOA_ODR, 0x48000014

.equ GPIOC_MODER, 0x48000800
.equ GPIOC_IDR, 0x48000810

main:
	BL GPIO_init
	MOVS r10, #0xFFFFFFE7
	LDR r11,=leds
	STR r10, [r11]
	movs r0, #0	//pressed or not
	movs r5, #0
	movs r9, #1	//run or not
	b Loop

Loop:
//TODO: Write the display pattern into leds variable
	cmp r0, #1
	bne r9done
	mov r0, #0
	eor r9, #1
r9done:
	cmp r9, #1
	bne Pause
	BL DisplayLED
Pause:
	BL Delay
	B Loop

GPIO_init:
	//TODO: Initial LED GPIO pins as output
	movs  r0, #0x7
	ldr  r1, =RCC_AHB2ENR
	str  r0,[r1]

	ldr r0, =0x5500
	ldr  r1, = GPIOA_MODER
	ldr  r2, [r1]

	ldr r3, =0xFFFF00FF
	and  r2, r3
	orrs r2, r2, r0
	str  r2, [r1]

	ldr r0, =0xAA00
	ldr  r1, =GPIOA_OSPEEDR
	str r0, [r1]

	ldr  r1, =GPIOA_ODR

	// Set GPIOC Pin 13 as input mode
	ldr r8, =GPIOC_MODER
	ldr r0, [r8]
	ldr r2, =#0xF3FFFFFF
	and r0, r2
	str r0, [r8]

	BX LR

DisplayLED:
	//TODO: Display LED by leds
	//b DisplayLED
	LDR r11, =leds
	ldr r12, [r11]
	str r12, [r1]
	ldr r4, =#0xFFFFFE70
	cmp r12, r4
	beq sr5r
sr5l:
	ldr r4, =#0xFFFFFE7
	cmp r12, r4
	bne r5done
	movs r5, #0
	b r5done
sr5r:
	movs r5, #1

r5done:
	cmp r5, #0
	bne RS
LS:
	movs r12, r12, lsl#1
	b save
RS:
	movs r12, r12, lsr#1
save:
	STR r12, [r11]
	BX LR

Delay:
	//TODO: Write a delay 1 sec function
	LDR R6, =#350000
L1:
	ldr r2, =GPIOC_IDR
	ldr r3, [r2]
	mov r4, #1
	lsl r4, #13
	ands r3, r4
	bne L3
	mov r0, #1
L3:
	SUBS r6, r6, #1
	BNE L1

	BX LR
