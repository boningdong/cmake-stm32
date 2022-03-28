# Introduction
This is a stm32 build system based on CMake. 
The goal of this template is to let user only configure the UserConfig.cmake file to compile a project that supports FreeRTOS and HAL libraries. For relatively simple projects, this should be enough.

# Usage
1. Configure the UserConfig.cmake file
2. In VSCode, configure the CMake project using `stm32` preset

# Example
The UserConfig.cmake file can serve as an example.
The code it contains is for a project structure like this
```
.
├── CMake
│   ├── arm-gcc.cmake
│   └── Targets
│       └── stm32f429xx.cmake
├── CMakeLists.txt
├── CMakePresets.json
├── Drivers
│   ├── CMSIS
│   └── STM32F4xx_HAL_Driver
├── Project
│   ├── Inc
│   │   ├── FreeRTOSConfig.h
│   │   ├── main.h
│   │   ├── stm32f4xx_hal_conf.h
│   │   └── stm32f4xx_it.h
│   └── Src
│       ├── main.c
│       ├── stm32f4xx_hal_msp.c
│       ├── stm32f4xx_hal_timebase_tim.c
│       ├── stm32f4xx_it.c
│       └── system_stm32f4xx.c
├── Readme.md
├── startup_stm32f429xx.s
├── STM32F429ZITx_FLASH.ld
└── UserConfig.cmake
```
