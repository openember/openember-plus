cmake_minimum_required(VERSION 3.1.0)

project(OpenEmber 
    VERSION     1.0.0
    DESCRIPTION "OpenEmber Project"
    LANGUAGES   C
)

set(CMAKE_THREAD_LIBS_INIT "-lpthread")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pthread")
set(CMAKE_HAVE_THREADS_LIBRARY 1)
set(CMAKE_USE_WIN32_THREADS_INIT 0)
set(CMAKE_USE_PTHREADS_INIT 1)
set(THREADS_PREFER_PTHREAD_FLAG ON)

################################################################################
# Include CMake dependencies
################################################################################
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# Include helper macros and commands, and allow the included file to override
# the CMake policies in this file
include(${CMAKE_SOURCE_DIR}/cmake/AglooCMakeHelper.cmake NO_POLICY_SCOPE)

# Kconfig
include(${CMAKE_SOURCE_DIR}/cmake/top.cmake)

if(CONFIG_TEST_OPTION)
    message("Config test_option enabled")
endif()


################################################################################
# Options
################################################################################
option( DEBUG_ENABLED "Whether to enable debug mode" ON)
option( OPTIMIZATION_DISABLED "Whether to disable the optimization of compilation. " OFF)
option( CROSSCOMPILE_ENABLED "Whether to build for ARM" OFF)
option( OPENMP_ENABLED "Whether to enable omp feature" OFF)
option( TESTS_ENABLED "Whether to unit test" ON)
option( EXAMPLES_ENABLED "Whether compile examples" ON)
option( BUILD_DDS "Whether compile CycloneDDS" OFF)
option( BUILD_CJSON "Whether compile cJSON" OFF)
option( BUILD_MQTT "Whether compile MQTT" OFF)
option( BUILD_MD5 "Whether compile md5" OFF)
option( BUILD_ZLOG "Whether compile zlog" OFF)
option( BUILD_EASYLOGGER "Whether compile EasyLogger" ON)

if (DEBUG_ENABLED)
    set(CMAKE_BUILD_TYPE "Debug")
endif()

if (OPTIMIZATION_DISABLED)
    set(CMAKE_C_FLAGS "-Werror -O0 -Wno-deprecated-declarations")
    set(CMAKE_C_FLAGS_DEBUG "-g")
    set(CMAKE_C_FLAGS_RELEASE "-O0")
endif()

if (CROSSCOMPILE_ENABLED)
    set(CMAKE_SYSTEM_NAME Linux)
    set(CMAKE_SYSTEM_PROCESSOR aarch64)
    set(target_arch aarch64-linux-gnu)
    set(CMAKE_C_COMPILER /usr/bin/aarch64-linux-gnu-gcc)
    set(CMAKE_CXX_COMPILER /usr/bin/aarch64-linux-gnu-g++)
    set(CMAKE_LIBRARY_ARCHITECTURE ${target_arch} CACHE STRING "" FORCE)
    set(CMAKE_FIND_ROOT_PATH /opt/petalinux/2021.2/sysroots/cortexa72-cortexa53-xilinx-linux)
    # Search for programs in the build host directories
    #set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
    # Libraries and headers in the target directories
    #set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
    #set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
    #set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
endif()

if (OPENMP_ENABLED)
    add_definitions(-DOPENMP_ENABLED)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fopenmp")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp")
endif()

################################################################################
# Find packages
################################################################################
find_package(CycloneDDS QUIET)

if(NOT CycloneDDS_FOUND) 
    message(STATUS "CycloneDDS not found! Build from source")
    set(BUILD_DDS TRUE)
    set(DDS_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/third_party/cyclonedds/src)
    set(DDS_LIBRARIES ddsc)
endif()
message(STATUS "├── ${DDS_LIBRARIES}")
message(STATUS "└── ${DDS_INCLUDE_DIRS}")


find_package(ZLOG QUIET)

if(NOT ZLOG_FOUND) 
    message(STATUS "zlog not found! Build from source")
    set(BUILD_ZLOG TRUE)
    set(ZLOG_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/third_party/zlog/src)
    set(ZLOG_LIBRARIES zlog)
