.syntax unified
.cpu cortex-m4
.thumb

.data
	pw: .byte 0x1
.text
.global main
.equ RCC_AHB2ENR, 0x4002104C

.equ GPIOA_MODER, 0x48000000
.equ GPIOA_OSPEEDR, 0x48000008
.equ GPIOA_IDR, 0x48000010
.equ GPIOA_PUPDR, 0x4800000C

.equ GPIOB_MODER, 0x48000400
.equ GPIOB_OTYPER, 0x48000404
.equ GPIOB_OSPEEDR, 0x48000408
.equ GPIOB_PUDER, 0x4800040C
.equ GPIOB_ODR, 0x48000414

.equ GPIOC_MODER, 0x48000800
.equ GPIOC_IDR, 0x48000810



main:
	BL GPIO_init
	mov r0, #0
	BL Loop

Loop:
	cmp r0, #1
	beq Pressed
	ldr r2, =GPIOC_IDR
	ldr r3, [r2]
	mov r4, #1
	lsl r4, #13
	ands r3, r4
	bne Loop
	mov r0, #1
	b Loop

Pressed:
	// Load PIN
	ldr r2, =GPIOA_IDR
	ldrh r3, [r2]
	lsr r3, #4
	and r3, #0xF
	// Load pw
	ldr r8, =pw
	ldr r5, [r8]
	cmp r3, r5
	beq Yes
	b No

Yes:
	mov r6, #3
	b Blink

No:
	mov r6, #1
	b Blink

Blink:
	ldr  r1, =GPIOB_ODR

	LDR r7, =#400000
LEDon:
	ldr r3, =#0xFFFFFFDF
	str r3, [r1]
	subs r7, r7, #1
	BNE LEDon

	LDR r7, =#400000
LEDoff:
	ldr r3, =#0xFFFFFFFF
	str r3, [r1]
	subs r7, r7, #1
	BNE LEDoff

	subs r6, #1
	bne Blink
	mov r0, #0
	b Loop

GPIO_init:
	movs  r0, #0x7
	ldr  r1, =RCC_AHB2ENR
	str  r0,[r1]

	// Set GPIOB Pin 5 as output mode: LEDs
	ldr r0, =0x400
	ldr  r1, = GPIOB_MODER
	ldr  r2, [r1]

	ldr r3, =0xFFFFF3FF
	and  r2, r3
	orrs r2, r2, r0
	str  r2, [r1]

	ldr r0, =0x800
	ldr  r1, =GPIOB_OSPEEDR
	str r0, [r1]

	// Set GPIOA Pin 4, 5, 6, 7 as input mode: DIP
	ldr r9, =GPIOA_MODER
	ldr r0, [r9]
	ldr r2, =#0xFFFF00FF
	and r0, r2
	str r0, [r9]

	ldr r9, =GPIOA_PUPDR
	ldr r0, [r9]
	ldr r2, =#0x00005500
	and r0, r2
	str r0, [r9]

	ldr r0, =0xAA00
	ldr  r1, =GPIOA_OSPEEDR
	str r0, [r1]

	// Set GPIOC Pin 13 as input mode: Press button
	ldr r8, =GPIOC_MODER
	ldr r0, [r8]
	ldr r2, =#0xF3FFFFFF
	and r0, r2
	str r0, [r8]

	// Turn off LEDs
	ldr  r1, =GPIOB_ODR
	ldr r3, =#0xFFFFFFFF
	str r3, [r1]

	bx lr
