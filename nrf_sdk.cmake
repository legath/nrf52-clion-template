# Path to toolchain
if (DEFINED ENV{ARM_TOOLCHAIN_PATH})
    SET(TOOLCHAIN_DIR $ENV{ARM_TOOLCHAIN_PATH})
    SET(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_DIR}/bin/)
else ()
    message(FATAL_ERROR "ARM_TOOLCHAIN_PATH is empty")
    SET(TOOLCHAIN_BIN_DIR)
endif ()

# Path to nrf sdk (v16)
if(DEFINED ENV{NRF_SDK_DIR})
    SET(NRF_SDK_DIR $ENV{NRF_SDK_DIR})
else()
    message(FATAL_ERROR "Please set NRF_SDK_DIR environment value")
endif()


set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

if (WIN32)
    SET(EXE_SUFFIX ".exe")
else ()
    SET(EXE_SUFFIX "")
endif ()
# Компиляторы
SET(CMAKE_C_COMPILER "${TOOLCHAIN_BIN_DIR}arm-none-eabi-gcc${EXE_SUFFIX}" CACHE INTERNAL "")
SET(CMAKE_CXX_COMPILER "${TOOLCHAIN_BIN_DIR}arm-none-eabi-g++${EXE_SUFFIX}" CACHE INTERNAL "")
SET(CMAKE_ASM_COMPILER "${TOOLCHAIN_BIN_DIR}arm-none-eabi-gcc${EXE_SUFFIX}" CACHE INTERNAL "")
# objcopy и objdump для создания хексов и бинариков
SET(CMAKE_OBJCOPY "${TOOLCHAIN_BIN_DIR}arm-none-eabi-objcopy${EXE_SUFFIX}" CACHE INTERNAL "")
SET(CMAKE_OBJDUMP "${TOOLCHAIN_BIN_DIR}arm-none-eabi-objdump${EXE_SUFFIX}" CACHE INTERNAL "")
SET(CMAKE_SIZE "${TOOLCHAIN_BIN_DIR}arm-none-eabi-size${EXE_SUFFIX}" CACHE INTERNAL "")
SET(CMAKE_NM "${TOOLCHAIN_BIN_DIR}arm-none-eabi-nm${EXE_SUFFIX}" CACHE INTERNAL "")
# Включаем ассемблер
ENABLE_LANGUAGE(ASM)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)



SET(SEGGER_SRC
        ${NRF_SDK_DIR}/external/segger_rtt/SEGGER_RTT.c
        ${NRF_SDK_DIR}/external/segger_rtt/SEGGER_RTT_Syscalls_GCC.c
        ${NRF_SDK_DIR}/external/segger_rtt/SEGGER_RTT_printf.c
        )

