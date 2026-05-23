cmake_minimum_required(VERSION 3.15)
project(edge_proxy VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Treat warnings as errors for systems programming
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Werror -pedantic -Wconversion")

# Include directories
include_directories(include)

# Source files
file(GLOB_RECURSE SRC_FILES "src/*.cpp")

# Main executable
add_executable(edge_proxy ${SRC_FILES} src/main.cpp)
