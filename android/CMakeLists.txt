cmake_minimum_required(VERSION 3.22.1)

project(native_print)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(
        native_print
        SHARED
        ../lib/ffi/native_print.cpp
)

find_library(
        log-lib
        log
)

target_link_libraries(
        native_print
        ${log-lib}
)
