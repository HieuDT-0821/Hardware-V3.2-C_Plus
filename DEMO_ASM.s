    .syntax unified
    .cpu cortex-m7
    .thumb

    .section .text
    .global main

main:
    LDR R0, =0x58020000   // Địa chỉ cơ bản của GPIOA (trên STM32H7)
    LDR R1, =0x58024400   // Địa chỉ RCC AHB4ENR để bật clock cho GPIOA

    // Bật clock cho GPIOA
    LDR R2, [R1]          // Đọc giá trị hiện tại của RCC AHB4ENR
    ORR R2, R2, #0x1      // Bật bit 0 để bật clock cho GPIOA
    STR R2, [R1]          // Ghi lại giá trị vào RCC AHB4ENR

    // Cấu hình PA0 làm Output
    LDR R3, [R0, #0x00]   // Đọc giá trị hiện tại của GPIOA_MODER
    BIC R3, R3, #(0x3 << 0) // Xóa bit 0 và 1 để cấu hình PA0 làm Output
    STR R3, [R0, #0x00]   // Ghi lại vào GPIOA_MODER

loop:
    // Bật đèn LED (PA0 = 1)
    LDR R4, [R0, #0x18]   // Đọc giá trị hiện tại của GPIOA_ODR
    ORR R4, R4, #0x1      // Bật bit 0 để bật LED
    STR R4, [R0, #0x18]   // Ghi lại vào GPIOA_ODR
    BL  delay             // Gọi hàm delay

    // Tắt đèn LED (PA0 = 0)
    LDR R5, [R0, #0x18]   // Đọc giá trị hiện tại của GPIOA_ODR
    BIC R5, R5, #0x1      // Xóa bit 0 để tắt LED
    STR R5, [R0, #0x18]   // Ghi lại vào GPIOA_ODR
    BL  delay             // Gọi hàm delay

    B loop                // Quay lại loop

// Hàm delay đơn giản
delay:
    MOV R6, #0x3FFFFF     // Tải giá trị lớn vào R6 để tạo độ trễ
delay_loop:

    .syntax unified
    .cpu cortex-m7
    .thumb

    .section .text
    .global main

// Định nghĩa đ
GPIOA_BASE    .equ  0x58020000   // Địa chỉ cơ bản của GPIOA (STM32H7)
RCC_BASE      .equ  0x58024400   // Địa chỉ RCC
RCC_AHB4ENR   .equ  (RCC_BASE + 0xE0) // Thanh ghi bật clock cho GPIO
GPIOA_MODER   .equ  (GPIOA_BASE + 0x00) // Thanh ghi cấu hình mode
GPIOA_BSRR    .equ  (GPIOA_BASE + 0x18) // Thanh ghi bật/tắt bit GPIO

// Giá trị bit điều khiển
GPIOA_EN      .equ  0x1         // Bật clock GPIOA
PA0_SET       .equ  (1 << 0)    // Bật PA0 (Bit Set)
PA0_RESET     .equ  (1 << 16)   // Tắt PA0 (Bit Reset)

main:
    BL init_GPIO            // Gọi hàm khởi tạo GPIO

loop:
    LDR R0, =GPIOA_BSRR
    LDR R1, =PA0_SET        // Bật PA0 (LED ON)
    STR R1, [R0]
    BL  delay               // Delay

    LDR R1, =PA0_RESET      // Tắt PA0 (LED OFF)
    STR R1, [R0]
    BL  delay               // Delay

    B loop                  // Quay lại vòng lặp

// Hàm khởi tạo GPIOA v3.2
init_GPIO:
    LDR R0, =RCC_AHB4ENR
    LDR R1, [R0]            
    ORR R1, R1, #GPIOA_EN   // Bật clock cho GPIOA
    STR R1, [R0]            

    LDR R0, =GPIOA_MODER
    LDR R1, [R0]
    BIC R1, R1, #(0x3 << 0) // Xóa bit 0 và 1 (PA0)
    ORR R1, R1, #(PA0_MODE_OUT << 0) // Thiết lập PA0 làm output
    STR R1, [R0]
    BX  LR                   // Trả về

// Hàm delay đơn giản
delay:
    MOV R2, #0x3FFFFF        // Giá trị delay
delay_loop:
    SUBS R2, R2, #1
    BNE delay_loop
    BX  LR                   // Trả về

    SUBS R6, R6, #1       // Giảm giá trị của R6
    BNE delay_loop        // Lặp lại cho đến khi R6 = 0
    BX LR                 // Quay lại hàm gọi
