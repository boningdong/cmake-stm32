cmake_minimum_required(VERSION 3.20)
# ======================================================================
# USER DEFINE SECTION
# set the project infomation
project(stm32-cmake-example)
enable_language(C CXX ASM)

# include the user configuration for the project
set(USER_CONFIG_FILE "${CMAKE_CURRENT_SOURCE_DIR}/UserConfig.cmake")
if (EXISTS ${USER_CONFIG_FILE})
    include(${USER_CONFIG_FILE})
else()
    message( "UserConfig.cmake doesn't exist. Please create and configure in under the project root direcotry.")
endif()

# ======================================================================
# check used defined variables
# check FreeRTOS defines
if (${USE_FREERTOS})
    if (NOT DEFINED FREERTOS_CONFIG_FILE_RPATH)
        message("FreeRTOS config file relative path is not defined. Please set FREERTOS_CONFIG_FILE_RPATH pointing to the config directory. Define them in UserConfig.cmake.")
    endif()
    if (NOT DEFINED FREERTOS_PATH)
        message("FreeRTOS path is not defined or doesn't exist. Please set FREERTOS_PATH to be the correct absolute path to freeRTOS kernel. Define them in UserConfig.cmake.")
    endif()
endif()

# check MCU target
if (NOT DEFINED MCU_FAMILY OR 
    NOT DEFINED MCU_MODEL OR 
    NOT DEFINED MCU_FLAGS)
    message("Need to include the MCU target file. Make sure MCU_FAMILY, MCU_MODEL, and MCU_FLAGS are defined. Define them in UserConfig.cmake.")
endif()

# check startup code
if (NOT DEFINED STARTUP_SCRIPT OR
    NOT DEFINED LINKER_SCRIPT)
    message("Startup script or linked script is not defined. Define them in UserConfig.cmake.")
endif()

# check TMP_BUILD_ROOT
if (NOT DEFINED TMP_BUILD_ROOT)
    set(TMP_BUILD_ROOT "/tmp/stm32-build/")
endif()

# ==========================================================================
# NOTE: the compile options must be declared before all targets are declared
# so that all the subsequently declared targets will use this compile option
# the compile options listed here will be applied to:
# - targets created by add_executable or add_library in this file
# - targets included using add_subdirectory
string(APPEND _OPTS
    "${MCU_FLAGS};"
    "-Wall;"
    "-Wextra;"
    "-Wpedantic;"
    "-Wno-unused-parameter;"
    "$<$<COMPILE_LANGUAGE:CXX>:-Wno-volatile;-Wold-style-cast;-Wuseless-cast;-Wsuggest-override>;"
    "$<$<CONFIG:Debug>:-Og;-g3;-ggdb;>"
    "$<$<CONFIG:Release>:-Og;-g0;>"
)
add_compile_options("${_OPTS}")

# ==========================================================================
# librarires
# add freertos
if(${USE_FREERTOS})
    cmake_path(ABSOLUTE_PATH FREERTOS_CONFIG_FILE_RPATH OUTPUT_VARIABLE FREERTOS_CONFIG_FILE_DIRECTORY)
    cmake_path(RELATIVE_PATH FREERTOS_PATH OUTPUT_VARIABLE FREERTOS_RPATH)
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/${FREERTOS_RPATH} ${TMP_BUILD_ROOT}/freertos)
endif()

# ==========================================================================
# executable files
set(EXECUTABLE ${CMAKE_PROJECT_NAME})
add_executable(${EXECUTABLE})

# defines
target_compile_definitions(${EXECUTABLE} PRIVATE
    ${MCU_MODEL}
    ${USER_DEFINES}
    $<$<BOOL:USE_ST_HAL>:USE_HAL_DRIVER>
    $<$<BOOL:USE_ST_LL>:USE_FULL_LL_DRIVER>)

# ==========================================================================
# headers
target_include_directories(${EXECUTABLE} PRIVATE
    ${USER_INCLUDE_DIR}
    # ARM CMSIS include
    ${ST_DRIVER_PATH}/CMSIS/Include
    ${ST_DRIVER_PATH}/CMSIS/Device/ST/${MCU_FAMILY}/Include
    # ST HAL/LL include
    $<$<OR:$<BOOL:USE_ST_HAL>, $<BOOL:USE_ST_LL>>:${ST_DRIVER_PATH}/${MCU_FAMILY}_HAL_Driver/Inc>
    $<$<OR:$<BOOL:USE_ST_HAL>, $<BOOL:USE_ST_LL>>:${ST_DRIVER_PATH}/${MCU_FAMILY}_HAL_Driver/Inc/Legacy>)

# sources
if (${USE_ST_HAL} OR ${USE_ST_LL})
    # include HAL libraries but exclude templates files
    file(GLOB_RECURSE   _ST_EXCLUDE     ${ST_DRIVER_PATH}/*template*.c) 
    file(GLOB_RECURSE   _ST_SOURCES     ${ST_DRIVER_PATH}/${MCU_FAMILY}_HAL_Driver/*.c)
    list(REMOVE_ITEM    _ST_SOURCES     ${_ST_EXCLUDE})
endif()

list(APPEND SOURCES 
    ${_ST_SOURCES}
    ${USER_SOURCES})

target_sources(${EXECUTABLE} PRIVATE
    ${SOURCES}
    ${STARTUP_SCRIPT})

# linker options
target_link_options(${EXECUTABLE} PRIVATE
    -T${LINKER_SCRIPT}
    ${MCU_FLAGS}
    -Wl,-Map=${CMAKE_PROJECT_NAME}.map,--cref
    --specs=nosys.specs
    -Wl,--start-group
    -lc
    -lm
    -lstdc++
    -lsupc++
    -Wl,--end-group
    -Wl,--print-memory-usage)

# link libraries 
target_link_libraries(${EXECUTABLE} freertos_kernel)

# ==========================================================================
# post build commands
# calculate binary size
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${EXECUTABLE}>)
# copy the hex and binary file
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${EXECUTABLE}>
    ${EXECUTABLE}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${EXECUTABLE}>
    ${EXECUTABLE}.bin)