# Нужен cmake >=3.5
CMAKE_MINIMUM_REQUIRED(VERSION 3.5)
include(nrf_sdk.cmake)
PROJECT(nrf_template)

# Флаги компиляторов, тут можно подкрутить
#SET(CMAKE_C_FLAGS "-ffinite-math-only -MMD -MP -Wall -mcpu=cortex-m3 -mthumb -mfloat-abi=soft -fno-strict-aliasing -fdata-sections -ffunction-sections  -std=gnu99" CACHE INTERNAL "c compiler flags")
#SET(CMAKE_CXX_FLAGS "-ffinite-math-only -MMD -MP -Wall -mcpu=cortex-m3 -mthumb -mfloat-abi=soft -fno-strict-aliasing -fdata-sections -ffunction-sections -std=c++11" CACHE INTERNAL "cxx compiler flags")
#SET(CMAKE_EXE_LINKER_FLAGS "--specs=nosys.specs --specs=nano.specs -Wl,--gc-sections" CACHE INTERNAL "exe link flags")
#file(GLOB_RECURSE SRC_C_FILES ${PROJECT_SOURCE_DIR}/src/*.c)
#file(GLOB_RECURSE SRC_HEADERS ${PROJECT_SOURCE_DIR}/src/*.h)

SET(SRC_C_FILES
        ${PROJECT_SOURCE_DIR}/main.c)

SET(STARTUP_SOURCES
        ${NRF_SDK_DIR}/modules/nrfx/mdk/gcc_startup_nrf52840.S)

SET(PROJECT_SOURCES
        ${SRC_C_FILES}
        ${SRC_CPP_FILES}
        ${NRF_SDK_SRC}
        )


# Флаги компилятора для разных типов сборки.
SET(COMPILE_DEFINITIONS_DEBUG -O0 -g3 -DDEBUG)
SET(COMPILE_DEFINITIONS_RELEASE -Os)


#скрипт линковки и где его искать
SET(LD_SCRIPT stm32f103c8_flash.ld)

SET(CMAKE_EXE_LINKER_FLAGS "-L${LD_SCRIPTS_DIR} -T${LD_SCRIPT} ${CMAKE_EXE_LINKER_FLAGS}")


# Добавляем пути поиска заголовочных файлов
INCLUDE_DIRECTORIES(


)

# Собираем исходники пректа, модули, и т.д. в elf
ADD_EXECUTABLE(${CMAKE_PROJECT_NAME}.elf
        ${STARTUP_SOURCES}
        ${HAL_SOURCES}
        ${PROJECT_SOURCES}
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
ADD_CUSTOM_COMMAND(TARGET ${CMAKE_PROJECT_NAME}.elf POST_BUILD COMMAND ${CMAKE_OBJCOPY} ARGS -Oihex ${CMAKE_PROJECT_NAME}.elf ${FW_NAME}.hex)
ADD_CUSTOM_COMMAND(TARGET ${CMAKE_PROJECT_NAME}.elf POST_BUILD COMMAND ${CMAKE_OBJCOPY} ARGS -Obinary ${CMAKE_PROJECT_NAME}.elf ${FW_NAME}.bin)
ADD_CUSTOM_COMMAND(TARGET ${CMAKE_PROJECT_NAME}.elf POST_BUILD COMMAND ${CMAKE_SIZE} ARGS --format=sysv ${CMAKE_PROJECT_NAME}.elf)
ADD_CUSTOM_COMMAND(TARGET ${CMAKE_PROJECT_NAME}.elf POST_BUILD COMMAND ${CMAKE_SIZE} ARGS --format=berkeley ${CMAKE_PROJECT_NAME}.elf)

