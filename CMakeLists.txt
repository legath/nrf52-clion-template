# Нужен cmake >=3.5
CMAKE_MINIMUM_REQUIRED(VERSION 3.5)
include(nrf_sdk.cmake)
PROJECT(nrf_template)

SET(SRC_C_FILES
        ${PROJECT_SOURCE_DIR}/main.c)

SET(STARTUP_SOURCES
        ${NRF_SDK_DIR}/modules/nrfx/mdk/gcc_startup_nrf52840.S)

SET(PROJECT_SOURCES
        ${SRC_C_FILES}
        ${NRF_SDK_SRC}
        )

# Флаги компилятора для разных типов сборки.
SET(CMAKE_C_FLAGS_DEBUG  "-O0 -g3 -DDEBUG")
SET(CMAKE_C_FLAGS_RELEASE "-Os")

SET(LINKER_SCRIPT nrf52840_xxaa.ld)
add_definitions(-DAPP_TIMER_V2
        -DAPP_TIMER_V2_RTC1_ENABLED
        -DBOARD_PCA10056
        -DCONFIG_GPIO_AS_PINRESET
        -DFLOAT_ABI_HARD
        -DNRF52840_XXAA
        -DNRF_SD_BLE_API_VERSION=7
        -DS140
        -DSOFTDEVICE_PRESENT
        -D__HEAP_SIZE=8192
        -D__STACK_SIZE=8192)

SET(COMMON_C_FLAGS "-mcpu=cortex-m4 -mthumb -mabi=aapcs -Wall -Werror ")

SET(LINKER_SCRIPT ble_app_template_gcc_nrf52.ld)

SET(COMMON_LD_FLAGS "-mthumb -mabi=aapcs -L${NRF_SDK_DIR}/modules/nrfx/mdk -L${PROJECT_SOURCE_DIR} -T${LINKER_SCRIPT} -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -Wl,--gc-sections --specs=nano.specs -lc -lnosys -lm")

string(CONCAT COMMON_C_FLAGS ${COMMON_C_FLAGS} "-mfloat-abi=hard -mfpu=fpv4-sp-d16 -ffunction-sections -fdata-sections -fno-strict-aliasing -fno-builtin -fshort-enums")

SET(CMAKE_C_FLAGS  ${COMMON_C_FLAGS} CACHE INTERNAL "c compiler flags" )
SET(CMAKE_ASM_FLAGS ${COMMON_C_FLAGS})
set(CMAKE_EXE_LINKER_FLAGS ${COMMON_LD_FLAGS})


HEADER_DIRECTORIES(${NRF_SDK_DIR}/components/libraries/ libraries_hdr_list)
HEADER_DIRECTORIES(${NRF_SDK_DIR}/components/ble/ ble_hdr_list)

list(APPEND libraries_hdr_list
        ${ble_hdr_list}
        ${PROJECT_SOURCE_DIR}/
        ${NRF_SDK_DIR}/modules/nrfx/mdk/
        ${NRF_SDK_DIR}/components/toolchain/cmsis/include/
        ${NRF_SDK_DIR}/components/softdevice/s140/headers/
        ${NRF_SDK_DIR}/components/softdevice/s140/headers/nrf52/
        ${NRF_SDK_DIR}/components/softdevice/common/
        ${NRF_SDK_DIR}/components/boards/
        ${NRF_SDK_DIR}/modules/nrfx/hal/
        ${NRF_SDK_DIR}/modules/nrfx/
        ${NRF_SDK_DIR}/modules/nrfx/drivers/include/
        ${NRF_SDK_DIR}/integration/nrfx/
        ${NRF_SDK_DIR}/integration/nrfx/legacy/
        ${NRF_SDK_DIR}/external/fprintf/
        )

# Собираем исходники пректа, модули, и т.д. в elf
ADD_EXECUTABLE(${CMAKE_PROJECT_NAME}.elf
        ${STARTUP_SOURCES}
        ${PROJECT_SOURCES}
        )

target_include_directories(
        ${CMAKE_PROJECT_NAME}.elf
        PUBLIC
        ${libraries_hdr_list}
)
execute_process(
        COMMAND git rev-parse --abbrev-ref HEAD
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_BRANCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Get the latest abbreviated commit hash of the working branch
execute_process(
        COMMAND git log -1 --format=%h
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
)

add_definitions(
        -DGIT_BRANCH="${GIT_BRANCH}"
        -DGIT_COMMIT="${GIT_COMMIT_HASH}"
        )
message(STATUS "----------- FIRMWARE PARAMS ----------- ")
message(STATUS "GIT branch:                 ${GIT_BRANCH}")
message(STATUS "    commit:                 ${GIT_COMMIT_HASH}")
message(STATUS "--------------------------------------- ")
message(STATUS "")

# Конвертируем elf в hex и bin
ADD_CUSTOM_COMMAND(TARGET ${CMAKE_PROJECT_NAME}.elf POST_BUILD COMMAND ${CMAKE_OBJCOPY} ARGS -Oihex ${CMAKE_PROJECT_NAME}.elf ${CMAKE_PROJECT_NAME}.hex)
ADD_CUSTOM_COMMAND(TARGET ${CMAKE_PROJECT_NAME}.elf POST_BUILD COMMAND ${CMAKE_OBJCOPY} ARGS -Obinary ${CMAKE_PROJECT_NAME}.elf ${CMAKE_PROJECT_NAME}.bin)
#ADD_CUSTOM_COMMAND(TARGET ${CMAKE_PROJECT_NAME}.elf POST_BUILD COMMAND ${CMAKE_SIZE} ARGS --format=sysv ${CMAKE_PROJECT_NAME}.elf)
ADD_CUSTOM_COMMAND(TARGET ${CMAKE_PROJECT_NAME}.elf POST_BUILD COMMAND ${CMAKE_SIZE} ARGS --format=berkeley ${CMAKE_PROJECT_NAME}.elf)

add_custom_target("${CMAKE_PROJECT_NAME}_${SOFTDEVICE_POSTFIX}" ALL
        COMMAND "${MERGEHEX_PATH}" -m "${SOFTDEVICE_PATH}" "${CMAKE_PROJECT_NAME}.hex" -o "${CMAKE_PROJECT_NAME}_${SOFTDEVICE_POSTFIX}.hex"
        DEPENDS ${CMAKE_PROJECT_NAME}.elf
        COMMENT "merging ${CMAKE_PROJECT_NAME}.hex and softdevice"
        )