endif()
message(STATUS "├── ${ZLOG_LIBRARIES}")
message(STATUS "└── ${ZLOG_INCLUDE_DIRS}")

find_package(EasyLogger QUIET)

if(NOT EasyLogger_FOUND) 
    message(STATUS "EasyLogger not found! Build from source")
    set(BUILD_EASYLOGGER TRUE)
    set(EASYLOGGER_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/third_party/easylogger/inc)
    set(EASYLOGGER_LIBRARIES easylogger)
endif()
message(STATUS "├── ${EASYLOGGER_LIBRARIES}")
message(STATUS "└── ${EASYLOGGER_INCLUDE_DIRS}")

find_package(cJSON QUIET)

if(NOT cJSON_FOUND) 
    message(STATUS "cJSON not found! Build from source")
    set(BUILD_CJSON TRUE)
    set(CJSON_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/third_party/cJSON)
    set(CJSON_LIBRARIES cjson)
endif()
message(STATUS "├── ${CJSON_LIBRARIES}")
message(STATUS "└── ${CJSON_INCLUDE_DIRS}")

find_package(PahoMqttC QUIET)

if(NOT PahoMqttC_FOUND) 
    message(STATUS "PahoMqttC not found! Build from source")
    set(BUILD_MQTT TRUE)
    set(PAHO_MQTT_C_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/third_party/paho.mqtt.c/src)
    set(PAHO_MQTT_C_LIBRARIES paho-mqtt3a paho-mqtt3c)
endif()
message(STATUS "├── ${PAHO_MQTT_C_LIBRARIES}")
message(STATUS "└── ${PAHO_MQTT_C_INCLUDE_DIRS}")

set(SQLITE_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/third_party/sqlite)
set(SQLITE_LIBRARIES sqlite3)

add_subdirectory(third_party)

set( AGLOO_EXTERNAL_INCLUDE_DIRS
    ${DDS_INCLUDE_DIRS}
    ${ZLOG_INCLUDE_DIRS}
    ${EASYLOGGER_INCLUDE_DIRS}
    ${PAHO_MQTT_C_INCLUDE_DIRS}
    ${CJSON_INCLUDE_DIRS}
    ${SQLITE_INCLUDE_DIRS}
)

set( AGLOO_EXTERNAL_LIBRARIES
    ${DDS_LIBRARIES}
    ${ZLOG_LIBRARIES}
    ${EASYLOGGER_LIBRARIES}
    ${PAHO_MQTT_C_LIBRARIES}
    ${CJSON_LIBRARIES}
    ${SQLITE_LIBRARIES} dl
)

set( AGLOO_INTERNAL_INCLUDE_DIRS 
    ${CMAKE_SOURCE_DIR}/inc
    ${CMAKE_SOURCE_DIR}/libs/HAL
    ${CMAKE_SOURCE_DIR}/libs/GSDL/src
    ${CMAKE_SOURCE_DIR}/libs/Log
    ${CMAKE_SOURCE_DIR}/libs/ppool
    ${CMAKE_SOURCE_DIR}/libs/msgbus
    ${CMAKE_SOURCE_DIR}/libs/Common
    ${CMAKE_SOURCE_DIR}/libs/Algorithm
    ${CMAKE_SOURCE_DIR}/libs/libcsv
    ${CMAKE_SOURCE_DIR}/libs/libyaml
)

set( AGLOO_INCLUDE_DIRS 
    ${AGLOO_EXTERNAL_INCLUDE_DIRS}
    ${AGLOO_INTERNAL_INCLUDE_DIRS}
)

set( AGLOO_INTERNAL_LIBRARIES 
    HAL
    gdsl
    Log
    ppool
    msgbus
    Common
    Algorithm
    csv
    yaml
)

set( AGLOO_LIBRARIES
    ${AGLOO_EXTERNAL_LIBRARIES}
    ${AGLOO_INTERNAL_LIBRARIES}
)

add_subdirectory(libs)
add_subdirectory(modules)
add_subdirectory(src)
add_subdirectory(applications)

#========================================================
# for unittest, call "cmake .. -DUNIT_TEST=ON"
if(TESTS_ENABLED)
    enable_testing()
    add_subdirectory(test)
endif()
#========================================================
