cmake_minimum_required(VERSION 3.4.1)
project(flutter_opencv_plugin)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fopenmp")

set(OPENCV_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src/main/opencv)
include_directories(${OPENCV_DIR}/include)

add_library(lib_opencv_imgproc STATIC IMPORTED)
add_library(lib_opencv_core STATIC IMPORTED)
add_library(lib_opencv_highgui STATIC IMPORTED)

set_target_properties(lib_opencv_highgui PROPERTIES IMPORTED_LOCATION ${OPENCV_DIR}/${ANDROID_ABI}/libopencv_highgui.a)
set_target_properties(lib_opencv_imgproc PROPERTIES IMPORTED_LOCATION ${OPENCV_DIR}/${ANDROID_ABI}/libopencv_imgproc.a)
set_target_properties(lib_opencv_core PROPERTIES IMPORTED_LOCATION ${OPENCV_DIR}/${ANDROID_ABI}/libopencv_core.a)

find_library(log-lib log)
find_library(android-lib android)
find_library(c-lib c)
find_library(m-lib m)
find_library(stdcpp-lib c++_static)
find_library(atomic-lib atomic)
find_library(unwind-lib unwind)   # add this

add_library(flutter_opencv_plugin SHARED ../ios/Classes/native_opencv.cpp)

target_link_libraries(
        flutter_opencv_plugin
        lib_opencv_highgui
        lib_opencv_imgproc
        lib_opencv_core
        ${log-lib}
        ${android-lib}
        ${c-lib}
        ${m-lib}
        ${stdcpp-lib}  # c++_static now
)

if(atomic-lib)
    target_link_libraries(flutter_opencv_plugin ${atomic-lib})
endif()

if(unwind-lib)
    target_link_libraries(flutter_opencv_plugin ${unwind-lib})
endif()
