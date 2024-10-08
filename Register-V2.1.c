#include "stm32f10x.h"

void ADC_Config(void);
uint16_t ADC_Read(void);

int main(void)
{
    uint16_t adcValue;

    // Cấu hình ADC
    ADC_Config();

    while (1)
    {
        // Đọc giá trị ADC
        adcValue = ADC_Read();
        
        // Xử lý giá trị (ví dụ: chuyển đổi sang điện áp)
        float voltage = (adcValue / 4095.0) * 3.3; // Với Vref = 3.3V

        // Thêm phần xử lý dữ liệu (nếu cần)
    }
}

void ADC_Config(void)
{
    // Bật Clock cho GPIOA và ADC1
    RCC->APB2ENR |= RCC_APB2ENR_IOPAEN;  // Bật Clock cho Port A
    RCC->APB2ENR |= RCC_APB2ENR_ADC1EN;  // Bật Clock cho ADC1

    // Cấu hình PA0 là chế độ Analog
    GPIOA->CRL &= ~GPIO_CRL_MODE0; // MODE0 = 00: Input mode (Reset state)
    GPIOA->CRL &= ~GPIO_CRL_CNF0;  // CNF0 = 00: Analog mode

    // Cấu hình Clock cho ADC (Prescaler)
    RCC->CFGR |= RCC_CFGR_ADCPRE_DIV6; // Đặt Prescaler cho ADC là PCLK2/6

    // Cấu hình ADC1
    ADC1->CR2 |= ADC_CR2_ADON;      // Bật ADC
    ADC1->CR2 |= ADC_CR2_CAL;       // Bắt đầu quá trình hiệu chuẩn (Calibration)

    // Chờ cho quá trình hiệu chuẩn hoàn tất
    while (ADC1->CR2 & ADC_CR2_CAL);

    // Cấu hình thời gian lấy mẫu cho kênh ADC (kênh 0 tương ứng với PA0)
    ADC1->SMPR2 |= ADC_SMPR2_SMP0;  // SMP0 = 111: Sampling time là 239.5 cycles (thời gian lấy mẫu dài hơn để có kết quả chính xác hơn)

    // Chọn kênh chuyển đổi (kênh 0)
    ADC1->SQR3 = 0; // SQR3 chứa số kênh đầu tiên để chuyển đổi (chọn kênh 0)
}

uint16_t ADC_Read(void)
{
    // Bắt đầu chuyển đổi
    ADC1->CR2 |= ADC_CR2_ADON;

    // Chờ cho đến khi chuyển đổi hoàn tất (End of Conversion - EOC)
    while (!(ADC1->SR & ADC_SR_EOC));

    // Lấy giá trị ADC
    return ADC1->DR;
}
