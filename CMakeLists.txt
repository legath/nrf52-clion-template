# Нужен cmake >=3.5
CMAKE_MINIMUM_REQUIRED(VERSION 3.5)
include(nrf_sdk.cmake)

PROJECT(nrf_template)

file(GLOB_RECURSE SRC_C_FILES ${PROJECT_SOURCE_DIR}/src/*.c)
file(GLOB_RECURSE SRC_CPP_FILES ${PROJECT_SOURCE_DIR}/src/*.cpp)
file(GLOB_RECURSE SRC_HEADERS ${PROJECT_SOURCE_DIR}/src/*.h)

SET(PROJECT_SOURCES
        ${SRC_C_FILES}
        ${SRC_CPP_FILES}
        ${SRC_H_FILES})

# Флаги компилятора для разных типов сборки.
SET(COMPILE_DEFINITIONS_DEBUG -O0 -g3 -DDEBUG)
SET(COMPILE_DEFINITIONS_RELEASE -Os)


#скрипт линковки и где его искать
SET(LD_SCRIPT stm32f103c8_flash.ld)

SET(CMAKE_EXE_LINKER_FLAGS "-L${LD_SCRIPTS_DIR} -T${LD_SCRIPT} ${CMAKE_EXE_LINKER_FLAGS}")


# Добавляем пути поиска заголовочных файлов
INCLUDE_DIRECTORIES(
        ${CMSIS_INCLUDE_DIR}
        ${HAL_INCLUDE_DIRS}
        ${PROJECT_SOURCE_DIR}/src/

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

