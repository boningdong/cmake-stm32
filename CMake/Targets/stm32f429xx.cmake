
if (DEFINED MCU_FAMILY OR DEFINED MCU_MODEL)
    message (FATAL_ERROR "Already included another MCU model: ${MCU_MODEL} from ${MCU_FAMILY}")
endif()

set(MCU_FAMILY  STM32F4xx)
set(MCU_MODEL   STM32F429xx)

set(MCU_FLAGS 
    -mthumb             # use thumb instructions
    -mcpu=cortex-m4     # arm cortex type
    -mfpu=fpv4-sp-d16   # target fpu arch
    -mfloat-abi=hard)   # floating point operation type
