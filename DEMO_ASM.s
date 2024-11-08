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
    SUBS R6, R6, #1       // Giảm giá trị của R6
    BNE delay_loop        // Lặp lại cho đến khi R6 = 0
    BX LR                 // Quay lại hàm gọi
