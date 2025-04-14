# Set the minimum required CMake version
cmake_minimum_required(VERSION 3.4.1)

# Set the C and C++ flags for OpenMP support
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp -static-openmp")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fopenmp -static-openmp")

set(OPENCV_DIR ${CMAKE_CURRENT_SOURCE_DIR}/app/src/main/opencv)
include_directories(${OPENCV_DIR}/include)


# Define imported libraries for OpenCV components
add_library(lib_opencv_core SHARED IMPORTED)
add_library(lib_opencv_imgproc SHARED IMPORTED)
add_library(lib_opencv_highgui SHARED IMPORTED)

# Set the path to the OpenCV libraries for each architecture (using the correct ABI)
set_target_properties(lib_opencv_core PROPERTIES IMPORTED_LOCATION ${OPENCV_DIR}/${ANDROID_ABI}/libopencv_core.a)
set_target_properties(lib_opencv_imgproc PROPERTIES IMPORTED_LOCATION ${OPENCV_DIR}/${ANDROID_ABI}/libopencv_imgproc.a)
set_target_properties(lib_opencv_highgui PROPERTIES IMPORTED_LOCATION ${OPENCV_DIR}/${ANDROID_ABI}/libopencv_highgui.a)

# Find the log library (standard Android log library)
find_library(log-lib log)

# Add the native OpenCV source file (you can adjust the path to your own source file)
add_library(native_opencv SHARED ../ios/Classes/native_opencv.cpp)

# Link the libraries with the native OpenCV library
target_link_libraries(native_opencv lib_opencv_core lib_opencv_imgproc lib_opencv_highgui ${log-lib})
