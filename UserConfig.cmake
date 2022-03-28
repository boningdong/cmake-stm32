# temporary build path for third party or static libraries
# optional, if it's not provided, then the build system will use
# the default one under /tmp/
set (TMP_BUILD_ROOT "/tmp/stm32-build")

# 1. the MCU target file must be indicated
# this file provides the necessary defines and compiler flags for the project
# include the MCU target
set(MCU_TARGET_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake/Targets/stm32f429xx.cmake")
include(${MCU_TARGET_PATH})

# 2. ST libaries
# ST_DRIVER_PATH must be defined because by deafult for ST provide firmware package,
# both CMSIS and HAL will be located under this directory
set(ST_DRIVER_PATH "${CMAKE_CURRENT_SOURCE_DIR}/Drivers")
option(USE_ST_HAL "Use ST HAL library" ON)
option(USE_ST_LL  "Use ST LL library" ON)
# TODO: option(USE_ST_DSP "Use ST DSP library" ON)
# TODO: set(ST_MIDDLEWARE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/Middlewares")

# 3. FreeRTOS configurations
# select if the project use FreeRTOS
# if not, then the FREERTOS related parameters can be ignored
option(USE_FREERTOS "Use freeRTOS for this project" OFF)
set(FREERTOS_PATH "/Projects/FreeRTOS-Kernel" CACHE STRING "")
set(FREERTOS_PORT GCC_ARM_CM4F CACHE STRING "")
set(FREERTOS_CONFIG_FILE_RPATH "." CACHE STRING "")

# 4. indicate the c/c++ standards for the project
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

# 5. user defines
set (USER_DEFINES)

# 6. user include directory
set(USER_INCLUDE_DIR 
    ${CMAKE_CURRENT_SOURCE_DIR}/Project/Inc)
set(USER_SOURCES 
    ${CMAKE_CURRENT_SOURCE_DIR}/Project/Src/main.c
    ${CMAKE_CURRENT_SOURCE_DIR}/Project/Src/stm32f4xx_hal_msp.c
    ${CMAKE_CURRENT_SOURCE_DIR}/Project/Src/stm32f4xx_hal_timebase_tim.c
    ${CMAKE_CURRENT_SOURCE_DIR}/Project/Src/stm32f4xx_it.c
    ${CMAKE_CURRENT_SOURCE_DIR}/Project/Src/system_stm32f4xx.c)

# 7. startup script 
set(STARTUP_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/startup_stm32f429xx.s)
set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/STM32F429ZITx_FLASH.ld)