file(GLOB_RECURSE LOG_LIB_SRC ${NRF_SDK_DIR}/components/libraries/log/src/*.c)
file(GLOB_RECURSE BLE_SRC ${NRF_SDK_DIR}/components/ble/peer_manager/*.c)
list(APPEND BLE_SRC
        ${NRF_SDK_DIR}/components/ble/common/ble_advdata.c
        ${NRF_SDK_DIR}/components/ble/common/ble_conn_params.c
        ${NRF_SDK_DIR}/components/ble/common/ble_conn_state.c
        ${NRF_SDK_DIR}/components/ble/common/ble_srv_common.c
        ${NRF_SDK_DIR}/components/ble/ble_advertising/ble_advertising.c
        ${NRF_SDK_DIR}/components/ble/nrf_ble_gatt/nrf_ble_gatt.c
        ${NRF_SDK_DIR}/components/ble/nrf_ble_qwr/nrf_ble_qwr.c
        )

file(GLOB_RECURSE FPRINTF_SRC ${NRF_SDK_DIR}/external/fprintf/*.c)
file(GLOB_RECURSE DRIVERS_SRC ${NRF_SDK_DIR}/modules/nrfx/drivers/src/*.c)
file(GLOB_RECURSE FSTORAGE_SRC ${NRF_SDK_DIR}/components/libraries/fstorage/*.c)

list(APPEND DRIVERS_SRC
        ${NRF_SDK_DIR}/integration/nrfx/legacy/nrf_drv_clock.c
        ${NRF_SDK_DIR}/integration/nrfx/legacy/nrf_drv_uart.c)

SET(TIMER_SRC
        ${NRF_SDK_DIR}/components/libraries/timer/app_timer2.c
        ${NRF_SDK_DIR}/components/libraries/timer/drv_rtc.c
        )

SET(UTIL_SRC
    ${NRF_SDK_DIR}/components/libraries/util/app_error.c
    ${NRF_SDK_DIR}/components/libraries/util/app_error_handler_gcc.c
    ${NRF_SDK_DIR}/components/libraries/util/app_error_weak.c
    ${NRF_SDK_DIR}/components/libraries/util/app_util_platform.c
    ${NRF_SDK_DIR}/components/libraries/util/nrf_assert.c
    )



SET(SOFTDEV_SRC
        ${NRF_SDK_DIR}/components/softdevice/common/nrf_sdh.c
        ${NRF_SDK_DIR}/components/softdevice/common/nrf_sdh_ble.c
        ${NRF_SDK_DIR}/components/softdevice/common/nrf_sdh_soc.c
    )

SET(ATOMIC_SRC
        ${NRF_SDK_DIR}/components/libraries/atomic_fifo/nrf_atfifo.c
        ${NRF_SDK_DIR}/components/libraries/atomic_flags/nrf_atflags.c
        ${NRF_SDK_DIR}/components/libraries/atomic/nrf_atomic.c
        ${NRF_SDK_DIR}/modules/nrfx/soc/nrfx_atomic.c
        )


SET(BSP_SRC
        ${NRF_SDK_DIR}/components/libraries/bsp/bsp.c
        ${NRF_SDK_DIR}/components/libraries/bsp/bsp_btn_ble.c
    )

SET(COMPLIBS_SRC ${FSTORAGE_SRC} ${UTIL_SRC} ${LOG_LIB_SRC} ${BSP_SRC})

list(APPEND COMPLIBS_SRC
        ${NRF_SDK_DIR}/components/libraries/strerror/nrf_strerror.c
        ${NRF_SDK_DIR}/components/libraries/memobj/nrf_memobj.c
        ${NRF_SDK_DIR}/components/libraries/pwr_mgmt/nrf_pwr_mgmt.c
        ${NRF_SDK_DIR}/components/libraries/fds/fds.c
        ${NRF_SDK_DIR}/components/libraries/sortlist/nrf_sortlist.c
        ${NRF_SDK_DIR}/components/libraries/experimental_section_vars/nrf_section_iter.c
        ${NRF_SDK_DIR}/components/libraries/balloc/nrf_balloc.c
        ${NRF_SDK_DIR}/components/libraries/ringbuf/nrf_ringbuf.c
        ${NRF_SDK_DIR}/components/libraries/button/app_button.c
        )

SET(NRF_SDK_SRC
        ${SEGGER_SRC}
        ${BLE_SRC}
        ${TIMER_SRC}
        ${FPRINTF_SRC}
        ${COMPLIBS_SRC}
        ${SOFTDEV_SRC}
        ${ATOMIC_SRC}
        ${DRIVERS_SRC}
        ${NRF_SDK_DIR}/components/libraries/strerror/nrf_strerror.c
        ${NRF_SDK_DIR}/components/libraries/memobj/nrf_memobj.c
        ${NRF_SDK_DIR}/modules/nrfx/mdk/system_nrf52840.c
        ${NRF_SDK_DIR}/components/boards/boards.c
        )

MACRO(HEADER_DIRECTORIES start_path return_list)
FILE(GLOB_RECURSE new_list ${start_path}/*.h)
SET(dir_list "")
FOREACH(file_path ${new_list})
    GET_FILENAME_COMPONENT(dir_path ${file_path} PATH)
    SET(dir_list ${dir_list} ${dir_path})
ENDFOREACH()
LIST(REMOVE_DUPLICATES dir_list)
SET(${return_list} ${dir_list})
ENDMACRO()